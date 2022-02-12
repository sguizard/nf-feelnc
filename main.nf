#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// CHECK PARAMETERS ------------------------------------------------------------

params.genome =
  params.containsKey('genome') ?
  params.genome : ''

params.ref_annotation =
  params.containsKey('ref_annotation') ?
  params.annotation : ''

params.new_annotation =
  params.containsKey('new_annotation') ?
  params.annotation : ''

params.feelnc_args =
  params.containsKey('feelnc-args') ?
  params.'feelnc-args' : ''

error = ''

if (!params.genome) {
  error += '\nNo --genome provided\n'
}

if (!params.ref_annotation) {
  error += '\nNo --ref_annotation provided\n'
}

if (!params.new_annotation) {
  error += '\nNo --new_annotation provided\n'
}

if (error) exit(1, error)

// INCLUDE WORKFLOWS -----------------------------------------------------------

include {
    CREATE_CHANNELS
} from './workflows/create_channels.nf'

// INCLUDE MODULES -------------------------------------------------------------

include {
  FEELNC_classify_transcripts
} from './modules/feelnc.nf'

include {
  MULTIQC_generate_report
} from './modules/multiqc.nf'

// WORKFLOW --------------------------------------------------------------------

workflow {

  // CREATE CHANNELS -----------------------------------------------------------

  CREATE_CHANNELS()

  // one genome
  channel_genome =
    CREATE_CHANNELS.out.channel_genome

  // one ref annotation
  channel_ref_annotation =
    CREATE_CHANNELS.out.channel_ref_annotation

  // one new annotation
  channel_new_annotation =
    CREATE_CHANNELS.out.channel_new_annotation

  // each [reports]
  channel_reports =
    Channel.empty()

  // DETECT LONG NON-CODING TRANSCRIPTS ----------------------------------------

  if (!params.skip_feelnc && !params.skip_assembly) {

    // one genome & reference_annotation & novel_annotation => [reports]
    FEELNC_classify_transcripts(
      channel_genome,
      channel_ref_annotation,
      channel_new_annotation
    )

    // each [reports]
    channel_reports =
      channel_reports.mix(FEELNC_classify_transcripts.out.reports)
  }

  // GENERATE HTML REPORT ------------------------------------------------------

  // one [reports] & config & custom_images & metadata
  MULTIQC_generate_report(
    channel_reports.flatten().collect(),
    Channel.fromPath(
      projectDir + '/assets/multiqc/config.yaml',
      checkIfExists: true
    ),
    Channel.fromPath(
      projectDir + '/assets/multiqc/custom_images.tsv',
      checkIfExists: true
    ),
    params.metadata ? Channel.fromPath(params.metadata) : []
  )
}
