#!/bin/env bash

### usage:
usage="Usage:
$(basename "$0") [-hfoz] -g genome_file.txt -t target_file.txt -d gmap_directory

Wrapper allowing batch of getseq analyses: Takes a list of fasta files for 
    target loci and retrieve corresponding sequences from a list of genomes.

Options:
    -d, --gmap-dir          directory containing gmap genome databases
                            (only one)
    -f                      force locus/target processing (needed to analyse
                            new genomes) [false]
    -F                      force genome processing (force locus/target processing
                            as well) [false]
    -g, --genome-list       file listing **absolute paths** of genome fasta
                            files to be searched into
    -o, --out-dir           global output directory containing all subdirectories
                            of target results. Will be created if not existing
                            [./results]
    -t, --target-list       file listing **absolute paths** of target fasta
                            files to search for (1 sequence per fasta file)
    -z                      compress directory of target results (tar.gz) [false]
    -h, --help              show this help text"

### print out passed command line
echo "Submitted command line:"
echo `basename $0` $*
echo ""

### command line options
# read the options
TEMP="$(getopt -o d:fFhg:o:t:z --long gmap-dir:,genome-list:,--out-dir:,target-list:,help -n 'getallseq.sh' -- "$@")"

#~echo $TEMP

# if invalid option, print usage and exit
if [ $? -ne 0 ] ; then  # $? is the status of the last I don't remember what
    echo ""
    echo "$usage"
    exit
fi

# extract options and their arguments into variables.
eval set -- "$TEMP"
#~unset TEMP

# set initial values for some parameters
force="false"
FORCE="false"
outdir="./results"
zip="false"
while true ; do
    case "$1" in
        -h|--help)
            echo "$usage"
            exit
            ;;
        -f)
            force="true"
            shift
            ;;
        -F)
            FORCE="true"
            shift
            ;;
        -d|--gmap-dir)
            case "$2" in
                "") shift 2 ;;
                *) gmapd=$2 ; shift 2 ;;
            esac ;;
        -g|--genome-list)
            case "$2" in
                "") shift 2 ;;
                *) fgenos=$2 ; shift 2 ;;
            esac ;;
        -o|--out-dir)
            case "$2" in
                "") shift 2 ;;
                *) outdir=./$2 ; shift 2 ;;
            esac ;;
        -t|--target-list)
            case "$2" in
                "") shift 2 ;;
                *) ftargs=$2 ; shift 2 ;;
            esac ;;
        -z)
            zip="true"
            shift
            ;;
        --) shift ; break ;;
        *) echo "Internal error!" 
        exit 1 ;;
    esac
done

# test if required parameters are specified
if [ -z "$gmapd" ] || [ ! -d "$gmapd" ]; then
    echo '@@@@@ ERROR: Please specify a correct gmap directory'
    echo ""
    echo "$usage"
    exit
elif [ -z "$fgenos"  ] || [ ! -f "$fgenos" ]; then
    echo '@@@@@ ERROR: Please specify a correct genome list'
    echo ""
    echo "$usage"
    exit
elif [ -z "$ftargs"  ] || [ ! -f "$ftargs" ]; then
    echo '@@@@@ ERROR: Please specify a correct target list'
    echo ""
    echo "$usage"
    exit
fi

echo "gmap-dir:                                     '$gmapd'"
echo "List file of genomes:                         '$fgenos'"
echo "List file of targets:                         '$ftargs'"
echo "Global output directory:                      '$outdir'"
echo "Compress subdirectories of target results?    '$zip'"
echo "Force analyse of processed targets?           '$force'"
echo ""

while read line1 ; do
    tID=`basename ${line1%.f[as]*}`
    # skip empty lines of input files (or there will be errors)
    if [ -z "$line1" ] ; then
        continue
    fi
    
    if [ ! -f "$line1" ]; then
        echo "################################"
        echo "WARNING: Pass locus $tID (does not exist!!!)"
        echo "################################"
        echo ""
        continue
    fi
    ftarg=$line1
    
    # check if an already compressed result exist and uncompress if so
    if [ -f $outdir/$tID.tar.gz ]; then
        #~echo "Untar previous result folder"
        tar -xf $outdir/$tID.tar.gz
        rm -rf $outdir/$tID.tar.gz
    fi
    
    # skip analysis if target locus already processed
    dummy=$outdir/$tID/${tID}.dummy
    if [ "$FORCE" == "true" ] || [ "$force" == "true"  ] || [ ! -f "$dummy" ] ; then
        echo "################################"
        echo "Process locus $tID"
        echo "################################"
        echo ""
    else
        echo "################################"
        echo "Pass locus $tID (already processed)"
        echo "################################"
        echo ""
        continue
    fi

    time (
        i=1
        while read line2 ; do
            if [ -z "$line2" ]; then  # skip empty lines
                continue
            fi
            fgeno=$line2
            # printf "getallseq.sh: fgeno is $fgeno\n\n"
            # gID=`basename ${fgeno%.f[as]?([sa])?(t)?(a)}`    # genome ID -> doesn't work by calling the script but works directly in the shell, I don't know why...
            gID=`basename ${fgeno%.f[as]*}`
            echo "$gID  - genome $i"
            dd=$outdir/$tID/$gID
            mkdir -p $dd
            # echo $dd
            
            ff=$dd/getseq.$gID.$tID.dummy
            if [ "$FORCE" == "true" ] || [ ! -f "$ff" ] ; then   # does the file exist?
                echo "################"
                echo "Process genome $gID for locus $tID"
                logf=$dd/getseq.$gID.$tID.log
                getseq.sh $fgeno $ftarg $gmapd $outdir &> $logf
                gzip -fv ${logf} # gzip original logfile
                echo "touch $ff"
                touch $ff   # dummy file indicating analysis of fgeno is complete
                echo "################"
                echo ""
            else
                echo "################"
                echo "Pass genome $gID for locus $tID (already processed)"
                echo "################"
                echo ""
            fi
            i=$((i + 1))
        done < $fgenos
        
        # generate the multifasta
        zcat $outdir/$tID/*/*CatEx.fasta.gz > $outdir/$tID/ali.$tID.fasta
        touch $dummy    # dummy file indicating the analysis of ftarg is complete
        # gzip $outdir folder
        if [ "$zip" == "true" ]; then
            echo "Compress result folder for $tID"
            tar --remove-files -zcf $outdir/$tID.tar.gz -C $outdir $tID
        fi
    ) 2>&1

    echo "################################"
    echo "Locus $tID done"
    echo "################################"
    echo ""
done < $ftargs
