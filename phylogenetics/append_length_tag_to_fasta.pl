#!/usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;

##########################################################################################
#
# #################### Iker Irisarri. Feb 2018. Uppsala University ##################### #
# 
# Adds a tag and sequence length to fasta header
#
# It also makes headers unique, if repeated headers exist
#
##########################################################################################


my $usage = 'USAGE: perl append_length_tag_to_fasta.pl infile.fasta > STDERR\n';

my $file = $ARGV[0] or die $usage;
my $tag = "***";
my %fasta;
my $count_dupl = "0";

my $seqio_obj = Bio::SeqIO->new('-file' => "<$file", 
								'-format' => "fasta", 
		);

while (my $inseq = $seqio_obj->next_seq) {

	my $name = $inseq->primary_id;
	my $seq = $inseq->seq;
	$seq =~ s/-//g;
	my $length = length $seq;

	my $header = $name . $tag . "len=" . $length;

	if ( !exists $fasta{$header} ) {
		
		$fasta{$header} = $inseq->seq;
	}
	else {
		$count_dupl++;
		$header .= $count_dupl;
	}
}

foreach my $key ( sort keys %fasta ) {
	
	print ">$key\n";
	print "$fasta{$key}\n";
}
