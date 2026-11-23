rule minimap2_index:
    input:
        target="results/{genome}/fasta/{genome}.fasta",
    output:
        index="results/{genome}/minimap2/{genome}.mmi",
    log:
        "results/{genome}/minimap2/{genome}.log",
    threads: 1
    params:
        extra=lambda wc: GENOMES[wc.genome]["asset"]["minimap2"]
    wrapper:
        "v7.1.0/bio/minimap2/index"
