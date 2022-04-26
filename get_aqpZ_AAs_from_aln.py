#!/usr/bin/env python3

'''

get_aqpZ_AAs_from_aln.py

usage: get_aqpZ_AAs_from_aln.py in.fasta

extracts aln columns corresponding to certain residues of interest from a reference protein (E coli aqpZ)

Iker Irisarri 2022, University of Goettingen

# alternative idea to generalize script: treat aln as matrix and extract columns of 
interest with numpy; could also automate reading positions from file

# Bio.Align functions explained: https://biopython.org/docs/1.75/api/Bio.Align.html

'''

from Bio import AlignIO
import Bio.Align
import sys
import pprint
import pdb

infile1 = sys.argv[1] # sitelh file

alignment = AlignIO.read(infile1, "fasta")


#print(type(alignment)) #<class 'Bio.Align.MultipleSeqAlignment'>
#print(alignment) # print summary of alignment

# basic stats
#len(alignment) # get number of sequences 
#alignment.get_alignment_length() # get aln length

# we can extract aln columns as strings (e.g., for position 0)
#print(alignment[:, 0])

# residues of interest in the reference sequence as ( "location": "AA" )
dict_residues = {8: "E", 43: "F", 58: "S", 59: "G", 63: "N", 64: "P", 65: "A",
88: "Q", 91: "G", 103: "I", 174: "H", 182: "N", 183: "T", 186: "N", 187: "P",
188: "A", 189: "R", 190: "S", 194: "A", 208: "F", 209: "W", 212: "P", 215: "G"}


# get aln slices corresponding to the residues of interest
# according to E. coli AQPZ

ref_aqpz = list()
aln_counter = int("0")
seq_counter = int("0")
aln_indices = list()

# get aqpz sequence (aligned)
for record in alignment:

	# get AQPZ
	if record.id == "AQPZ_ECOLI":
	
		#print(record.id)
		#print(record.seq)

		# save string into a list
		ref_aqpz = record.seq
		break

# traverse the alignment and get index in alignment and sequence
for i in ref_aqpz:

	if i == "-":
		aln_counter += 1
		continue
	else:
		#print(i)
		aln_counter += 1
		seq_counter += 1
		
	#print(i, aln_counter, seq_counter)
	
	# see if a seq_counter index is among the residues of interest
	if seq_counter in dict_residues:
	
#		pdb.set_trace()
		#print(i, aln_counter, seq_counter)
		# save alignment indices corresponding to the seq indices of interest
		# substract 1 because alignment slices are 0-based
		aln_indices.append(int(aln_counter - 1))
	
#pprint.pprint(aln_indices)

# get slices of interest (hard coded)
aln_slices = alignment[:, aln_indices[0]:aln_indices[0]+1] \
 + alignment[:, aln_indices[1]:aln_indices[1]+1] \
 + alignment[:, aln_indices[2]:aln_indices[2]+1] \
 + alignment[:, aln_indices[3]:aln_indices[3]+1] \
 + alignment[:, aln_indices[4]:aln_indices[4]+1] \
 + alignment[:, aln_indices[5]:aln_indices[5]+1] \
 + alignment[:, aln_indices[6]:aln_indices[6]+1] \
 + alignment[:, aln_indices[7]:aln_indices[7]+1] \
 + alignment[:, aln_indices[8]:aln_indices[8]+1] \
 + alignment[:, aln_indices[9]:aln_indices[9]+1] \
 + alignment[:, aln_indices[10]:aln_indices[10]+1] \
 + alignment[:, aln_indices[11]:aln_indices[11]+1] \
 + alignment[:, aln_indices[12]:aln_indices[12]+1] \
 + alignment[:, aln_indices[13]:aln_indices[13]+1] \
 + alignment[:, aln_indices[14]:aln_indices[14]+1] \
 + alignment[:, aln_indices[15]:aln_indices[15]+1] \
 + alignment[:, aln_indices[16]:aln_indices[16]+1] \
 + alignment[:, aln_indices[17]:aln_indices[17]+1] \
 + alignment[:, aln_indices[18]:aln_indices[18]+1] \
 + alignment[:, aln_indices[19]:aln_indices[19]+1] \
 + alignment[:, aln_indices[20]:aln_indices[20]+1] \
 + alignment[:, aln_indices[21]:aln_indices[21]+1] \
 + alignment[:, aln_indices[22]:aln_indices[22]+1]

#print(aln_slices)

# write alignment slices
AlignIO.write(aln_slices, infile1 + ".RESIDUES.fa", "fasta")

print("Outfile written! input.RESIDUES.fa", file=sys.stderr)



'''
# DISCONTINUED
# aln slices can't be added on a simple loop

#print(alignment[:, 495:496])

aln_slice = Bio.Align.MultipleSeqAlignment([])
aln_slices = Bio.Align.MultipleSeqAlignment([])

for ind in aln_indices:

	#print(ind)
	#get corresponding slice
	if aln_slices == '':
		aln_slices = alignment[:, int(ind):int(ind+1)]
	else:
		aln_slices = aln_slices + alignment[:, int(ind):int(ind+1)]
	
#print(aln_slices)
AlignIO.write(aln_slices, infile1 + ".RESIDUES.fa", "fasta") 

	#aln_slices = aln_slices + aln_slice
	
#	 + alignment[:, :10]
#print(aln_slices)
'''

