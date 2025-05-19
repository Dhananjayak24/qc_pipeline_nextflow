#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

params.input_path = '/input_files/'
params.qc_output = '/media/d1672139-af38-4080-8ce9-3acbf29c35a5/projects/practice_folder/rsync/qc_output'

//calling modules
include { ADAPTER_TRIMMING } from './modules/adapter_trimming.nf'
include { HOST_DNA_TRIMMING } from './modules/host_dna_trimming.nf'
include { QUALITY_CHECK } from './modules/quality_check.nf'

workflow {

    // STEP 1: Creating channel for fastq files
    fastq_ch = Channel.fromPath("${params.input_path}/*.fastq")
    trimmed_fastq_ch = ADAPTER_TRIMMING(fastq_ch)

    // Step 2: Host DNA trimming
    trimmed_host_ch = HOST_DNA_TRIMMING(trimmed_fastq_ch).trimmed_host_ch

    // Step 3: Quality check
    qc_output = QUALITY_CHECK(trimmed_host_ch)
}

