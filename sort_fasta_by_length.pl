#!/usr/bin/perl -w

use strict;
use warnings;
use Bio::DB::Fasta;
use Bio::SeqIO;
use Data::Dumper;

# Iker Irisarri, University of Konstanz. May 2016
# Simple script to order sequences according to their length

my $usage = "sort_fasta_by_header.pl infile.fa > STDOUT\n";
my $fasta = $ARGV[0] or die $usage;

# read fasta file with SeqIO
my $seqio_obj = Bio::SeqIO->new('-file' => "<$fasta",
	                	        '-format' => "fasta");

my %fasta;
my %lengths;

while (my $seq_obj = $seqio_obj->next_seq){

    my $seqname = $seq_obj->primary_id;
    #my $description = $seq_obj->description;
	my $sequence = $seq_obj->seq;
	my $length = $seq_obj->length;
	
	#my $header = $seqname . $description;
	#$fasta{$header} = $sequence;
	
	$fasta{$seqname} = $sequence;
	$lengths{$seqname} = $length;
}

my $sorted_seqnames_by_length;

foreach my $name ( sort { $lengths{$a} <=> $lengths{$b} } keys %lengths ) {

	print ">$name\n";
	print "$fasta{$name}\n";
}

