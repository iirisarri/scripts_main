#!/usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;
use Bio::SearchIO;
use Data::Dumper;
use Bio::DB::Fasta;

# Iker Irisarri. Konstanz, April 2015
# originally for extracting all Hb genes from full genomes
# blast parser takes ALL hits and for each query and extracts the full sequence from blast DB (e.g. genomes)
# i.e. from first to last position of the hit, including hsps and introns in between


my $usage = "parse_blast_and_extract_full_hit.pl blast_report > output.fa";
my $blast_report = $ARGV[0] or die $usage;
my $fasta = $ARGV[1];

# read blast report
my $report = new Bio::SearchIO(-format => "blast", 
            	               -file   => "<$blast_report",
			                   );

# create fasta DB
my $db = Bio::DB::Fasta->new($fasta);

my %hash;
my $strand_sum;

while( my $result = $report->next_result ) {

    while( my $hit = $result->next_hit ) {

	my $query_name;
	my $hit_name;
	# empty arrays for each new hit
	my @starts = ();
	my @ends = ();
	my @strands = ();

	    while( my $hsp = $hit->next_hsp ) {

    		$query_name = $result->query_name;
		    $hit_name = $hit->name;
			my $start = $hsp->start('hit');
		    my $end = $hsp->end('hit');
		    my $strand = $hsp->strand('hit');

		    push (@starts, $start);
		    push (@ends, $end);
		    push (@strands, $strand);
		} 
		
		my @sorted_starts = sort @starts;    
		my @sorted_ends = sort @ends;    
		my $first_pos_in_hit = shift @sorted_starts;    
		my $last_pos_in_hit = pop @sorted_ends;   
    
    	# sum all frames. In several cases hps for one hit are on both strands
    	# If the overall value is > 0 means that the orientation is (+)
    	# If the overall value is < 0 means that the orientation is (-) => revcomp
    	$strand_sum = 0;
    	foreach my $str ( @strands ) {
    		$strand_sum = $strand_sum + $str;
    	}
    
	    $hash{$query_name} = [$hit_name,$first_pos_in_hit,$last_pos_in_hit,$strand_sum];
		    
	}

}

foreach my $key ( keys %hash ) {
	
	# get hit name, start and end positions
	my $scaffold = $hash{$key}[0];
	my $st = $hash{$key}[1];
	my $en = $hash{$key}[2];
	# extract sequence substring
	my $seqstr = $db->seq($scaffold, $st => $en);
	my $header = "$key" . "_" . "scaffold:$hash{$key}[0]";
	
	# revcomp if $strand_sum < 0 (i.e., majority of frames are negative)
	if ( $strand_sum == 0 ) {
		# print warning if strand cannot be determined
		print STDERR "could not determine hit orientation 
		for hit $hash{$key}[1] from query $hash{$key}[0]\n";
	} elsif ( $strand_sum < 0 ) {
	    # reverse-complement in two steps
	    my $seqstr_revcomp = reverse $seqstr;
	    $seqstr_revcomp =~ tr/ACGTacgt/TGCAtgca/;
			
	    # header: query_hit_frame
	    $header = $header . "_strand-";
	    print ">$header\n";
	    print "$seqstr_revcomp\n";
	} else {
	    # header: query_hit_frame
	    $header = $header . "_strand+";
	    print ">$header\n";
	    print "$seqstr\n";
	}

}

