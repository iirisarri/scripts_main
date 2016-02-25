#!/usr/bin/perl

use strict;
use warnings;

########################################################

##   Iker Irisarri, University of Konstanz. Feb 2015  ##

########################################################

# simple script to change format from multiphylip (interleaved) to single fasta
# e.g. change format from multilocus bootstrap replicates created by phybase to single fasta files
# to be analyzed by fasttree (fasttree has a bug and cannot read multiphylip files)

# it also removes species if seqs are only composed of X/-
# and checks that all species have the same sequence length

# Bug fix Feb 2016. Sometimes seque lengths in output fasta were unequal
# 					Added few changes, including the initialization of the %seq_hash
#					for every new alignment, new condition to check that all sequences and
#					blocks are processed before writing to output file and further check
#					to print error if sequence lengths are not equal in output file.


my $usage = "multiphylip_2indiv.fasta.pl infile output_name > stdout\n";
my $infile = $ARGV[0] or die $usage;
my $out_name = $ARGV[1] or die $usage;

open (IN, "<", $infile) or die "Cannot open file $infile: $!\n";

my $output_name;
my $num_of_taxa;
my $tot_aln_length;
my $tot_seq_length;
my $aln_count = 0;
my $taxa_count = 0;		# counts num species in first block
my $block_count = 0;	# counts num species in subsequent blocks
						# both $taxa_count and $block_count mark the position of each 
						# species in first and subsequent blocks, respectively
my %seq_hash;

while ( my $line = <IN> ) {

    chomp $line;
    
    # scape empty lines and initialize $taxa_count and $block_count
    if ( $line =~ /^$/ || $line =~ /^\n$/ || $line =~ /^[\t\s]*\n$/ ) {
    
		$taxa_count = 0;
		$block_count = 0;
		next;
	}

    # detect phylip header
 	if ( $line =~ /\s*(\d+)\s+(\d+)/ ) {
 	
		# count aln && initialize $taxa_count with every new alignment
 		$num_of_taxa = $1;
 		$tot_aln_length = $2;
 		$aln_count++;
		$taxa_count = 0;
		$block_count = 0;
		
		# initialize (emtpy) hash for each new alignment
		%seq_hash = ();
		
		# create outfile name
		if ( $aln_count > 0 ) {
			$output_name = $out_name . "_" . $aln_count . ".fa";
		}
		next;

 	}
 	
 	# process lines within each block, until the number of lines eq $num_of_species
	while ( $taxa_count < ( $num_of_taxa + 1 ) || $block_count < ( $num_of_taxa + 1 ) ) {

 		# store data in hash for first block (contains taxa names)
 		if ( $line =~ /(\S+)[\s\t]+(\S+)/ ) {
 		
 			$taxa_count++;
 			my $taxa = $1;
 			my $seq1 = $2;
 			 		
 			$seq_hash{$taxa_count}{'taxa'} = $taxa;
 			$seq_hash{$taxa_count}{'seq'} = $seq1;

 			# update $tot_seq_length every time a sequence is added to %seq_hash
 			$tot_seq_length = length $seq1;
 			
 			last; # scape while loop
 		}
 		
 		# store data in hash for subsequent blocks
 		if ( $line =~ /\s*(\S+)/ ) {
 		
	 		# select species by their order
 			$block_count++;
 				
	 		my $seq2 = $1;
 			my $seq_long = $seq_hash{$block_count}{'seq'} . $seq2;
 			# re-assign the new (longer) sequence
 			$seq_hash{$block_count}{'seq'} = $seq_long;
 			
 			# update $tot_seq_length every time a sequence is added to %seq_hash
 			$tot_seq_length = length $seq_long;
  			
  			last; # scape while loop
		
 		}
 	}
	
	# print out results when the whole aln has been processed
	# i.d. sequence length equals total length AND the last block is processed till the end
	if ( $tot_seq_length == $tot_aln_length && $num_of_taxa == $block_count ) {

		# open new input file for every new aln
		open (OUT, ">", $output_name) or die "Cannot create output file\n";

		my $first_length = 0;
		# print sequences in fasta format to output file
		foreach my $key ( sort keys %seq_hash ) {

			# scape species withouth data (seq is XXX or ---)
			next if ( $seq_hash{$key}{'seq'} =~ /^[X-]+$/ );
			
			# check that all species have the same seq length
			my $length = length $seq_hash{$key}{'seq'};
			
			if ( $first_length == 0 ) {

			    $first_length = $length;
			}
			elsif ( $length != $first_length ) {
			    
			    print STDERR "ERR: sequences not of the same length in $output_name\n";
			}
			    
			print OUT ">", $seq_hash{$key}{'taxa'}, "\n";
			print OUT $seq_hash{$key}{'seq'}, "\n";

		}

	close(OUT);
	
	}
}
	
print STDERR "\ndone!\n\n";

