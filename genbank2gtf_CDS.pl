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

Given a genbank format file (.gb), parse its feature parts (CDS feature to get CDS regions) to get information like transcript id, gene name, etc.,
and store the result in gtf format

=head1 USAGE

perl genbank2gtf_CDS.pl input.gb chromosome >chromosome_CDS.gtf

=head1 RESULTS

The output is a file named as chromosome_CDS.gtf, in which chromosome is given as the input parameter

=cut


#Script begin
#Convert a genbank file into a gtf format file (Only parse CDS feature)

my $usage = "perl $0 GenBank.gb chromosome >chromosome_CDS.gtf\n";
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
    # print $feature;
    my @features;
    while($feature=~/^ {5}\S.*\n(^ {21}\S.*\n)*/gm){
        push @features,$&;
    }
    #Loop each feature and only parse those CDS features to get the exon region, together with other
    #information like gene name, transcript id, etc.
    foreach my $f (@features){
        if($f=~/^ {5}(\S+).*\n(^ {21}\S.*\n)*/){
            if($1 eq "CDS"){ #this time only CDS
                my ($gene_id,$transcript_id,$gene_name,$transcript_name,$protein_id)=("","","","","","");
                my $strand="+";
                $strand="-" if($f=~/complement\(/);
                #
                if($f=~/\/transcript_id="(.*?)"/){
                    $transcript_id=$1;
                    $transcript_name=$1;
                }
                if($f=~/\/db_xref="GeneID:(\d+)"\n/){
                    $gene_id=$1;
                }
                
                if($f=~/\/gene="(.*?)"/){
                    $gene_name=$1;
                }
        
                if ($f=~/\/protein_id="(.*?)"\n/){
                    $protein_id=$1;
                }
                
                my $codon_start=1;
                if($f=~/\/codon_start=(\d)/){
                    $codon_start=$1;
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

     CDS             complement(join(102933..103045,104811..104942,
                     105561..105643,105732..105835,105910..106020))
                     /gene="CCDC115"
                     /note="Derived by automated computational analysis using
                     gene prediction method: GNOMON."
                     /codon_start=1
                     /product="coiled-coil domain-containing protein 115"
                     /protein_id="XP_003980291.1"
                     /db_xref="GI:410947099"
                     /db_xref="GeneID:101080349"
                     /translation="MAAPDLRAELDSLLLQLFQDLEELEAKRAALNARVEEGWLSLSK
                     ARYSMGAKSVGPLQYASLMEPQVCVYTSEAQDGLQRFWLVRASAQTPEEVGPREAALR
                     RRKGLTRTPEPESFPALRDPLNWFGILVPHSLRQAQASFREGLQLAADMATLQIRIDW
                     GRSQLRGLQEKLKQLEPESA"
=cut
                #Parse coding exons
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
                    #    if($strand eq "+"){
                    my $i=0;
                    my $j=$i+1;
                    my $frame=$codon_start-1;  #The first exon
                    my $group="gene_id \"$gene_id\"; transcript_id \"$transcript_id\"; exon_number \"$j\"; gene_name \"$gene_name\"; transcript_name \"$transcript_name\"; protein_id \"$protein_id\";\n";
                                print join "\t",($chr,"protein_coding","CDS",$start[$i],$end[$i],
                                                ".",$strand,$frame,$group);
                    
                    my @frame;
                    $frame[$i]=$frame;
                    $i++;$j++;
                    
                    while(defined($start[$i])){
                        $frame=(($end[$i-1]-$start[$i-1])+1-$frame[$i-1]) % 3;
                        if($frame !=0){
                            $frame=3-$frame;
                        }
                        $frame[$i]=$frame;
                        
                        $group="gene_id \"$gene_id\"; transcript_id \"$transcript_id\"; exon_number \"$j\"; gene_name \"$gene_name\"; transcript_name \"$transcript_name\"; protein_id \"$protein_id\";\n";
                                print join "\t",($chr,"protein_coding","CDS",$start[$i],$end[$i],
                                                ".",$strand,$frame,$group);
                        $i++;
                        $j++;
                    }
               }
            }
        }
    }
}
