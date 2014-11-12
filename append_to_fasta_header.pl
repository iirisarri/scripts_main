#!/usr/bin/perl
 
use strict;
use Bio::SeqIO;

# append text to fasta headers, introduced by standard input

my $usage = "append_to_fasta_header.pl infile.fa text_to_append > outfile.fa";
my $fasta = $ARGV[0] or die $usage;
my $text = $ARGV[1] or die $usage;

# read file in with seqio
my $seqio_obj = Bio::SeqIO->new('-file' => "<$fasta", 
				'-format' => "fasta"
				);

while (my $seqio_obj = $seqio_obj->next_seq) {
	print ">", $seqio_obj->primary_id, "_", $text, "\n";
	print $seqio_obj->seq, "\n";
}


