# Long-reads-shotgun-metagenomics-of-rice-straw-decomposition

This repository contains scripts and workflows for benchmarking **MATAWGS** and **Hifi-MAG-Pipeline** and also  **LorBin** and **SemiBin2** for contig-level binning of long-read metagenomic assemblies. The analysis was performed on PacBio HiFi datasets, comparing the performance of the two binners in terms of genome completeness, contamination, and overall bin quality was done with **MAGFlow**.

**MetaWGS**, **Hifi-MAG-pipeline**
**LorBin** uses a self-supervised variational autoencoder to generate contig embeddings based on k-mer frequencies and abundance, followed by a two-stage adaptive clustering strategy. **SemiBin2** applies self-supervised contrastive learning with must-link and cannot-link constraints to learn contig embeddings and uses a DBSCAN-based ensemble clustering approach for long-read assemblies.  

The repository includes:
- Scripts to run LorBin and SemiBin2 on metagenomic assemblies
- Workflow for pre-processing, mapping, and generating coverage information
- Analysis scripts to evaluate binning quality using metrics such as completeness and contamination
