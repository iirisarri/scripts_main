#!/usr/bin/perl -w
use strict;
use Bio::SeqIO;
use Bio::SearchIO;
use Data::Dumper;

# blast parser to count number of hits
# option to use a filter for an evalue threshold
# Iker Irisarri. Konstanz, Jan 2016

my $usage = "parse_blast_num_hits.pl blast_report > output.fa";
my $blast_report = $ARGV[0] or die $usage;

# read blast report
my $report = new Bio::SearchIO(	-format => "blast", 
                           		-file   => "<$blast_report"
                          		);

my %hash;


while( my $result = $report->next_result ) {

    # initialize hit number
    my $hit_num = 0;

    while( my $hit = $result->next_hit ) {

	$hit_num++;
	my $query = $result->query_name;
	#my $evalue = $hit->significance;
	# my $hit_name = $hit->name;

	$hash{$query} = [$hit_num];
    }
}


#print Dumper \%hash;

# print sequences, not in order (because $query is alphanumeric)

foreach my $key ( sort { $hash{$b} <=> $hash{$a} } keys %hash ) {
    
	print "$key\t$hash{$key}[0]\n";

} 


