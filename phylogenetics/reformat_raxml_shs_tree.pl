#!/usr/bin/perl

use warnings;
use strict;

# reformat_raxml_shs_tree.pl
# Iker Irisarri. University of Konstanz. Jan 2016
# Change tree format after computation of SH-like support values by RAxML to be read by tree editors


my $usage = "reformat_raxml_shs_tree.pl infile.tre > stdout\n";
my $infile = $ARGV[0] or die $usage;

open (IN, "<", $infile) or die "Cannot open file $infile\n";

my $tree;
my $line_count = 0;

while ( my $line =<IN> ) {
	chomp $line;
	$tree = $line;

	# swap places for branch lengths and support values
	$tree =~ s/(:\d*\.\d*)(\[\d+])/$2$1/g;
	# remove square brackets
	$tree =~ s/\[//g;
	$tree =~ s/\]//g;
	
	print "$tree\n";
	
}