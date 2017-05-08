for i in 0_99 0_95 0_9 0_75 0_5 
do
for j in 1 2 3 4 5 6

do 

python ../../F3/popstats/popstats.py --file ${j}_p${i}_100kb --pops Pa,PxH,PxA -b 1000 --f3  > ../F3_statistic/${j}.p${i}_admix.f3
python ../../F3/popstats/popstats.py --file ${j}_p${i}_100kb --pops Pa,PxA,PxH -b 1000 --f3  > ../F3_statistic/${j}.p${i}_null.f3

done
wait
done