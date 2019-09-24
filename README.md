# nORF-VEP-annotation
Annotate vcf variants sets in the context of novel ORFs using Ensembl's Variant Effect Predictor (VEP).

## Getting Started

These instructions will outline the relevant software and files to download for the analysis.

### Prerequisites

1. Docker
2. R with tidyverse installed


### Downloads

1. Download vep docker image
2. Download cache and fasta for GRCh37 and/or GRCh38
    ```
    #Example for GRCh37
    docker run -t -i -v $HOME/vep_data:/opt/vep/.vep ensemblorg/ensembl-vep perl INSTALL.pl -a cf -s homo_sapiens -y GRCh37
    #Example for GRCh38
    docker run -t -i -v $HOME/vep_data:/opt/vep/.vep ensemblorg/ensembl-vep perl INSTALL.pl -a cf -s homo_sapiens -y GRCh38
    ```
3. Download bedToGenePred and gtfToGenePred
    ```
    wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/bedToGenePred
    wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/gtfToGenePred
    chmod u+x bedToGenePred
    chmod u+x gtfToGenePred
    ```
4. Download of clone `gtfMaker.R` from this repository.
5. Generate nORFs bed file (`noInFrame_19.bed` and/or `noInFrame_38.bed`) files from https://github.com/PrabakaranGroup/nORF-data-prep
6. Download VCF files of interest
For examples here we will show COSMIC coding variants and gnomAD exomes as examples. For COSMIC [register](https://cancer.sanger.ac.uk/cosmic/download) then unzip and download the coding `.vcf` file to a new directory called `Cosmic`. For [gnomAD](https://gnomad.broadinstitute.org/downloads) download the exomes `.vcf` files. 

## Process nORFs bed file into a usable GTF file for custom annotations

In hg19:
```
./bedToGenePred noInFrame_19.bed temp.norfs_19.gp
./genePredToGtf file temp.norfs_19.gp temp.norfs_19.gtf
Rscript gtfMaker.R temp.norfs_19.gtf
rm temp.*
grep -v "#" norfs_19.gtf | sort -k1,1 -k4,4n -k5,5n -t$'\t' | bgzip -c > norfs_19.gtf.gz
tabix -p gff norfs_19.gtf.gz
```
In hg38
```
./bedToGenePred noInFrame_38.bed temp.norfs_38.gp
./genePredToGtf file temp.norfs_38.gp temp.norfs_38.gtf
Rscript gtfMaker.R temp.norfs_38.gtf
rm temp.*
grep -v "#" norfs_38.gtf | sort -k1,1 -k4,4n -k5,5n -t$'\t' | bgzip -c > norfs_38.gtf.gz
tabix -p gff norfs_38.gtf.gz
```

## Annotate variants in nORF and canonical contexts
This code is for VEP 96, which can be up updated in these lines to the VEP version being used.
```
#gnomadExomes norfs
docker run -d -t -i -v $HOME/vep_data:/opt/vep/.vep ensemblorg/ensembl-vep ./vep -i /opt/vep/.vep/gnomADexomes.vcf -o /opt/vep/.vep/gnomadExomes_norfs.vcf --port 3337 --gtf /opt/vep/.vep/norfs_19.gtf.gz --force_overwrite --most_severe --fasta /opt/vep/.vep/homo_sapiens/96_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz 
#gnomadExomes canonical
docker run -d -t -i -v $HOME/vep_data:/opt/vep/.vep ensemblorg/ensembl-vep ./vep -i /opt/vep/.vep/gnomADexomes.vcf -o /opt/vep/.vep/gnomadExomes_vep.vcf --port 3337 --cache --force_overwrite --most_severe --fasta /opt/vep/.vep/homo_sapiens/96_GRCh37/Homo_sapiens.GRCh37.75.dna.primary_assembly.fa.gz 

#Cosmic Coding norfs
docker run -d -t -i -v $HOME/vep_data:/opt/vep/.vep ensemblorg/ensembl-vep ./vep -i /opt/vep/.vep/CosmicCodingMuts.vcf -o /opt/vep/.vep/cosmicCoding_norfs.vcf --gtf /opt/vep/.vep/norfs_38.gtf.gz --force_overwrite --most_severe --fasta /opt/vep/.vep/homo_sapiens/96_GRCh38/Homo_sapiens.GRCh38.dna.toplevel.fa.gz  
#Cosmic Coding canonical
docker run -d -t -i -v $HOME/vep_data:/opt/vep/.vep ensemblorg/ensembl-vep ./vep -i /opt/vep/.vep/CosmicCodingMuts.vcf -o /opt/vep/.vep/cosmicCoding_vep.vcf --cache --force_overwrite --most_severe 

```

## Authors

Matt Neville (Department of Genetics, University of Cambridge)

## Acknowledgments
Supervisor: Sudhakaran Prabakaran (https://prabakaran-group.org/)
