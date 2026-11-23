# import basic packages
from snakemake.utils import validate
from pathlib import Path

# ─────────────────────────────────────────────────────────────────────────────
# Helpers for processing genomes
# ─────────────────────────────────────────────────────────────────────────────

REFERENCE_GENOMES = config["data"].keys()  # list of all reference keys
GENOMES = config["genomes"]  # dict of all genome blocks

# Maps each supported tool to its sentinel output file (the file rule_all waits on)
ASSET_SENTINELS = {
    "star":    lambda g: f"results/{g}/star/SAindex",
    "bowtie2": lambda g: f"results/{g}/bowtie2/{g}.1.bt2",
    "minimap2": lambda g: f"results/{g}/minimap2/{g}.mmi",
    "bwamem2": lambda g: f"results/{g}/bwa_mem2/{g}.0123",
    "fai": lambda g: f"results/{g}/fasta/{g}.fa.fai",
}

def all_asset_targets():
    targets = []
    for genome, cfg in GENOMES.items():
        for tool in cfg["asset"]:
            targets.append(ASSET_SENTINELS[tool](genome))
    return targets

def get_genome_files(wc):
    files = []
    for genome in GENOMES[wc.combined_genome]["species"]:
        if GENOMES[wc.combined_genome]["prefix"][genome] != "":
            files.append(f"results/{wc.combined_genome}/fasta/{genome}_prefixed.{wc.filetype}")
        else:
            files.append(f"results/{wc.combined_genome}/fasta/{genome}.{wc.filetype}")
    return files