==== purpose ====
get_seq_gmap is a collection of scripts allowing to retrieve a sequence 
from a genome using a reference sequence.
the main part of the work is performed using gmap utilities.

The main script is "getseq.sh". In short, this script:
- prepares the gmap dictionary of your genome of interest if needed
- performs a similarity research ('blast') of the your targeted gene on
    the genome of interest using gmap
- extracts the coordinates of the best hit [path (1)]
- gets the corresponding sequence
- merges exon sequences if several exons are present

The script "getallseq.sh" is a simple wrapper for "getseq.sh" allowing 
to loop over sequence targets and/or genomes.
=================

----------------
Input files
----------------
The pipeline require several input files:
- a text file giving the path of target sequence file(s) (1 file name per
    line)
- a text file giving the path of the genome file(s) to be screened for the 
target sequence(s) (1 file name per line)
- fasta file(s) of target sequence(s) **(one target per fasta file!)**
- fasta file(s) of screened genome(s) (all the contigs can be in the same
    file)


----------------
Dependencies:
----------------
**All the dependencies need to be in the PATH**
________________________________________________
Programs & scripts:
- gmap (version 2015-09-29) - may work with more recent or older versions
    that share the same result file format.
- gmap_build
- get-genome
- getseq.sh
    - split_fasta.jl
    - getmatchposition_gmap.jl
    - merge_exons.jl

language:
- julia version: 0.4.5. As the julia scripts are rather simple, they may 
work with an older version of Julia but I cannot guarantee.
