#!/usr/bin/env perl6

use v6;

sub format-codepoint(Int $codepoint) {
    sprintf "%s    %s    U+%05x\n",
        $codepoint.chr,
        $codepoint.uniname.tclc,
        $codepoint;
}

multi sub MAIN(Str $x where .chars == 1) {
    print format-codepoint($x.ord);
}

multi sub MAIN($search is copy) {
    $search.=uc;
    my $uni-file = "$*HOME/.config/diySync/uniname";
    unless $uni-file.IO.f {
        $uni-file.IO.spurt:
            (1..0x10FFFF)
            .grep({$_.uniname ~~ /^ <[ A..Z + 0..9 ]> /})
            .map(&format-codepoint)
            .join();
    }
    my $result = run 'grep', "-i" ,"$search", "$uni-file", :out;
    $result.out.slurp(:close).print;
}

multi sub MAIN($x, Bool :$identify!) {
    print $x.ords.map(&format-codepoint).join;
}



