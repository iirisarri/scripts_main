#!/usr/bin/perl -w

#Yo pongo siempre esto, para que me avise de cualquier cosa rara. Te obliga a declarar todas las variables.
use strict;

use Bio::DB::Fasta;
use Bio::SeqIO;
use Data::Dumper;

my $usage = "extractSeqFromFasta fasta_file query_file\n";
my $fasta = $ARGV[0] or die $usage;
my $query = $ARGV[1] or die $usage;

# read fasta file with SeqIO
my $seqio_obj = Bio::SeqIO->new('-file' => "<$fasta",
                	        '-format' => "fasta");
                		        
# declare hash
# Mejor hacerlo con un hash que con un array
my %queries;
my %queries_found;

#open query file, chomp line and save it into the array with push
#the hash will contain gene names (variable $line) as keys and 1 as a value (that's random)
open (IN , $query) or die "Can't open $query, $!\n";

while (my $line = <IN>){
	chomp $line;
	#print $line, "\n";
	$queries{$line} = 1;	
	}

#check structure of hash	
#print Dumper \%queries, "\n";

while (my $seq_obj = $seqio_obj->next_seq){

    my $seqname = $seq_obj->primary_id;
    my $description = $seq_obj->description;

    if ( exists ( $queries{$seqname} ) ) {

	# if the sequence is found, store it in new hash
	$queries_found{$seqname} = 1;

#     	print ">",  $seq_obj->description, "\n";
        print ">",  $seq_obj->primary_id, " ",  $seq_obj->description, "\n";
       	print $seq_obj->seq, "\n";
    }

}

# print out sequences that were not found
foreach my $q ( keys %queries ) {

    if ( !exists $queries_found{$q} ) {

	print STDERR "sequence $q not found!\n";

    }

}

__END__

#Si quisieras hacerlo con arrays (sería mucho menos eficiente):
while (my $seq_obj = $seqio_obj->next_seq){

	my $seqname = shift @queries;
	#La comparación nunca es con "=". Si son números "==". Si son caracteres "eq".
	foreach my $query ( @queries ) {
		if($seq_obj->primary_id eq $query) {
			print $seq_obj->primary_id;
			print $seq_obj->seq;
			last; # salimos del bucle
		}
	}
}


__END__

Structure of %queries

$VAR1 = {
          'comp161255_c2_seq1' => 1,
          'comp177440_c0_seq1' => 1,
          'comp178046_c1_seq9' => 1,
          'comp170200_c0_seq5' => 1,
          'comp166596_c2_seq13' => 1,
          'comp149867_c0_seq1' => 1,
          'comp174145_c0_seq7' => 1,
          'comp165635_c0_seq1' => 1,
          'comp167515_c0_seq5' => 1,
				[...]
        };
$VAR2 = '
';
