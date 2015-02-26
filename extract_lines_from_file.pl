#!/usr/bin/perl

use strict;
use warnings;

########################################################

##   Iker Irisarri, University of Konstanz. Feb 2015  ##

########################################################

# simple script to read multiple-line file and print out only some lines
# lines to be printed out should be given as integers (2nd input file)

my $usage = "extract_lines_from_file.pl infile line_query_file > stdout\n";
my $infile = $ARGV[0] or die $usage;
my $queries = $ARGV[1] or die $usage;

open (IN1, "<", $infile) or die "Cannot open file $infile: $!\n";
open (IN2, "<", $queries) or die "Cannot open file $queries: $!\n";

# store query lines in array

my @queries;

while ( my $l = <IN2> ) {
    chomp $l;
    next if ( $l =~ /^#.+/ );
    push (@queries, $l);
}

close(IN2);


# read infile and print out queried lines

my %lines;
my $line_num = 0;

while ( my $line = <IN1> ) {
    chomp $line;
    next if ( $line =~ /^#.+/ );
    $line_num++;
    
    $lines{$line_num} = $line;
    
}

close(IN1);


foreach my $query ( @queries ) {

	if ( exists $lines{$query} ) {
	
		print $lines{$query}, "\n";
		
	}
}