rule bowtie2_build:
    input:
        ref="results/{genome}/fasta/{genome}.fasta",
    output:
        multiext(
            "results/{genome}/bowtie2/{genome}",
            ".1.bt2",
            ".2.bt2",
            ".3.bt2",
            ".4.bt2",
            ".rev.1.bt2",
            ".rev.2.bt2",
        ),
    log:
        "results/{genome}/bowtie2/build.log",
    threads: 1
    params:
        extra=lambda wc: GENOMES[wc.genome]["asset"]["bowtie2"]
    message:
        "build bowtie2 index"
    wrapper:
        "v9.19.4/bio/bowtie2/build"