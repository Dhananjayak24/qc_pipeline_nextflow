process QUALITY_CHECK {
    './env/nanostat.yml'
    tag "${hostTrimmed_fastq.simpleName.replaceAll('hostTrimmed_','')}"
    publishDir "${params.qc_output}/${params.run_number}", mode : 'copy'

    input:
    file hostTrimmed_fastq

    output:
    path "qc_complete.txt", emit: qc_written
    path "ont_qc/${hostTrimmed_fastq.simpleName.replaceAll('hostTrimmed_','')}.txt"

    script:
    """
    #!/bin/bash
    set -e

    #Variable declaration
    sample_name=${hostTrimmed_fastq.simpleName.replaceAll('hostTrimmed_', '')}
    log_file="${params.log_dir}/qc_log.csv"
    output_txt="ont_qc/${hostTrimmed_fastq.simpleName.replaceAll('hostTrimmed_','')}.txt"

    echo "Processing file: ${hostTrimmed_fastq.simpleName}"
    #ensure output directory exists
    mkdir -p ont_qc
    #Printing exact command for debugging
    #echo "conda run -n nanostat NanoStat --fastq ${hostTrimmed_fastq} > ont_qc/${hostTrimmed_fastq.simpleName.replaceAll('hostTrimmed_','')}.txt"
    
    #command
    # Run nanostat
    conda run -n nanostat \\
        NanoStat --fastq ${hostTrimmed_fastq} \\
        > "\$output_txt" \\
    
    # Extract key metrics
    Q5_bases=\$(grep "^>Q5:" "\$output_txt" | awk '{print \$4}' | sed 's/,//g')
    mean_read_length=\$(grep "Mean read length:" "\$output_txt" | awk -F ':' '{print \$2}' | xargs | sed 's/,//g')
    number_of_reads=\$(grep "Number of reads:" "\$output_txt" | awk -F ':' '{print \$2}' | xargs | sed 's/,//g')
    total_bases=\$(grep "Total bases:" "\$output_txt" | awk -F ':' '{print \$2}' | xargs | sed 's/,//g')

    full_path="${params.qc_output}/${params.run_number}/\$(basename "\$output_txt")"

    # Append log entry atomically using flock
    (
        flock -x 200
        if [ ! -f "\$log_file" ]; then
            echo "sample_name,Q5_bases,mean_read_length,number_of_reads,total_bases,qc_report_path" > "\$log_file"
        fi
        echo "\${sample_name},\${Q5_bases},\${mean_read_length},\${number_of_reads},\${total_bases},\${full_path}" >> "\$log_file"
    ) 200>"\${log_file}.lock"

    echo "QC writing completed at \$(date)" > qc_complete.txt
    """
}
