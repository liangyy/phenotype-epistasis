# Implementation of data analysis pipeline proposed in this repository

## Step 1: $\beta_I, X_T$ \rightarrow \hat{Y}_I$

Pipeline is glued by snakemake.

### Prepare $X_T$

```
# Pseudo-code for this task

## comment 1 & 2
$ mean2dist_genotype --input test.genotype-mean.txt --output test.genotype-dist-flip.txt

## comment 3
$ gen_snpinfo --input test.pos --output test.bimbam.snpinfo 

## run fcgene
$ fcgene --wgd test.genotype-dist-flip.txt --pos test.bimbam.snpinfo --oformat plink-bed --out test.bplink

## outcome files
$ ls
test.bplink.bed test.bplink.bim test.bplink.fam
```


