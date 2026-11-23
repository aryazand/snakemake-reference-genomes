# snakemake-reference-genomes

This is a snakemake based workflow to create reference genome assets. 

Features include:
  1. combine an arbitrary number of genomes into individual individual asset (e.g. genome + spike-in, host + pathogen genome etc)
  2. assets: fasta index, bowtie2 index, bwamem2 index, minimap2 index, STAR index

To Do: 
  1. Demonstrate methods for combining with datalad
  2. Github Actions for CI/CD
  3. Validation Schema for config.yaml

The workflow is built using [snakemake](https://snakemake.readthedocs.io/en/stable/).


## Authors

- Arya Zandvakili MD PhD
  - Affiliation: University of Cincinnati College of Medicine
  - ORCID profile: https://orcid.org/my-orcid?orcid=0000-0001-8031-8067
  - github page: https://github.com/aryazand

## References

> Köster, J., Mölder, F., Jablonski, K. P., Letcher, B., Hall, M. B., Tomkins-Tinch, C. H., Sochat, V., Forster, J., Lee, S., Twardziok, S. O., Kanitz, A., Wilm, A., Holtgrewe, M., Rahmann, S., & Nahnsen, S. _Sustainable data analysis with Snakemake_. F1000Research, 10:33, 10, 33, **2021**. https://doi.org/10.12688/f1000research.29032.2.