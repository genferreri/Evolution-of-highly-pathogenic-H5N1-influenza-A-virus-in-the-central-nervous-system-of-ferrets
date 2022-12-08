#!/bin/bash
#20211020
#This is the latest version of ParseALT_SNPdat.sh
#This script needs the reference sequence in fasta format, SNPdat_v1.0.5.pl, 
# as well as a GTF file

GTF=$(find . -name "*.gtf.txt")
FASTA=$(find . -name "*.fa")

#Run SNPdat
for f in *.txt; do FILENAME=${f%%.*};
perl ~/scripts/SNPdat/SNPdat_v1.0.5.pl -i ${FILENAME}.AF.Cov.ALT.vcf.txt -f ${FASTA} -g ${GTF};
done; 

#Parse columns
for r in *.output; do FILENAME=${r%%.*};
cat ${FILENAME}.AF.Cov.ALT.vcf.txt.output | awk 'NR>1' | \
awk 'BEGIN{OFS"\t"} {split($21, a, "/"); print $1 "\t" $2 "\t" a[1] "\t" a[2] "\t" $22}' | \
awk 'BEGIN{OFS"\t"} {split($3, a, "["); split ($4, b, "]"); print $1 "\t" $2 "\t" a[2] "\t" b[1] "\t" $5}' \
> ${FILENAME}.SNPdat.temp.txt
tr -d '-' < ${FILENAME}.SNPdat.temp.txt > ${FILENAME}.SNPdat.txt


done;

rm *.summary 
rm *.SNPdat.temp.txt
mkdir SNPdat
rm *ref.AF.Cov.ALT.vcf.txt.output
rm *ref.SNPdat.txt
mv *vcf.txt ./SNPdat
mv *.output ./SNPdat

## Add sample's name
for f in *.SNPdat.txt
do 
	NAME=${f%%.*}
	echo $NAME
	##add name of the sample
	awk -F, -v s="$NAME" '{$6="\t"s; print }' "$NAME".SNPdat.txt > "$NAME".SNPdat.temp.txt

	rm "$NAME".SNPdat.txt

	##remove "-" from name
	tr -d '-' < "$NAME".SNPdat.temp.txt > "$NAME".SNPdat.txt

	rm "$NAME".SNPdat.temp.txt

done
