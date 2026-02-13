#!/usr/bin/env bash

#SBATCH --time=5-14:00:00
#SBATCH --mem=192G
#SBATCH --cpus-per-task=20
#SBATCH --job-name=magFlow
#SBATCH --output=/data/users/fkurz/metagenomics/output/output-MAGFlow/output_Sampled_%j.o
#SBATCH --error=/data/users/fkurz/metagenomics/output/output-MAGFlow/error_Sampled_%j.e
#SBATCH --mail-type=END
#SBATCH --mail-user=florence.kurz@unifr.ch
#SBATCH --partition=pibu_el8



#modules
module load Anaconda3/2022.05
module load Java/18.0.2.1

# Download and install Nextflow version 23.04.0
cd ~
export NXF_VER=23.04.0
curl -s https://get.nextflow.io | bash


# Move it to a bin directory
mkdir -p ~/bin
mv nextflow ~/bin/
chmod +x ~/bin/nextflow

# Add to your PATH 
export PATH=~/bin:$PATH

# Verify the version
 
nextflow -version
cd /data/users/fkurz/metagenomics
#path 

export NXF_WORK="/data/users/fkurz/metagenomics/work"
export NXF_APPTAINER_CACHEDIR="/home/fkurz/singularity_cache"
export APPTAINER_BIND="/data/users/fkurz,/tmp,/work,/scratch"
export TMPDIR=/tmp

rm -rf /data/users/fkurz/metagenomics/work
nextflow run /data/users/fkurz/metagenomics/MAGFlow/main.nf \
  -work-dir /data/users/fkurz/metagenomics/work \
  -profile apptainer \
  --csv_file /data/users/fkurz/metagenomics/magflow_input/new_none.csv \
  --gtdbtk2_db /data/users/fkurz/metagenomics/release220 \
  --outdir /data/users/fkurz/metagenomics/output_MAGFlow/new_rice_no_treatment \
  --directory_to_bind '/data/users/fkurz'

#rm -rf /data/users/fkurz/metagenomics/work
#nextflow run /data/users/fkurz/metagenomics/MAGFlow/main.nf \
 # -work-dir /data/users/fkurz/metagenomics/work \
 # -profile apptainer \
 # --csv_file /data/users/fkurz/metagenomics/magflow_input/old_none.csv \
 # --gtdbtk2_db /data/users/fkurz/metagenomics/release220 \
 # --outdir /data/users/fkurz/metagenomics/output_MAGFlow/old_rice_no_treatment \
 # --directory_to_bind '/data/users/fkurz' 

#rm -rf /data/users/fkurz/metagenomics/work
#nextflow run /data/users/fkurz/metagenomics/MAGFlow/main.nf \
 # -work-dir /data/users/fkurz/metagenomics/work2 \
 # -profile apptainer \
 # --csv_file /data/users/fkurz/metagenomics/magflow_input/new_fitotripen.csv \
 # --gtdbtk2_db /data/users/fkurz/metagenomics/release220 \
 # --outdir /data/users/fkurz/metagenomics/magflow_output/new_rice_treatment \
 # --directory_to_bind '/data/users/fkurz' 
  
#rm -rf /data/users/fkurz/metagenomics/work
#nextflow run /data/users/fkurz/metagenomics/MAGFlow/main.nf \
 # -work-dir /data/users/fkurz/metagenomics/work \
 # -profile apptainer \
 # --csv_file /data/users/fkurz/metagenomics/magflow_input/old_fitotripen.csv \
 # --gtdbtk2_db /data/users/fkurz/metagenomics/release220 \
 # --outdir /data/users/fkurz/metagenomics/output_MAGFlow/old_rice_treatment \
 # --directory_to_bind '/data/users/fkurz' \
 # -resume