#!/usr/bin/perl

use strict;
use warnings;
use Bio::AlignIO;
use Bio::SimpleAlign;

# Iker Irisarri, University of Konstanz. Mar 2015
# Get a slice from an alignments and write it to a new file
 
my $usage = "extract_aln_columns.pl infile.fa column_range (1-1000) \">infile.1-1000.fa\"\n"; 
my $infile = $ARGV[0] or die $usage;
my $range = $ARGV[1] or die $usage;
my $outfile = $infile . "$range" . ".fa";

# get start and end positions (they are not 0-based but 1-based)
# e.g. 1-1000 will extract positions from 1 (first column) to 10000, both inclusive
$range =~ /(\d+)-(\d+)/;
my $start = $1;
my $end =  $2;


my $in = Bio::AlignIO->new(	-file   => $infile ,
                        	-format => 'fasta');

my $out = Bio::AlignIO->new(-file   => ">$outfile" ,
                            -format => 'fasta');

while ( my $aln = $in->next_aln() ) {

	# get slice of aln and write to output
	my $aln2 = $aln->slice($start,$end);
	$out->write_aln($aln2);

}
                           
                           
