#!/usr/bin/perl   
use strict;
use Bio::SeqIO;
use Bio::DB::Fasta;
# Shaohua Fan
# the data from ENSEMBL contain several isoforms of the same gene
# this script selects the longest isoform for each gene
# this reduces the complexity to find 1:1 orthologs in blasting
# we can do this before creating the blast database

my $usage = "fetch_longest.pl infile.fa outfile.fa";
my $input = $ARGV[0] or die $usage;
my $output = $ARGV[1] or die $usage;

my $db = Bio::DB::Fasta->new("$input");
#my $db1= Bio::DB::Fasta->new("./Oryzias_latipes.MEDAKA1.67.cdna.all.fa");
my $infile = "$input";
my $infileformat = "fasta";
         my $seq_in = Bio::SeqIO->new('-file' => "<$infile",
                                      '-format' => $infileformat);

# declare hash that will contain sequence information
my %protein_information;

# read lines in file
# collect gene and transcript id, and protein length
while (my $inseq = $seq_in->next_seq) {
    my $protein_id=$inseq->id;
    $inseq->desc=~/gene\:(\w+)/g;
    my $gene_id=$1;
    $inseq->desc=~/transcript\:(\w+)/g;
    my $transcript_id=$1;
    my $protein_length=$inseq->length;

# if there is information for the gene_id, collect the above information in an array
if (!exists $protein_information{$gene_id} )
{
    $protein_information{$gene_id}=[$protein_length,$protein_id,$transcript_id];
}

# otherwise, if the length is longer, re-asign the information
else
{
    if ($protein_length>$protein_information{$gene_id}[0])
    {
	$protein_information{$gene_id}=[$protein_length,$protein_id,$transcript_id];
    }
}
}
open (OUT,">$output");
#open (OUT1,">./longest_medaka_cdna_sequence.fa");

# keys retrieves list of "keys"
# sort keys
foreach my $keys(sort keys %protein_information)
{
    my $seq=$db->seq($protein_information{$keys}[1]);
    print OUT ">$keys\:protein_id$protein_information{$keys}[1]:transcript_id:$protein_information{$keys}[2]\n";
    print OUT $seq,"\n";
#    my $seq1=$db1->seq($protein_information{$keys}[2]);
#    print OUT1 ">$keys\:protein_id$protein_information{$keys}[1]:transcript_id:$protein_information{$keys}[2]\n";
#    print OUT1 $seq1,"\n";



}
close (OUT);
#close (OUT1);
