#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Bio::SeqIO;

# Iker Irisarri, Jun 2018. Museo Nacional de Ciencias Naturales - CSIC

my $usage = "select_pos_shared_by_taxa_fasta.pl input.fasta taxa_list.txt DNA/PROT > output.fa\n";
my $in_fasta = $ARGV[0] or die $usage;
my $taxa_list = $ARGV[1] or die $usage;
#my $data_type = "DNA";
my $data_type = $ARGV[2] or die $usage; # this can take two values: DNA or PROT

# check that $data_type is correctly set up
$data_type = uc $data_type;

unless ( $data_type eq "DNA" or $data_type eq "PROT" ) {

	print STDERR "ERR: data type incorrectly set. It should be DNA or PROT\n";
	die;
}

## Store alignment in hash of arrays

my %fasta_hash;
my %taxa_list;
my %pos_to_remove; # hash to store positions
my @pos_to_remove; # array with unique ordered positions
my $header;
my @seq;
my $length = "0";

=pod
# read fasta file with SeqIO
my $seqio_obj = Bio::SeqIO->new('-file' => "<$in_fasta",
								'-format' => "fasta");

while ( my $seq_obj = $seqio_obj->next_seq ) {

    $header = $seq_obj->primary_id;
    my $sequence = $seq_obj->seq;
    
    @seq = split (//, $sequence);
    
	$fasta_hash{$header} = [@seq];

}
=cut

# fasta parser without bioperl
open(IN, "<", $in_fasta);

while ( my $line =<IN> ) {
	chomp $line;
	if ($line =~ />(.+)/ ) {
		$header = $1;
	}
	else {
		# check that sequence is aligned
		#print "LEN: $length\n";
		if ( $length == "0") {
			$length = length $line;
		}
		elsif ( $length != length $line ) {
			print STDERR "ERR: sequences are not aligned!\n";
			die;
		}
		$line = uc $line;
		@seq = split (//, $line);
	} 
	$fasta_hash{$header} = [@seq];

}

# parse list of taxa
open(IN2, "<", $taxa_list);

while ( my $line2 =<IN2> ) {
	chomp $line2;
	$taxa_list{$line2} = "1";
}

# get positions where all taxa contain DNA/PROT characters

foreach my $tax ( keys %taxa_list ) {

	if ( !exists $fasta_hash{$tax} ) {
	
		print STDERR "ERR: $tax not present in alignment!\n";
		die;
	}
	
	# de-reference sequence array
	my @sequence_array = @{ $fasta_hash{$tax} };
	
	my $pos = "0";
	
	# loop through sequence and store positions to remove
	# repeated positions will be overwritten
	foreach my $char ( @sequence_array ) {
	
		#print "\n$pos: $char\n\n";
		#print Dumper \%pos_to_remove;
	
		if ( $data_type eq "DNA" ) {
		
			if ( $char ne "A" && $char ne "C" && $char ne "G" &&  $char ne "T" ) {
		
				$pos_to_remove{$pos} = $pos;
				$pos++;
				next;
			}
			else {
				$pos++;
				next;
			}
		}

		if ( $data_type eq "PROT" ) {
		
			if ( $char ne "A" && $char ne "R" && $char ne "N" && $char ne "D" && $char ne "C" &&
				 $char ne "Q" && $char ne "E" && $char ne "G" && $char ne "H" && $char ne "I" &&
				 $char ne "L" && $char ne "K" && $char ne "M" && $char ne "F" && $char ne "P" &&
				 $char ne "S" && $char ne "T" && $char ne "W" && $char ne "Y" && $char ne "V" ) {

				$pos_to_remove{$pos} = $pos;
				$pos++;
				next;
			}
			else {
				$pos++;
				next;
			}
		}
		
	}
}


#print Dumper \%pos_to_remove;
#print Dumper \%fasta_hash;

# remove positions in %pos_to_remove_from_alignment
foreach my $tax2 ( sort keys %fasta_hash ) {

	# de-reference sequence array
	my @sequence_array2 = @{ $fasta_hash{$tax2} };
	
	foreach my $p_rm ( keys %pos_to_remove ) {
	
		# mask positions to remove with 0s
		# to avoid loosing coordinates (array indexes)
		$sequence_array2[$p_rm] = "0";
	}
	# remove 0s and substitute in original hash
	my @sequence_array3 = ();
	
	foreach my $nonzero ( @sequence_array2 ) {

		if ( $nonzero ne "0") {

			push (@sequence_array3, $nonzero);
		}		
	}
	$fasta_hash{$tax2} = [@sequence_array3];
}

#print Dumper \%fasta_hash;

# print (trimmed) sequences
foreach my $key ( sort keys %fasta_hash ) {

	print ">$key\n";
	print join ("", @{ $fasta_hash{$key} }), "\n";
}


print STDERR "\ndone!\n\n";
