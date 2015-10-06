#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

########################################################

##   Iker Irisarri, University of Konstanz. Oct 2015  ##

########################################################

# simple script to change format from interleaved phylip to sequentail
# modif of multiphylip_2indiv.fasta.pl

# possibility to remove species if seqs are only composed of X/-

my $usage = "phylip_interleaved_2_sequential.pl infile > stdout\n";
my $infile = $ARGV[0] or die $usage;

open (IN, "<", $infile) or die "Cannot open file $infile: $!\n";

my $output_name;
my $num_of_taxa;
my $taxa_count = 0;
my $block_count = 0;
my %seq_hash;

while ( my $line =<IN> ) {

    chomp $line;

    # detect phylip header and get number of taxa
 	if ( $line =~ /\s*(\d+)\s+\d+/ ) {
 	
 		$num_of_taxa = $1;
 		next;
 	}
    # scape empty lines and reinitialize $taxa_count
    if ( $line =~ /^$/ || $line =~ /^\n$/ || $line =~ /^[\t\s]*\n$/ ) {
    
    	$taxa_count=0;
		next;
	}
    
 	# process lines within each block, until the number of lines == $num_of_species
	while ( $taxa_count < ( $num_of_taxa + 1 ) ) {

 		# store data in hash for first block (contains taxa names)
 		if ( $line =~ /(\S+)[\s\t]+(\S+)/ ) {
 		
 			$taxa_count++;
 			my $taxa = $1;
 			my $seq1 = $2;
 		
 			$seq_hash{$taxa_count}{'taxa'} = $taxa;
 			$seq_hash{$taxa_count}{'seq'} = $seq1;
 			
 			last; # scape while loop
 		}
 		
 		# store data in hash for subsequent blocks
 		if ( $line =~ /\s*(\S+)/ ) {
 		
	 		# select species by their order
 			$taxa_count++;
	 		my $seq2 = $1;
 			my $seq_long = $seq_hash{$taxa_count}{'seq'} . $seq2;
 			# re-assign the new (longer) sequence
 			$seq_hash{$taxa_count}{'seq'} = $seq_long;
  			
  			last; # scape while loop
		
 		}
	}

}

#print Dumper \%seq_hash;

# print sequences in fasta format to output file
foreach my $key ( sort keys %seq_hash ) {

	# scape species withouth data (seq is XXX or ---)
	#next if ( $seq_hash{$key}{'seq'} =~ /^[X-]+$/ );
			
	print ">", $seq_hash{$key}{'taxa'}, "\n";
	print $seq_hash{$key}{'seq'}, "\n";

}
	
	

	
print STDERR "\ndone!\n\n";

