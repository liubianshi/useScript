#!/usr/bin/env perl6

use v6;

sub format-codepoint(Int $codepoint) {
    sprintf "%s\t%s\tU+%05x\n",
        $codepoint.chr,
        $codepoint.uniname.tclc,
        $codepoint;
}

multi sub MAIN(Str $x where .chars == 1) {
    print format-codepoint($x.ord);
}

multi sub MAIN($search is copy) {
    $search.=uc;
    print (1..0x10FFFF).grep(*.uniname.contains($search))
                       .map(&format-codepoint)
                       .join;
}

multi sub MAIN($x, Bool :$identify!) {
    print $x.ords.map(&format-codepoint).join;
}



