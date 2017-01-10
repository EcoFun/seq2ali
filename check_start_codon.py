#!/usr/bin/env python2

__author__ = "Ludovic Duvaux"
__maintainer__ = "Ludovic Duvaux"
__license__ = "GPL_v3"

from sys import argv, exit
from os.path import basename
from os import system
import re

files = argv[1:]

verbose = "false"

if verbose == "true":
    print files

for ff in files:
    # 1) get locus coordinate from hmmer file (BUSCO folder 'selected')
    f = basename(ff)
    print "\n#### Process sequence %s" % ff
    sel = open(ff)
    txt = sel.readlines()[1]
    stc = txt[0:3]
    print stc
    
    if stc != "ATG":
        print "WARNING: sequence %s does not start with a 'ATG' start codon" % f
    sel.close()
    
    
    
