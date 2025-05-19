# ONT Read QC Pipeline

A Nextflow pipeline for quality control of Oxford Nanopore Technologies (ONT) sequencing data, featuring adapter trimming, host DNA removal, and quality metrics generation.

## Overview

This pipeline processes raw ONT FASTQ files through three main steps:
1. **Adapter Trimming** (Porechop)
2. **Host DNA Removal** (Kraken2 with CHM13 human genome database)
3. **Quality Assessment** (NanoStat)

![Pipeline Workflow](workflow_diagram.png) *(Consider adding a diagram later)*

## Requirements

- Nextflow (>= 22.10.0)
- Conda or Mamba
- Java (>= 8)
- 10+ CPU cores recommended
- 16GB+ RAM recommended

## Installation

```bash
git clone https://github.com/Dhananjayak24/qc_pipeline_nextflow.git
cd qc_pipeline_nextflow
