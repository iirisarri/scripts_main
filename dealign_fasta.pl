#!/usr/bin/perl

use warnings;
use strict;
use Bio::SeqIO;

##########################################################################################
#
# #################### Iker Irisarri. Oct 2017. Uppsala University ##################### #
# 
# Removes gaps from sequences in fasta format
#
##########################################################################################


my $usage = "\tdealign_fasta.pl input.fa > STDOUT \n";
my $fasta = $ARGV[0] or die $usage;

# read fasta file with SeqIO
my $seqio_obj = Bio::SeqIO->new('-file' => "<$fasta",
	                	        '-format' => "fasta");


while (my $seq_obj = $seqio_obj->next_seq){

	# store sequences into %hash
    my $seqname = $seq_obj->primary_id;
	my $seq = $seq_obj->seq;
	
	# remove gaps
	$seq =~ s/-//g;

    print ">",  $seq_obj->primary_id, "\n";
    print "$seq\n";
}
                		        
