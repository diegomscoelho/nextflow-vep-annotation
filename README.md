# code-challenge-nextflow-vep-annotation

## Pre-requisites

    * Nextflow (https://www.nextflow.io/docs/latest/getstarted.html)
    * Docker (https://docs.docker.com/engine/install/ubuntu/)

## Run example

```sh
nextflow -C nextflow.config run run_vep.nf --vcf $PWD/examples/small.vcf.gz --cadd $PWD/examples/cadd_snv.tsv.gz
```

If user just want a subset of determined chrs, for chrs (4, 10, 22):

```sh
nextflow -C nextflow.config run run_vep.nf --vcf $PWD/examples/small.vcf.gz --cadd $PWD/examples/cadd_snv.tsv.gz --chros 10,22,4
```

For more details of usage:

```sh
nextflow run run_vep.nf --help
```