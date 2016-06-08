#!/bin/env bash

### usage:
# getseq.sh fgeno ftarg gmapd

## parameter definition
# genome assembly to fetch the sequence from (only one!)
fgeno=$1

# target sequence (only one!)
ftarg=$2

# folder of gmap dictionaries (only one!)
gmapd=$3

outdir=$4   # root of the output directory (needed for getallseq.sh)

if [ -z "$outdir" ]; then
    outdir="./results"
fi

##### script
##### no variable definition beyond this point 

# fetch sequence for each sample
# set IDs

#~echo "getseq.sh: fgeno is '$fgeno'"
#~gID=`basename ${fgeno%.f[as]?(s)?(t)?(a)}`    # genome ID -> doesn't work by calling the script but works directly in the shell, I don't know why...
gID=`basename ${fgeno%.f[as]*}`    # genome ID
#~echo $gID
#~echo ""

#~echo "getseq.sh: ftarg is '$ftarg'"
#~tID=`basename ${ftarg%.f[as]?(s)?(t)?(a)}`  # target ID -> doesn't work by calling the script but works directly in the shell, I don't know why...
tID=`basename ${ftarg%.f[as]*}`  # target ID
#~echo $tID
#~echo ""

echo "############### Fetching sequence of $tID from $gID ###############"
date


# set output folders
root=$outdir/$tID/$gID
mkdir -p $root/


###### 1) build gmap dictionary if needed
gmapdb_dum=$gmapd/$gID/$gID.salcpchilddc
echo "$gmapdb_dum"
if [ ! -f "$gmapdb_dum" ]; then
    printf "###### 1) Prepare gmap database for $gID\n."
    echo "gmap_build -d $gID $fgeno &> $root/buildGmapGenome.$gID.log"
    if [ ! -d "$gmapd/build_logs/" ]; then
        mkdir -p $gmapd/build_logs/
        echo "mkdir -p $gmapd/build_logs/"
    fi
    gmap_build_log=$gmapd/build_logs/buildGmapGenome.$gID.log
    gmap_build -d $gID $fgeno &> $gmap_build_log
    gzip -fv $gmap_build_log
else
    printf "###### 1) Pass preparation of gmap database for $gID (already set)\n\n"
fi

###### 2) blast
# the gmap*gz is the last thing performed, so if present the dummy as well
    # so no need to check its presence
gres=$root/gmap.$tID.$gID.txt
gdum=$root/gmap.$tID.$gID.dummy
if [ -f "$gdum" ]; then
    echo ""
    echo "###### 2) Skip Blast (gmap) for $tID on $gID (already done)"
    echo ""
        # gunzip gmap gz if present
        if [ -f $gres.gz ]; then
            echo "WARNNING: $gres is already present from a previous analysis"
            echo "          Did you forced genome re-processing?"
            echo "          gunzip $gres"
            gunzip $gres.gz
        fi
else
    echo ""
    echo "###### 2) Blast (gmap) $tID on $gID"
    echo "gmap -d $gID -A $ftarg &> $gres"
    gmap -d $gID -A $ftarg &> $gres
    touch $gdum
    echo ""
fi

###### 3) extract positions of the match from gmap results
### 3.1) count n paths (do it in any case)
echo ""
echo "###### 3) Extract sequence of $tID for $gID"
echo "### 3.1) Check number of paths found"
Np=`grep "Paths (" $gres | cut -d '(' -f 2| cut -d ')' -f 1`
echo "Gmap found $Np paths"
echo ""

### 3.2) extract path (1) [do it in any case]
echo "### 3.2) Extract coordinates and sequence of path (1) for $gID"
if [ "$Np" -eq "0" ]; then
    echo ""
    echo "  @@@@@ WARNING: No match was found for $tID on ${gID}!"
    printf "      @ Analysis stopped\n\n"
else
    if [ "$Np" -gt "1" ]; then
        echo ""
        echo "  @@@@@ WARNING: There is $Np paths for $tID on $gID:"
        printf "      @ Path 1 has been used\n\n" 
    fi
    
    # actual step performing:
        # i) coordinate extraction
        # ii) sequence fetching (get-genome)
            # set fasta file names
    rootID=$root/$gID.$tID
    mesta=$rootID.fasta
    finf=$rootID.CatEx.fasta

    echo "getmatchposition_gmap.py $gres $gID $rootID"
    Nex=`getmatchposition_gmap.py $gres $gID $rootID` # Nex is number of exons
    echo ""
    echo "Gmap found $Nex exons"
    echo ""
    ###### 4) merge all exons files if several exons
    if [ -f $rootID.1.fasta ]; then
        echo "### 3.3) Merge all exons sequences"
        echo "  # Files are present, let's merge them"
        echo "cat $rootID.[0-9]*.fasta > $mesta"
        cat $rootID.[0-9]*.fasta > $mesta
        rm  $rootID.[0-9]*.fasta
        echo ""
        
        # merge exon sequence
            # absolutely redo if the gz does not exist! as it can be wrong
        
        echo ""
        echo "###### 4) Merge exon sequences of $gID.fasta"
        echo "merge_exons.py $mesta '> ${gID}$tID.CatEx' $finf"
        merge_exons.py $mesta "> ${gID}$tID.CatEx" $finf # CatEx
    else
        echo ""
        echo "  @@@@@ WARNING: gmap exon files does not exist while #paths > 0"
        echo "      @  i. merging already done!"
        echo "      @  ii. OR gmap dictionary does not exist!"
    fi
    # gzip the fasta files if present
    echo ""
    echo "# Gzip fasta files"
    gzip -fv $mesta    # don't do that before nor after
    gzip -fv $finf
fi

# very last step, gzip the gmap file (always present)
printf "\n# Gzip gmap file\n"
gzip -fv $gres
echo "############### Fetching sequence of $tID from $gID complete! ###############"
