#!/usr/bin/perl                                                            

use strict;
use warnings;

# Iker Irisarri, University of Konstanz, Feb 2015
# Converts ali to fasta format by replacing spaces and * by - and removing comment lines (starting with #)


my $usage = "ali2fasta.pl file.ali > STDOUT (fasta)\n";
my $infile = $ARGV[0] or die $usage;

open (IN, $infile) or die "Can't open $infile, $!\n";

while (my $line = <IN>) {
    chomp $line;
    # scape lines with comments
    next if ( $line =~ /^#.*/ );
	# print headers
	if ( $line =~ /^>.+/ ) {
	
		print "$line\n";
		
	}
	# process sequences
	else {
	
		$line =~ tr/ /-/;
		$line =~ tr/\*/-/;
		print "$line\n";

	}
	
}

