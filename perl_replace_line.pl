#!/usr/perl

use strict;
use warnings;

my $infile = shift;

open (IN, "<", $infile) or die "Cannot open file $infile\n";

while ( my $line =<IN> ) {
    chomp $line;
    
    if ( length $line > 150 ) {
	print "$line\n";
    }
#    else {
#	print STDERR "line with > 150 chars was replaced, one time.\n";
#        print "SRR062634.6108336       100     100     48      SRR062634.10162383      100     18      70      86.25   218     2e-11   -\n"
#    }
}

