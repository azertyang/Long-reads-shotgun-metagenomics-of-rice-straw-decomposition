#!/usr/bin/env bash

#SBATCH --time=5-14:00:00
#SBATCH --mem=192G
#SBATCH --cpus-per-task=20
#SBATCH --job-name=magFlow2
#SBATCH --output=/data/users/fkurz/metagenomics/output/output-MAGFlow_part2/output_Sampled_%j.o
#SBATCH --error=/data/users/fkurz/metagenomics/output/output-MAGFlow_part2/error_Sampled_%j.e
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

# This creates a 'nextflow' executable in your current directory
# Move it to a bin directory
mkdir -p ~/bin
mv nextflow ~/bin/
chmod +x ~/bin/nextflow

# Add to your PATH (add this to your ~/.bashrc to make it permanent)
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
  --csv_file /data/users/fkurz/metagenomics/magflow_input/new_fitotripen_semibin-lorbin.csv \
  --outdir /data/users/fkurz/metagenomics/output_MAGFlow/new_fitotripen_semibin-lorbin \
  --directory_to_bind '/data/users/fkurz'

