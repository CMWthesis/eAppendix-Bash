#!/bin/bash

for PName1 in PxSA
	do 
		for PName2 in PaSA PxHaw
do
echo "making fst of $PName1:$PName2"
/opt/shared/vcftools/0.1.12a-gnu_4.8.0/bin/vcftools --vcf Plutella_1-29_minDP5.vcf --weir-fst-pop $PName1 --weir-fst-pop $PName2 --fst-window-size 10000 --fst-window-step 5000 --out fst/PlutellaSA_$PName1.$PName2
done
done 
/opt/shared/vcftools/0.1.12a-gnu_4.8.0/bin/vcftools --vcf Plutella_1-29_minDP5.vcf --weir-fst-pop PaSA --weir-fst-pop PaHaw --fst-window-size 10000 --fst-window-step 5000 --out fst/PlutellaSA_PaSA.PxHaw

for PName1 in PxGF
	do 
		for PName2 in PaGF PxHaw
do
echo "making fst of $PName1:$PName2"
/opt/shared/vcftools/0.1.12a-gnu_4.8.0/bin/vcftools --vcf Plutella_1-29_minDP5.vcf --weir-fst-pop $PName1 --weir-fst-pop $PName2 --fst-window-size 10000 --fst-window-step 5000 --out fst/PlutellaACT15_$PName1.$PName2
done
done 
/opt/shared/vcftools/0.1.12a-gnu_4.8.0/bin/vcftools --vcf Plutella_1-29_minDP5.vcf --weir-fst-pop PaGF --weir-fst-pop PaHaw --fst-window-size 10000 --fst-window-step 5000 --out fst/PlutellaACT15_PaSA.PxHaw

for PName1 in PxCook
	do 
		for PName2 in PaCook PxHaw
do
echo "making fst of $PName1:$PName2"
/opt/shared/vcftools/0.1.12a-gnu_4.8.0/bin/vcftools --vcf Plutella_1-29_minDP5.vcf --weir-fst-pop $PName1 --weir-fst-pop $PName2 --fst-window-size 10000 --fst-window-step 5000  --out fst/PlutellaACT14_$PName1.$PName2
done
done 
/opt/shared/vcftools/0.1.12a-gnu_4.8.0/bin/vcftools --vcf Plutella_1-29_minDP5.vcf --weir-fst-pop PaCook --weir-fst-pop PaHaw --fst-window-size 10000 --fst-window-step 5000  --out fst/PlutellaACT14_PaCook.PxHaw