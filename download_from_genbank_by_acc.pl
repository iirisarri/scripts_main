#!/usr/bin/perl

use warnings;
use strict;

use Data::Dumper;
use Bio::DB::GenBank;
use Bio::SeqIO;

# Iker Irisarri, University of Konstanz. Mar 2015

# download_from_genbank_by_acc.pl
# downloads sequences from NCBI using their accessions, output in fasta format

my $usage = "download_from_genbank_by_acc.pl query_file > stdout (fasta)\n";
my $queries = $ARGV[0] or die $usage;


my @accessions;

# hard-coded accessions
#my @accessions = qw (JJ725300 JJ725301 JJ725302 JJ725303 JJ725304);

# get accessions from file
open (IN ,"<", $queries);

while ( my $line = <IN> ) {
	chomp $line;
	push (@accessions, $line);
}
	
# connect to genbank
my $gb = Bio::DB::GenBank->new();


foreach my $accession (@accessions) {
	
	# create sequence object for each accession 
	my $seq_object = $gb->get_Seq_by_acc($accession);
	#my $seq_object = $gb->get_Seq_by_version($accession);
	
	# get header and sequence
	my $header = $seq_object->desc;
	my $seq = $seq_object->seq;
	
	# print to stdout
	print ">$header\n";
	#print ">$accession\n";
	print "$seq\n";
	
} 
	
	