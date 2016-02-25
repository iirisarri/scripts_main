#!/usr/bin/perl
 
use strict;
use warnings;

use Bio::SeqIO;

# check if all sequences in a fasta file have the same length

my $infile = shift; 

my $seqio_in = Bio::SeqIO->new(	-file => "<$infile", 
							    -format => "fasta", 
    	);

my $first_seq_length = ();
my $next_seq_length = ();

while (my $inseq = $seqio_in->next_seq) {

	# get sequence length
	my $length = $inseq->length;

	# define sequence length
	if ( !defined $first_seq_length ) {
		
		$first_seq_length = $length;
	}
	# compare
	if ( $length != $first_seq_length ) {
	
		print STDERR "ERR: sequences not of the same length in $infile\n";
	}
}

