#!/usr/bin/perl

use strict;
use warnings;

# Iker Irisarri, Apr 2015. University of Konstanz
# simple script to substitute elements in a file
# Substitution of elements stored in arrays by its index (position of element in array)

# Can be used to substitute species in a tree

my @originals = qw (Acipenser_baeri Alligator_sinensis );

my @alternatives = qw ( Acipenser_  Alligator_ );

my $infile = shift;

open (IN, "<", $infile) or die "Cannot open file $infile; $!\n";

my %lines;
my $line_count = 0;

while ( my $line =<IN> ) {
    chomp $line;
    $line_count++;
    $lines{$line_count} = $line;
    
}

foreach my $key ( keys %lines ) {

    for ( my $i=0; $i< scalar @originals; $i++ ) {

	#print "$originals[$i]\t$alternatives[$i]\n";
	$lines{$key} =~ s/$originals[$i]/$alternatives[$i]/g;
	#print "$lines{$key}\n";

    }

    print "$lines{$key}\n";

}


