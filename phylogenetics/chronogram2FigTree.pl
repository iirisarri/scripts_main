#!/usr/bin/perl
use strict;
use warnings; 

# Simple script to change the format of chronogram estimated by phylobayes 
# into nexus treefile with 95%HPD intervals readable by FigTree

my $usage = "chronogram2FigTree.pl infile > outfile\n";
my $infile = shift or die $usage;

my $counter = "0";

open(IN, "<", $infile) or die "Can't open $infile!\n";

while ( my $line =<IN>) {

	chomp $line;
	$counter++;
	
	$line =~ s/(\d+\.\d+)_(\d+\.\d+)/[\&95%={$2,$1}]/g;
	
	print "#NEXUS\nBEGIN TREES;\n\n\tUTREE $counter = ";
	print "$line\n";
	print "\nEND;\n";
}



