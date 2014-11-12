#!/usr/bin/perl

# removes sequences that are repeated in a fasta file
# I used it to remove repeated sequences from uniprot invert proteins
# because repeated prots give an error when creating blast databases
# Downloaded from http://www.bioinformatics-made-simple.com

use Bio::Perl;
my $infile1 = $ARGV[0];
my %FIRSTSEQ;
my $total = 0;
my $total1=0;
my $dup = 0;

open (OUTIE, ">$ARGV[1]");

$infile1 = Bio::SeqIO -> new('-format'=>'Fasta',-file => $infile1);

#read in all fasta sequences

while ((my $seqobj = $infile1->next_seq())) 
{

    $rawid = $seqobj -> display_id;
    $seq = $seqobj -> seq;

    print "ID is $rawid\n";
#print "Sequence is $seq\n";

    my $holder = 0;

    if(defined($FIRSTSEQ{$rawid}))
    {
	print "Key match with $rawid\n";
	#$rawid = $rawid.$holder;
	$dup++;
    } 
    else
    {
	$FIRSTSEQ{$rawid} = $seq;
	$total++;
    }
}

while ( ($key, $value) = each(%FIRSTSEQ) )
{
    print OUTIE ">$key\n";
    print OUTIE "$value\n\n";
    $total1++;
}

print "\n$total unduplicated sequences in the file\n";
print "$dup duplicated sequences in the file\n";
print "$total1 unique sequences printed out.\n";

close(OUTIE);
