if LIBRARY_TYPE == "pe":

    rule aln_preprocessing:
        """
        Examine read alignments with test data
        """
        input:
            alignment = f"{INPUT_DIR}/{{sample}}.cram",
            genome_fasta = rules.unzip_reference.output.unzipped_fasta,
            jf_counts = rules.count_k_mers_in_reference.output.jf_counts
        output:
            directory("{output}/{sample}/reads_test/")
        log:
            "{output}/{sample}/reads_test/reads_preproc.log"
        threads:
            THREADS_NUMBER
        shell:
            """
            locityper preproc -a {input.alignment} -r {input.genome_fasta} -j {input.jf_counts} -o {output} --threads {threads} &> {log}
            """


else:

    rule aln_preprocessing:
        """
        Examine read alignments with test data with full check (--no-index)
        """
        input:
            alignment = f"{INPUT_DIR}/{{sample}}.cram",
            genome_fasta = rules.unzip_reference.output.unzipped_fasta,
            jf_counts = rules.count_k_mers_in_reference.output.jf_counts
        output:
            directory("{output}/{sample}/reads_test/")
        log:
            "{output}/{sample}/reads_test/reads_preproc.log"
        threads:
            THREADS_NUMBER
        shell:
            """
            locityper preproc --no-index -a {input.alignment} -r {input.genome_fasta} -j {input.jf_counts} -o {output} --threads {threads} &> {log}
            """


rule locityper_genotype:
    """
    Run genotyping
    """
    input:
        alignment = f"{INPUT_DIR}/{{sample}}.cram",
        loci_database = rules.create_loci_database.output,
        preprocessed_aln = rules.aln_preprocessing.output,
        genome_bed = REFERENCE_BED
    output:
        directory("{output}/{sample}/genotypes/")
    log:
        "{output}/{sample}/genotypes/genotyping.log"
    threads:
        THREADS_NUMBER
    shell:
        """
        locityper genotype -O 1 -a {input.alignment} -d {input.loci_database} --recr-bed {input.genome_bed} -p {input.preprocessed_aln} -o {output} --threads {threads} &> {log}
        """
