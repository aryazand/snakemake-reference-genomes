rule efetch_accession:
    output:
        "results/{genome}/ncbi/{genome}_accession.txt",
    log:
        "results/{genome}/ncbi/{genome}_accession.log",
    conda:
        "../envs/efetch.yml"
    params:
        genbank_id=lambda wc: config["data"][wc.genome]["ncbi"]["genbank"],
    message:
        "get genome assembly accession from genbank id"
    shell:
        """
        esearch -db nuccore -query {params.genbank_id} 2>{log} \
            | elink -target assembly \
            | esummary | xtract -pattern DocumentSummary -element AssemblyAccession \
            >{output}

        # Verify we actually got something
        if [ ! -s {output} ]; then
            echo "ERROR: Could not resolve assembly accession for {params.genbank_id}" >&2
            exit 1
        fi
        """


rule ncbi_datasets:
    input:
        branch(
            lambda wc: config["data"][wc.genome]["ncbi"]["assembly"],
            then=[],
            otherwise=rules.efetch_accession.output,
        ),
    output:
        fasta="results/{genome}/ncbi/{genome}.fasta",
        gff="results/{genome}/ncbi/{genome}.gff3",
    log:
        "results/{genome}/ncbi/{genome}.log",
    conda:
        "../envs/ncbi_datasets.yml"
    params:
        accession=lambda wc: config["data"][wc.genome]["ncbi"]["assembly"],
        extra=lambda wc: config["data"][wc.genome]["ncbi"]["extra"] or "",
    message:
        "download genome genome from NCBI"
    shell:
        """
        # Use a local scratch directory
        WORKDIR=$(mktemp -d)
        trap "rm -rf $WORKDIR" EXIT

        # Determine genome assembly accession
        if [[ -n "{params.accession}" ]]; then
            ACCESSION="{params.accession}"
        else
            ACCESSION=$(tail -1 {input})
        fi

        echo "Using accession: $ACCESSION" >{log}

        # Download genome
        datasets download genome accession "$ACCESSION" \
            --include genome,gff3 {params.extra} \
            --filename "$WORKDIR/genome.zip" >>{log} 2>&1

        # Unzip
        unzip -o "$WORKDIR/genome.zip" -d "$WORKDIR/genome" >>{log} 2>&1

        # Collect FASTA
        find "$WORKDIR/genome" -name "*.fna" | sort | xargs cat >{output.fasta}

        # Collect GFF3
        find "$WORKDIR/genome" -name "*.gff" | sort | xargs cat >{output.gff}
        """

rule get_fasta:
    input:
        branch(
            lambda wc: config["data"][wc.genome]["source"] == "local",
            then=lambda wc: local(config["data"][wc.genome]["local"]["fasta"]),
            otherwise=rules.ncbi_datasets.output.fasta,
        ),
    output:
        "results/{combined_genome}/fasta/{genome}.fasta",
    log:
        "results/{combined_genome}/fasta/{genome}_fasta.log",
    wildcard_constraints:
        genome="|".join(REFERENCE_GENOMES),
    conda:
        "../envs/basic.yml"
    message:
        "obtaining fasta files"
    shell:
        """
        input_file=$(realpath {input})
        ln -s $input_file {output}
        echo 'made symbolic link from {input} to {output}' >{log}
        """

rule get_gff:
    input:
        branch(
            lambda wc: config["data"][wc.genome]["source"] == "local",
            then=lambda wc: local(config["data"][wc.genome]["local"]["gff"]),
            otherwise=rules.ncbi_datasets.output.gff,
        ),
    output:
        "results/{combined_genome}/gff/{genome}.gff",
    log:
        "results/{combined_genome}/gff/{genome}_gff.log",
    wildcard_constraints:
        genome="|".join(REFERENCE_GENOMES),
    conda:
        "../envs/basic.yml"
    shell:
        """
        input_file=$(realpath -e {input})
        ln -sf $input_file {output}
        echo 'made symbolic link from {input} to {output}' >{log}
        """