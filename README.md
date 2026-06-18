# Genotyping

## Genome-wide genotyping using pangenome reference

### Requirements

- python > 3.10
- snakemake
- pangenie
- bcftools
- tabix

#### Reference data

[Reference genome in fasta format](https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGSVC2/technical/reference/20200513_hg38_NoALT/hg38.no_alt.fa.gz)

[PanGenie-ready VCFs and Callsets](https://github.com/eblerjana/pangenie/wiki/D:-Running-PanGenie-on-HPRC-data)

[Script for biallelic covertion](https://github.com/eblerjana/pangenie-workshop/blob/main/pipelines/snakemake-pipeline/workflow/scripts/convert-to-biallelic.py)

## Targeted genotyping

### Requirements

- python > 3.10
- snakemake
- locityper

#### Reference data

For CRAM files specific reference should be used (specification can be found in CRAM header). 
Provide gz version to the pipeline. 

[Reference genome in fasta format](https://42basepairs.com/browse/s3/1000genomes/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa)

For fastq files same reference genome as used for PanGenie should be sufficient.

[Pangenome VCF raw](https://s3-us-west-2.amazonaws.com/human-pangenomics/index.html?prefix=pangenomes/scratch/2025_12_23_minigraph_cactus/hprc-v2.1-mc-grch38/hprc-v2.1-mc-grch38.raw.vcf.gz)

[Script for json to csv conversion](https://github.com/tprodanov/locityper/blob/main/extra/into_csv.py)

[Additional script for into_csv.py](https://github.com/tprodanov/locityper/blob/main/extra/common.py)

[Test file with loci](https://locityper.vercel.app/test_dataset)
