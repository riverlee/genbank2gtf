#!/usr/bin/perl -w
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

Given a genbank format file (.gb), parse its feature parts (mRNA feature to get exon regions) to get information like transcript id, gene name, etc.,
and store the result in gtf format

=head1 USAGE

perl genbank2gtf_mRNA.pl input.gb chromosome >chromosome_mRNA.gtf

=head1 RESULTS

The output is a file named as chromosome_mRNA.gtf, in which chromosome is given as the input parameter

=cut


#Script begin
#Convert a genbank file into a gtf format file (Only parse mRNA feature)

my $usage = "perl $0 GenBank.gb chromosome >chromosome.gtf \n";
die $usage unless (@ARGV==2);


genbank2gtf($ARGV[0],$ARGV[1]);


sub genbank2gtf{
    my ($in,$chr) = @_;
    open(IN,$in) or die "The genbank annotation is not exists \n";
    my $feature="";
    my $flag=0;
    
    #Getting feature lines
    while(<IN>){
        if(/^FEATURES/){
            $flag=1;
            next;
        }
        last  if(/^ORIGIN/); #The following lines display the sequences
        $feature.=$_ if ($flag);
    }
    close IN;
    
    #Begin parse the $feature;
    #print $feature;
    my @features;
    while($feature=~/^ {5}\S.*\n(^ {21}\S.*\n)*/gm){
        push @features,$&;
    }
    
    #Loop each feature and only parse those mRNA features to get the exon region, together with other
    #information like gene name, transcript id, etc.
    foreach my $f (@features){
        if($f=~/^ {5}(\S+).*\n(^ {21}\S.*\n)*/){
            #Only feature is mRNA
            if($1 eq "mRNA"){
                # information need to be fetched
                my ($gene_id,$transcript_id,$gene_name,$transcript_name);
                my $strand="+";
                $strand="-" if($f=~/complement\(/);
                
                #transcript_id and transcript_name share the same name
                if($f=~/\/transcript_id="(.*?)"/){
                    $transcript_id=$1;
                    $transcript_name=$1;
                }
                #gene id
                if($f=~/\/db_xref="GeneID:(\d+)"\n/){
                    $gene_id=$1;
                }
                #gene name
                if($f=~/\/gene="(.*?)"/){
                    $gene_name=$1;
                }

=head1 EXON REGION PARSE

=head2 CODE

    if($f=~/(complement\()?(join\()?(\d+[\d\.\n,> ]+\d)(\))?/){
        my $tmp=$3;
        $tmp=~s/\s|\n|>//g;
        my @array = split ",",$tmp;
        my @start;
        my @end;
        foreach my $s(@array){
            if($s=~/(\d+)\.\.(\d+)/){
                push @start,$1;
                push @end,$2;
            }else{
                push @start,$s;
                push @end,$s+1;
            }
        }
        
        if($strand eq "-"){
            @start=reverse @start;
            @end=reverse @end;
        }
    }
    
=head2 EXAMPLE

     mRNA            complement(join(102429..103045,104811..104942,
                     105561..105643,105732..105835,105910..106035))
                     /gene="CCDC115"
                     /product="coiled-coil domain containing 115"
                     /note="Derived by automated computational analysis using
                     gene prediction method: GNOMON. Supporting evidence
                     includes similarity to: 4 ESTs, 1 Protein"
                     /transcript_id="XM_003980242.1"
                     /db_xref="GI:410947098"
                     /db_xref="GeneID:101080349"

=cut
                #Parse exons
                if($f=~/(complement\()?(join\()?(\d+[\d\.\n,> ]+\d)(\))?/){
                    my $tmp=$3;
                    $tmp=~s/\s|\n|>//g;
                    my @array = split ",",$tmp;
                    my @start;
                    my @end;
                    foreach my $s(@array){
                        if($s=~/(\d+)\.\.(\d+)/){
                            push @start,$1;
                            push @end,$2;
                        }else{
                            push @start,$s;
                            push @end,$s+1;
                        }
                    }
                    
                    if($strand eq "-"){
                        @start=reverse @start;
                        @end=reverse @end;
                    }
                    
                    #if($gene_name eq "ITK"){print STDERR $tmp,"\n";print STDERR join "\n",@array;};
                    for(my $i=0;$i<@array;$i++){
                        my $j=$i+1;
                        my $group="gene_id \"$gene_id\"; transcript_id \"$transcript_id\"; exon_number \"$j\"; gene_name \"$gene_name\"; transcript_name \"$transcript_name\";\n";
                        print join "\t",($chr,"protein_coding","exon",$start[$i],$end[$i],
                                        ".",$strand,".",$group);
                    }
                }
            }
        }
    }

}

