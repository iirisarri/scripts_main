#!/usr/bin/perl

use strict;
use warnings;

my $infile = shift;

open (IN, "<", $infile) or die "Cannot open file $infile\n";

while ( my $line =<IN> ) {
    chomp $line;
    
    if ( length $line < 1000 ) {
		print "$line\n";
    }
    else {
		print STDERR "WARN: line with > 1000 chars was skipped:\n";
		print STDERR "$line\n\n";
    }
}

