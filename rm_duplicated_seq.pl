#!/usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;

##########################################################################################
#
# #################### Iker Irisarri. Dec 2017. Uppsala University ##################### #
# 
# rm_duplicated_seqs.pl
# 
# It removes duplicated sequences in fasta file, randomly removes second, third etc. 
# 	occurrences of the same sequence
#
##########################################################################################

my $usage = "rm_duplicated_seqs.pl infile.fa > outfile.uniq.fa\n";
my $fasta = $ARGV[0] or die $usage; 

my %sequences;

my $seqio_obj = Bio::SeqIO->new('-file' => "<$fasta", 
								'-format' => "fasta"
								);


while (my $seqio_obj = $seqio_obj->next_seq) {

	my $name = $seqio_obj->primary_id;

	# save into %hash using sequence as key	
	if ( !exists $sequences{$seqio_obj->seq} ) {
	
		$sequences{$seqio_obj->seq} = $seqio_obj->primary_id;
	}
	# if sequence is already present, it will be ignored
	else {
	
		print STDERR "Skipping $name, identical sequence to $sequences{$seqio_obj->seq}\n";
	}
}


my $outfile = $fasta . ".uniq.fa";

open(OUT, ">", $outfile);

print STDERR "\nPrinting unique sequences to: $outfile...\n";

foreach my $key (sort keys %sequences ) {

	print OUT ">$sequences{$key}\n";
	print OUT "$key\n";
}
close(OUT);

print STDERR "\ndone!\n";
