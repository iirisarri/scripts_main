#!/usr/bin/perl -w

#use lib "/home/iirisar/iirisar/lib/perl5";
#use Bio::Perl;

use strict;
use Bio::SearchIO;
use Data::Dumper;

# blast parser vertebrate phylogenomic project
# detect contaminants from gene alignments
# prints out species name of query and best hits and evalue
# blastp against nr using seed files (fasta queries) provided by Hervé
# IMPORTANT! If query_name or query_description are repeated in the blastp output, some of them will be lost as they are rewritten in the hash
# in this case I had separate files for blastp output and worked by using a for loop:
#  for f in Dxaa/*.blastp; do perl parse_blast_best_hit_taxonomy.pl $f > $f.acc.parsed; done &

my $usage = "parsed_blast_best_hit_taxonomy.pl blast_report evalue_cutoff> outfile\n";
my $blast_report = $ARGV[0] or die $usage;
#my $evalue_cutoff = $ARGV[1] or die $usage;

# read blast report
my $in = new Bio::SearchIO(-format => "blast", 
                           -file   => "<$blast_report");

my %results;

# read through the blast report
while( my $result = $in->next_result ) {
	while( my $hit = $result->next_hit ) {
		while( my $hsp = $hit->next_hsp ) {
			# assign values
			my $query = $result->query_name;
			# $hit->name does not include the taxonomy data
			# extract only taxonomy data from the description
			$hit->description=~/.*\[(.*)\].*/;
			my $best_hit = $1;
# modified to output query accession 23 sept 2014
#			my $best_hit = $hit-> accession;
			my $evalue = $hsp->evalue;
				# if the query does not exist, create a hash for it
				# key = query; values = hit, evalue
				if( !exists $results{$query} ) {
					$results{$query}=[$best_hit,$evalue];
					# if the hash is already present, compare with previous hit by evalue and replace
					} else {
						if( $evalue<$results{$query}[1] ) {
							$results{$query}=[$best_hit,$evalue];
						}
					}
		}
	}
}



# for each best hit, print the selected values in tab-delimited form
foreach my $keys(sort keys %results) {
#	print Dumper \%results, "\n";
#   filter by evalue
#    if ($results{$keys}[1] < 1) {
        #print Query, Hit, evalue
	print $keys, "\t", $results{$keys}[0], "\t", $results{$keys}[1], "\n";
#    }
}

