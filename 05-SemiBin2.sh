#!/usr/bin/env bash
#SBATCH --time=5-14:00:00
#SBATCH --mem=192G
#SBATCH --cpus-per-task=20
#SBATCH --job-name=semibin
#SBATCH --output=/data/users/fkurz/metagenomics/output/output-semibin/output_%j.o
#SBATCH --error=/data/users/fkurz/metagenomics/output/output-semibin/error_%j.e
#SBATCH --mail-user=florence.kurz@unifr.ch
#SBATCH --partition=pibu_el8

module load Anaconda3/2022.05

# IMPORTANT: initialize conda for non-interactive shell
source $(conda info --base)/etc/profile.d/conda.sh
conda activate semibin

ASSEMBLY_DIR="/data/users/fkurz/metagenomics/ASM"
MINIMAP_DIR="/data/users/fkurz/metagenomics/output/Lorbin/minimap-mappings"
OUT_DIR="/data/users/fkurz/metagenomics/output/SemiBin2"

for bc in bc2161 bc2162; do # bc2128 bc2161 bc2162 bc2163 bc2164 bc2165 bc2166 bc2167 bc2168 bc2169 bc2170 
    echo "Processing $bc"
    mkdir -p ${OUT_DIR}/${bc}

    SemiBin2 single_easy_bin \
        -i ${ASSEMBLY_DIR}/${bc}/*.p_ctg.fa \
        -b ${MINIMAP_DIR}/${bc}.sorted.bam \
        -o ${OUT_DIR}/${bc} \
        -t 20

    echo "$bc done"
done
