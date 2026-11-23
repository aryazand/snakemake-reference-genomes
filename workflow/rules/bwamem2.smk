rule bwa_mem2_index:
    input:
        ref="results/{genome}/fasta/{genome}.fasta",
    output:
        multiext(
            "results/{genome}/bwa_mem2/{genome}",
            ".0123",
            ".amb",
            ".ann",
            ".bwt.2bit.64",
            ".pac",
        ),
    log:
        "results/{genome}/bwa_mem2/{genome}.log",
    message:
        "build bwa_mem2 index"
    wrapper:
        "v7.2.0/bio/bwa-mem2/index"
