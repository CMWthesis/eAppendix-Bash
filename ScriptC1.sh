#!/bin/bash
end=500
nester=`for ((i=1;i<=$end;i++)); do echo $i; done`
for j in $nester
do 

/localscratch/Programs/ms-20140908/bin/ms 4 1 -I 4 1 1 1 1 -ej 1 2 1 -ej 1.2 3 1 -ej 5 4 1 -r 500 50000 -T | tail -n +4 | grep -v "//" > $j.4pop.null.trees

echo "$j"
done
wait