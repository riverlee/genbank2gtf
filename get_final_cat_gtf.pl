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

Merge the mRNA gtf (exon) and CDS gtf (exon) together by fill the values of transcript_id and transcript_name in the CDS gtf file. This help define the relationship between transcript_id and protein_id, the relationship is parsed from the proteinid.gb file

=head1 USAGE

perl get_final_cat_gtf.pl

=head1 RESULTS

In your current working directory. There will generate a file named as felCat5_final.gtf

=cut

#1) Get all the transcript id
my %transcript;
my @gtfs=<chr??.gtf>;
push @gtfs,<chr?.gtf>;
foreach my $f (@gtfs){
    open(IN,$f) or die $!;
    while(<IN>){
        if(/transcript_id "(.*?)"/){
            #$transcript{$1}++;
            my $long=$1;
            my $short=$long;
            $short=~s/\..*//g;
            $transcript{$short}=$long;
        }
    }
}
print "There are total ",scalar(keys %transcript)," transcripts\n";

#2) get the np to nx mapping
my @nps=<NP/*.gb>;
my %np2nm;
foreach my $f (@nps){
    my $np = $f;
    $np=~s/NP\/|\.gb//g;
    open(IN,$f) or die $!;
    my $s="";
    while(<IN>){$s.=$_;};
    my $nm="";
    if($s=~/DBSOURCE\s+REFSEQ:\s+accession\s+(.*?)\n/){
        $nm=$1;
    }
    $nm=~s/\..*//g;
    if(!exists($transcript{$nm})){
        print $np,"\t$nm\n";
    }
    $np2nm{$np}=$nm;
}

#3) Write out all
open(OUT,">felCat5_final.gtf") or die $!;
foreach my $f (@gtfs){
    open(IN,$f) or die $!;
    while(<IN>){
        print OUT $_;
    }
}

my @cds=<chr*_CDS.gtf>;
#print join "\n",@cds;
foreach my $f (@cds){
    open(IN,$f) or die $!;
    while(<IN>){
        my $np="";
        if(/protein_id "(.*?)"/){
            $np=$1;
        }
        my $nmshort=$np2nm{$np};
        if(!defined($nmshort)){
            print "$np\t$_";
            next;
        }
        if(exists($transcript{$nmshort})){
            my $nm=$transcript{$nmshort};
            s/transcript_id ".*?"/transcript_id "$nm"/g;
            s/transcript_name ".*?"/transcript_name "$nm"/g;
            print OUT $_;
        }
    }
}
close OUT ;

system("sort -k1,4,3 felCat5_final.gtf -0 felCat5_final.gtf");
