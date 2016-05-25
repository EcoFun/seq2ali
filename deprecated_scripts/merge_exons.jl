#!/usr/local/extras/Genomics/bin/julia

inp = ARGS[1]
hea = ARGS[2]

if length(ARGS) < 3
    pstd = "false"
end

out = replace(inp, ".fasta", ".CatEx.fasta")

f = open(inp)
o = open(out, "w")
println("# Write file $out")

i = 0
for l in eachline(f)
    if (l[1] != '>')
        if pstd == "true"
            print(strip(l))
        end
        print(o, strip(l))
    elseif (i == 0)
        if pstd == "true"
            println(hea)
        end
        println(o, hea)
        i = 1
    end
end

if pstd == "true"
    print("\n")
end
print(o, "\n")
close(f)
close(o)
