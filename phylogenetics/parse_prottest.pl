#!/usr/bin/perl -w                                                              
use strict;

my $usage = "parse_prottest.pl prottest_output > outfile\n";
my $infile = $ARGV[0] or die $usage;

open (IN, $infile) or die "Can't open $infile, $!\n";

while (my $line = <IN>) {
    chomp $line;
#    print $line;
    if ($line =~/Alignment file\.+\s:\s(.+)/) {
	print "Gene_file\tBest_fit_model\n";
	print $1, "\t";
    } elsif ($line =~/Best model according to .+\:(.+)/g) {
	print $1 "\n";
    }
}

