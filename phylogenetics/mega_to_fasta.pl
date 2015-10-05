#!/usr/bin/perl


# FILE FORMAT CHANGE FROM MEGA TO FASTA
# Iker Irisarri. University of Konstanz, October 2015
# It will ignore all the information about gene partitions etc. (will skip everything starting with "!")

my $usage = "mega_to_fasta.pl infile > STDOUT\n";

my $infile = shift;

open (IN, "<", $infile) or die "Can't open file $infile\n";

my %sequences;

while ( my $line =<IN>) {
	chomp $line;
	#skip information lines from mega format (including gene partitions)
	next if $line =~ /^#mega/;
	next if $line =~ /^!.+/;
	# get actual line with information
	if ( $line =~ /#(\S+)/ ) {
		my $taxa = $1;
		my @lines = split (" ", $line);

		#print join ("--", @lines), "\n";
		
		# remove first element of @lines (#taxa)
		shift @lines;
		# join sequences
		my $seq = join ("", @lines);

		# store information first time appearance of taxa
		# if taxa exists, append new sequence		
		if ( !exists $sequences{$taxa} ) {
		
			$sequences{$taxa} = $seq;
		}
		else {
		
			$sequences{$taxa} .= $seq;
		}				
		
	}
}

# print out data in fasta format

foreach my $key ( keys %sequences ) {
	print ">$key\n";
	print "$sequences{$key}\n";
}

