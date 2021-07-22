##!/usr/bin/env python3

'''

given a list of ncbi taxids, obtain their taxonomic lineage (here truncated to first 3 ranks)

Iker Irisarri, Jul 2021
University of Goettingen

'''


import sys
import re
from ete3 import NCBITaxa


ncbi = NCBITaxa()
#ncbi.update_taxonomy_database()

input = sys.argv[1] # list of ncbi taxids

with open (input, 'r') as fh:

    taxids = fh.read().splitlines() # returns a list

    for taxid in taxids:

        # get taxonomic lineage of a given taxid
        lineage = ncbi.get_lineage(taxid) # returns a list

        # select the first 4 ranks excluding 'root' 0
        lineage = lineage[1:4]

        # get names of taxids
        names = ncbi.get_taxid_translator(lineage) # returns a dictionary with taxids as keys and names as values

        print('\t'.join([names[taxid] for taxid in lineage]))

