#!/usr/bin/perl

use strict;
use warnings;
use Bio::SeqIO;

# Iker Irisarri, Dec 2014, University of Kosntanz
# Calculates composition of sequences in fasta format and prints out raw counts
# Will count any element present in the sequence, including N-X?

my $usage = "calculate_seq_comp.pl input.fa\n";
my $input = $ARGV[0] or die $usage;

my $seqio_obj = Bio::SeqIO->new('-file' => "<$input",
				'-format' => "fasta");

my %fasta_hash;

# store sequences into hash
while (my $seq_obj = $seqio_obj->next_seq){
    my $seqname = $seq_obj->primary_id;
    my $seq =  $seq_obj->seq;
    $fasta_hash{$seqname} = $seq;
}

# loop through the hash to calcualte composition and print out
print "\nCalculating composition of sequences in $input...\n\n";
foreach my $key ( sort keys %fasta_hash ) {
    
    # submit sequence to subroutine
    my %returned = calculate_seq_comp($fasta_hash{$key});
    
    # print out stuff
    print "$key:\n";
    print "\t";
    foreach my $k ( sort keys %returned ) {
	print "$k $returned{$k} ";
    }
    print "\n";
}

print "\ndone!\n\n";

# subroutine to calculate composition of sequence
sub calculate_seq_comp {

    my $sequence = shift;

    my @seq_array;
    my %count;
    my %result;

    @seq_array = split //, $sequence;
    foreach my $elem ( @seq_array ) {
	    $count{$elem}++;
	}
    print "\t";
    foreach my $key ( sort keys %count ) {
	$result{$key} = $count{$key};
    }
    return %result;
}


	
