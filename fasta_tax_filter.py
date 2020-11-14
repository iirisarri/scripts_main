#!/usr/bin/env python3

from Bio import SeqIO
import sys
import pdb
import pprint

'''

Taxonomic filter for fasta files.

USAGE: fasta_tax_filter.py infile.fa tax_filt.txt

Filter requires the presence of one taxa per line in the taxonomic filter file.
Taxa must be separated by a space and annotations might be done after "#"

Taxon presence is assessed by the presence of keywords (in taxonomic filter file)
in the headers of the input fasta.

Example of taxonomic filter file:
    /////
    Amborella Oryza Arabidopsis # angiosperms
    Gnetum
    Physcomitrium Sellaginella
    Marchantia
    Chlamydomonas
    /////

'''

infile1 = sys.argv[1] # fasta file
infile2 = sys.argv[2] # taxonomic filter file (see format above)

# declare
headers = dict() # saves headers from input fasta
species_in_lines = dict() # stores taxa keywords and line numbers
lineage_found = [] # list saves line_number for each species found in fasta
line_number = int('0') # initalizes line numbers

#pdb.set_trace()

# get all fasta headers
for sequence in SeqIO.parse(infile1, "fasta"):

    headers[sequence.id] = '1'
#pprint.pprint(headers)

# get taxonomic filter
with open(infile2) as taxfilt:

    for line in taxfilt:

        line_number += 1

        line = line.rstrip()

        # save species in this line
        # skip possible annotations
        if '#' in line:
            (line, annotations) = line.split('#')
        species = line.split(' ')

        # store individual species per line
        species = list(filter(None, species)) # remove empty strings if any

        # save line number for each species
        for sp in species:
            species_in_lines[sp] = line_number

    #pprint.pprint(species_in_lines)


# find taxa in headers & save line number of that species in taxonomic filter
for taxa in species_in_lines:
    #print(taxa)

    for header in headers:
        #print(header)

        # search substring in header
        # this will only record the species presence
        # because loop breaks after first match
        if taxa in header:

            #print(taxa, "\t", header)
            lineage_found.append(species_in_lines[taxa]) # dict value returns line_number
            break

#pprint.pprint(lineage_found)

# check if all required lineages are found
# i.e. if lineage_found contains all line numbers
lineage_set = set(lineage_found) # make list values unique by converting to a set

if len(lineage_set) == line_number:

    print("Taxonomic filter passed:\t", infile1)

else:
    print("Taxnomic filter failed:\t", infile1)



'''
Dataset examples:

headers:        {'Amborella_evm_27.model.AmTr_v1.0_scaffold00012.86': '1',
                 'Amborella_evm_27.model.AmTr_v1.0_scaffold00025.270': '1',
                 'Amborella_evm_27.model.AmTr_v1.0_scaffold03839.1': '1',
                 'Arabidopsis_AT5G35400.2': '1',
                 'Arabidopsis_ATMG00860.1': '1',
                 'Chara_GBG41013.1': '1',
                 'Chara_GBG41395.1': '1',
                 'Chara_GBG41400.1': '1'}

species_in_lines: {'Amborella': 1,
                 'Arabidopsis': 2,
                 'Chlamydomonas': 7,
                 'Chlorella': 8,
                 'Micromonas': 10,
                 'Oryza': 1,
                 'Ostreococcus': 11,
                 'Physcomitrium': 5,
                 'Sellaginella': 6,
                 'Ulva': 12}

lineage_found:   [1,
                 1,
                 2,
                 3,
                 4,
                 5,
                 6]

'''
