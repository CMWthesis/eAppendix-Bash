#!/bin/sh

#File structure should be in the format of a directory containing: all your fq files; this shell script; and your adapter.txt (for trimmomatic) 
#note: stampy will not run if you have files with the same name, the rest will overwrite by default 
#if workflow fails there are single run files for each step



# input paths/directories and number of genomes for trimmo
mother_dir=/scratch/cward/fastq #directory with fastq files in it
number_of_genome=4 #number of genomes you have/ number of sequence pairs
trimmo_dir=/opt/shared/trimmomatic/0.32 # directory for trimmo jar executable 
reference_dir=/scratch/cward/reference #directory of your reference genome 
adapter_file=moth_adapter.txt # name of the adapters and indicies for removal with trimmomatic
exc_num=1  #excecution number / ID if you have to run this multiple times, to make the log names unique. Log files will have a iteration.exc_num.PROGRAM.log nomenclature
float=0 #set float to nuber_of_genomes * run number-1: 1st run 0, 2nd run 2, 3rd run 4 ect ect for number_genome =3

# make directories in mother directory that contains fastq; subsiquent files will be put in here
# if you are running this multiple times just comment this out if you want; doesnt matter though... will just throw errors sating there is already a dir and continue
mkdir $mother_dir/samtools_chinese
mkdir $mother_dir/trimmo
mkdir $mother_dir/stampy_chinese
mkdir $mother_dir/picard_chinese


# makes 2 text files containing all file names in specified directory '$mother_dir' that match the grep PATTERN; in this case 'R1_*...\.fastq$' can be changed to whatever 
#grep has same syntax as in R * = can ignore previous . = wildard character ^ = start of line $ = end of line
ls $mother_dir | grep 'R1_*.*.*.*\.fastq.gz$' > $mother_dir/R1_filenames.txt
ls $mother_dir | grep 'R2_*.*.*.*\.fastq.gz$' > $mother_dir/R2_filenames.txt

#nested for loop code to carry out for loops number_of_genome times
nester=`for ((i=1+$float;i<=$float+$number_of_genome;i++)); do echo $i; done`



# input paths/directories and number of genomes for stampy
stampy_dir=/opt/shared/stampy/1.0.21 # location of stampy python excecutable
PL=illumina # PL field 
sub_rate=0.01 # substitution rate for stampy to use
ref_genome=P.xylostella.scaffolds # name of reference genome within the reference_dir
hash=P.xylostella.scaffolds # name of reference genome hash within the reference_dir
ID=1
nthread=20 # how many threads you want to use, note the for loop will run ALL alignments simultaneously so nthread=20 will run on 120 threads for number_of_genome=6


#makes the filenames.txt in the same way but only takes paired reads from the dir we made in the mother_dir 'trimmo' using the pattern 'R1_paired.fq_1$'
ls $mother_dir/trimmo | grep 'paired.fq_1.gz$' > $mother_dir/paired_R1_filenames.txt
ls $mother_dir/trimmo | grep 'paired.fq_2.gz$' > $mother_dir/paired_R2_filenames.txt


for i in $nester
do
#works down the list line by line following i
trimmo_in_R1_name=`sed "$i q;d" $mother_dir/R1_filenames.txt`
trimmo_in_R2_name=`sed "$i q;d" $mother_dir/R2_filenames.txt`
#makes output names by taking all the characters before R* and adding 'paired.fq_*' or 'orphan.fq_*' to the end
trimmo_out_fwd_paired=`sed "$i q;d" $mother_dir/R1_filenames.txt | grep -o ".\{0,40\}R1" | sed 's/$/_paired.fq_1.gz/'`
trimmo_out_fwd_orphan=`sed "$i q;d" $mother_dir/R1_filenames.txt | grep -o ".\{0,40\}R1" | sed 's/$/_orphan.fq_1.gz/'`
trimmo_out_rev_paired=`sed "$i q;d" $mother_dir/R2_filenames.txt | grep -o ".\{0,40\}R2" | sed 's/$/_paired.fq_2.gz/'`
trimmo_out_rev_orphan=`sed "$i q;d" $mother_dir/R2_filenames.txt | grep -o ".\{0,40\}R2" | sed 's/$/_orphan.fq_2.gz/'`

#command to run trimmomatic PE to change parameters just change them in the command
java -jar $trimmo_dir/trimmomatic.jar PE -threads 20 $mother_dir/$trimmo_in_R1_name  $mother_dir/$trimmo_in_R2_name $mother_dir/trimmo/$trimmo_out_fwd_paired $mother_dir/trimmo/$trimmo_out_fwd_orphan $mother_dir/trimmo/$trimmo_out_rev_paired $mother_dir/trimmo/$trimmo_out_rev_orphan ILLUMINACLIP:$mother_dir/$adapter_file:2:30:10 TRAILING:5 SLIDINGWINDOW:4:15 MINLEN:75 2> $mother_dir/trimmo/$i.$exc_num.trimmo.log &
sleep 1
done
wait
echo 'trimmo done'

#runs the stampy commands
for i in $nester

do

#SM is the SM that will be included in your SAM file 
#SM will be used for naming. My samples had the relevant file info before a Pa or Px followed by a 2 digit reat (14/15)
#grep -o '.\{0,40\}P...' will go to P... (where . is any char) and remove 0-40 characters before P... (including P...)
#P... can be changed to anything 
SM=`sed "$i q;d" $mother_dir/paired_R1_filenames.txt | grep -o '.\{0,40\}P...'`
stampy_in_R1_paired=`sed "$i q;d" $mother_dir/paired_R1_filenames.txt`
stampy_in_R2_paired=`sed "$i q;d" $mother_dir/paired_R2_filenames.txt`

#stampy command with above file names once again check your nthreads MAKE SURE YOU HAVE ENOUGH THREADS FREE FOR THE JOBS!
python2.6 $stampy_dir/stampy.py  -g $reference_dir/$ref_genome -h $reference_dir/$hash --baq --gatkcigarworkaround --substitutionrate=$sub_rate -f sam --readgroup=ID:$ID,PL:$PL,SM:$SM -o $mother_dir/stampy_chinese/$SM.stampy.sam -t $nthread -M $mother_dir/trimmo/$stampy_in_R1_paired $mother_dir/trimmo/$stampy_in_R2_paired 2> $mother_dir/stampy_chinese/$SM.stampy.log &

  sleep 1
  done
wait
sleep 5
echo 'Stampy is finished'

ls $mother_dir/stampy_chinese | grep 'stampy.sam$' > $mother_dir/chinese_aligned_filenames.txt


for i in $nester

do

#filenames made in the same way as with stampy
IN=`sed "$i q;d" $mother_dir/chinese_aligned_filenames.txt`
SM=`sed "$i q;d" $mother_dir/chinese_aligned_filenames.txt | grep -o '.\{0,60\}_P...'`
RG=`sed "$i q;d" $mother_dir/chinese_aligned_filenames.txt | grep -o 'L...'`

#samtools excecutable dir
samtools_dir=/opt/shared/SamTools/0.1.19

#converts SAM to compressed BAM
$samtools_dir/samtools view -Shb $mother_dir/stampy_chinese/$IN > $mother_dir/samtools_chinese/$SM.$RG.stampy.bam
#sorts BAMs
$samtools_dir/samtools sort $mother_dir/samtools_chinese/$SM.$RG.stampy.bam $mother_dir_chinese/samtools/$SM.$RG.stampy.sorted
#indexes BAMs
$samtools_dir/samtools index $mother_dir/samtools_chinese/$SM.$RG.stampy.sorted.bam

#next 2 lines will remove the SAMs and the unsorted BAMs; use if you want to conserve space/saves time later deleting them 
#they are commented out because alignment is the most time consuming; will have to start 	alignment again if BAMs are corrupt or missing
rm $mother_dir/samtools_chinese/$SM.$RG.stampy.bam

  done
wait
sleep 5

echo 'SamTools is done, Picard will begin removing duplicates'
#makes names in the same way as before but with pattern to match samtools output 'stampy.sorted.bam$' 

#makes names in the same way as before but with pattern to match samtools output 'stampy.sorted.bam$' 
ls $mother_dir/samtools | grep 'stampy.sorted.bam$' > $mother_dir/aligned_filenames.txt

picard_dir=/opt/shared/picard/1.71 #picard jar executable directory

for i in $nester 
do 
SM=`sed "$i q;d" $mother_dir/paired_R1_filenames.txt | grep -o '.\{0,40\}P...'`
#names made in the same way from new file

#Picard mark and remove duplicates 
java -Xmx20g -Dsnappy.disable=true -jar $picard_dir/MarkDuplicates.jar REMOVE_DUPLICATES=true ASSUME_SORTED=true VALIDATION_STRINGENCY=SILENT MAX_RECORDS_IN_RAM=2000000 MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=4000 INPUT=$mother_dir/samtools/$SM.stampy.sorted.bam OUTPUT=$mother_dir/picard/$SM.stampy.rmdup.bam METRICS_FILE=$mother_dir/picard/$i.$exc_num.picard.metrics > $mother_dir/picard/$i.$exc_num.picard.log &
done
wait
