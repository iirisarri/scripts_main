#!/usr/bin/perl
 
use strict;
use Bio::SeqIO;
 
my $infile = shift; 
my $outfile = shift;

my $seqio_in = Bio::SeqIO->new(
    -file => "<$infile", 
    -format => 'fasta', 
    -alphabet => 'dna',
    );

my $seqio_out = Bio::SeqIO->new(
    -file => ">$outfile",
    -format => 'fasta', 
    -alphabet => 'dna',
    );
 

while (my $inseq = $seqio_in->next_seq) {
    if ($inseq->length > 199) {
	print $seqio_out->write_seq($inseq), "\n";
    }
}

