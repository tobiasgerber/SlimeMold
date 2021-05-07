#!/bin/bash

set -e

for i in `/bin/ls split*bam|sed "s/^split.//g" |sed "s/\.bam$//g" | grep -P "^\w\d"`; do 
    
    mkdir /mnt/SingleCellGenomics/scg_projects/SlimeMold/SpatialTranscriptomics384Experiments/BSS1/$i
    cd /mnt/SingleCellGenomics/scg_projects/SlimeMold/SpatialTranscriptomics384Experiments/BSS1/$i
    /home/gabriel_renaud/scripts/bamlib/ignoreZQW ../split."$i".bam /dev/stdout | /home/gabriel_renaud/projects/BCL2BAM2FASTQ/bam2fastq/bam2fastq /dev/stdin $i
done

