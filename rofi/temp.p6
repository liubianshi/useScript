#!/usr/bin/env perl6

for lines() {
    my @input = $_.split: ',';
    unshift @input, @input[0].ord.base(16);
    put @input.join: "\t";
}
