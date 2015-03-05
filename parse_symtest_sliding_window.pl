#!/usr/bin/perl
 
use strict;
use Data::Dumper;

# Iker Irisarri, University of Konstanz. Mar 2015
# parses symtest results after sliding window analysis
# symtest -t a -w1000,100 myfile.fa > symtest.out       # window size 1000, step size 100


my $usage = "parse_symtest_sliding_window.pl infile > stdout\n";
my $symtest = $ARGV[0] or die $usage;

my $window_size;
my $step;
my $matrix_length;
my $window;
my $significant;
my $percent;
my %hash;

open (IN , $symtest) or die "Can't open $symtest, $!\n";

while (my $line = <IN>){
    chomp $line;
	
	
	if ( $line =~ /WindowSize=(\d+)\sStepWidth=(\d+)\s_cols=(\d+)/ ) {
		$window_size = $1;
		#$step = $2;
		#$matrix_length = $3;
		next;
	}
	
	if ( $line =~ /^Highlights from the analysis \(window (\d+-\d+)\)/ ) {
		$window = $1;
		next;
	}
	if ( $line =~ /^P-values\s<\s0\.05\s+(\d+)\s\((.+?)%\)/ ) {
		$significant = $1;
		$percent = $2;

		# store data in hash
		$hash{$window} = $percent;
		next;
	}

}

#print Dumper \%hash;

my $start_1 = 0;
my $start_2 = 0;
my $end_1 = 0;
my $end_2 = 0;

my $block_count = 0;

foreach my $key ( sort { $a <=> $b } keys %hash ) {

	# print out window coords and percentages of tests below 0.05
	if ( $hash{$key} <= "5" ) {
	
	    # get start and end coords for current block (2)
	    $key =~ /(\d+)-(\d+)/;
	    my $start_2 = $1;
	    my $end_2 = $2;
	    
	    # assign coords for first block
	    if ( $start_1 == 0 && $end_1 == 0 ) {
	    	$start_1 = $start_2;
	    	$end_1 = $end_2;
	    	
			$block_count++;
	    	print "$key\t$hash{$key}\n";
		}
	    # compare coords from current block (1) with previous block (2)
	    # scape until block 2 is not overlapping
	    next if ( $start_2 < $end_1 ) ;
	    
	    # print next block if not overlapping

		$block_count++;
	    print "$key\t$hash{$key}\n";
	    
	    # re-assign coordinates of current block (2) to be previous (1) for next comparison
	    $start_1 = $start_2;
	    $end_1 = $end_2;
	
	}
	
}

my $concat_size = $block_count * $window_size;

print "\nNumber non-overlapping blocks with P < 0.05: $block_count\n";
print "Approx. size of final matrix: $concat_size\n\n";

