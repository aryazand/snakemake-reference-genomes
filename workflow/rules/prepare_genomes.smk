rule add_prefix_to_fasta:
    """Prepend '<prefix>_' to every contig name in a reference FASTA."""
    input:
        rules.get_fasta.output,
    output:
        "results/{combined_genome}/fasta/{genome}_prefixed.fasta",
    log:
        "results/{combined_genome}/fasta/{genome}_prefixed.fasta.log",
    conda:
        "../envs/basic.yml"
    params:
        prefix=lambda wc: GENOMES[wc.combined_genome]["prefix"][wc.genome],
    shell:
        """
        awk -v pfx="{params.prefix}" '
            /^>/ {{ print ">" pfx "_" substr($0, 2) }}
            !/^>/ {{ print }}
        ' {input} >{output} 2>{log}
        """


rule add_prefix_to_gff:
    """
    Add a prefix to every contig name (column 1) in a GFF file.
    Handles standard GFF2/GFF3 format; skips comment lines.
    """
    input:
        rules.get_gff.output,
    output:
        "results/{combined_genome}/gff/{genome}_prefixed.gff",
    log:
        "results/{combined_genome}/gff/{genome}_prefixed.gff.log",
    conda:
        "../envs/basic.yml"
    params:
        prefix=lambda wc: GENOMES[wc.combined_genome]["prefix"][wc.genome],
    wildcard_constraints:
        genome="|".join(REFERENCE_GENOMES),
        combined_genome="|".join(GENOMES.keys()),
    shell:
        """
        awk -v pfx="{params.prefix}" '
            /^#/ {{ print; next }}
            NF   {{
                idx = index($0, "\\t")
                print pfx "_" substr($0, 1, idx-1) substr($0, idx)
            }}
        ' {input} >{output} 2>{log}
        """

rule concatenate_reference:
    """Concatenate an arbitrary number of prefixed reference FASTAs."""
    input:
        get_genome_files,
    output:
        "results/{combined_genome}/{filetype}/{combined_genome}.{filetype}",
    log:
        "results/{combined_genome}/{filetype}/{combined_genome}.log",
    conda:
        "../envs/seqtk.yml"
    message:
        "concatenate reference {wildcards.filetype} file"
    shell:
        """
        if [ "{wildcards.filetype}" = "fasta" ]; then
            cat {input} | seqtk seq -l 60 > {output} 2> {log}
        else
            cat {input} > {output} 2> {log}
        fi
        """


# ─────────────────────────────────────────────────────────────────────────────
# 3. Create chromosome index of reference contigs
# ─────────────────────────────────────────────────────────────────────────────

rule samtools_faidx:
    input:
        "results/{combined_genome}/fasta/{combined_genome}.fasta",
    output:
        "results/{combined_genome}/fasta/{combined_genome}.fa.fai",
    log:
        "results/{combined_genome}/fasta/{combined_genome}.fa.fai.log",
    params:
        extra="",
    wrapper:
        "v9.19.5/bio/samtools/faidx"

rule get_chr_bed:
    input:
        rules.samtools_faidx.output,
    output:
        "results/{combined_genome}/bed/{combined_genome}.bed",
    log:
        "results/{combined_genome}/bed/{combined_genome}.bed.log",
    conda:
        "../envs/get_chr_bed.yml"
    message:
        "create bed file of reference contigs"
    shell:
        """
        awk '{{print $1 "\t0\t" $2}}' {input} >{output}
        """
