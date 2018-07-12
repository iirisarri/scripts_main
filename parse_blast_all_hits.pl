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
# modif Jan 2016 to make it general

my $usage = "parse_blast_best_hit.pl blast_report > output.fa";
my $blast_report = $ARGV[0] or die $usage;

# read blast report
my $report = new Bio::SearchIO(	-format => "blast", 
                           		-file   => "<$blast_report"
                          		);

my %hash;

while( my $result = $report->next_result ) {

    while( my $hit = $result->next_hit ) {
	
	my $hsp_counter = 0;

		while ( my $hsp = $hit->next_hsp ) {

			$hsp_counter++;

			# get query name
			# $result->query_name =~ /Protopteru_(G\d{5})/;
			#    my $query=$1;
			my $query = $result->query_name;
			my $hit_name = $hit->name;
			my $evalue = $hsp->evalue;
			my $bits = $hsp->bits;
			my $strand = $hsp->query->strand;
			my $query_start = $hsp->start('query');
			my $query_end = $hsp->end('query');
			#my $query_start = $hsp->start('hit');
			#my $query_end = $hsp->end('hit');


			$hash{$query}{$hit_name}{$hsp_counter} = [$evalue, $bits, $query_start, $query_end, $strand];
		
		}
    }
}


#print Dumper \%hash;

# print sequences

print "QUERY\tHIT\tHPS_NUM\tE-VALUE\tQUERY_START\tQUERY_END\tSTRAND\n";

foreach my $k ( keys %hash ) {
    
    foreach my $l ( keys %{ $hash{$k} } ) {

		foreach my $m ( keys %{ ${ $hash{$k} }{$l} } ) {

			# filter by e-value
			if ( ${ ${ $hash{$k} }{$l} }{$m}[0] < 1e-3 ) {

			print "$k\t$l\t$m\t";
			print "${ ${ $hash{$k} }{$l} }{$m}[0]\t";
			print "${ ${ $hash{$k} }{$l} }{$m}[2]\t";
			print "${ ${ $hash{$k} }{$l} }{$m}[3]\t";
			print "${ ${ $hash{$k} }{$l} }{$m}[4]\n";
			}
		}
	}
}

__END__
    
    # filter by evalue
    if ( $hash{$key}[2] < 1e-3 ) {

	print "$key\t$hash{$key}[0]\t$hash{$key}[2]\n";

    }
} 


