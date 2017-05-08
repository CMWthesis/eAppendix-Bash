#!/bin/sh

number_of_genomes=21
mother_dir=/scratch/cward/fastq #directory with fastq files in it
gatk_dir=/opt/shared/gatk/3.3-0 # directory for trimmo jar executable 
reference_dir=/scratch/cward/reference #directory of your reference genome 


nester1=`for ((i=1;i<=7;i++)); do echo $i; done`
nester2=`for ((i=8;i<=14;i++)); do echo $i; done`
nester3=`for ((i=15;i<=$number_of_genomes;i++)); do echo $i; done`


mkdir $mother_dir/gatk/gvcf


for i in $nester1

do

SM=`sed "$i q;d" $mother_dir/picard/bam_filenames.txt | grep -o '.\{0,40\}P...'`


if [[ $SM == *"Pa1"* ]]
then
	java -Xmx12g -jar $gatk_dir/GenomeAnalysisTK.jar -T HaplotypeCaller  -nct 8 --max_alternate_alleles 2 -variant_index_type LINEAR -variant_index_parameter 128000 -hets 0.0497 -R $reference_dir/GCA_000330985.1_DBM_FJ_V1.1_genomic.Pxmt.fasta -I $mother_dir/picard/filtered/$SM.rmdp.filtered.bam --emitRefConfidence GVCF -o $mother_dir/gatk/gvcf/$SM.g.vcf 2> $mother_dir/gatk/gvcf/$SM.vcf.log &
else
	if [[ $SM == *"Px1"* ]]
	then
		java -Xmx12g -jar $gatk_dir/GenomeAnalysisTK.jar -T HaplotypeCaller  -nct 8 --max_alternate_alleles 2 -variant_index_type LINEAR -variant_index_parameter 128000 -hets 0.0348  -R $reference_dir/GCA_000330985.1_DBM_FJ_V1.1_genomic.Pxmt.fasta -I $mother_dir/picard/filtered/$SM.rmdp.filtered.bam  --emitRefConfidence GVCF -o $mother_dir/gatk/gvcf/$SM.g.vcf 2> $mother_dir/gatk/gvcf/$SM.vcf.log &
	else
		java -Xmx12g -jar $gatk_dir/GenomeAnalysisTK.jar -T HaplotypeCaller  -nct 8 --max_alternate_alleles 2 -variant_index_type LINEAR -variant_index_parameter 128000 -hets 0.0272 -R $reference_dir/GCA_000330985.1_DBM_FJ_V1.1_genomic.Pxmt.fasta -I $mother_dir/picard/filtered/$SM.rmdp.filtered.bam --emitRefConfidence GVCF -o $mother_dir/gatk/gvcf/$SM.g.vcf 2> $mother_dir/gatk/gvcf/$SM.vcf.log &
	fi
fi
done 
wait



echo "FIRST LOT DONE"
