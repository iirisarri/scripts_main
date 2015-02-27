#!/usr/bin/perl

use strict;
use warnings;

########################################################

##   Iker Irisarri, University of Konstanz. Feb 2015  ##

########################################################

# simple script to change format from multiphylip (interleaved) to single fasta
# e.g. change format from multilocus bootstrap replicates created by phybase to single fasta files
# to be analyzed by fasttree (fasttree has a bug and cannot read multiphylip files)

my $usage = "multiphylip_2indiv.fasta.pl infile output_name > stdout\n";
my $infile = $ARGV[0] or die $usage;
my $out_name = $ARGV[1] or die $usage;

open (IN, "<", $infile) or die "Cannot open file $infile: $!\n";

my $output_name;
my $num_of_taxa;
my $aln_count = 0;
my $taxa_count = 0;
my $block_count = 0;
my %seq_hash;

while ( my $line = <IN> ) {

    chomp $line;
    
    # scape empty lines
    if ( $line =~ /^$/ || $line =~ /^\n$/ || $line =~ /^[\t\s]*\n$/ ) {
    
		$taxa_count = 0;
		$block_count = 0;
		next;
	}

    # detect phylip header
 	if ( $line =~ /\s*(\d+)\s+\d+/ ) {
 	
		# count aln && initialize $taxa_count with every new alignment
 		$num_of_taxa = $1;
 		$aln_count++;
		$taxa_count = 0;
		$block_count = 0;
		
		# create outfile name
		if ( $aln_count > 0 ) {
			$output_name = $out_name . "_" . $aln_count . ".fa";
		}
		next;

 	}
 	
 	# process lines within each block, until the number of lines == $num_of_species
	while ( $taxa_count < ( $num_of_taxa + 1 ) || $block_count < ( $num_of_taxa + 1 ) ) {

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
 			$block_count++;
 				
	 		my $seq2 = $1;
 			my $seq_long = $seq_hash{$block_count}{'seq'} . $seq2;
 			# re-assign the new (longer) sequence
 			$seq_hash{$block_count}{'seq'} = $seq_long;
  			
  			last; # scape while loop
		
 		}
 	}
	
	# print out results when the whole aln has been processed
	if ( $block_count == $num_of_taxa ) {
	
		# open new input file for every new aln
		open (OUT, ">", $output_name) or die "Cannot create output file\n";

		# print sequences in fasta format to output file
		foreach my $key ( sort keys %seq_hash ) {

			# scape species withouth data (seq is XXX or ---)
		
			print OUT ">", $seq_hash{$key}{'taxa'}, "\n";
			print OUT $seq_hash{$key}{'seq'}, "\n";

		}

	close(OUT);
	
	}
}
	
print STDERR "\ndone!\n\n";

