#!/usr/bin/env bash

#SBATCH --time=5-14:00:00
#SBATCH --mem=192G
#SBATCH --cpus-per-task=20
#SBATCH --job-name=gunc
#SBATCH --output=/data/users/fkurz/metagenomics/output/output-MAGFlow/output_magflow_%j.o
#SBATCH --error=/data/users/fkurz/metagenomics/output/output-MAGFlow/error_magflow_%j.e
#SBATCH --mail-type=END
#SBATCH --mail-user=florence.kurz@unifr.ch
#SBATCH --partition=pibu_el8

# This was done in srun 



create -n lorbin_env python=3.10
conda create -n lorbin_env python=3.10
srun --pty     --time=4-18:00:00     --mem=192G     --cpus-per-task=5   --partition=pibu_el8  --output=/data/users/fkurz/metagenomics/output/LORbin/output_lorbinBinning_%j.o   --error=/data/users/fkurz/metagenomics/output/LORbin/error_lorbinBinning_%j.e    bash
conda activate lorbin_env
OUT_DIR="/data/users/fkurz/metagenomics/output/Lorbin/lorbin-binning"
 
for bc in bc2121 bc2122 bc2123 bc2124  bc2126 bc2127 bc2128 bc2161 bc2162 bc2163 bc2164 bc2165 bc2166 bc2167 bc2168 bc2169 bc2170 bc2171 bc2172 bc2173 bc2174 bc2175 bc2176; do #bc2125     echo "Processing $bc...";     LorBin bin     -o ${OUT_DIR}/${bc}     -fa ${ASSEMBLY_DIR}/hifiasm_meta_${bc}/${bc}.contigs.fa     -b ${MINIMAP_DIR}/${bc}.sorted.bam ;     echo "$bc done!"; done




