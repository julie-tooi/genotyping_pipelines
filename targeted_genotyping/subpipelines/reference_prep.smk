rule unzip_reference:
    """
    Unzip reference genome
    """
    input:
        zipped_fasta = REFERENCE_FASTA
    output:
        unzipped_fasta = "{output}/ref/reference.fasta"
    shell:
        """
        gunzip -c {input.zipped_fasta} > {output.unzipped_fasta}
        """


rule samtools_index_reference:
    """
    Create index with samtools
    """
    input:
       genome_fasta = rules.unzip_reference.output.unzipped_fasta
    output:
       genome_index = "{output}/ref/reference.fasta.fai"
    shell:
       """
       samtools faidx {input.genome_fasta}
       """


rule count_k_mers_in_reference:
    """
    Count kmers in reference genome
    """
    input:
       genome_fasta = rules.unzip_reference.output.unzipped_fasta,
       genome_index = rules.samtools_index_reference.output.genome_index
    output:
       jf_counts = "{output}/ref/counts.jf"
    threads:
        THREADS_NUMBER
    shell:
       """
       jellyfish count --canonical --lower-count 2 --out-counter-len 2 --mer-len 25 --threads {threads} --size 3G --output {output.jf_counts} {input.genome_fasta}
       """


rule filter_raw_vcf:
    """
    Filter overlapping variants in pangenome reference 
    """
    input:
        raw_graph = REFERENCE_GRAPH_VCF_RAW
    output:
        filtered_graph ="{output}/ref/filtered_graph_no_overlaps.vcf.gz"
    shell:
        """
        vcfbub -l 0 -i {input.raw_graph} | bgzip > {output.filtered_graph}
        tabix -p vcf {output.filtered_graph}
        """


rule create_loci_database:
    """
    Create loci database and locus haplotypes
    """
    input:
        genome_fasta = rules.unzip_reference.output.unzipped_fasta,
        filtered_graph = rules.filter_raw_vcf.output.filtered_graph,
        jf_counts = rules.count_k_mers_in_reference.output.jf_counts,
        loci_coordinates = LOCI_COORDINATES
    output:
        directory("{output}/ref/loci_db/")
    log:
        "{output}/ref/loci_db.log"
    shell:
        """
        locityper target -d {output} -v {input.filtered_graph} -r {input.genome_fasta} -j {input.jf_counts} -L {input.loci_coordinates} &> {log}
        """