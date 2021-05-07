
#!/bin/bash

set -e

for i; do
        echo $i
        cd /mnt/SingleCellGenomics/scg_projects/SlimeMold/SpatialTranscriptomics384Experiments/BSS1/$i
        mkdir /mnt/SingleCellGenomics/scg_projects/SlimeMold/SpatialTranscriptomics384Experiments/BSS1/$i/$i\_starOutput
        if test -f $i\_r1.fq; then
            cd /mnt/SingleCellGenomics/scg_projects/SlimeMold/SpatialTranscriptomics384Experiments/BSS1/$i/$i\_starOutput
            STAR --genomeDir /mnt/SingleCellGenomics/genome_data/10xSlimeMoldTranscriptome/10xSlimeMoldTranscriptomeUpdated/star/ --readFilesIn ../$i\_r1.fq ../$i\_r2.fq
            /home/tobias_gerber/Perl/CalculateTPM_SlimeMold.pl Aligned.out.sam
        fi
        if test -f $i\_r1.fq.gz; then
            gunzip $i\_r1.fq.gz
            gunzip $i\_r2.fq.gz
            cd /mnt/SingleCellGenomics/scg_projects/SlimeMold/SpatialTranscriptomics384Experiments/BSS1/$i/$i\_starOutput
            STAR --genomeDir /mnt/SingleCellGenomics/genome_data/10xSlimeMoldTranscriptome/10xSlimeMoldTranscriptomeUpdated/star/ --readFilesIn ../$i\_r1.fq ../$i\_r2.fq
            /home/tobias_gerber/Perl/CalculateTPM_SlimeMold.pl Aligned.out.sam
	    gzip ../$i\_r1.fq
	    gzip ../$i\_r2.fq
        fi
done

cd /mnt/SingleCellGenomics/scg_projects/SlimeMold/SpatialTranscriptomics384Experiments/


# first remove the header from all tracking files, rename file, and save it in each cell’s kallisto_output folder

for f in ./BSS1/*/*_starOutput/CountMatrix.tsv ; do echo $f ; cat $f | sed '1d' > ${f/CountMatrix.tsv/CountMatrix.tsv.nohead.tsv} ;done
 
 
#then add the cell id to first column and cat all the data together into a master file

for f in ./BSS1/*/*_starOutput/CountMatrix.tsv.nohead.tsv ; do
    d=$(dirname $(dirname "$f"))
    while read line; do
        echo "$d $line"
    done <"$f"
done > SlimeMold_SmartSeq2_SpatialTranscriptomics384_BSS1_tpm

# add back the header
echo -e "cellID\tgene\tRPK\tTPM" | cat - SlimeMold_SmartSeq2_SpatialTranscriptomics384_BSS1_tpm > /tmp/out && mv /tmp/out SlimeMold_SmartSeq2_SpatialTranscriptomics384_BSS1_tpm_header
 
# change spaces to tabs and rename 
tr ' ' \\t < SlimeMold_SmartSeq2_SpatialTranscriptomics384_BSS1_tpm_header > SlimeMold_SmartSeq2_SpatialTranscriptomics384_BSS1_tpm_final
 

