#!/bin/bash
end=500
nester=`for ((i=1;i<=$end;i++)); do echo $i; done`
for j in $nester
do 


partitions=($(wc -l trees/$j.admixture.null.trees))
echo $partitions
seq-gen -mHKY -l 50000 -s 0.01 -p $partitions < trees/$j.admixture.null.trees > fasta/$j.phylo.fa


done