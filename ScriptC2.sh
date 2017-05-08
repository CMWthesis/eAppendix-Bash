#!/bin/bash
end=100
nester=`for ((i=1;i<=$end;i++)); do echo $i; done`
cd trees/
for j in $nester
do 
	echo "build phylogenies for $j.phylo.fa"
		raxmlHPC -m GTRGAMMA -p 334 -N 5 -s ../fasta/$j.phylo.fa -n $j


done


