#!/usr/bin/perl -w
use strict;
use File::Basename;

foreach (@ARGV) {
    print "Estimating TPM\n";
    open FH,"samtools view $_ |" or die "Ooops";
    open REF, "/mnt/SingleCellGenomics/genome_data/10xSlimeMoldTranscriptome/SlimeMold_annotation_table_TranscriptomeUpdated.txt" or die "Shit";

    open WRITE, ">CountMatrix.tsv" or die;
    print WRITE "Gene\tRPK\tTPM\n"; 

    #####Collect gene length and gene annotation information and set all transcript entries in %counts to 0 and generate a control hash with transcript names as values######
    
	
    my %GeneLength;
    my %annotation;
    my %count;
    while (<REF>) {
        	chomp;
        	my @line = split /\t/,$_;
		if ($line[0] eq "Chr_ID") {
			next;
		} else {
			$annotation{$line[0]} = $line[2];
			$GeneLength{$line[0]} = $line[3];
			$count{$line[0]} = 0;
		}
    }
    close REF;

    #####Count Reads in star output bamfile######
    
    while (<FH>) {
        chomp;
	my @line = split /\t/,$_;
	$count{$line[2]}++;

    }
    foreach my $key(keys %count) {
	if ($count{$key} > 0) {
		$count{$key} = 	$count{$key} / 2;
	}

    }

    #####Calculate RPK#####
    my %RPK;
    foreach my $key(keys %count) {
	$RPK{$key} = $count{$key} / $GeneLength{$key};

    }


    #####Sum RPK for isoforms#####
    my %cor_RPK;
    foreach my $key(keys %RPK) {
	if ($cor_RPK{$annotation{$key}} ) {
		$cor_RPK{$annotation{$key}} += $RPK{$key};
	} else {
		$cor_RPK{$annotation{$key}} = $RPK{$key};
	}

    }

    
    #####Calculate scale factor#####
    my $ScaleFactor = 0;
    foreach my $key(keys %RPK) {
	$ScaleFactor = $ScaleFactor + $RPK{$key};
    }
    if ($ScaleFactor == 0) {
	next;
    } else {
    	$ScaleFactor = $ScaleFactor / 1000000;
    }

    #####Calculate TPM######
    my %TPM;
    foreach my $key(keys %cor_RPK) {
	$TPM{$key} = $cor_RPK{$key} / $ScaleFactor;
    }

    #####Output#####
    foreach my $key(keys %TPM) {
	print WRITE "$key\t$cor_RPK{$key}\t$TPM{$key}\n";
    }
}
close FH;

close WRITE;



