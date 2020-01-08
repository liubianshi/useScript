#!/usr/bin/env perl6

use v6;

for lines() {
    state @line;
    @line = $_.split: "\t";
    put @line[0], "\tu+", @line[0].ord.base(16), "\t", @line[3], " \[@line[1] / @line[2]\]";
}
