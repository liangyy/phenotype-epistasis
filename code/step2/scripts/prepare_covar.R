library(optparse)

help_text = '
This script takes a PRS file output by ldpred and the corresponding FAM file, and prepares the covariate file for plink
'

option_list = list(
  make_option(c('-i', '--input'), type="character",
              help="a covariate file output by ldpred", metavar="character"),
  make_option(c('-f', '--fam'), type="character",
              help="the corresponding FAM file", metavar="character"),
  make_option(c('-o', '--output'), type='character',
              help='the file name of output file covariate ready for plink', metavar='character')
);

opt_parser = OptionParser(option_list=option_list, usage=help_text);
opt = parse_args(opt_parser);

covariate <- read.table(opt$input, sep = ' ', header = T)
fam <- read.table(opt$fam, header = F, sep = ' ')
out <- data.frame(FID = fam[, 1], IID = covariate[, 1], PRS = covariate[, 3])
write.table(out, file = opt$output, quote = F, row.names = F, col.names = T)
