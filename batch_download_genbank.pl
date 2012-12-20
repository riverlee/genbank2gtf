#!/usr/bin/perl
#############################################
#Author: Jiang Li
#email:  riverlee2008@gmail.com
#Creat Time: Tue 23 Oct 2012 01:37:54 PM CDT
#Vanderbilt Center for Quantitative Sciences
#############################################
use strict;
use warnings;

=pod

=head1 SYNOPSIS

Use NCBI etuils (efetch) to download each chromosome's annotation in genbank format of Cat genome.

=head1 USAGE

perl batch_download_genbank.pl

=head1 RESULTS

In your current working directory. There will generate 20 ChrXX.gb files.


=cut


## Script begin
# The chromosomes ids of cat comes from http://www.ncbi.nlm.nih.gov/genome/78
# Apply NCIB eutils to download genbank (full) format files of each chromosome

my $log="download.log";
while(<DATA>){
    next if (!/^Chr/);
    my ($chr,$name,$refseq,@other) = split /\s+/;
    print "[",scalar(localtime),"] Downloading ${chr}${name}|$refseq \n";
    my $comm = "wget \"http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=$refseq&rettype=gbwithparts&retmode=text\" -O ${chr}${name}.gb >>$log 2>&1";
    
    #print $comm,"\n\n";
    
    # Due to interent, some of the donwloads may fail, thus, you could 
    #re-run the program without downloading the already downloaded ones.
    if(! -s "${chr}${name}.gb"){
        print "Yes\n";
        system($comm);
    }
}

__DATA__
Type	 Name	 RefSeq	 INSDC	 Size (Mb)	 GC%	 Protein	 rRNA	 tRNA	 Other RNA	 Gene	 Pseudogene
Chr	A1	NC_018723.1	CM001378.1	239.3	0.0	1,398	-	18	22	1,491	285
Chr	A2	NC_018724.1	CM001379.1	169.04	0.0	1,746	-	28	11	1,736	203
Chr	A3	NC_018725.1	CM001380.1	142.46	0.0	1,310	-	11	16	1,235	148
Chr	B1	NC_018726.1	CM001381.1	205.24	0.0	1,099	-	8	24	1,210	295
Chr	B2	NC_018727.1	CM001382.1	154.26	0.0	1,161	-	153	17	1,423	268
Chr	B3	NC_018728.1	CM001383.1	148.49	0.0	1,355	-	33	12	1,421	219
Chr	B4	NC_018729.1	CM001384.1	144.26	0.0	1,420	-	13	15	1,402	241
Chr	C1	NC_018730.1	CM001385.1	221.44	0.0	1,957	-	41	31	1,957	292
Chr	C2	NC_018731.1	CM001386.1	157.66	0.0	1,000	-	11	16	1,076	234
Chr	D1	NC_018732.1	CM001387.1	116.87	0.0	1,583	-	16	14	1,558	222
Chr	D2	NC_018733.1	CM001388.1	89.82	0.0	729	-	3	10	688	94
Chr	D3	NC_018734.1	CM001389.1	95.74	0.0	767	-	16	12	814	121
Chr	D4	NC_018735.1	CM001390.1	96.02	0.0	862	-	8	14	868	135
Chr	E1	NC_018736.1	CM001391.1	63	0.0	1,234	-	43	5	1,145	67
Chr	E2	NC_018737.1	CM001392.1	64.04	0.0	1,104	-	14	9	1,141	139
Chr	E3	NC_018738.1	CM001393.1	43.02	0.0	716	-	24	6	699	37
Chr	F1	NC_018739.1	CM001394.1	68.67	0.0	738	-	20	3	730	81
Chr	F2	NC_018740.1	CM001395.1	82.76	0.0	455	-	11	8	509	112
Chr	X	NC_018741.1	CM001396.1	126.43	0.0	865	-	19	29	963	270
Chr	MT	NC_001700.1	U20753.1	0.017009	40.3	13	2	22	-	13	-
