#! /usr/bin/env raku
constant $bm-file    = %*ENV<BM_PATH> // "$*HOME/.config/diySync/.bm_path";
constant $nutstore   = %*ENV<NUTSTORE>;
constant $dropbox    = %*ENV<DROPBOX>;
my regex tag { <:L + :Nd + :P - [\']> };
my %bookmarks = $bm-file.IO.lines
    .grep(/ ^ <tag> \: /)
    .map({slip .split(":", 2)})
    if $bm-file.IO.rw;


constant $command = "lf";
constant $bm-file-command = "$*HOME/.local/share/lf/marks" if qx/command -v lf/;
my Bool $diff-index = False;

sub path-trans(Str:D $path is copy, Bool :$env = True) {
    if $env {
        $path .= subst($nutstore, '$NUTSTORE') if $nutstore;
        $path .= subst($dropbox,  '$DROPBOX')  if $dropbox;
        $path .= subst($*HOME,    '$HOME');
    } else {
        $path .= subst('$HOME', $*HOME);
        $path .= subst('$NUTSTORE', $nutstore) if $nutstore;
        $path .= subst('$DROPBOX',  $dropbox)  if $dropbox;
    }
    return $path;
}

multi book-manage ("get", Str:D $format = "") {
    if $format eq "lf" {
        return %bookmarks.map: {$_.key ~ ":" ~ path-trans( $_.value, :!env )};
    }
    return %bookmarks.map: {$_.key ~ ":" ~ $_.value};
}

multi book-manage ("add", @bm where { all(@_) ~~ / ^ <tag> \: / }) {
    for @bm -> $bm {
        state Str ($tag, $path, $new-bm);
        ($tag, $path) = $bm.split(":", 2);
        unless $path.IO.d {
            say "Warning: $path is invalid!";
            next;
        };
        $path = path-trans($path);
        %bookmarks{$tag} = $path;
    }
    my @bm-list = book-manage("get");
    $bm-file.IO.spurt: @bm-list.join("\n");
    $diff-index = True;
    return @bm-list;
}

multi book-manage("diff-handle", :$confirm = False)
{
    $diff-index = book-manage('diff');
    return unless $diff-index;

    unless $confirm {
        book-manage("sync", :base<all>);
        return;
    }

    say qq:to/PROMPT/;
        choose:
            1) merge by union;
            2) replace $command with Repo;
            3) replace Repo with command;
            0) do nothing;
        PROMPT
    my $index = prompt "0/1/2/3): ";
    given $index {
        when 1 { book-manage("sync", :base<all>) }
        when 2 { book-manage("sync", :base<repo> ) }
        when 3 { book-manage("sync", :base($command)) }
        default { say "please synchronize by hand!" }
    }
}

multi book-manage("diff", Bool :$detail = False) {
    if $command eq "lf" {
        my @bookmarks-lf   = $bm-file-command.IO.lines.grep(/ ^ <tag> \: /);
        my @bookmarks-repo = book-manage(|<get lf>);

        return ?(@bookmarks-lf (^) @bookmarks-repo) unless $detail;

        my @repo-lf        = (@bookmarks-lf (&) @bookmarks-repo).keys.map: &path-trans;
        my @only-lf        = (@bookmarks-lf (-) @bookmarks-repo).keys.map: &path-trans;
        my @only-repo      = (@bookmarks-repo (-) @bookmarks-lf).keys.map: &path-trans;
        my %diff;
        %diff<common>      = @repo-lf if @repo-lf;
        %diff<command>     = @only-lf if @only-lf;
        %diff<repo>        = @only-repo if @only-repo;
        return %diff;
    }
}

multi book-manage ("sync", Str:D :$base where * eq any(«all repo $command») = "all")
{
    $diff-index = book-manage('diff');
    return unless $diff-index;

    if $command eq 'lf' {
        die "command not found: lf" if $bm-file-command eq "";
        my @bookmarks-lf   = $bm-file-command.IO.lines.grep(/ ^ <tag> \: /);
        my @bookmarks-repo = book-manage(|<get lf>);
        my @new-lf         = (@bookmarks-lf (-) @bookmarks-repo).keys;
        my @new-repo       = (@bookmarks-repo (-) @bookmarks-lf).keys;
        if $base eq "all" {
            $bm-file-command.IO.spurt("\n" ~ @new-repo.join("\n"), :append) if @new-repo;
            book-manage("add", @new-lf) if @new-lf;
        } elsif $base eq "repo" {
            $bm-file-command.IO.spurt: @bookmarks-repo.join("\n");
        } elsif $base eq "lf" {
            %bookmarks = %();
            book-manage("add", @bookmarks-lf);
        }
        $diff-index = False;
        return;
    }
}

multi MAIN (Str:D $path where * !~~/ ^ <tag> \: /) {
    book-manage('diff-handle');
    return if $diff-index;

    my $bm;
    if $path ~~ / ^ <tag> \: / {
        $bm = $path;
    } else {
        my $tag = trim prompt "Please enter a character as a tag: ";
        until $tag ~~ /^ <tag> $/ {
            if $tag.chars != 1 {
                say 'wrong tag format, must one char';
            } elsif $tag eq "'" {
                say '\' is forbidden';
            } else {
                say 'the entered label is invalid, enter a letter, ' ~
                    'digit or half-width punctuataion (excluding \')';
            }
            $tag = trim prompt "Please re-enter a character as a tag: ";
    }
    my $bm = $tag ~ ":" ~ $path;
}
    book-manage("add", [$bm]);
    book-manage("sync", :base<repo>);
}

multi MAIN (Str:D :$delete! where /^ <tag> ** 1..* $/, Bool:D :$confirm = True) {
    book-manage('diff-handle');
    return if $diff-index;

    my %d;
    for $delete.comb -> $tag {
        %d{$tag} = $_ with %bookmarks{$tag};
    }
    return unless %d;
    say "Delete the following bookmarks? (Y/N)";
    say %d.map({ $_.key ~ " " x 4 ~ $_.value }).join("\n");
    if (prompt "Y/N: ").trim.uc eq any(<Y YES>) {
        %bookmarks{ %d.keys }:delete;
        $diff-index = True;
        my @bm-list = book-manage("get");
        $bm-file.IO.spurt: @bm-list.join("\n");
        book-manage("sync", :base<repo>);
        return @bm-list;
    }
}

multi MAIN (Bool :$sync!, Bool :$confirm = False) {
    book-manage("diff-handle", :$confirm);
    say book-manage("get")>>.subst(":", '    ').sort.join("\n");
}

multi MAIN ( Bool :$diff = False) {
    unless $diff {
        say book-manage("get")>>.subst(":", '    ').sort.join("\n");
        return;
    }
    my %diff = book-manage("diff", :detail);
    if %diff<common>:exists {
        say "In repo and $command:";
        say %diff<common>».subst(":", '    ').sort.join("\n").indent(4);
    }
    if %diff<repo>:exists {
        say "\nIn repo only:";
        say %diff<repo>».subst(":", '    ').sort.join("\n").indent(4);
    }
    if %diff<command>:exists {
        say "\nIn $command only:";
        say %diff<command>».subst(":", '    ').sort.join("\n").indent(4);
    }
}

multi MAIN (:$test) {
    path-trans("/home/liubianshi/Music").say;
    path-trans("/home/liubianshi/Dropbox/Backup").say;
    path-trans('$NUTSTORE/Backup', :!env).say;
    path-trans(path-trans("/home/liubianshi/Nutstore Files/Nutstore/Sync"), :!env).say;
    book-manage("diff").say;
}

