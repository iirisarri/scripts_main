#!/usr/bin/perl

use strict;
use warnings;
use Bio::TreeIO;
use Data::Dumper;

# parse_tree_check_monophyly.pl
# Iker Irisarri, University of Konstanz 2014
# Intended to be run in a for loop (bash) to test multiple trees (in individual files)
# requires (1) one tree; (2) file with taxa for which we want to test for monophyly (allows comments with #)
# Prints file name and checks if all the taxa in file $clade are really present in the tree and remove missing taxa accordingly
# This allows running the script for a bunch of trees that might have a slightly different taxon sampling

my $usage = "parse_trees_check_monophyly.pl tree monophyly_file outgroup> stdout\n";
my $in_tree = $ARGV[0] or die $usage;
my $clade = $ARGV[1] or die $usage;
my $outgroup = $ARGV[2] or die $usage;


# get taxa from $clade file

open (IN, "<", $clade) or die "Cannot open file $clade: $!\n";

my @clade;
my @clade2;
my @test_taxa;

while ( my $line = <IN> ) {
    chomp $line;
    next if ( $line =~ /^#.+/ );
    push (@clade, $line);
}


# print file name to output
print "File: ", $in_tree, "\n";


# read tree, root on outgroup and test monophyly

my $treeio = new Bio::TreeIO(-file   => "$in_tree",
			     -format => "newick");

while( my $tree = $treeio->next_tree ) {

    # store taxa into a hash where keys are taxa names
    my %leaves = %{ &get_all_leaves($tree->get_root_node) };

    foreach my $key (keys %leaves) {
	#print "$key\n";
        # (re)root tree 
	if (!exists $leaves{$outgroup} ) {
	    print "Error: cannot find $outgroup in the tree!\n";
	}
	if ( $key eq $outgroup ) {
	    my $root = $tree->find_node( -id => $key );
	    $tree->reroot( $root );
	}

    # remove taxa from @clade if not present in this particular tree 
	foreach my $taxa (@clade) {
	    if ( !exists $leaves{$taxa} ) {
		# print join ("--", @clade), "\n\n";
		# modify @clade to remove $taxa not present in the current tree
		@clade = grep {$_ ne $taxa} @clade;
		# print join ("--", @clade), "\n\n";
	    }
	}
    }    

    # need to find the nodes for taxa in the monophyly test & outgroup!
    # find node for taxa
    foreach my $i (@clade) {
	my $node = $tree->find_node(-id => $i);
	# $node is a Bio::Tree::Node object
	push (@test_taxa, $node);
    }
    # find node for outgroup
    my $outg_node = $tree->find_node(-id => $outgroup);

    # monophyly test
    # checks if the mrca of all the members of @clade is more recent than the mrca of any of them with the outgroup
    # change to this line for paraphyly test
    # note that the paraphyly test will also return true even if the taxa being tested do not branch consecutively
    # (e.g. a, c, d will be paraphylyletic in the following tree: (out,(a,(b,(c,d))))
    # if ( $tree->is_paraphyletic( -nodes => \@test_taxa,

    if ( $tree->is_monophyletic( -nodes => \@test_taxa,
				 -outgroup => $outg_node ) ) {
	print "\tMonophyly of the following taxa in $clade:\n\t";
	print join (" ", @clade), "\n";
    }
    else {
	print "\tTaxa are not monophyletic :-(\n";
    }
}



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
