#!/usr/bin/perl
 
use strict;
use warnings;
use BIO::AlignIO

my $usage = "parse_prottest.pl prottest_output > outfile\n";
my $infile = $ARGV[0] or die $usage;

my $io = Bio::AlignIO->new(-file   => "<$infile",
                           -format => "phylip" ); # interleaved


$out = Bio::AlignIO->new(-file => ">outputfilename",
                         -format => "phylip");

my $count = 0;
 
while ( my $aln = $in->next_aln ) { 

    $count++;
    if ( $count > $aln_num ) {

	$out->write_aln($aln);

    } 
}
