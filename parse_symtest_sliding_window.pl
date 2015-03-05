#!/usr/bin/perl
 
use strict;
use Data::Dumper;

# Iker Irisarri, University of Konstanz. Mar 2015
# parses symtest results after sliding window analysis
# symtest -t a -w1000,100 myfile.fa > symtest.out       # window size 1000, step size 100


my $usage = "parse_symtest_sliding_window.pl infile > stdout\n";
my $symtest = $ARGV[0] or die $usage;

my $window;
my $significant;
my $percent;
my %hash;

open (IN , $symtest) or die "Can't open $symtest, $!\n";

while (my $line = <IN>){
    chomp $line;
	
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

foreach my $key ( sort keys %hash ) {

	# print out window coords and percentages of tests below 0.05
	if ( $hash{$key} <= "5" ) {
	
		print "$key\t$hash{$key}\n";
		
	}
	
}