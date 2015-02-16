#!/usr/bin/perl

use warnings;
use strict;
use Bio::AlignIO;


# Iker Irisarri, University of Konstanz. Feb 2015
# converts fasta to nexus format (interleaved)


my $usage = "fasta2nexusinterleaved.pl in_file > stdout\n";
my $in = $ARGV[0] or die $usage;

my $io = Bio::AlignIO->new(-file   => "$in",
                           -format => "fasta" );

my $out = Bio::AlignIO->new(-format => 'nexus');

while ( my $aln = $io->next_aln ) { 

    $out->write_aln($aln); 

}
