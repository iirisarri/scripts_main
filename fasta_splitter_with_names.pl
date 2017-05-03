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
	
	# specific for headers with format gene_name@taxa_name
#	my ($gene, $taxa) = split ("\@", $header); 
#	my $outfile = $gene . ".ref";
	
	my $outfile = $header . ".fa";
	
	# print out sequence to file
	open (OUT, ">", "$outfile") or die "Can't open $outfile\n";

	print OUT ">$header\n";
#	print OUT ">$taxa\n";
	print OUT "$sequence\n"; 

	print STDERR "\twrote $outfile\n";
}

print STDERR "\ndone!\n";
