# Overview

A set of scripts to convert genbank into gtf format. 
These scripts presented here work in serials to prepare the **[Cat genome] (http://www.ncbi.nlm.nih.gov/genome/78)**  annation in gtf format from NCBI's genbank foramt.
This set of scripts could be applied to other species whose genome annotation in gtf is not available but only in genbank format for each chromosome.   

# How to run them

They are run in serials, the orders are:

1. batch_download_genbank.pl
    * Download genbank format information of each chromosome
2. batch_annotation_mRNA.pl
    * Will wrap genbank2gtf_mRNA.pl
    * In the gtf file, generate records of those exon regions
3. batch_annotation_CDS.pl
    * Will wrap genbank2gtf_CDS.pl
    * In the gtf file, generate records of those CDS regions, but from each chromosome's genbank file, we could not determine the which protein (protein_id) comes from which transcript (transcript_id), thus, we need to download other genbank files according to protein id to determine the relationship between proteins and transcripts (the next step).
4. batch_download_genbank_protein.pl
5. get_final_cat_gtf.pl

# Script's Details

## batch_download_genbank.pl

```
perldoc batch_download_genbank.pl
```

```
BATCH_DOWNLOAD_GENBANK(U1s)er Contributed Perl DocumentatBiAoTnCH_DOWNLOAD_GENBANK(1)

SSYYNNOOPPSSIISS
       Use NCBI etuils (efetch) to download each chromosome’s annotation in
       genbank format of Cat genome.

UUSSAAGGEE
       perl batch_download_genbank.pl

RREESSUULLTTSS
       In your current working directory. There will generate 20 ChrXX.gb
       files.


perl v5.12.3                      2012‐12‐19         BATCH_DOWNLOAD_GENBANK(1)
```

## genbank2gtf_mRNA.pl

```
perldoc genbank2gtf_mRNA.pl
```

```

GENBANK2GTF_MRNA(1)   User Contributed Perl Documentation  GENBANK2GTF_MRNA(1)



SSYYNNOOPPSSIISS
       Given a genbank format file (.gb), parse its feature parts (mRNA
       feature to get exon regions) to get information like transcript id,
       gene name, etc., and store the result in gtf format

UUSSAAGGEE
       perl genbank2gtf_mRNA.pl input.gb chromosome >chromosome_mRNA.gtf

RREESSUULLTTSS
       The output is a file named as chromosome_mRNA.gtf, in which chromosome
       is given as the input parameter

EEXXOONN RREEGGIIOONN PPAARRSSEE
   CCOODDEE
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

               if($strand eq "−"){
                   @start=reverse @start;
                   @end=reverse @end;
               }
           }

   EEXXAAMMPPLLEE
            mRNA            complement(join(102429..103045,104811..104942,
                            105561..105643,105732..105835,105910..106035))
                            /gene="CCDC115"
                            /product="coiled−coil domain containing 115"
                            /note="Derived by automated computational analysis using
                            gene prediction method: GNOMON. Supporting evidence
                            includes similarity to: 4 ESTs, 1 Protein"
                            /transcript_id="XM_003980242.1"
                            /db_xref="GI:410947098"
                            /db_xref="GeneID:101080349"



perl v5.12.3                      2012‐12‐19               GENBANK2GTF_MRNA(1)
```

## batch_annotation_mRNA.pl

```
perldoc batch_annotation_mRNA.pl
```

```
BATCH_ANNOTATION_MRNA(1U)ser Contributed Perl DocumentatiBoAnTCH_ANNOTATION_MRNA(1)



SSYYNNOOPPSSIISS
       A wrap of genbank2gtf_mRNA.pl to batch convert genbank format into gtf
       (only those mRNA features)

UUSSAAGGEE
       perl batch_annotation_mRNA.pl

RREESSUULLTTSS
       20 chrXX_mRNA.gtf files



perl v5.12.3                      2012‐12‐19          BATCH_ANNOTATION_MRNA(1)
```


## genbank2gtf_CDS.pl

```
perldoc genbank2gtf_CDS.pl
```

```
GENBANK2GTF_CDS(1)    User Contributed Perl Documentation   GENBANK2GTF_CDS(1)



SSYYNNOOPPSSIISS
       Given a genbank format file (.gb), parse its feature parts (CDS feature
       to get CDS regions) to get information like transcript id, gene name,
       etc., and store the result in gtf format

UUSSAAGGEE
       perl genbank2gtf_CDS.pl input.gb chromosome >chromosome_CDS.gtf

RREESSUULLTTSS
       The output is a file named as chromosome_CDS.gtf, in which chromosome
       is given as the input parameter

EEXXOONN RREEGGIIOONN PPAARRSSEE
   CCOODDEE
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


               if($strand eq "−"){
                   @start=reverse @start;
                   @end=reverse @end;
               }
           }

   EEXXAAMMPPLLEE
            CDS             complement(join(102933..103045,104811..104942,
                            105561..105643,105732..105835,105910..106020))
                            /gene="CCDC115"
                            /note="Derived by automated computational analysis using
                            gene prediction method: GNOMON."
                            /codon_start=1
                            /product="coiled−coil domain−containing protein 115"
                            /protein_id="XP_003980291.1"
                            /db_xref="GI:410947099"
                            /db_xref="GeneID:101080349"
                            /translation="MAAPDLRAELDSLLLQLFQDLEELEAKRAALNARVEEGWLSLSK
                            ARYSMGAKSVGPLQYASLMEPQVCVYTSEAQDGLQRFWLVRASAQTPEEVGPREAALR
                            RRKGLTRTPEPESFPALRDPLNWFGILVPHSLRQAQASFREGLQLAADMATLQIRIDW
                            GRSQLRGLQEKLKQLEPESA"



perl v5.12.3                      2012‐12‐19                GENBANK2GTF_CDS(1)
```

## batch_annotation_CDS.pl

```
perldoc batch_annotation_CDS.pl
```

```
BATCH_ANNOTATION_CDS(1)User Contributed Perl DocumentatioBnATCH_ANNOTATION_CDS(1)



SSYYNNOOPPSSIISS
       A wrap of genbank2gtf_CDS.pl to batch convert genbank format into gtf
       (only those CDS features)

UUSSAAGGEE
       perl batch_annotation_CDS.pl

RREESSUULLTTSS
       20 chrXX_CDS.gtf files



perl v5.12.3                      2012‐12‐19           BATCH_ANNOTATION_CDS(1)
```

## batch_download_genbank_protein.pl

```
perldoc batch_download_genbank_protein.pl
```

```
BATCH_DOWNLOAD_GENBANK_UPsReOrTECIoNn(t1r)ibuted Perl DoBcAuTmCeHn_tDaOtWiNoLnOAD_GENBANK_PROTEIN(1)



SSYYNNOOPPSSIISS
       Use NCBI etuils (efetch) to download information in genbank format with
       a given protein id (NP_XXXXX)

UUSSAAGGEE
       perl batch_download_genbank_protein.pl

RREESSUULLTTSS
       Results are stored in a subfolder named NP in your current working
       directory. Files are named is proteinid.gb



perl v5.12.3                      2012‐12‐19 BATCH_DOWNLOAD_GENBANK_PROTEIN(1)
```

## get_final_cat_gtf.pl

```
perldoc get_final_cat_gtf.pl
```

```
GET_FINAL_CAT_GTF(1)  User Contributed Perl Documentation GET_FINAL_CAT_GTF(1)



SSYYNNOOPPSSIISS
       Merge the mRNA gtf (exon) and CDS gtf (exon) together by fill the
       values of transcript_id and transcript_name in the CDS gtf file. This
       help define the relationship between transcript_id and protein_id, the
       relationship is parsed from the proteinid.gb file

UUSSAAGGEE
       perl get_final_cat_gtf.pl

RREESSUULLTTSS
       In your current working directory. There will generate a file named as
       felCat5_final.gtf



perl v5.12.3                      2012‐12‐19              GET_FINAL_CAT_GTF(1)
```
