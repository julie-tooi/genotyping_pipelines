rule samtools_index:
    """
    Create index for input CRAM files
    """
    input:
       alignment = f"{INPUT_DIR}/{{sample}}.cram"
    output:
       alignment_index = f"{INPUT_DIR}/{{sample}}.cram.crai"
    threads:
        THREADS_NUMBER
    shell:
       """
       samtools index -o {output.alignment_index} --threads {threads} {input.alignment}
       """


rule aln_preprocessing:
    """
    Examine read alignments with test data
    """
    input:
        alignment = f"{INPUT_DIR}/{{sample}}.cram",
        alignment_index = rules.samtools_index.output.alignment_index,
        genome_fasta = rules.unzip_reference.output.unzipped_fasta,
        jf_counts = rules.count_k_mers_in_reference.output.jf_counts
    output:
        directory("{output}/read_test/{sample}_reads_test/")
    log:
        "{output}/read_test/{sample}_reads_test/reads_preproc.log"
    threads:
        THREADS_NUMBER
    shell:
        """
        locityper preproc -a {input.alignment} -r {input.genome_fasta} -j {input.jf_counts} -o {output} --threads {threads} &> {log}
        """


rule locityper_genotype:
    """
    Run genotyping
    """
    input:
        alignment = f"{INPUT_DIR}/{{sample}}.cram",
        alignment_index = rules.samtools_index.output.alignment_index,
        loci_database = rules.create_loci_database.output,
        preprocessed_aln = rules.aln_preprocessing.output
    output:
        directory("{output}/genotyping/{sample}/")
    log:
        "{output}/genotyping/{sample}_genotyping.log"
    threads:
        THREADS_NUMBER
    params:
        reference_fasta = rules.unzip_reference.output.unzipped_fasta,
        reference_index = rules.samtools_index_reference.output.genome_index
    shell:
        """
        locityper genotype -a {input.alignment} -d {input.loci_database} -p {input.preprocessed_aln} -r {params.reference_fasta} -o {output} --threads {threads} &> {log}
        """


rule convert_output_to_csv:
    """
    Convert json output to one merged csv
    """
    input:
        json_output_logs = expand("{{output}}/genotyping/{sample}_genotyping.log",sample = samples)
    output:
        csv_output = "{output}/merged-genotypes.csv"
    params:
        path_to_input = lambda wildcards: f"{wildcards.output}/genotyping/./*"
    shell:
        """
        python3 scripts/into_csv.py -i {params.path_to_input} -o {output.csv_output}
        """