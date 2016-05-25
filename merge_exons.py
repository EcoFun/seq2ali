#!/bin/env python2
from sys import argv

inp = argv[1]
hea = argv[2]
out = argv[3]

o = open(out, "w")
print "# Write file %s" % out

i = 0
with open(inp) as f:
    for l in f:
        if l[0] != '>':
            o.write(l.strip())
        elif i == 0:
            o.write(hea + "\n")
            i = 1

o.write('\n')
f.close()
o.close()
