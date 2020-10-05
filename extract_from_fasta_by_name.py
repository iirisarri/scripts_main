#!/usr/bin/env python3

'''
source: https://bioinformatics.stackexchange.com/questions/3931/remove-delete-sequences-by-id-from-multifasta

extracts sequences that are present in query file

usage: extract_from_fasta_by_names.py input.fasta list_of_scf_to_filter > filtered.fasta

'''

from Bio import SeqIO
import sys

ffile = SeqIO.parse(sys.argv[1], "fasta")
header_set = set(line.strip() for line in open(sys.argv[2]))

for seq_record in ffile:
    try:
        header_set.remove(seq_record.name)
        print(seq_record.format("fasta"))
    except KeyError:
        continue
if len(header_set) != 0:
    print(len(header_set),'of the headers from list were not identified in the input fasta file.', file=sys.stderr)
