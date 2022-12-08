# Evolution-of-highly-pathogenic-H5N1-influenza-A-virus-in-the-central-nervous-system-of-ferrets
This repository has the code used to determine presence of variants and to calculate diversity (π) in "Evolution-of-highly-pathogenic-H5N1-influenza-A-virus-in-the-central-nervous-system-of-ferrets"

# Variant Analysis and evaluation of amino acid substitutions.
To run variant analysis using LoFreqAnalysis.sh, fastq files (R1 and R2) need to be within the same folder as H5_CNS_Jurre.fa. PATH in .bashrc should be /Users/YOURUSERNAME/scripts/iSNV. Scripts should be located within iSNV folder. Afterwards, files present in 04_Results needs to be modified using 1_VCFvariant_Jurre.sh. The output of this step will be used by SNPdat_Parse.V3.sh. This will produce a table showing the amino acid changes produced by the variant.

# Calculation of π (Diversity)
For the calculation of diversity, I used the script runSNPGenie_Diversity.sh which is dependent on SNPGenie (PMID:26227143). A concatenated version of the influenza genome was used as a reference (JU-Reference-Concatenated.fa). To run the analysis, the directory should have the fastq files, fasta file and the GTF file.  

