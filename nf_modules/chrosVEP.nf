#!/usr/bin/env nextflow

/* 
 * Script to run VEP on chromosome-wise split VCF files
 */

nextflow.enable.dsl=2

// defaults
prefix = "vep"
params.outdir = ""
params.cpus = 1

process chrosVEP {
  /*
  Function to run VEP on chromosome-wise split VCF files

  Returns
  -------
  Returns 2 files per chromosome:
      1) VEP output file for each chromosome-wise split VCF
      2) A tabix index for that VCF output file
  */
  publishDir "${params.outdir}/vep-summary",
    pattern: "${prefix}-*.vcf.gz_summary.*",
    mode:'move'
  cpus params.cpus

  input:
  tuple path(vcfFile), path(indexFile)
  
  output:
  path("${prefix}-*.vcf.gz"), emit: vcfFile
  path("${prefix}-*.vcf.gz.tbi"), emit: indexFile
  path("${prefix}-*.vcf.gz_summary.*")

  script:
  if( !vcfFile.exists() ) {
    exit 1, "VCF file is not generated: ${vcfFile}"
  }
  else if ( !indexFile.exists() ){
    exit 1, "VCF index file is not generated: ${indexFile}"
  }
  else {
    """
    vep -i ${vcfFile} -o ${prefix}-${vcfFile} --vcf --force_overwrite --database --compress_output bgzip --format vcf 
    tabix -p vcf ${prefix}-${vcfFile}
    """	
  }
}