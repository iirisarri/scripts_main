#!/usr/bin/perl -w

use strict;

use Bio::DB::Fasta;
use Bio::SeqIO;
use Data::Dumper;


# Iker Irisarri, University of Konstanz. Feb 2015
# modified from extract_from_fasta_by_name.pl to extract sequences from ensembl
# header contains gene ids and species names
# Warning: when downloading species other than chordates might give an error with gene ids
#			because they do not follow ENSXXXG pattern (but non extracted queries will be printed to stderr)

my $usage = "extract_from_fasta_addtax_ensembl.pl fasta_file query_file > STDOUT\n";
my $fasta = $ARGV[0] or die $usage;
my $query = $ARGV[1] or die $usage;

# read fasta file with SeqIO
my $seqio_obj = Bio::SeqIO->new('-file' => "<$fasta",
	                	        '-format' => "fasta");

# ensembl species (v.78)
my %ENSEMBL = ('ENSAME' => 'ailuropoda_melanoleuca', 'ENSAPL' => 'anas_platyrhynchos', 'ENSACA' => 'anolis_carolinensis', 'ENSAMX' => 'astyanax_mexicanus', 'ENSBTA' => 'bos_taurus', 'ENSY54F10' => 'caenorhabditis_elegans', 'ENSCJA' => 'callithrix_jacchus', 'ENSCAF' => 'canis_familiaris', 'ENSCPO' => 'cavia_porcellus', 'ENSCSA' => 'chlorocebus_sabaeus', 'ENSCHO' => 'choloepus_hoffmanni', 'ENSCIN' => 'ciona_intestinalis', 'ENSCSAV' => 'ciona_savignyi', 'ENSDRE' => 'danio_rerio', 'ENSDNO' => 'dasypus_novemcinctus', 'ENSDOR' => 'dipodomys_ordii', 'FBpp' => 'drosophila_melanogaster', 'ENSETE' => 'echinops_telfairi', 'ENSECA' => 'equus_caballus', 'ENSEEU' => 'erinaceus_europaeus', 'ENSFCA' => 'felis_catus', 'ENSFAL' => 'ficedula_albicollis', 'ENSGMO' => 'gadus_morhua', 'ENSGAL' => 'gallus_gallus', 'ENSGAC' => 'gasterosteus_aculeatus', 'ENSGGO' => 'gorilla_gorilla', 'ENSG0' => 'homo_sapiens', 'ENSSTO' => 'ictidomys_tridecemlineatus', 'ENSLAC' => 'latimeria_chalumnae', 'ENSLOC' => 'lepisosteus_oculatus', 'ENSLAF' => 'loxodonta_africana', 'ENSMMU' => 'macaca_mulatta', 'ENSMEU' => 'macropus_eugenii', 'ENSMGA' => 'meleagris_gallopavo', 'ENSMIC' => 'microcebus_murinus', 'ENSMDO' => 'monodelphis_domestica', 'ENSMUS' => 'mus_musculus', 'ENSMPU' => 'mustela_putorius_furo', 'ENSMLU' => 'myotis_lucifugus', 'ENSNLE' => 'nomascus_leucogenys', 'ENSOPR' => 'ochotona_princeps', 'ENSONI' => 'oreochromis_niloticus', 'ENSOAN' => 'ornithorhynchus_anatinus', 'ENSOCU' => 'oryctolagus_cuniculus', 'ENSORL' => 'oryzias_latipes', 'ENSOGA' => 'otolemur_garnettii', 'ENSOAR' => 'ovis_aries', 'ENSPTR' => 'pan_troglodytes', 'ENSPAN' => 'papio_anubis', 'ENSPSI' => 'pelodiscus_sinensis', 'ENSPMA' => 'petromyzon_marinus', 'ENSPFO' => 'poecilia_formosa', 'ENSPPY' => 'pongo_abelii', 'ENSPCA' => 'procavia_capensis', 'ENS[VA' => 'pteropus_vampyrus', 'ENSRNO' => 'rattus_norvegicus', 'Y' => 'saccharomyces_cerevisiae', 'ENSSHA' => 'sarcophilus_harrisii', 'ENSSAR' => 'sorex_araneus', 'ENSSSC' => 'sus_scrofa', 'ENSTGU' => 'taeniopygia_guttata', 'ENSTRU' => 'takifugu_rubripes', 'ENSTSY' => 'tarsius_syrichta', 'ENSTNI' => 'tetraodon_nigroviridis', 'ENSTBE' => 'tupaia_belangeri', 'ENSTTR' => 'tursiops_truncatus', 'ENSVPA' => 'vicugna_pacos', 'ENSXET' => 'xenopus_tropicalis', 'ENSXMA' => 'xiphophorus_maculatus'); 

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

	# get ensembl geneid
	# ensembl:novel scaffold:ailMel1:GL193041.1:400442:403556:-1 gene:ENSAMEG00000003001 gene_biotype:protein_coding transcript_biotype:protein_coding'
	my @split = split (":", $seq_obj->description);
	$split[7] =~ /(ENS\w{3}G\d+).+/;
    my $seqname = $1;
    #my $description = $seq_obj->description;
    
    if ( exists ( $queries{$seqname} ) ) {

		# if the sequence is found, store it in new hash
		$queries_found{$seqname} = 1;

		# get species name from %ENSEMBL and create fasta header
		my $header = ();
		$seqname =~ /(ENS\w{3}).+/;
		
		if ( exists $ENSEMBL{$1} ) {
	
			$header = $ENSEMBL{$1} . "_" . $seqname;
	
		}

		# print out sequence in fasta format
    	print ">$header\n";
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

Structure of seq_obj from ensembl

0  Bio::Seq=HASH(0x7ff6baa502e8)
   'primary_id' => 'ENSAMET00000003281'
   'primary_seq' => Bio::PrimarySeq=HASH(0x7ff6baa50300)
      'alphabet' => 'dna'
      'desc' => 'ensembl:novel scaffold:ailMel1:GL193041.1:400442:403556:-1 gene:ENSAMEG00000003001 gene_biotype:protein_coding transcript_biotype:protein_coding'
      'display_id' => 'ENSAMET00000003281'
      'length' => 735
      'primary_id' => 'ENSAMET00000003281'
      'seq' => 'CCCCTTCCGGGCTGCCTGCCCGCTCTAGCTGGCTCCCAAGTGAAGAGGCTGTCGGCCTCCAAGCGGAAACAGCACTTCATCCACCAGGCTGTGCGGAACTCAGACCTCGTGCCCAAGGCCAAGGGGCGGAAGAGCCTCCAGCGCCTAGAGAACACCCAGTACCTCCTATCCCTGCTGGAGACCGACGGGGGCACAGCCGGTCTGGACGATGGGGACCTGGCCCCCCCGGCAGCACCCGGGATCTTCGCAGAGGCCTGCAGCAATGAGACCTACATGGAGGTCTGGAATGACTTCATGAACCGCTCTGGGGAGGAGCAGGAAAGGGTTCTCCGCTACCTGGAGGATGAGGGCAAGAGCAAGACGCGGAGGAGGGGGCCTGGCCGCGGAGAGGACAGAAGGAGAGAGGACCCGGCCTACACACCCCGTGACTGCTTCCAGCGCATCAGCCGGCGTCTGAGAGCCGTCCTCAAGCGGAGCCGCATCCCCATGGAGACGCTGGAGACCTGGGAGGAGAGGTTGCTGACGTTCTTCTCGGTCTCTCCCCAGGCCGTGTACACGGCCATGCTGGACAACAGTTTCGAGAGGCTCCTGCTTCATGCCATCTGCCAGTACATGGACCTCATCTCAGCCAGTGCTGACCTGGAAGGCAAGAGGCAGATGAAGGTCAGCAATCGCCACCTGGACTTCCTGCCGCCGGGGCTGCTCCTGTCTGCGTACCTGGAGCAGCGCAGCTGA'

