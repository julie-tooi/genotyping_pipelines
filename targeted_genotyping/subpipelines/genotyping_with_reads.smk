if LIBRARY_TYPE == "pe":

    rule reads_preprocessing:
        """
        Examine reads with test data
        """
        input:
            forward_reads = f"{INPUT_DIR}/{{sample}}_1.fastq.gz",
            reverse_reads = f"{INPUT_DIR}/{{sample}}_2.fastq.gz",
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
            locityper preproc -i {input.forward_reads} {input.reverse_reads} -r {input.genome_fasta} -j {input.jf_counts} -o {output} --threads {threads} &> {log}
            """


    rule locityper_genotype:
        """
        Run genotyping
        """
        input:
            forward_reads = f"{INPUT_DIR}/{{sample}}_1.fastq.gz",
            reverse_reads = f"{INPUT_DIR}/{{sample}}_2.fastq.gz",
            loci_database = rules.create_loci_database.output,
            preprocessed_reads = rules.reads_preprocessing.output
        output:
            directory("{output}/{sample}/genotypes/")
        log:
            "{output}/{sample}/genotypes/genotyping.log"
        threads:
            THREADS_NUMBER
        shell:
            """
            locityper genotype -i {input.forward_reads} {input.reverse_reads} -d {input.loci_database} -p {input.preprocessed_reads} -o {output} --threads {threads} &> {log}
            """


else:

    rule reads_preprocessing:
        """
        Examine reads with test data
        """
        input:
            reads = f"{INPUT_DIR}/{{sample}}.fastq.gz",
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
            locityper preproc -i {input.reads} -r {input.genome_fasta} -j {input.jf_counts} -o {output} --threads {threads} &> {log}
            """


    rule locityper_genotype:
        """
        Run genotyping
        """
        input:
            reads = f"{INPUT_DIR}/{{sample}}.fastq.gz",
            loci_database = rules.create_loci_database.output,
            preprocessed_reads = rules.reads_preprocessing.output
        output:
            directory("{output}/{sample}/genotypes/")
        log:
            "{output}/{sample}/genotypes/genotyping.log"
        threads:
            THREADS_NUMBER
        shell:
            """
            locityper genotype -i {input.reads} -d {input.loci_database} -p {input.preprocessed_reads} -o {output} --threads {threads} &> {log}
            """
