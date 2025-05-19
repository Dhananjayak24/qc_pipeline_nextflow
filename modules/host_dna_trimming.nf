//Trimming human DNA
process HOST_DNA_TRIMMING {
    //conda './env/kraken2.yml'
    tag "${trimmed_fastq.simpleName.replaceAll('adapterTrimmed_','')}"
    publishDir "${params.qc_output}/${params.run_number}", mode : 'copy'

    input:
    file trimmed_fastq
    
    output:
    path "host_trimmed/hostTrimmed_${trimmed_fastq.simpleName.replaceAll('adapterTrimmed_', '')}.fastq", emit: trimmed_host_ch
    //path "log_files/kraken2_${trimmed_fastq.simpleName.replaceAll('adapterTrimmed_', '')}.txt", emit: log_host_ch

    script:
    """
    #!/bin/bash
    set -e

    # declaring variables
    sample_name=${trimmed_fastq.simpleName.replaceAll('adapterTrimmed_', '')}
    log_file="${params.log_dir}/host_trim_log.csv"
    output_fastq="host_trimmed/hostTrimmed_${trimmed_fastq.simpleName.replaceAll('adapterTrimmed_', '')}.fastq"

    
    #echo "Processing file: ${trimmed_fastq.simpleName}"
    #ensure output directory exists
    mkdir -p host_trimmed
    #mkdir -p log_files
    #Printing exact command for debugging
    #echo "conda run -n kraken2 kraken2 --db /media/decodeage/d1672139-af38-4080-8ce9-3acbf29c35a5/projects/internal_projects/minimap2/kraken2_chm13db/CHM13_kraken2_db --unclassified-out host_trimmed/hostTrimmed_${trimmed_fastq.simpleName.replaceAll('adapterTrimmed_', '')}.fastq ${trimmed_fastq} ${trimmed_fastq} 2>&1 >/dev/null | grep -E 'classified|unclassified' | tail -n 2 | uniq > "log_files/kraken2_${trimmed_fastq.simpleName.replaceAll('adapterTrimmed_', '')}.txt" || touch "log_files/kraken2_${trimmed_fastq.simpleName.replaceAll('adapterTrimmed_', '')}.txt""
    
    #command
    # Run kraken2 and filter stderr to capture only summary statistics
    kraken2_output=\$(conda run -n kraken2\\
        kraken2 --db /media/decodeage/d1672139-af38-4080-8ce9-3acbf29c35a5/projects/internal_projects/minimap2/kraken2_chm13db/CHM13_kraken2_db \\
        --unclassified-out "\$output_fastq" \\
        "${trimmed_fastq}" 2>&1 >/dev/null | grep -E 'classified|unclassified' | tail -n 2 | uniq || echo "No classification info")
    
    #Clean commas from output
    kraken2_output_cleaned=\$(echo "\$kraken2_output" | sed 's/,//g')

    full_path="${params.qc_output}/${params.run_number}/host_trimmed/\$(basename "\$output_fastq")"

    # Append log entry atomically using flock
    (
        flock -x 200
        if [ ! -f "\$log_file" ]; then
            echo "sample_name,kraken2_summary,host_trimmed_path" > "\$log_file"
        fi
        echo "\${sample_name},\"\${kraken2_output_cleaned}\",\"\${full_path}\"" >> "\$log_file"
    ) 200>"\${log_file}.lock"
    """
}
