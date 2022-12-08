#!/bin/bash

NAME1=$(find . -maxdepth 1 -name "*_S*_L*_R1_001.fastq.gz" | xargs -I {} basename {} .fastq.gz)

NAME2=$(find . -maxdepth 1 -name "*_S*_L*_R2_001.fastq.gz" | xargs -I {} basename {} .fastq.gz)

NAME3=$(echo *.fastq.gz | awk -v FS='_' '{print $1}')

FASTA=$(find . -maxdepth 1 -name "*.fa")

cwd=$(pwd)

time cutadapt -f fastq --match-read-wildcards \
-e 0.1 -O 6 -m 32 -g ^GAGCTAGTCTG -g ^GTCGAGCTCG -g ^GTTACGCGCC -g ^GGGGGG -g ^CGGGTTATT -g ^GGTAACGCGTGATC \
-a GATCGGAAGAGCACACGTCT -b ACACTCTTTCCCTACACGACGCTCTTCCGATCT -b GCCAGAGCCGTAAGGACGACTTGGCGAGAAGGCTAGA \
-o "$NAME1"_cutadapt.fastq.gz -p "$NAME2"_cutadapt.fastq.gz \
"$NAME1".fastq.gz "$NAME2".fastq.gz 1>job.out 2>job.err 

# QC is not required when using LoFreq
# https://csb5.github.io/lofreq/blog/

mkdir 00_Fastq

mv *1.fastq.gz ./00_Fastq

cat *.fastq.gz > "$NAME3".fastq.gz

mv *1_cutadapt.fastq.gz ./00_Fastq

NAME=$(find . -maxdepth 1 -name "*.fastq.gz" | xargs -I {} basename {} .fastq.gz)

bwa index "$FASTA"

# Preprocess alignments
bwa mem "$FASTA" "$NAME".fastq.gz > "$NAME".sam

# Tool corrects any flaws in read-pairing that may have been introduced by the aligner
samtools fixmate -r -m "$NAME".sam "$NAME".bam

# realignment
lofreq viterbi -f "$FASTA" "$NAME".bam > "$NAME"_vit.bam

samtools sort "$NAME"_vit.bam > "$NAME"_vitSort.bam

lofreq indelqual -f "$FASTA" --dindel -o "$NAME"_dindel.bam "$NAME"_vitSort.bam

lofreq alnqual "$NAME"_dindel.bam "$FASTA" > "$NAME"_alnqual.bam #not a bam file

samtools view -b -o "$NAME"_postpros.bam "$NAME"_alnqual.bam

rm *alnqual*
rm *dindel*
rm *vit*
rm *.sam

lofreq call -f "$FASTA" --min-cov 400 -o "$NAME".vcf "$NAME"_postpros.bam

grep "^##" -v "$NAME".vcf | awk 'BEGIN{OFS"\t"} {split($8, a, ";"); print $1, $2, $4, $5, "\t", a[2]}' | \
awk 'BEGIN{OFS"\t"} {split($5, a, "="); print $1, "\t", $2, "\t", $3, "\t", $4, "\t", a[2]}'  > "$NAME"_LoFreq-AF.vcf 
#remove header "CHROM" and keep number corresponding to segment
grep "^#" -v "$NAME"_LoFreq-AF.vcf | awk 'BEGIN{OFS"\t"} {split($1, a, "|"); print a[1], "\t", $2, "\t", $3, "\t", $4, "\t", $5}' > "$NAME"_LoFreq-nuclAF.vcf

samtools depth "$NAME"_postpros.bam | awk 'BEGIN{OFS"\t"} {split($1, a, "|"); print a[1], "\t",$2, "\t", $3}' > "$NAME"_coverage.tsv

Rscript ~/scripts/iSNV/Coverage.R

rm Rplots.pdf

##Organize results

mkdir 01_Reference
mv *.fa ./01_Reference
mv *.fa.* ./01_Reference
mkdir 02_Alignments
mv *.bam ./02_Alignments
mkdir 04_Results
mv *-nuclAF.vcf ./04_Results
mv *_coverage.tsv ./04_Results
mkdir 03_VCF
mv *.vcf ./03_VCF
mv *.fastq.gz 00_Fastq
mkdir 05_Plots
mv *.pdf 05_Plots
