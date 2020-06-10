#!/usr/bin/env python3
import sys
import pprint
import numpy as np

'''

# save blastp by line into dict, splitting by tab
# filter by evalue
#save into dict (sorted query-hit)=rest

# reach my blast1:
# find query-hit pairs in blast2
# do they overlap > threshold?
# print out

# qseqid				sseqid					pident	mismatch	gapopen	qstart	qend	sstart	send	evalue	bitscore	qcovs	qcovhsp	qlen	slen	length
# GPAL|GPLIN_000000100  GROS|GROS_g13706.t1     55.77   41      	3       81      184     3       101     2e-18   77.4    	55      55      190     108     104
# GPAL|GPLIN_000001400  GROS|GROS_g06997.t1     73.58   20      	5       1       304     1       386     0.0     546   		100     100     304     386     386
# qcovs 	= percent query length covered by subject
# qcovhsp 	= percent query length covered by this HSP

'''



infile1 = sys.argv[1]
infile2 = sys.argv[2]
evalue_treshold  = float('1e-6')

def parse_blast_report(infile):

    blast_report = {}

    with open(infile,"r") as file_object:

        for line in file_object:
            line = line.rstrip()
            lines  = line.split('\t')

            query_hit = list()
            query_hit.append(lines[0])
            query_hit.append(lines[1])
            query_hit = '-'.join(sorted(query_hit))
            evalue = float(lines[9])

            #filter by evalue threshold
            if evalue <= evalue_treshold:

                # if key in dict exists, append to dictionaries
                # otherwise simply save it
                if query_hit in blast_report:

                    records = len(blast_report[query_hit])
                    new_record = records + 1
                    blast_report[query_hit][new_record] = {}        # declare dict at different levels
                    blast_report[query_hit][new_record] = lines

                else:
                    blast_report[query_hit] = {}                    # declare dict at different levels
                    blast_report[query_hit]['1'] = {}               # declare dict at different levels
                    blast_report[query_hit]['1'] = lines

        return(blast_report) # dictionary of dictionaries of lists

# process blast
blast1 = parse_blast_report(infile1)
blast2 = parse_blast_report(infile2)
#pprint.pprint(blast1)

# find overlapping RBBH

# loop through all the records in blast1 and find overlapping records in blast2
for q_h in blast1:

    # get values from blast1
    for n in blast1[q_h]:

        #qseqid1 = blast1[q_h][n][0]
        #sseqid1 = blast1[q_h][n][1]
        qstart1 = int(blast1[q_h][n][5])
        qend1 = int(blast1[q_h][n][6])
        sstart1 = int(blast1[q_h][n][7])
        send1 = int(blast1[q_h][n][8])
        #evalue1 = float(blast1[q_h][n][9])
        #print(qseqid, sseqid)
        # sort coordinates so we can call range(); it requires start < end
        qcoord1 = sorted([qstart1, qend1]) # sort coordinates for range()
        scoord1 = sorted([sstart1, send1])
        qrange1  = set(range(qcoord1[0], qcoord1[1])) # save as set, not range
        srange1  = set(range(scoord1[0], scoord1[1]))

        # does it overlap with any record with same query_hit iin blast2?
        for m in blast2[q_h]:

            #qseqid2 = blast2[q_h][m][0]
            #sseqid2 = blast2[q_h][m][1]
            qstart2 = int(blast2[q_h][m][5])
            qend2 = int(blast2[q_h][m][6])
            sstart2 = int(blast2[q_h][m][7])
            send2 = int(blast2[q_h][m][8])
            #evalue2 = float(blast2[q_h][m][9])

            qcoord2 = sorted([qstart2, qend2]) # sort coordinates for range()
            scoord2 = sorted([sstart2, send2])
            qrange2  = set(range(qcoord2[0], qcoord2[1])) # save as set, not range
            srange2  = set(range(scoord2[0], scoord2[1]))

            if qrange1 & srange2 and qrange2 & srange1:

                # PRINT ALL PAIRS OF RBBH RECORDS
                #print('\nRBBH pair:')
                #print(blast1[q_h][n])
                #print(blast2[q_h][m])

                # PRINT RBBH AS COORDINATES FOR SHINYCIRCOS
                #only blast1 record is printed (blast2 record is redundant)
                array=np.array(blast1[q_h][n])          # create numpy array to extract multiple elems at once
                elem_to_print = [0,5,6,1,7,8]           # indices: qseqid qstart qend sseqid sstart send
                print(','.join(array[elem_to_print]))

                # REGULAR TAB-DELIM PRINT
                # array=np.array(blast1[q_h][n])          # create numpy array to extract multiple elems at once
                # elem_to_print = [0,1,5,6,7,8,9]           # indices: qseqid qstart qend sseqid sstart send
                # print(','.join(array[elem_to_print]))
