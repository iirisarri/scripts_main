#!/usr/bin/perl
 
use strict;
use warnings;
use Bio::SeqIO;
use Data::Dumper;

# Iker Irisarri. Uppsala University. March 2017

my $usage = "rm_duplicated_taxa_from_fasta.pl in_fasta > STDOUT (fasta)\n";
my $fasta = $ARGV[0] or die $usage; 

# file in with seqio

#READ_IN: 
my $seqio_obj = Bio::SeqIO->new('-file' => "<$fasta", 
				'-format' => "fasta", 
				);

# store sequences in a hash

my %hash;
my @seen;

# print infile when executed in loop
print STDERR "$fasta\n";

while (my $inseq = $seqio_obj->next_seq) {

	my $taxa = $inseq->primary_id;
	my $seq = $inseq->seq;

	# store taxa already present in %hash for final removal
	if ( exists $hash{$taxa} ) {
	
		push (@seen, $taxa);
		print STDERR "$taxa present twice\n";
		next; # skips repeated taxa
	}
	
	# store data into %hash
	$hash{$taxa} = $seq;

}

# loop through %hash and remove repeated taxa
foreach my $elem ( @seen ) {

	delete $hash{$elem};
	print STDERR "$elem removed!\n";
}

# print out sequence

foreach my $k ( sort keys %hash ) {

	print ">$k\n";
	print "$hash{$k}\n";
}
