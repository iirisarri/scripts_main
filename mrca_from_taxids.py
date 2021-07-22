##!/usr/bin/env python3

'''

mrca_from_taxids.py

Iker Irisarri, Jul 2021
University of Goettingen

usage python3 mrca_from_taxids.py

INPUT: file containing multiple NCBI taxids
OUTPUT: MRCA of all taxids in the set

'''

import pdb
import sys
import re
from ete3 import NCBITaxa
import pprint
import pandas as pd
import numpy as np


######################################

### CUSTOM FUNCTIONS ###

# function to make list elements unique
def list2unique(list1):
    list_set = set(list1) # convert list into set (makes values unique)
    unique_list = (list(list_set)) # convert set to list
    #for x in unique_list:
    #    print(x)
    return(unique_list)

# function to identify mrca from NCBI taxonomy
def find_mrca(dict1):
    # find the lowest rank that is common to all taxids
    df = pd.DataFrame({ key:pd.Series(value) for key, value in dict1.items() }).transpose() # create dataframe
    #pprint.pprint(df)                                                                                            
    common_ranks = list() # initialise list                                                                                                               
    # get unique values in column                                                                                                
    for column in df:
        unique = df[column].unique()
        #print(unique)
        if len(unique) == 1:
            common_ranks.append(unique)
        else:
            break # exist loop when >1 elements for a given rank
    # print last common rank for all taxids                                                                                                     
    return(common_ranks.pop())

#############################

ncbi = NCBITaxa()
#ncbi.update_taxonomy_database()

input = sys.argv[1] # list of ncbi taxids 

# declare dictionaries to save info
cellular_organisms = dict()
viruses = dict()
other = dict()

# process input file
with open (input, 'r') as fh:

    taxids = fh.read().splitlines() # returns a list

    taxids = list2unique(taxids)

    for taxid in taxids:

        # get taxonomic lineage of a given taxid
        lineage = ncbi.get_lineage(taxid) # returns a list

        # lineage lists don't always have the same length for all species (intermediate ranks are not always defined)
        # when converting to data frames empty values need to be filled with NaN

        names = ncbi.get_taxid_translator(lineage) # returns dictionary with taxids as keys and names as values
        name_list = [names[taxid] for taxid in lineage]
        #print(name_list)
        key = "-".join(name_list)
        if name_list[1] == 'cellular organisms':
             cellular_organisms[key] = name_list
             continue
        if name_list[1] == 'Viruses':
            viruses[key] = name_list
            continue
        else:
            other[key] = name_list

    # find mrca for each of the dictionaries by passing it to the function & print
    unique_cellular = find_mrca(cellular_organisms)
    print("MRCA cellular organisms: ", unique_cellular)
    # if viruses or other kinds of sequences are present, print MRCA/info
    if viruses:
        unique_viruses = find_mrca(viruses)
        print("MRCA viruses: ", unique_viruses)
    if other:
        print("Other sequences: ")
        for o in other:
            print(other[o])

