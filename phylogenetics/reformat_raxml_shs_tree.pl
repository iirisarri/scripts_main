#!/usr/bin/perl

use warnings;
use strict;

# reformat_raxml_shs_tree.pl
# Iker Irisarri. University of Konstanz. Jan 2016
# Change tree format after computation of SH-like support values by RAxML to be read by tree editors
# July 2016: pattern match change to allow reformatting IC trees (after manually removing either IC or ICA:
# e.g. by replacing "\[-*\d\.\d+," by "[" or ",\-*\d\.\d+]" by "]"

my $usage = "reformat_raxml_shs_tree.pl infile.tre > stdout\n";
my $infile = $ARGV[0] or die $usage;

open (IN, "<", $infile) or die "Cannot open file $infile\n";

my $tree;
my $line_count = 0;

while ( my $line =<IN> ) {
	chomp $line;
	$tree = $line;

	# swap places for branch lengths and support values
	
	# modified for shs and IC trees
	$tree =~ s/(:\d*\.\d*)(\[[-\d\.]+])/$2$1/g;
	# original for shs trees
	#$tree =~ s/(:\d*\.\d*)(\[\d+])/$2$1/g;
	
	# remove square brackets
	$tree =~ s/\[//g;
	$tree =~ s/\]//g;
	
	print "$tree\n";
	
}