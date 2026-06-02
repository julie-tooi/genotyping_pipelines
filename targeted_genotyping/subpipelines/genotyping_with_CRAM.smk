if LIBRARY_TYPE == "pe":

    rule separate_aln_to_forward_and_reverse_reads:
        """
        Separate alignment to initial files with forward and reverse reads
        """
        input:
            alignment = f"{INPUT_DIR}/{{sample}}.cram",
            genome_fasta = rules.unzip_reference.output.unzipped_fasta
        output:
            forward_reads = "{output}/{sample}/reads/{sample}_1.fastq",
            reverse_reads = "{output}/{sample}/reads/{sample}_2.fastq"
        shell:
            """
            samtools collate -O -u {input.alignment} -T {input.reference}| samtools fastq -1 {output.forward_reads} -2 {output.reverse_reads} -0 /dev/null -s /dev/null
            """


    rule reads_preprocessing:
        """
        Examine reads with test data
        """
        input:
            forward_reads = rules.separate_aln_to_forward_and_reverse_reads.output.forward_reads,
            reverse_reads = rules.separate_aln_to_forward_and_reverse_reads.output.reverse_reads,
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
            forward_reads = rules.separate_aln_to_forward_and_reverse_reads.output.forward_reads,
            reverse_reads = rules.separate_aln_to_forward_and_reverse_reads.output.reverse_reads,
            loci_database = rules.create_loci_database.output,
            preprocessed_reads = rules.reads_preprocessing.output,
            genome_bed = REFERENCE_BED
        output:
            directory("{output}/{sample}/genotypes/")
        log:
            "{output}/{sample}/genotypes/genotyping.log"
        threads:
            THREADS_NUMBER
        shell:
            """
            locityper genotype -O 1 -i {input.forward_reads} {input.reverse_reads} -d {input.loci_database} {input.genome_bed} -p {input.preprocessed_reads} -o {output} --threads {threads} &> {log}
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
            locityper genotype -O 1 -a {input.alignment} -d {input.loci_database} {input.genome_bed} -p {input.preprocessed_aln} -o {output} --threads {threads} &> {log}
            """