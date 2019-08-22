#!/usr/bin/perl
 
use strict;
use Bio::SeqIO;
use Data::Dumper;

# Iker Irisarri. University of Konstanz, Februrary 2015

my $usage = "rm_gap_only_seqs.pl in_fasta > stdout (fasta)\n";
my $phylip = $ARGV[0] or die $usage; 

#READ_IN:
open(IN, "<", $phylip) or die "Can't open $phylip!\n";

my $ntax = "";
my $nchar = "";
my $remove = "0";
my %output;

while ( my $line =<IN> ) {
	chomp $line;
	# substitute space by tab
	$line =~ s/\s+/\t/g;
	
	# header
	if ( $line =~ /^\t*\d+\t\d+$/ ) {
		($ntax, $nchar) = split ("\t", $line);
		next;
	}
	#alignments
	
	my ($tax, $seq) = split ("\t", $line);
	
	if ( $seq =~ /^[-XNn]*$/ ) {
		print STDERR "\tremoved: $tax\n";
		#print STDERR "\t$seq\n";
		$remove++;
	}
	else {
		$output{$tax} = $seq;
	}
	
}

# adjust ntax
$ntax = $ntax - $remove;

# print output
print "$ntax\t$nchar\n";

foreach my $key ( sort keys %output ) {

	print "$key  $output{$key}\n";
}
