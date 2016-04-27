#!/usr/bin/perl
 
use strict;
use Bio::SeqIO;
use Data::Dumper;

# Iker Irisarri. University of Konstanz, Februrary 2015

my $usage = "rm_gap_only_seqs.pl in_fasta > stdout (fasta)\n";
my $fasta = $ARGV[0] or die $usage; 

# file in with seqio

#READ_IN: 
my $seqio_obj = Bio::SeqIO->new('-file' => "<$fasta", 
				'-format' => "fasta", 
				'-alphabet' => "protein"
				);

# store sequences in a hash

my %hash;

while (my $inseq = $seqio_obj->next_seq) {

    if ( $inseq->seq =~ /^[-XNn]*$/ ) {
	
	print STDERR $inseq->primary_id, " contains only undetermined characters\n"; 

    }

    else {

	print ">", $inseq->primary_id, "\n";
	print $inseq->seq, "\n";

    }
}
