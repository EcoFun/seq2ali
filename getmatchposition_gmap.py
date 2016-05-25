#!/bin/env python2

# BEWARE: to work properly, the gmap analysis as to be done on one target only!
from re import search, sub, split
from os import system
from sys import argv, stderr

# parameters
fil = argv[1]   # gmap results
g = argv[2] # genome to fetch the sequence from
outpref = argv[3]  # prefix of output (full path but no extension)

# load gmap results all at once
f = open(fil)
txt = f.readlines()
f.close()

# check number of exons
Nex = filter(lambda x:search('    Number of exons:', x), txt)[0]
Nex = int(Nex.split()[-1])

# loop on all exons
for i in range (Nex):
    # get coordinates
    l = [j for j, item in enumerate(txt) if search('  Alignment for path 1:', item)][0]
    lc = l + 1 + (i + 1)

    # remove leading strand sign
    lt = sub(r"^[+-]", "", (txt[lc]).strip())
    chr, coor = split(r"[ :]", lt)[0:2]
    sta, sto = split('-', coor.strip())[0:2]

    # run get-genome
    cmd = "get-genome -d %s %s:%s-%s > %s.%s.fasta\n" % (g, chr,
        sta, sto, outpref, i+1)
    stderr.write("  # Fetch exon %s sequence for genome %s\n" % (i+1, g))
    stderr.write(cmd)
    system(cmd)

print Nex
