#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// CHECK PARAMETERS ------------------------------------------------------------

params.genome         = params.containsKey('genome')         ? params.genome         : ''
params.ref_annotation = params.containsKey('ref_annotation') ? params.ref_annotation : ''
params.new_annotation = params.containsKey('new_annotation') ? params.new_annotation : ''
params.feelnc_args    = params.containsKey('feelnc-args')    ? params.'feelnc-args'  : ''

error = ''
if (!params.genome)          error += 'No --genome provided\n'
if (!params.ref_annotation)  error += 'No --ref_annotation provided\n' 
if (!params.new_annotation)  error += 'No --new_annotation provided\n' 
if (error)                   exit(1, error)

// INCLUDE WORKFLOWS -----------------------------------------------------------

include { CREATE_CHANNELS             } from './workflows/create_channels.nf'

// INCLUDE MODULES -------------------------------------------------------------

include { FEELNC_classify_transcripts } from './modules/feelnc.nf'
include { MULTIQC_generate_report     } from './modules/multiqc.nf'

// WORKFLOW --------------------------------------------------------------------

workflow {

  // CREATE CHANNELS -----------------------------------------------------------

  CREATE_CHANNELS()

  
  channel_genome         = CREATE_CHANNELS.out.channel_genome         // one genome
  channel_ref_annotation = CREATE_CHANNELS.out.channel_ref_annotation // one ref annotation
  channel_new_annotation = CREATE_CHANNELS.out.channel_new_annotation // one new annotation
  channel_reports        = Channel.empty()                            // each [reports]

  // DETECT LONG NON-CODING TRANSCRIPTS ----------------------------------------

  // one genome & reference_annotation & novel_annotation => [reports]
  FEELNC_classify_transcripts(
    channel_genome,
    channel_ref_annotation,
    channel_new_annotation
  )

  // each [reports]
  channel_reports = channel_reports.mix(FEELNC_classify_transcripts.out.reports)

  // GENERATE HTML REPORT ------------------------------------------------------

  // one [reports] & config & custom_images & metadata
  MULTIQC_generate_report(
    channel_reports.flatten().collect(),
    Channel.fromPath(projectDir + '/assets/multiqc/config.yaml',       checkIfExists: true),
    Channel.fromPath(projectDir + '/assets/multiqc/custom_images.tsv', checkIfExists: true),
    []
  )
}
