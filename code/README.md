# Implementation of data analysis pipeline proposed in this repository

## Step 1: $\beta_I, X_T \rightarrow \hat{Y}_I$

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

## post process test.bplink.fam
```

### Prepare $\beta_I$

Formating summary statistic. LDpred uses p-value and sample size to compute beta (standard format) and raw beta is not used at all

### Combine $X_T$ and $Y_T$

```
# change the last column to phenotype (1 unaffected, 2 affected)
$ bash add_phenotype.sh -p 1 -i data1.fam -o data1_phenotyped.fam
$ bash add_phenotype.sh -p 2 -i data2.fam -o data2_phenotyped.fam

# rename *.bim and *.bed files accordingly
$ mv data1.bim data1_phenotyped.bim.fam; mv data1.bed data1_phenotyped.bed
$ mv data2.bim data2_phenotyped.bim.fam; mv data2.bed data2_phenotyped.bed

# merge two data sets
$ plink --bfile data1_phenotyped --bmerge data2_phenotyped --make-bed --out merged_data

# QC
$ plink --bfile merged_data --make-bed --mind 0.05 --maf 0.01 --geno 0.05 --hwe 0.05 --out merged_data_QC
```

### Run LDpred or P+T

Now, only LDpred is implemented.

**TODO**: add P+T

## Step 2: $Y_T \sim \hat{Y}_I \cdot X_T$

### Get PCs of $X_T$

```
Rscript getQC.R --geno merged_data_QC -nPCs 2 --output PCs.merged_data_QC.txt.gz
```

### Determine the direction of effect

#### Direction of $X_T$

```
$ plink --bfile merged_data_QC --logistic --out log_assoc_merged_data_QC --covar <(zcat < PCs.merged_data_QC.txt.gz)
$ Rscript extractDirection.R --input log_assoc.merged_data_QC.logistic --output direction_XT.merge_data_QC.txt.gz
```

#### Direction of $Y_I$

```
# predict Y_I based on merged_data_QC
$ python ldpred/validate.py SOMETHING --input merged_data_QC --out merged_data_QC_YI  # ignore the prediction accuracy since the phenotype is wrong

# determine the direction
$ Rscript computeDirection.R --input merged_data_QC_YI.txt.gz --output directon_YI.merged_data_QC.txt.gz
```

### Perform interaction test

```
# merge covariates
bash merge_two_covar.sh -a YI.merged_data_QC.txt.gz -b PCs.merged_data_QC.txt.gz -o covars.merged_data_QC.txt.gz

# additive model
$ plink --bfile merged_data_QC --logistic --covar <(zcat < YI.merged_data_QC.txt.gz) --interaction --out interaction_add_YI.merged_data_QC

# dominant/recessive model
## note that the dominant/recessive is respective to reference allele but not the risk one
## in the end, the dominant and recessive will be reassigned according to direction files
$ plink --bfile merged_data_QC --logistic --covar <(zcat < YI.merged_data_QC.txt.gz) --interaction --dominant --out interaction_dom_YI.merged_data_QC
$ plink --bfile merged_data_QC --logistic --covar <(zcat < YI.merged_data_QC.txt.gz) --interaction --recessive --out interaction_rec_YI.merged_data_QC
```
