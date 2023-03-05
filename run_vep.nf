/* 
 * Workflow to run VEP on a VCF file
 *
 * This workflow relies on Nextflow (see https://www.nextflow.io/tags/workflow.html)
 *
 */

nextflow.enable.dsl=2

 // params default
params.help = false
params.cpus = 1
params.outdir = "outdir"
params.chros=""

// module imports
include { splitVCF } from "$baseDir/nf_modules/splitVCF.nf"
include { mergeVCF } from "$baseDir/nf_modules/mergeVCF.nf"  
include { chrosVEP } from "$baseDir/nf_modules/chrosVEP.nf"
include { readChrVCF } from "$baseDir/nf_modules/readChrVCF.nf"

 // print usage
if (params.help) {
  log.info ''
  log.info 'Pipeline to run VEP chromosome-wise'
  log.info '-------------------------------------------------------'
  log.info ''
  log.info 'Usage: '
  log.info '  nextflow -C nf_config/nextflow.config run workflows/run_vep.nf --vcf <path-to-vcf> --chros 1,2 --vep_config'
  log.info ''
  log.info 'Options:'
  log.info '  --vcf VCF                 VCF that will be split. Currently supports sorted and bgzipped file'
  log.info '  --outdir DIRNAME          Name of output dir. Default: outdir'
  log.info '  --chros LIST_OF_CHROS	Comma-separated list of chromosomes to generate. i.e. 1,2,... (Optional)'
  log.info '  --cpus INT	        Number of CPUs to use. Default 1.'
  exit 1
}

// Input validation

if( !params.vcf) {
  exit 1, "Undefined --vcf parameter. Please provide the path to a VCF file"
}

vcfFile = file(params.vcf)
if( !vcfFile.exists() ) {
  exit 1, "The specified VCF file does not exist: ${params.vcf}"
}

check_bgzipped = "bgzip -t $params.vcf".execute()
check_bgzipped.waitFor()
if(check_bgzipped.exitValue()){
  exit 1, "The specified VCF file is not bgzipped: ${params.vcf}"
}

vcf_index = "${params.vcf}.tbi"
vcfIndexFile = file(vcf_index)
if ( !vcfIndexFile.exists() ) {
  exit 1, "The specified VCF file does not have index: ${vcf_index}\nTry to create index using tabix ${params.vcf}"
}

log.info 'Starting workflow.....'

workflow {
log.info params.chros
  if (params.chros){
    log.info 'Reading chromosome names from list'
    chr_str = params.chros.toString()
    chr = Channel.of(chr_str.split(','))
  }
  else {
    log.info 'Computing chromosome names from input'
    readChrVCF(params.vcf, vcf_index)
    chr = readChrVCF.out.splitText().map{it -> it.trim()}
  }
  splitVCF(chr, params.vcf, vcf_index)
  chrosVEP(splitVCF.out)
  mergeVCF(chrosVEP.out.vcfFile.collect(), chrosVEP.out.indexFile.collect())
}  

workflow.onComplete { 
	log.info ( workflow.success ? "\nDone! Outputs can be found on --> $params.outdir\n" : "Error: Workflow has failed." )
}