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


rule extract_targets:
    """
    Extract haplotypes from the set of reference assemblies 
    """
    input:
        hprc_assemblies = REFERENCE_ASSEMBLIES,
        assembly_aliases = ASSEMBLY_ALIASES,
        ref_fasta = rules.unzip_reference.output.unzipped_fasta,
        loci_coordinates = LOCI_COORDINATES
    output:
        directory("{output}/ref/extracted_haplotypes/")
    log:
        "{output}/ref/extract_haplotypes.log"
    shell:
        """
        extract-targets.sh -i {input.ref_fasta} -i {input.hprc_assemblies} -n {input.assembly_aliases} -c {input.loci_coordinates} -r {input.ref_fasta} -o {output} &> {log}
        """


rule create_loci_database:
    """
    Create loci database and locus haplotypes
    """
    input:
        ref_fasta = rules.unzip_reference.output.unzipped_fasta,
        jf_counts = rules.count_k_mers_in_reference.output.jf_counts,
        extracted_targets = f"{output}/ref/extracted_haplotypes/targets.bed"
    output:
        directory("{output}/ref/loci_db/")
    log:
        "{output}/ref/loci_db.log"
    shell:
        """
        locityper target -d {output} -r {input.ref_fasta} -j {input.jf_counts} -L {input.extracted_targets} &> {log}
        """
