#!/usr/bin/perl

use strict;
use warnings;

# Iker Irisarri, University of Konstanz Mar 2016
# Reads nexus file generated by TIGER and prints out the positions in each Bin to different files
# Generated output files are ready to be excluded with raxml


my $infile = shift;

open (IN, "<", $infile) or die "Can't open file $infile!\n";

while ( my $line =<IN> ) {
    chomp $line;
    # skip all lines besides charsets
    next while ( $line !~/^\tCharset/ );
    
    my @lines = split (" ", $line);
    # get bin name
    my $bin = $lines[1];
    # remove first three elements in array (Chaset, BinX, =)
    shift @lines;
    shift @lines;
    shift @lines;
    # remove semicolon from last element
    my $last = pop @lines;
    $last =~ /(\d+);/;
    push ( @lines, $1 );
    
    #print join ("--", @lines);

    #create excludefiles
    my $output = $infile . "_" . $bin . ".excludefile";
    open (OUT, ">", $output) or die "Can't open output file $output: !$\n";
    foreach my $elem ( @lines ) {
	print OUT "$elem-$elem\n";
    }
    close (OUT);
}
    
close (IN);

print STDERR "\nDone!\n\n";
