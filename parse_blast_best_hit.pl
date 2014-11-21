#!/usr/bin/perl -w
use strict;
use Bio::SeqIO;
use Bio::SearchIO;
use Data::Dumper;

# blast parser takes best hit and prints the following information
# query   best_hit   evalue

# option to use a filter for an evalue threshold
# Iker Irisarri. Konstanz, November 2014
# originally for getting comps of best hits to extract from fasta files (transcriptomes)


my $usage = "parse_blast_best_seq.pl blast_report > output.fa";
my $blast_report = $ARGV[0] or die $usage;

# read blast report
my $report = new Bio::SearchIO(-format => "blast", 
                           -file   => "<$blast_report",
                          );

my %hash;
# initialize evalue as 1
my $evalue1 = 1;


while( my $result = $report->next_result ) {

    # reasign 1 to evalue for each new result 
    $evalue1 = 1;

    while( my $hit = $result->next_hit ) {

	# get query name
	$result->query_name =~ /Protopteru_(G\d{5})/;
        my $query=$1;
	# get evalue for that hit
        my $evalue = $hit->significance;

	# compare evalue of this hit with that from previous hits
	# for first hit, compares against evalue of 1
	# for next hits, compares with evalue of previous hit
	if ( $evalue < $evalue1 ) {

	    # assing new evalue to $value1 (for comparison)
	    $evalue1 = $evalue;

	    # get info and store it in array
	    $result->query_name =~ /Protopteru_(G\d{5})/;
	    my $query=$1;
#	    my $hit_name = $hit->name;
	    # to remove "lcl|" that appears in hit name
	    $hit->name =~ /lcl\|(.+)/;
	    my $hit_name = $1;
	    my $bits1 = $hit->bits;

	    $hash{$query} = [$hit_name,$bits1,$evalue];
	}
    }
}


#print Dumper \%hash;

# print sequences, not in order (because $query is alphanumeric)

foreach my $key ( sort { $a cmp $b } keys %hash ) {
    
    # filter by evalue
    if ( $hash{$key}[2] < 1e-3 ) {

	print "$key\t$hash{$key}[0]\t$hash{$key}[2]\n";

    }
} 


