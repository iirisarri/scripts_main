#!/usr/bin/perl -w

use strict;

use Bio::SeqIO;
use Data::Dumper;

# Iker Irisarri, Univeristy of Konstanz, January 2014
# Script to make fasta headers unique (it will append a number to it)
# E.g. before building blast DB
# will print out some info to stderr and all the sequences to stdout (after making headers unique)

my $usage = "make_fasta_headers_uniq.pl fasta_file > stdout\n";
my $fasta = $ARGV[0] or die $usage;

# read fasta file with SeqIO
my $seqio_obj = Bio::SeqIO->new('-file' => "<$fasta",
                	        '-format' => "fasta");


my %info;
my $repeat_seq_count = 0;

while (my $seq_obj = $seqio_obj->next_seq){

    my $seqname = $seq_obj->primary_id;
    # example of primary id: comp11_c0_seq1
    my $seq = $seq_obj->seq;

    if ( !exists $info{$seqname} ) {

	$info{$seqname} = $seq;

    }

    else {
	
        $repeat_seq_count++;

	my $new_seqname = $seqname . "_" . $repeat_seq_count;
	$info{$new_seqname} = $seq;

	print STDERR "$seqname\t$new_seqname\n";

    }
}

# print out all sequences
foreach my $key ( sort keys %info ) {

    print ">$key\n";
    print $info{$key}, "\n";

}

print STDERR "$repeat_seq_count repeated sequences found, and made unique\n\ndone!\n\n";




