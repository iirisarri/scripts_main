#!/usr/bin/perl
# http://seqanswers.com/forums/showthread.php?t=15856
# the original script measured numb reads with lengths between 18-28
# my @bins = qw/18 19 20 21 22 23 24 25 26 27 28/;
# I modified my @bins to show the distribution between 200-4000 in bins of 50bp
# for trinity, I set min contig length to 200; transcripts > 4000 won't appear
# explanation: http://search.cpan.org/~colink/Statistics-Descriptive-2.6/Descriptive.pm

use warnings;
use strict;
use Statistics::Descriptive;

my $stat = Statistics::Descriptive::Full->new();
my (%distrib);
my @bins = qw/200 250 300 350 400 450 500 550 600 650 700 750 800 850 900 950 1000 1100 1150 1200 1250 1300 1350 1400 1450 1500 1550 1600 1650 1700 1750 1800 1850 1900 1950 2000 2050 2100 2150 2200 2250 2300 2350 2400 2450 2500 2550 2600 2650 2700 2750 2800 2850 2900 2950 3000 3050 3100 3150 3200 3250 3300 3350 3400 3450 3500 3550 3600 3650 3700 3750 3800 3850 3900 3950 4000/;

my $fastaFile = shift;
open (FASTA, "<$fastaFile");
$/ = ">";

my $junkFirstOne = <FASTA>;

while (<FASTA>) {
	chomp;
	my ($def,@seqlines) = split /\n/, $_;
	my $seq = join '', @seqlines;
	$stat->add_data(length($seq));
}


%distrib = $stat->frequency_distribution(\@bins);

print "#Total reads:\t" . $stat->count() . "\n";
print "#Total nt:\t" . $stat->sum() . "\n";
print "#Mean length:\t" . $stat->mean() . "\n";
print "#Median length:\t" . $stat->median() . "\n";
print "#Mode length:\t" . $stat->mode() . "\n";
print "#Max length:\t" . $stat->max() . "\n";
print "#Min length:\t" . $stat->min() . "\n";
print "#Length\t# Seqs\n";
foreach (sort {$a <=> $b} keys %distrib) {
	print "$_\t$distrib{$_}\n";
}