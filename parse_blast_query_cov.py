#!/usr/bin/env python3

import sys
import pprint
from Bio import SeqIO


'''

BLAST parser that filters by % query coverage


INPUT:

1) BLAST outfmt6 (qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore)
2) QUERY fasta (to obtain query length)
3) coverage 0-1 (proportion of query covered by aln)


'''

fh = open(sys.argv[1], 'r') # input file
query_file = sys.argv[2] # query file (fasta format)
coverage = float(sys.argv[3]) # coverage threshold (0-1)

query_lengths = dict()
hits = list()

# read query file and store lengths
for record in SeqIO.parse(query_file, "fasta"):

	query_lengths[record.id] = len(record.seq)

#pprint.pprint(query_lengths)

# parse blast outfmt6 and filter by query coverage
for line in fh:

	query, hit, pident, length, mismatch, gapopen, qstart, qend, hitstart, hitend, evalue, bitscore = line.strip().split('\t')
	
	#print(query, hit, length, query_lengths[query])
	#print("length: ", length, "query: ", query_lengths[query], "coverage: ", coverage, (coverage * query_lengths[query]))
	
	if int(length) >= ( coverage * query_lengths[query]):
	
		# prints entire line of output
		#print(line)
		
		# get only hit names (make unique)
		hits.append(hit)

# get unique hits
for s in set(hits): # set() convert list to set gets automatically unique values

	print(s)
			
	
