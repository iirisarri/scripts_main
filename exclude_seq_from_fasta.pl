#!/usr/bin/perl -w

use strict;
use warnings;
use Bio::DB::Fasta;
use Bio::SeqIO;
use Data::Dumper;

my $usage = "exclude_seq_from_fasta.pl infile.fa query_file > STDOUT\n";
my $fasta = $ARGV[0] or die $usage;
my $query = $ARGV[1] or die $usage;

# read fasta file with SeqIO
my $seqio_obj = Bio::SeqIO->new('-file' => "<$fasta",
                	        '-format' => "fasta");

my %queries;
my $queries = 0;
my $removed = 0;

#open query file, chomp line and save it into the array with push
#the hash will contain gene names (variable $line) as keys and 1 as a value (that's random)
open (IN , $query) or die "Can't open $query, $!\n";

while (my $line = <IN>){
	chomp $line;
	#print $line, "\n";
	$queries{$line} = 1;	
	$queries++;
}

while (my $seq_obj = $seqio_obj->next_seq){

    my $seqname = $seq_obj->primary_id;
    my $description = $seq_obj->description;

    if ( exists ( $queries{$seqname} ) ) {

	$removed++;
    }
    else {
	print ">",  $seq_obj->primary_id, " ",  $seq_obj->description, "\n";
	print $seq_obj->seq, "\n";
    }
}


print STDERR "Queries to be removed: $queries\n";
print STDERR "Queries removed: $removed\n\nDone!\n\n";
