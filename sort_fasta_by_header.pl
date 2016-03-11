#!/usr/bin/perl -w

use strict;
use warnings;
use Bio::DB::Fasta;
use Bio::SeqIO;
use Data::Dumper;

# Iker Irisarri, University of Konstanz. Mar 2016
# Simple script to order sequences according to their fasta header

my $usage = "sort_fasta_by_header.pl infile.fa > STDOUT\n";
my $fasta = $ARGV[0] or die $usage;

# read fasta file with SeqIO
my $seqio_obj = Bio::SeqIO->new('-file' => "<$fasta",
	                	        '-format' => "fasta");

my %fasta;

while (my $seq_obj = $seqio_obj->next_seq){

    my $seqname = $seq_obj->primary_id;
    #my $description = $seq_obj->description;
	my $sequence = $seq_obj->seq;
	
	#my $header = $seqname . $description;
	#$fasta{$header} = $sequence;
	
	$fasta{$seqname} = $sequence;
}

foreach my $seq ( sort keys %fasta ) {

	print ">$seq\n";
	print "$fasta{$seq}\n";
}

