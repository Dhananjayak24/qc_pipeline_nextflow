/*

*/
process ADAPTER_TRIMMING {
    './env/porechop.yml'  // Assuming this activates the correct Conda environment
    tag "${fastq_file.simpleName}"
    publishDir "${params.qc_output}/${params.run_number}", mode: 'copy'

    input:
    path fastq_file

    output:
    path "adapter_trimmed/adapterTrimmed_${fastq_file.simpleName}.fastq", emit: trimmed_fastq_ch

    script:
    """
    #!/bin/bash
    set -e

    sleep 5
    # Variables
    sample_name=\$(basename "${fastq_file}" .fastq)
    log_file="${params.log_dir}/adapter_trim_log.csv"
    output_fastq="adapter_trimmed/adapterTrimmed_\${sample_name}.fastq"

    # Create output dir
    mkdir -p adapter_trimmed

    # Run Porechop and capture middle adapter trimming info
    middle_trimmed_adapter=\$(porechop -i "${fastq_file}" \\
        -o "\$output_fastq" \\
        --discard_middle --verbosity 1 \\
        -t 10 \\
        | grep -E '[0-9]+ / [0-9,]+ reads were discarded based on middle adapters' || echo "No middle adapter info")

    # Remove commas from the output (optional, but helpful for clean CSV)
    middle_trimmed_cleaned=\$(echo "\$middle_trimmed_adapter" | sed 's/,//g')

    full_path="${params.qc_output}/${params.run_number}/adapter_trimmed/\$(basename "\$output_fastq")"

    # Append log entry atomically using flock
    (
        flock -x 200
        if [ ! -f "\$log_file" ]; then
            echo "sample_name,porechop_summary,adapter_trimmed_path" > "\$log_file"
        fi
        echo "\${sample_name},\"\${middle_trimmed_cleaned}\",\"\${full_path}\"" >> "\$log_file"
    ) 200>"\${log_file}.lock"
    """
}
