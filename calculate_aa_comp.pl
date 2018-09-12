#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Math::Round;

##########################################################################################
#
# #################### Iker Irisarri. Apr 2017. Uppsala University ##################### #
#
# Calculates composition of AA sequences in fasta format and prints out (1) raw 
# 	proportions and (2) taxon-averaged proportions. Option 2 buffers the effect of missing
# 	data in some taxa.
#
#	The proportion of gaps and 
#
##########################################################################################

# Iker Irisarri, May 2015, University of Kosntanz
# Modif of calculate_seq_comp.pl to print out counts of determined (ACGT) and ambiguous (WSYRCHB etc) DNA bases
# Calculates composition of DNA sequences in fasta format and prints out raw counts
# Will count any element present in the sequence, including N-X?
# sequence cannot be total cause it would 
# possible to get out the completeness per sequence

my $usage = "calculate_aa_comp.pl input.fa\n";
my $input = $ARGV[0] or die $usage;

my %fasta_hash;
my @aa_order = qw (A R N D C Q E G H I L K M F P S T W Y V);
my $aln_length = 0;
my $num_seqs = 0;

=pod
use Bio::SeqIO;

my $seqio_obj = Bio::SeqIO->new('-file' => "<$input",
								'-format' => "fasta");

# store sequences into hash
while (my $seq_obj = $seqio_obj->next_seq){
    my $seqname = $seq_obj->primary_id;
    my $seq =  $seq_obj->seq;
    $fasta_hash{$seqname} = $seq;
}
=cut

open (IN, "<", $input) or die "Can't open $input!\n";

my $seqname;

while ( my $line = <IN> ) {

    chomp $line;

    if ( $line =~ /^>(.+)/g ) {

		$seqname=$1;
		$num_seqs++;
		
		# seqname cannot be 'total'
		if ( $seqname eq 'total' ) {
		
			die "ERR: Sequence name cannot be 'total'\n";
		}
		$fasta_hash{$seqname} = '';
		next;
	}
	else {
	
		$fasta_hash{$seqname} .= $line;
    }
}

my %aa_count = ();

# loop through the hash to calcualte composition 

foreach my $key ( sort keys %fasta_hash ) {

	my @seq_array = split //, $fasta_hash{$key};
	
	foreach my $elem ( @seq_array ) {

		# check that sequences are properly aligned
		if ( $aln_length != 0 && $aln_length != scalar @seq_array ) {
		
			print STDERR "ERR: sequences are not properly aligned! Check $key...";
		}
		$aln_length =  scalar @seq_array;

		$elem = uc $elem;
	
		# count gaps or missing data
		if ( $elem =~ /[-X?]/ ) {
		
			$aa_count{$key}{'gaps'}++;
			$aa_count{'total'}{'gaps'}++;
			next;
		}		
		if ( $elem =~ /[ARNDCQEGHILKMFPSTWYV]/ ) {
		
			$aa_count{$key}{$elem}++;
			$aa_count{'total'}{$elem}++;

			$aa_count{$key}{'unambiguous'}++;
			$aa_count{'total'}{'unambiguous'}++;	
		}
		else {

			print STDERR "Non-standard AA $elem in $key\n";		
		}
	}
}

#print Dumper \%aa_count;

# make stats and print out
print "\nCalculating AA composition of sequences in $input...\n\n";

my %aa_prop;

# calculate aa frequencies per sequence (including also 'total', ie, total frequencies)
foreach my $l ( sort keys %aa_count ) {

	foreach my $m ( sort keys %{ $aa_count{$l} } ) {
	
		my $freq = 0; # initialize

		# proportion of gaps and AA ("unambiguous" characters) calculated with respect to aln length
		if ( $m eq "gaps" || $m eq "unambiguous" ) {

			my $aa_count = ${ $aa_count{$l} }{$m};
			$freq = $aa_count / $aln_length;
			
			# total counts of gaps and unambiguous characters should also be divided by number of sequences
			if ( $l eq 'total' ) {
			
				$freq = $freq /  $num_seqs;
			}
		}		
		# AA proportions calculated with respect to total unambiguous AA
		else {
			my $aa_count = ${ $aa_count{$l} }{$m};
			my $unambiguous = ${ $aa_count{$l} }{'unambiguous'};

			$freq = $aa_count / $unambiguous;
		}
		# at this point, proportions of each AA and gaps/unambiguous-AA	are calculated with respect to different total characters
		$aa_prop{$l}{$m} = $freq;
	}
}		

#print Dumper \%aa_prop;

# print "total" raw proportions
print "Raw AA proportions (\"total\") in ARNDCQEGHILKMFPSTWYV order\n";
foreach my $aa ( @aa_order ) {

	print " $aa_prop{'total'}{$aa}";
}

# average proportions across sequences and print
print "\n\nAA proportions averaged across sequences in ARNDCQEGHILKMFPSTWYV order\n";
foreach my $aa ( @aa_order ) {

	# loop through taxa and add proportions
	my $sum_aa_prop = 0; # initialize for every aa

	foreach my $n ( sort keys %aa_prop ) {
	
		# skip "total"
		next if ( $n eq "total");
		# skip aa proportion if it does not exist in some taxa
		if ( !exists ${ $aa_prop{$n} }{$aa} ) {
		
			#print STDERR "AA $aa not existing for taxa $n\n";
			next;
		}
		$sum_aa_prop += ${ $aa_prop{$n} }{$aa};
	}
	# divide by number of taxa
	my $aa_prop_mean = $sum_aa_prop / $num_seqs;

	print " $aa_prop_mean";
}


# print proportion of AA per taxa
print "\n\nAA proportions perl taxa in ARNDCQEGHILKMFPSTWYV order\n";

# loop through taxa
foreach my $p ( sort keys %aa_prop ) {

	print "$p\t";

	# loop through AAs
	foreach my $aa ( @aa_order ) {

		# skip "total"
		next if ( $p eq "total");

		print sprintf("%.5f", ${ $aa_prop{$p} }{$aa}), "\t";

	}
	print "\n";
}

# print proportion of gaps and unambiguous AA per taxa
print "\n\nStatistics on missing data:\n";
print "taxa\tpresent\tgaps\n";

foreach my $o ( sort keys %aa_prop ) {

	my $present = ${ $aa_prop{$o} }{'unambiguous'};
	my $absent = 0;
	
	if ( exists ${ $aa_prop{$o} }{'gaps'} ) {
	
		$absent = ${ $aa_prop{$o} }{'gaps'};
	}
	
	my $present_round = sprintf("%.2f", $present);
	my $absent_round = sprintf("%.2f", $absent);
	print "$o\t$present_round\t$absent_round\n";
}

print STDERR "\ndone!\n\n";

		