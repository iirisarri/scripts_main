#!/usr/bin/perl -w
use strict;
use Bio::SeqIO;
use Bio::SearchIO;
use Data::Dumper;
use Bio::DB::Fasta;


# modified version of parse_blast_best_hit.pl
# additionally translates sequences and outputs the translation in the correct reading frame

# option to use a filter for an evalue threshold

# originally for getting comps of best hits to extract from fasta files (transcriptomes)
# translate them using the correct reading frame

# Iker Irisarri. Konstanz, November 2014  

my $usage = "blast_to_best_hit_prot.pl blast_report source_fasta > output.fa\n";
my $blast_report = $ARGV[0] or die $usage;
my $in_fasta = $ARGV[1] or die $usage;

# read blast report
my $report = new Bio::SearchIO(-format => "blast", 
			       -file   => "<$blast_report"
    );

my %hash;
my %queries;
my @frames;

# initialize evalues as 1, frames as 0
my $significance1 = 1;
my $evalue1 = 1;
my $frame_null = 0;
my $frame;


while( my $result = $report->next_result ) {

    # get query name
    $result->query_name =~ /Protopteru_(G\d{5})/;
    my $query = $1;
    # reasign 1 to evalue for each new result 
    $significance1 = 1;

    while( my $hit = $result->next_hit ) {

	# get evalue for that hit
        my $significance = $hit->significance;

	# compare evalue of this hit with that from previous hits
	# for first hit, compares against evalue of 1
	# for next hits, compares with evalue of previous hit
	if ( $significance < $significance1 ) {

	    # assing new evalue to $value1 (for comparison)
	    $significance1 = $significance;

#	    my $hit_name = $hit->name;
	    # to remove "lcl|" that appears in hit name
	    $hit->name =~ /lcl\|(.+)/;
	    my $hit_name = $1;
	    my $bits1 = $hit->bits;

	    # empty $frame1 & @frames for each new hit
	    $frame_null = 0;
	    my $frame = 0;
	    @frames = ();

	    $evalue1 = 1;

	    # get reading frame
	    while ( my $hsp = $hit->next_hsp ) {
		
#		my $evalue = $hsp->evalue;
#		if ( $evalue < $evalue1 ) {
#		    $evalue1 = $evalue;

	    # get reading frames for all hsps

	    # process first hsp for each hit ( only time $frame_null will be 0 )
       	    if ( $frame_null == 0 ) {
       		# get reading frame (1,2,3) multiplied by strand
		$frame = ( $hsp->hit->frame + 1 ) * $hsp->strand('hit');
		$frame_null = $frame;
		# store frame into array @frames
	       	push ( @frames, $frame );
       	    }
       	    # get further $frames in the loop
	    else {

		$frame = ( $hsp->hit->frame + 1 ) * $hsp->strand('hit');
	    }

	    # make sure all frames are the same for the different hsp within the same hit
	    if ( $frame != $frame_null ) {
		# will print as many times as reading frame shifts are present for each hit
		print STDERR "Warning! Frameshift for",
		" query $query and hit $hit_name\n";

		# add additional frames to array @frames
		push ( @frames, $frame );
		    
	    }
            
	    
#	    my $evalue = $hsp->evalue;
#                if ( $evalue < $evalue1 ) {
#                    $evalue1 = $evalue;
#	    }
	
	    # store info into hash of hashes
	    $hash{$query}{'blast_info'} = [$hit_name,$bits1,$significance,$frame];
	    # hash 'frames' would allow translating the same query in multiple frames
	    # to try to correct from frameshifts
	    $hash{$query}{'frames'} = [@frames];
	    }
	}
    }
}

#print Dumper \%hash;


# print sequences, not in order (because $query is alphanumeric)
#foreach my $key ( sort { $a cmp $b } keys %hash ) {
    # filter by evalue
#    if ( $hash{$key}{'blast_info'}[2] < 1e-3 ) {
	# store best hits as keys in new hash %queries
#	my $best_hit = $hash{$key}{'blast_info'}[0];
#	$queries{$best_hit} = 1;
#    }
#} 


###########################################
# extract_from_fasta_by_name && translate #
###########################################

# read fasta file with SeqIO
my $seqio_obj = Bio::SeqIO->new('-file' => "<$in_fasta",
                		'-format' => "fasta");

my $prot_obj = Bio::SeqIO->new('-format' => "fasta");

my $f;

# define custom header for proteins in output
#my $header_out = "Lepidosire";
my $header_out;

# extract best hits from source fasta & translate
while (my $seq_obj = $seqio_obj->next_seq){

    my $seqname = $seq_obj->primary_id;
    my $description = $seq_obj->description;

    foreach my $key ( sort { $a cmp $b } keys %hash ) {
	# get best hits from source fasta
	if ( $seqname eq $hash{$key}{'blast_info'}[0] ) {
	    # get all elements from @frames
	    foreach my $fram ( @{ $hash{$key}{'frames'} } ) {

		# get "real" reading frame and substract 1 to convert to perl reading frames (0,1,2)
		$fram =~ /-*(\d)/;
		$f = $1 - 1;
		$header_out = "Lepidosire_$key";

		# revcomp sequence if negative frame
		if ( $fram =~ /-\d/ ) {
		    
		    my $revcomp_obj = $seq_obj->revcom;
		    
		    # codontable_id 1 is for standard genetic code
		    $prot_obj = $revcomp_obj->translate(-codontable_id => 1,
							-frame => $f);
		}
		else {
		    $prot_obj = $seq_obj->translate(-codontable_id => 1,
						    -frame => $f);
		}

		print STDOUT ">", $header_out, "\n";
		print STDOUT $prot_obj->seq, "\n";
		# scape foreach loop of %hash once the sequence is found
		next;
	    }
	}
    }
}

__END__
