# nf-feelnc: A simple nf pipeline fir running feelnc tools

nf-feelnc is a Nexflow pipeline for detection of lncRNA in reference and non reference genome annotation using [feelnc](https://github.com/tderrien/FEELnc) program. It takes care of uncompressing genome and run the 3 feelnc scripts. This simple pipeline has been extracted and modified from [TAGADA](https://github.com/FAANG/analysis-TAGADA) pipeline. 

## Table of Contents

- [Dependencies](#dependencies)
- [Usage](#usage)
  - [Nextflow options](#nextflow-options)
  - [Pipeline options](#pipeline-options)
- [Workflow](#workflow)
- [Aknowledgments](#aknowledgments)
- [About](#about)

## Dependencies

To use this pipeline you will need:

- [Nextflow](https://www.nextflow.io/docs/latest/getstarted.html) >= 21.04.1
- [Docker](https://docs.docker.com/engine/install/) >= 19.03.2 or [Singularity](https://sylabs.io/guides/3.5/user-guide/quick_start.html) >= 3.7.3

## Usage

A small dataset is provided to test this pipeline. To try it out, use this command:

    nextflow run sguizard/nf-feelnc -profile test,docker -revision 1.2

### Nextflow Options

The pipeline is written in Nextflow, which provides the following default options:

| Option | Parameters | Description | Requirement |
|--------|--------------|-------------|-------------|
| __`-profile`__ | `profile1,profile2` | Profile(s) to use when<br>running the pipeline.<br>Specify the profiles that<br>fit your infrastructure<br>among `singularity`,<br>`docker`, `kubernetes`,<br>`slurm`. | Required |
| __`-revision`__ | `version` | Version of the pipeline<br>to launch. | Optional |
| __`-work-dir`__ | `directory` | Work directory where<br>all temporary files are<br>written. | Optional |
| __`-resume`__ | | Resume the pipeline<br>from the last completed<br>process. | Optional |

For more Nextflow options, see [Nextflow's documentation](https://www.nextflow.io/docs/latest/cli.html#run).

### Pipeline Options

| Option | Parameters | Description | Requirement |
|--------|--------------|-------------|-------------|
| __`--ref_annotation`__ | `ref_annotation.gtf` | Input reference<br>annotation file or url. | Required |
| __`--new_annotation`__ | `new_annotation.gtf` | Input reference<br>annotation file or url. | Required |
| __`--genome`__ | `genome.fa` | Input genome<br>sequence file or url. | Required |
| __`--feelnc-args`__ | `'--mode shuffle'` | Custom arguments to<br>pass to FEELnc's<br>[coding potential](https://github.com/tderrien/FEELnc#2--feelnc_codpotpl) script<br>when detecting long<br>non-coding transcripts. | Optional |
| __`--max-cpus`__ | `16` | Maximum number of<br>CPU cores that can be<br>used for each process.<br>This is a limit, not the<br>actual number of<br>requested CPU cores. | Optional |
| __`--max-memory`__ | `64GB` | Maximum memory that<br>can be used for each<br>process. This is a limit,<br>not the actual amount<br>of alloted memory. | Optional |
| __`--max-time`__ | `12h` | Maximum time that can<br>be spent on each<br>process. This is a limit<br>and has no effect on the<br>duration of each process.| Optional |

## Workflow and Results

The pipeline executes the following processes:
1. Decompress annotations and/or genome files if its gziped.
2. Detect long non-coding transcripts with [FEELnc](https://github.com/tderrien/FEELnc).  
   The annotation saved to `results/annotation` is updated with the results.
3. Aggregate quality controls into a report with [MultiQC](https://github.com/ewels/MultiQC).  
   The report is saved to `results/control` in a `.html` file.

## Aknowledgements
Many thanks to Sarah Djebali ([@sdjebali](https://github.com/sdjebali)), [Sylvain Foissac](https://www.linkedin.com/in/foissac/), [Cervin Guyomar](https://github.com/cguyomar) and Cyril Kurylo for their help and advices. 

## About

The GENE-SWitCH project has received funding from the European Union’s [Horizon 2020](https://ec.europa.eu/programmes/horizon2020/) research and innovation program under Grant Agreement No 817998.

This repository reflects only the listed contributors views. Neither the European Commission nor its Agency REA are responsible for any use that may be made of the information it contains.
