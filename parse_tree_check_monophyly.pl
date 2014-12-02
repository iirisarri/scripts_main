#!/usr/bin/perl

use strict;
use warnings;
use Bio::TreeIO;
use Data::Dumper;

# parse_tree_check_monophyly.pl
# Iker Irisarri, University of Konstanz 2014
# Intended to be run in a for loop (bash) to test multiple trees (in individual files)
# possibility to run also a single file with multiple trees (check options bellow for tracking trees)
# requires (1) one tree; (2) file with taxa for which we want to test for monophyly (allows comments with #)
# Prints file name and checks if all the taxa in file $clade are really present in the tree and remove missing taxa accordingly
# This allows running the script for a bunch of trees that might have a slightly different taxon sampling

                            ###############
############################# IMPORTANT!! ###############################
                            ###############

# is_monophyletic in TreeIO module is broken for some reason (J. Stajich G. Jordan)!
# original code for is_monophyletic is commented out (with label ## original code for is_monophyletic ##)
# I implemented new monophyly test by comparing sorted arrays of 
# (1) species to be tested and (2) all descendent leaves from the mrca
# suggested by J. Stajich
# note that monophyly requires that only the species being tested are descendents of their mrca!

#########################################################################

my $usage = "parse_trees_check_monophyly.pl tree monophyly_file outgroup> stdout\n";
my $in_tree = $ARGV[0] or die $usage;
my $clade = $ARGV[1] or die $usage;
my $outgroup = $ARGV[2] or die $usage;
my $outfile = "output";

# get taxa from $clade file

open (IN, "<", $clade) or die "Cannot open file $clade: $!\n";
open (OUT, ">", $outfile) or die "Cannot create output file: $!\n";

my $tree_num = 0;
my $tax_num = 0;
my @clade;
my @clade2;
my @test_taxa;
my @lca_desc;
my @sorted_clade2;
my @sorted_lca_descend;

while ( my $line = <IN> ) {
    chomp $line;
    next if ( $line =~ /^#.+/ );
    push (@clade, $line);
}

close(IN);

# print file name to output
print "File: ", $in_tree, "\n";


# read in trees
my $treeio = new Bio::TreeIO(-file   => "$in_tree",
			     -format => "newick");

# originally intended to print out trees not passing monophyly test
# removed function from script
#my $out = new Bio::TreeIO(-file   => ">outfile",
#                          -format => "newick");

while( my $tree = $treeio->next_tree ) {

    # initialize matrices & counts for every tree (if multiple trees in one file)
    # reasign taxa for monophyly test to @clade2
    @clade2 = @clade;
    @test_taxa = ();
    $tax_num = 0;

    # track tree number if multiple trees are stored in a single file
    $tree_num++;
    if ( $tree_num > 1) {
	print "Tree number $tree_num\n";
    }

    # store taxa into a hash where keys are taxa names
    my %leaves = %{ &get_all_leaves($tree->get_root_node) };

    # remove taxa from @clade2 if not present in this particular tree
   foreach my $taxa (@clade2) {
	if ( !exists $leaves{$taxa} ) {
            # print join ("--", @clade), "\n\n";
            # remove $taxa not present in the current tree
	    @clade2 = grep {$_ ne $taxa} @clade2;
            # print join ("--", @clade), "\n\n";                
	}
    }

    foreach my $key (keys %leaves) {
	#print "$key\n";

        # (re)root tree 
	if (!exists $leaves{$outgroup} ) {
	    print "\tError: cannot find $outgroup in the tree!\n";
	    # exit foreach loop after error
	    exit;
	}
	if ( $key eq $outgroup ) {
	    my $root = $tree->find_node( -id => $key );
	    $tree->reroot( $root );
	}
    }    

    

    # 1st, check that we have at least 2 taxa in @clade
    # 2nd, need to find the nodes for taxa in the monophyly test & outgroup!
    # find node for taxa 
    $tax_num = scalar @clade2;
    if ( $tax_num < 2 ) {
	print "\tAt least two taxa are required for testing monophyly and only $tax_num is present\n\n";
    }
    else {

	foreach my $i (@clade2) {
	    my $node = $tree->find_node(-id => $i);
	    # $node is a Bio::Tree::Node object
	    push (@test_taxa, $node);
	}


### Custom monophyly test ###

	# get the mrca of species for which we want to test monophyly
	# function returns a NodeI object
	my $lca = $tree->get_lca(-nodes => \@test_taxa);

	# get all descendents from that mrca
	my @lca_desc_obj = $lca->get_all_Descendents();
	
	# store all descendent leaves into an array
	my @lca_descend;

	foreach my $desc ( @lca_desc_obj ) {
	    if ( $desc->is_Leaf ) {
		# get leaf id (actual taxa name) and store it
		my $leaf = $desc->id();
		push ( @lca_descend, $leaf);
	    }
	}

	# sort both arrays
	@sorted_clade2 = sort (@clade2);
	@sorted_lca_descend = sort (@lca_descend);
	
	# compare sorted arrays
	if (@sorted_clade2 == @sorted_lca_descend){
	    print "\tMonophyly of the following taxa:\n\t";
	    print join (" ", @sorted_clade2), "\n";
	}
	else {
	    print "\tTaxa are not monophyletic :-(\n\n";
#	    $out->write_tree($tree);
	}

### End of monophyly test ###

## Original code for is_monophyletic ####
#	my $outg_node = $tree->find_node(-id => $outgroup);
#
#	# monophyly test
#	# checks if the mrca of all the members of @clade is more recent than the mrca of any of them with the outgroup
#	# change to this line for paraphyly test
#	# note that the paraphyly test will also return true even if the taxa being tested do not branch consecutively
#	# (e.g. a, c, d will be paraphylyletic in the following tree: (out,(a,(b,(c,d))))
#	# if ( $tree->is_paraphyletic( -nodes => \@test_taxa,
#
#	if ( $tree->is_monophyletic( -nodes => \@test_taxa,
#				     -outgroup => $outg_node ) ) {
#	    print "\tMonophyly of the following taxa in $clade:\n\t";
#	    print join (" ", @clade2), "\n";
#	}
#	else {
#	    print "\tTaxa are not monophyletic :-(\n";
#	    # print out trees not satisfying monophyly test to new file
#	    $out->write_tree($tree);
#	}
############################################
    }
}

close(OUT);

## SUBROUTINES ##

sub get_all_leaves {
    #Esta rutina devuelve todas las "hojas" descendientes de un nodo
    my $initial_node = $_[0];
    my %nodes;
    if( $initial_node->is_Leaf ) {
	$nodes{ $initial_node->id } = 1;
	return \%nodes;
    }
    foreach my $node ( $initial_node->get_all_Descendents() ) {
	if( $node->is_Leaf ) { 
	    # for example use below
	    $nodes{$node->id} = 1;
	}
    }
    return \%nodes;
}
