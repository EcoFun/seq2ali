Purpose 
====
`ali2seq` is a collection of scripts allowing to retrieve a sequence 
from a genome using a reference sequence.
The main part of the work is performed using gmap utilities.

The main script is `getallseq.sh` which is a wrapper for `getseq.sh` allowing 
to loop over sequence targets and/or genomes.

The `getseq.sh` script allow to:

- prepares the gmap dictionary of your genome of interest if needed
- performs a similarity research of one targeted sequence on
    one genome of interest using `gmap`
- extracts the coordinates of the best hit [`path (1)`]
- gets the corresponding sequence
- merges sequences if initial sequence is a concatenation (e.g. a cds may
    return several exons)


----------------
Input files
----------------
The pipeline requires several input files:

- a text file giving the **absolute** path of target sequence file(s) (1 file name per
    line)
- a text file giving the **absolute** path of the genome file(s) to be screened for the 
target sequence(s) (1 file name per line)
- fasta file(s) of target sequence(s) **(one target per fasta file!)**
- fasta file(s) of screened genome(s) (all the contigs can be in the same
    file)


----------------
Dependencies:
----------------
**All the dependencies need to be in the PATH**

Programs & scripts:

- gmap (version 2015-09-29) - may work with more recent or older versions
    that share the same result file format.
- gmap_build
- get-genome

language:
- python2.7
