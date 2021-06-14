#!/usr/bin/perl

use HTML::TreeBuilder::XPath;

$tree = HTML::TreeBuilder::XPath->new_from_url($ARGV[0]); 
($title = $tree->findvalue('//title')) =~ s/^\s+//;
print $title . "\n";
