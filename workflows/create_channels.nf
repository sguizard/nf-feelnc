// INCLUDE MODULES -------------------------------------------------------------

include {
  GZIP_decompress as GZIP_decompress_index
  GZIP_decompress as GZIP_decompress_genome
  GZIP_decompress as GZIP_decompress_annotation
} from '../modules/gzip.nf'

// DEFINE FUNCTIONS ------------------------------------------------------------



// WORKFLOW --------------------------------------------------------------------

workflow CREATE_CHANNELS {

  emit:

    channel_genome
    channel_ref_annotation
    channel_new_annotation

  main:

    // DECOMPRESS GENOME -------------------------------------------------------

    // one genome
    channel_genome =
      Channel.fromPath(
        params.genome,
        checkIfExists: true
      )

    if (params.genome.endsWith('.gz')) {

      // one genome => genome
      GZIP_decompress_genome(channel_genome)

      // one genome
      channel_genome =
        GZIP_decompress_genome.out
    }

    // DECOMPRESS REF ANNOTATION ---------------------------------------------------

    // one annotation
    channel_ref_annotation =
      Channel.fromPath(
        params.ref_annotation,
        checkIfExists: true
      )

    if (params.ref_annotation.endsWith('.gz')) {

      // one annotation => annotation
      GZIP_decompress_annotation(channel_ref_annotation)

      // one annotation
      channel_ref_annotation =
        GZIP_decompress_annotation.out
    }

    // DECOMPRESS NEW ANNOTATION ---------------------------------------------------

    // one annotation
    channel_new_annotation =
      Channel.fromPath(
        params.new_annotation,
        checkIfExists: true
      )

    if (params.new_annotation.endsWith('.gz')) {

      // one annotation => annotation
      GZIP_decompress_annotation(channel_new_annotation)

      // one annotation
      channel_new_annotation =
        GZIP_decompress_annotation.out
    }
}
