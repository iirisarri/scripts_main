#!/usr/bin/env python3

'''

filters blast output by alignment length; required to be a given proportion (def=75%) of the original query length

usage: blast_filter_by_query_length.py blast.outfmt6 queries.fasta > blast.outfmt6.hits

Iker Irisarri 2022, University of Goettingen

'''

from Bio import SeqIO
import sys
import pprint

infile1 = sys.argv[1] # blast output (tabular format outfmt6)
infile2 = sys.argv[2] # queries (fasta)

# declare
aln_len_prop = int("0.75") # how much of the query length should be covered by the alignment?
query_lengths = dict() # saves queries from input fasta

#pdb.set_trace()

# read queries & save lengths
for sequence in SeqIO.parse(infile2, "fasta"):

    query_lengths[sequence.id] = len(sequence)
    
#pprint.pprint(queries)

# read blast output & filter by % alignment length

with open(infile1) as blast_out:

	for line in blast_out:

		line = line.rstrip()
		lines = line.split('\t')
		query = lines[0] # query
		hit = lines[1] # hit
		aln_len = int(lines[3]) # alignment length
		
		#print(query, hit, aln_len, query_lengths[query])

		if aln_len >= (aln_len_prop * query_lengths[query]):
		
			#print(query, hit, aln_len, query_lengths[query])
			print(hit)
    	
