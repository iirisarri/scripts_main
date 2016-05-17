#!/usr/bin/perl                                                            

use strict;
use warnings;

# Iker Irisarri, University of Konstanz, May 2016
# Converts arb to newick format by removing underescores "_" and removing comment lines (starting with #)


my $usage = "arb2newick.pl file.ali > STDOUT (fasta)\n";
my $infile = $ARGV[0] or die $usage;

open (IN, $infile) or die "Can't open $infile, $!\n";

while (my $line = <IN>) {
    chomp $line;
    # scape lines with comments
    next if ( $line =~ /^#.*/ );
	
	$line =~ s/_+:/:/g;
	print "$line\n";

}

