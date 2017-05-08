#!/bin/bash

callsList=`ls | grep '.calls' | sed 's/......$//'`

home=/localscratch/cward_m/Hybrid_moth/VCF_for_phylo/all_sites/calls
for i in $callsList
do
echo 'make dir'
mkdir $i
echo 'change dir'
cd $i
pwd
echo "split $i into windows "
python ../../../python/sliPhy.py -i ../$i.calls -w 50000 -s 50000 -m 10000

cd $home

#popualte file list
phylipList=`ls $i/ | grep '.phy$'`


#run RAxML on all phylip alignements
for j in $phylipList 
	do
	cd $home
	echo 'make trees'
	echo 'change dir'
	mkdir $i/trees
	cd $i/trees
	echo "build phylogenies for $j"
		raxmlHPC -m GTRGAMMA -p 334 -s ../$j  -# 5 -n $j -T 20
		cd $home
	done
	
done