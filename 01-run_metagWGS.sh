#!/usr/bin/env bash

#SBATCH --time=5-18:00:00
#SBATCH --mem=192G
#SBATCH --cpus-per-task=48
#SBATCH --job-name=metagWGS_20
#SBATCH --output=/data/users/fkurz/metagenomics/output/output-WGS/output_metagWGS_%j.o
#SBATCH --error=/data/users/fkurz/metagenomics/output/output-WGS/error_metagWGS_%j.e
#SBATCH --mail-type=END
#SBATCH --mail-user=florence.kurz@unifr.ch
#SBATCH --partition=pibu_el8

module load Java/18.0.2.1
module load Nextflow/22.04.0
module load Python/3.9.5-GCCcore-10.3.0

export APPTAINER_TMPDIR=/data/users/fkurz/tmp
export APPTAINER_CACHEDIR=/data/users/fkurz/tmp
export SINGULARITY_TMPDIR=/data/users/fkurz/tmp
export SINGULARITY_CACHEDIR=/data/users/fkurz/tmp


mkdir -p /data/users/fkurz/tmp

# Clean partial downloads
#nextflow clean -f



# Paths
METAGWGS="/data/users/fkurz/metagenomics/metagwgs"
DATA="/data/users/fkurz/metagenomics/FASTQ"
OUTBASE="/data/users/fkurz/metagenomics/output/metagWGS"

mkdir -p "$OUTBASE"

##############################################
# RUN 1 — HiFi Assembly using Hifiasm-Meta
##############################################

mkdir -p output_hifiasm_01
cd output_hifiasm_01

 
nextflow run $METAGWGS/main.nf \
  -profile singularity \
  --type HiFi \
  --input $DATA/samplesheet.csv \
  --step "05_alignment" \
  --kaiju_db_dir /data/users/fkurz/metagenomics/databases \
  --skip_kaiju_download \
  --skip_func_annot \
  --skip_taxo_affi \
  --diamond_bank /data/users/fkurz/metagenomics/diamond_db/nr.dmnd \
  --checkm2_bank /data/users/fkurz/metagenomics/databases/checkm2DB/CheckM2_database/uniref100.KO.1.dmnd \
  --assembly hifiasm-meta \
  --skip_host_filter \
  --gtdbtk_bank /data/users/fkurz/metagenomics/release226 \
  --accession2taxid /data/users/fkurz/metagenomics/diamond_db/prot.accession2taxid.gz \
  --taxdump /data/users/fkurz/metagenomics/taxdump_files \
  --skip_kaiju \
  --outdir $OUTBASE/hifiasm \
  -with-report -with-timeline -with-trace -with-dag  \
  -resume
 
cd ..



 