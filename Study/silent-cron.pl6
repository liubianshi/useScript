#!/usr/bin/env raku

use DBIish;

# ExecutionResult, 用于保存运行结果 {{{1
my class ExecutionResult {
    has Int $.exitcode = -1;
    has Str $.output is required;
    has Bool $.timed-out = False;

    method is-success {
        !$.timed-out && $.exitcode == 0;
    }
}

# ExecutionResultRepository 数据库类定义 {{{1
class ExecutionResultRepository {
    constant $table = 'job_execution';
    has $.jobname is required;
    has $.statefile is required;
    has $!db;

    method !db() {
        return $!db if $!db;
        $!db = DBIish.connect('SQLite', :database($.statefile));
        self!create-schema();
        return $!db;
    }

    # 创建 create-schema {{{2
    method !create-schema() {
        $!db.do(qq:to/SCHEMA/);
            CREATE TABLE IF NOT EXISTS $table (
                id          INTEGER PRIMARY KEY,
                jobname     VARCHAR NOT NULL,
                exitcode    INTEGER NOT NULL,
                timed_out   INTEGER NOT NULL,
                output      VARCHAR NOT NULL,
                executed    TIMESTAMP NOT NULL DEFAULT (DATETIME('NOW'))
            );
        SCHEMA
        $!db.do(qq:to/INDEX/);
            CREATE INDEX IF NOT EXISTS {$table}_jobname_exitcode ON 
            $table ( jobname, exitcode );
        INDEX
        $!db.do(qq:to/INDEX/);
            CREATE INDEX IF NOT EXISTS {$table}_jobname_executed ON 
            $table ( jobname, executed );
        INDEX
    }

    # 插入数据 {{{2
    method insert(ExecutionResult $r) {
        self!db.do(qq:to/INSERT/, $.jobname, $r.exitcode, $r.timed-out, $r.output);
            INSERT INTO $table (jobname, exitcode, timed_out, output)
            VALUES(?, ?, ?, ?)
        INSERT
    }

    # 最后几条记录 {{{2
    method tail(Int $count) {
        my $sth = self!db.prepare(qq:to/SELECT/);
            SELECT exitcode, timed_out, output
              FROM $table
             WHERE jobname = ?
          ORDER BY executed DESC
             LIMIT $count
        SELECT
        $sth.execute($.jobname);
        $sth.allrows(:array-of-hash).map: -> %h {
            ExecutionResult.new(
                exitcode => %h<exitcode>,
                timed-out => ?%h<timed_out>,
                output => %h<output>,
            );
        }
    }
}

# run-with-timeout 执行程序 {{{1
sub run-with-timeout(@cmd, :$timeout, :$executer = Proc::Async) {
    my $proc = $executer.defined ?? $executer !! $executer.new(|@cmd);

    my $collector = Channel.new;
    for $proc.stdout, $proc.stderr -> $supply {
        $supply.tap: { $collector.send($_) }
    }
    my $promise = $proc.start;

    my $waitfor = $promise;
    $waitfor = Promise.anyof( Promise.in($timeout), $promise)
        if $timeout;
    $ = await $waitfor;
    $collector.close;

    my $output = $collector.list.join;
    if !$timeout || $promise.status ~~ Kept {
        say "No timeout";
        say "$output";
        return ExecutionResult.new(
            :$output,
            :exitcode($promise.result.exitcode),
        );
    }

    else {
        $proc.kill;
        sleep 1 if $promise.status ~~ Planned;
        $proc.kill(9);
        $ = await $promise;
        return ExecutionResult.new(
            :$output,
            :timed-out,
        );
    }
}

# MAIN 主程序 {{{1
multi sub MAIN(*@cmd, :$timeout,
    :$jobname is copy,
    :$statefile = 'silent-cron.sqlite3',
    Int :$tries =3 ) {
    $jobname //= @cmd.Str;
    my $result = run-with-timeout(@cmd, :$timeout);
    my $repo = ExecutionResultRepository.new(:$jobname, :$statefile);
    $repo.insert($result);

    my @runs = $repo.tail($tries);

    unless $result.is-success or @runs.grep({.is-success}) {
        say "The last @runs.elems() runs of @cmd[] all failed, the last execution ",
            $result.timed-out ?? "ran into a timeout"
                              !! "exited with code $result.exitcode()";
        print "Output:\n", $result.output if $result.output;
    }
    
    say $_.output for @runs;
    exit $result.exitcode // 2;
}

# MAIN 测试程序 {{{1
multi sub MAIN('test') {
    use Test;

    # Mock::Proc::Async 模拟 Async {{{2
    my class Mock::Proc::Async {
        has $.exitcode = 0;
        has $.execution-time = 0;
        has $.out = '';
        has $.err = '';

        method kill($?) {}
        method stdout {
            Supply.from-list($.out);
        }
        method stderr {
            Supply.from-list($.err);
        }
        method start {
            Promise.in($.execution-time).then({
                (class {
                    has $.exitcode;
                    method sink() {
                        die "mock Proc used in sink context";
                    }
                }).new(:$.exitcode);
            });
        }
    }

    # no timeout, success
    my $result = run-with-timeout([],
        timeout => 2,
        executer => Mock::Proc::Async.new(
            out => 'mocked output',
        )
    );
    isa-ok $result, ExecutionResult;
    is $result.exitcode, 0, 'exit code';
    is $result.output, 'mocked output', 'output';
    ok $result.is-success, 'success';

    # timeout
    $result = run-with-timeout([],
        timeout => 0.1,
        executer => Mock::Proc::Async.new(
            execution-time => 1,
            out => 'mocked output',
        ),
    );
    isa-ok $result, ExecutionResult;
    is $result.output, 'mocked output', 'output';
    ok $result.timed-out, 'timeout reported';
    nok $result.is-success, 'success';
}

