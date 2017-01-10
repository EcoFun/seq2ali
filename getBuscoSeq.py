#!/usr/bin/env python2
	# TODO:
		# extend to several BUSCO in several genomes?
			# need to create gmap dict if not existent
			# need to provide folder of gmap dict
__author__ = "Ludovic Duvaux"
__maintainer__ = "Ludovic Duvaux"
__license__ = "GPL_v3"

from glob import glob
import re, argparse, sys, os.path, os

# 0.1) get options from commands lines
parser = argparse.ArgumentParser(description='Get DNA sequence of a list of BUSCO genes from a BUSCO analysis',
	epilog="")
	
parser.add_argument('genome_list', help='List file of genomes to fetch the sequences from, where each line includes, separated by a tab, a genome tag, the respective busco directory and the respective gmap genome. E.g.: "Scedo.X\trun_X.contigs.fasta\tScedo.X.spades"', nargs=1)

parser.add_argument('BUSCO_gene_list', help='List file of genes to be fetched (one BUSCO ID per line)', nargs=1)

parser.add_argument('output_dir', help='Path of the output directory.', nargs=1)
argv = parser.parse_args()

# 0.2 set individuals variables
#~print argv
fgenos = argv.genome_list[0]	# individual
fgen = argv.BUSCO_gene_list[0]
pref = argv.output_dir[0]
#~sys.exit()
##### rest of the script
print "####### Start fetching BUSCO gene sequences"


with open(fgenos) as fgeno:
	for lgeno in fgeno:
		indiv, dbusco, ggmap = lgeno.strip().split("\t")
		print "##### Process genome %s" % indiv
		#~sys.exit()
		with open(fgen) as fg:
			for g in fg:
				g = g.strip()
				print "### Process gene %s for genome %s" % (g, indiv)

				# 1) get scaffold coordinate from full_table file
				#~print dbusco
				table = glob(dbusco + "/full_table_*" )[0]
				with open(table) as f:
					for l in f:
						if l[0] == "#" or g not in l:
							continue
						ele = l.split("\t")	# info per column
						scaf = ele[2]
						if ele[1] != "Complete":
							sys.exit("Gene %s not 'Complete'!" % g)
						break

				# 2) check locus with best E-Value in hmmer files
				cmd = "grep -rn '%s' %s/hmmer_output/%s* /dev/null|tr -s ' '" % (scaf, dbusco, g)	# here the /dev/null device is just to make grep thinks it always dealing with multiple files (in order to always display the filename in the results)
				print cmd;print "---"
				ele = re.split("\n", os.popen(cmd).read())
				#~print ele; print "---"
				res = []; e = 1
				for i in ele:
					if i == '':
						continue
					e1 = float(i.split(" ")[6])
					e1 < e
					if e1 < e:
						res = i
						e = e1
				aa = re.split(":| |\[|\]", res)
				#~print aa; print "---"
				gff = "%s/augustus/%s" % (dbusco, os.path.basename(aa[0]))
				gn = aa[2]
				scaf, coord = aa[3:5]
				sta, sto = coord.split("-")
				#~print gff, gn, scaf, sta, sto


				# 3) get strand orientation from Augustus gff file
				stra = ""
				with open(gff) as f:
					for l in f:
						if sta not in l or sto not in l or "gene" not in l:
							#~print "je passe"
							continue
						else:
							#~print l
							stra = l.strip().split("\t")[6]
							#~print stra
							break


				# 4) get sequence using get-genome
				fd = pref + "/" + g
				cmd = "mkdir -p " + fd
				os.system(cmd)
				#~print cmd
				nom = "%s/%s_%s.fasta" % (fd, g, indiv)
				#~print nom
				header = "%s_%s" % (indiv, g)
				if stra == "+":
					cmd = "get-genome -h '%s' -d %s %s:%s-%s > %s" % (header, ggmap, scaf, sta, sto, nom)
				elif stra == "-":
					cmd = "get-genome -h '%s' -d %s %s:%s-%s > %s" % (header, ggmap, scaf, sto, sta, nom)
				else:
					exit("ERROR: no correct strand was retrieved.")

				print cmd
				os.system(cmd)
				#~sys.exit()
				print ""
