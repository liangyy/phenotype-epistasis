library(optparse)

help_text = '
This scripts takes the association result of Y_T ~ Y_I (this is only used to determine the set name), Y_T ~ X_T and output the SNP candidates at the significance level --threshold in Y_T ~ X_T, namely significant hits in GWAS
'

option_list = list(
  make_option(c('-t', '--ytyi'), type="character",
              help="association Y_T ~ Y_I", metavar="character"),
  make_option(c('-x', '--ytxt'), type='character',
              help='association Y_T ~ X_T', metavar='character'),
  make_option(c('-p', '--pval_theshold'), type='numeric',
              help='p-value thredhold to call significant GWAS SNPs', metavar='numeric'),
  make_option(c('-a', '--pattern'), type='character',
              help='the pattern used to exact file name identifier from ytyi input 1st column (example: [first_part_to_remove]:[second_part_to_remove])', metavar='character'),
  make_option(c('-o', '--out'), type='character',
              help='the name of output file', metavar='character')
);

opt_parser = OptionParser(option_list=option_list, usage=help_text);
opt = parse_args(opt_parser);

# functions
source('scripts/myRLib.R')

# read input
ytxt <- read.table(opt$ytxt, header = T)
ytyi <- read.table(opt$ytyi, header = T)
ytxt$SNP <- as.character(ytxt$SNP)
sig.ind <- ytxt$P <= opt$pval_theshold

# get all yi's
yi <- trimString(ytyi[, 1], opt$pattern)

for(i in 1 : nrow(ytyi)) {
  # set name
  yi.name <- yi[i]
  # write to file
  cat(paste0(c(yi.name, ytxt[sig.ind, 'SNP'], 'END\n\n'), collapse = '\n'), file=opt$out, append = TRUE)
}
