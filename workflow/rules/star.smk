rule star_index:
    input:
        fasta="results/{genome}/fasta/{genome}.fasta",
    output:
        directory("results/{genome}/star/SAindex"),
    log:
        "results/{genome}/star/index.log",
    threads: 1
    params:
        extra=lambda wc: GENOMES[wc.genome]["asset"]["star"]
    message:
        "build star index"
    wrapper:
        "v3.3.7/bio/star/index"
