#!/usr/bin/perl

use warnings;
use strict;

use Bio::DB::Fasta;
use Bio::SeqIO;
use Data::Dumper;

# Simplified from extract_from_fasta_by_name.pl to read query from command line

my $usage = "extractSeqFromFasta fasta_file query_file\n";
my $fasta = $ARGV[0] or die $usage;
my $query = $ARGV[1] or die $usage;
my %found;

# read fasta file with SeqIO
my $seqio_obj = Bio::SeqIO->new('-file' => "<$fasta",
	                	        '-format' => "fasta");
                		        
while (my $seq_obj = $seqio_obj->next_seq){

    my $seqname = $seq_obj->primary_id;

	if ( $seqname eq $query ) {

		$found{$seqname} = 1;
        print ">",  $seq_obj->primary_id, " ",  $seq_obj->description, "\n";
       	print $seq_obj->seq, "\n";
    }
}

# print out sequences that were not found
if ( !exists $found{$query} ) {

	print STDERR "sequence $query not found!\n";
}
