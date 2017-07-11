#!/usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;
use Bio::SearchIO;

##########################################################################################
#
# #################### Iker Irisarri. Jul 2017. Uppsala University ##################### #
#
# Very simple script to translate DNA into proteins
#	 By default, only first reading frame and standard genetic code
#
##########################################################################################


my $usage = "translate_dna2prot_RF1.pl infile.fa => will generate infile.fa.pep\n";
my $infile = $ARGV[0] or die $usage;
#my $oufile = "$infile" . ".pep";


open (OUT, ">", "$infile.pep") or die "Can't create outfile $infile.pep\n";

# read fasta file with SeqIO
my $seqio_obj = Bio::SeqIO->new('-file' => "<$infile",
			         			'-format' => "fasta");

my $prot_obj = Bio::SeqIO->new('-format' => "fasta");

while (my $seq_obj = $seqio_obj->next_seq){

	# translate 
	$prot_obj = $seq_obj->translate(-codontable_id => 1,
				    				-frame => 1);

	print OUT ">", $seq_obj->primary_id, "\n";
	print OUT $prot_obj->seq, "\n";
}
close(OUT);