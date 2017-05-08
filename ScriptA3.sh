#!/bin/bash

number_of_genomes=29
mother_dir=/scratch/cward/fastq #directory with fastq files in it
gatk_dir=/opt/shared/gatk/3.3-0 # directory for trimmo jar executable 
reference_dir=/scratch/cward/reference #directory of your reference genome 
adapter_file=moth_adapter.txt # name of the adapters and indicies for removal with trimmomatic

nester=`for ((i=1;i<=$number_of_genomes;i++)); do echo $i; done`

ls $mother_dir/gatk/gvcf | grep '.g.vcf$' > $mother_dir/gatk/gvcf/gvcf_filenames.txt

mkdir $mother_dir/gatk/genotypegvcf

for i in $nester
do
get_line=`sed "$i q;d" $mother_dir/gatk/gvcf/gvcf_filenames.txt`

readlink -f $mother_dir/gatk/gvcf/$get_line > $mother_dir/gatk/gvcf/bam_name$i.dipis


done

cat $mother_dir/gatk/gvcf/*.dipis > $mother_dir/gatk/gvcf/gvcf.list

rm $mother_dir/gatk/gvcf/*.dipis

java -jar $gatk_dir/GenomeAnalysisTK.jar -T GenotypeGVCFs -nt 10 -R $reference_dir/GCA_000330985.1_DBM_FJ_V1.1_genomic.Pxmt.fasta --disable_auto_index_creation_and_locking_when_reading_rods -V $mother_dir/gatk/gvcf/gvcf.list -allSites -o $mother_dir/gatk/genotypegvcf/1-29_gvcf_genotypes.g.vcf 2> $mother_dir/gatk/genotypegvcf/genotypeGVCF.log


