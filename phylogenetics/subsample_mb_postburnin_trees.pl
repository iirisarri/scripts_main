#!/usr/bin/perl
 
use strict;
use warnings;
use Data::Dumper;

# Iker Irisarri, Oct 2016. University of Konstanz
# subsample_mb_postburnin_trees.pl
#
# Extracting post-burnin trees from MrBayes *runN.t files (similar to chain thinning from finished output) 
# 
# Originally used to subsample finished runs for input topologies for PhyloNet
# When multiple input files are processed in loop: redirect STDOUT to >> outfile 3
# && use the following line to read-in the number of trees present in outfile

my $usage = "subsample_mb_runs.pl infile.run1.t Num_trees_to_extract (Integer) > STDOUT\n ";
my $infile = $ARGV[0] or die $usage; 
my $num_gen_out = $ARGV[1] or die $usage; 

my $burnin = 250000; # (0.25)
my $total_gen = 10000000;
my %translate = ();
my %out_trees = ();
my $next_sampling_gen = 0;

# calculate frequency of 
my $postburnin = $total_gen - $burnin;
my $subsampling_freq = int ( $postburnin / $num_gen_out );

open (IN, "<", $infile) or die "Can't open file $infile\n";

while ( my $line =<IN> ) {
	chomp $line;

	# skip #NEXUS and comments
	next if ( $line =~ /^[\s\t]+$/ );
	next if ( $line =~ /^[#\[].+/ );
	next if ( $line =~ /^begin.+/i );	
	next if ( $line =~/[\s\t]*translate/i );
	
	# store num-taxa information
	if ( $line =~/[\s\t](\d+)\s(\w+)[,;]/ ) {

		$translate{$1} = $2;
	}
	
	# generations
	if ( $line =~/[\s\t]+tree gen\.(\d+)+\s=/ ) {
	
		my $curr_gen = $1;
	
		# skip burnin phase
		next while ( $curr_gen < $burnin );
		#print "$curr_gen\n";
		
		# skip generations until next sampling point
		next while ( $curr_gen < $next_sampling_gen );

		# skip last generation (when <10 generations are required, one extra tree is printed)
		next if ( $num_gen_out < 11 && $curr_gen == $total_gen );
	
		# get tree from given generation and store in %hash
		my @lines = split " ", $line;
		my $gen_tree = $lines[4];
		
#=pod		
		# translate taxon names
		foreach my $key ( keys %translate ) {

			# Substitution: Use the \b anchor to match only on a word boundary
			# Taxon names are always preceded by ( or , and followed by :
			$gen_tree =~ s/\($key\b:/($translate{$key}:/;
			$gen_tree =~ s/,$key\b:/,$translate{$key}:/;
			#print "$gen_tree\n";
		}			
#=cut			
		$out_trees{$curr_gen} = $gen_tree;
	
		# add X generations (according to subsampling frequency
		$next_sampling_gen = $curr_gen + $subsampling_freq;
		next;
	
	}
}

# process out files and translate taxa

# When multiple input files are processed in loop: redirect STDOUT to >> outfile 3
# && use the following line to read-in the number of trees present in outfile

my $out_count = `wc -l outfile`;

#my $out_count = 0;
 
foreach my $tree ( keys %out_trees ) {

	#print "$tree\n";
	#print "$out_trees{$tree}\n";

	# Special print for PhyloNet input
	$out_count++;
	print "Tree gene$out_count = $out_trees{$tree}\n";
}

