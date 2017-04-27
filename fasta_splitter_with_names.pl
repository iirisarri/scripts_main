#!/usr/bin/perl
 
use strict;
use warnings;
use Bio::SeqIO;
 
##########################################################################################
#
# #################### Iker Irisarri. Apr 2017. Uppsala University ##################### #
#
# Splits fasta into individual files, one per sequence. The output file names correspond
#	to the header in each sequence
#
##########################################################################################

my $usage = "fasta_splitter_with_names.pl multi_fasta.fa\n\n";
my $infile = $ARGV[0] or die $usage;

# read-in multifasta
my $seqio_in = Bio::SeqIO->new(
    -file => "<$infile", 
    -format => 'fasta'
    );

while (my $inseq = $seqio_in->next_seq) {

	# get header
	my $header = $inseq->id;
	my $sequence = $inseq->seq;
	
	
	
	# create seqio object
	my $seqio_out = Bio::SeqIO->new(
    	-file => ">$header.fa",
    	-format => 'fasta'
    	);
    	
	# print out sequence to file
	$seqio_out->write_seq($inseq);
	print STDERR "\twrote $header.fa\n";
}

print STDERR "\ndone!\n";