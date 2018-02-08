library(optparse)

help_text = '
This script takes a collection of PRS file from different chromosomes (but were generated with the same parameter in ldpred). It combines all values (adding together) and output a single PRS file where each row is one individual.
'

option_list = list(
  make_option(c('-i', '--inputs'), type="character",
              help="a collection of PRS file from different chromosomes (separated by ':')", metavar="character"),
  make_option(c('-o', '--output'), type='character',
              help='the file name of output file covariate', metavar='character')
);

opt_parser = OptionParser(option_list=option_list, usage=help_text);
opt = parse_args(opt_parser);

myRead <- function(f) {
  covariate <- readLines(f)
  covariate <- gsub(', ', ',', covariate)
  covariate <- gsub(',$', '', covariate)
  covariate <- read.table(textConnection(covariate), header = T, sep = ',')
  return(covariate)
}

inputs <- strsplit(opt$inputs, ':')[[1]]

f <- inputs[1]
covariate <- myRead(f)
iids <- covariate[, 1]
raw <- covariate[, 3]
prs <- covariate[, 4]
true_phens <- covariate[, 2]
for(i in 2 : length(inputs)) {
  f <- inputs[i]
  covariate <- myRead(f)
  iids.i <- covariate[, 1]
  if(sum(iids == iids.i) != length(iids)) {
    print('Unmatched IID. Exit!')
    quit()
  }
  raw.i <- covariate[, 3]
  prs.i <- covariate[, 4]
  raw <- raw + raw.i
  prs <- prs + prs.i
}

out <- data.frame(IID = iids, RAW_PRS = raw, PRS = prs, PHENO = true_phens)
write.table(out, file = opt$output, quote = F, row.names = F, col.names = T)
