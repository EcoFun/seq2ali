#!/usr/local/extras/Genomics/bin/julia

# BEWARE: to work properly, the gmap analysis as to be done one target only!

# parameters
fil = ARGS[1]   # gmap results
g = ARGS[2] # genome to fetch the sequence from
outpref = ARGS[3]  # prefix of output (full path but no extension)

# load gmap results all at once
f = open(fil)
txt = readlines(f)
close(f)

# check number of exons
Nex = filter(x -> contains(x, "    Number of exons:"), txt)[1]
Nex = parse(split(Nex, [ ' ', '\n'])[end-1])

# loop on all exons
for i in 1:Nex
    # get coordinates
    l = find(x -> contains(x, "  Alignment for path 1:"), txt)
    lc = l[1] + 1 + i

    # remove leading strand sign
    lt = replace(strip(txt[lc]), r"^[+-]", "")
    chr, coor = split(lt, [':', ' '])[1:2]
    sta, sto = split(strip(coor), '-')
    
    # run get-genome
    println(STDERR, "  # Fetch exon $i sequence for genome $g")
    println(STDERR, "get-genome -d $g $chr:$sta-$sto > $outpref.$i.fasta")
    run(pipeline(`get-genome -d $g $chr:$sta-$sto`, stdout="$outpref.$i.fasta"))
end

print(Nex)
