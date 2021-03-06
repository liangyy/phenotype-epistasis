library(optparse)

help_text = '
This scripts takes the association result of Y_T ~ Y_I, Y_T ~ X_T, Y_I ~ X_T and output the functionally consistent SNPs candidates at the significance level --threshold
'

option_list = list(
  make_option(c('-t', '--ytyi'), type="character",
              help="association Y_T ~ Y_I", metavar="character"),
  make_option(c('-x', '--ytxt'), type='character',
              help='association Y_T ~ X_T', metavar='character'),
  make_option(c('-i', '--yixt'), type='character',
              help='association Y_I ~ X_T', metavar='character'),
  make_option(c('-p', '--pval_theshold'), type='numeric',
              help='p-value thredhold to call SNP effect', metavar='numeric'),
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
yixt <- read.table(opt$yixt, header = T)
yixt <- yixt[yixt$rs %in% ytxt$SNP, ]
ytxt <- ytxt[ytxt$SNP %in% yixt$rs, ]
ytxt$SNP <- as.character(ytxt$SNP)
yixt$rs <- as.character(yixt$rs)
ytxt <- ytxt[order(ytxt$SNP), ]
yixt <- yixt[order(yixt$rs), ]
ambiguious.snp.ind <- isNotIdentifiable(as.character(yixt$ref), as.character(yixt$alt))
ytxt <- ytxt[!ambiguious.snp.ind, ]
yixt <- yixt[!ambiguious.snp.ind, ]
ytxt$STAT <- correctAllele(as.character(yixt$ref), as.character(yixt$alt), as.character(ytxt$A1), as.numeric(ytxt$STAT))

# remove too weak signal by thredholding
weak.snp.ind <- (ytxt$P > opt$pval_theshold) | (yixt$pval > opt$pval_theshold)
ytxt <- ytxt[!weak.snp.ind, ]
yixt <- yixt[!weak.snp.ind, ]

# get all yi's
yi <- trimString(ytyi[, 1], opt$pattern)

# extract functional consistent instances
ytxt.direction <- getDirection(ytxt$STAT)
yixt.direction <- getDirection(yixt$effalt)
for(i in 1 : nrow(ytyi)) {
  # check consistency
  yi.name <- yi[i]
  ytyi.direction <-  getDirection(ytyi[i, 'prs.estmate'])
  xt.consistent.ind <- (ytxt.direction * yixt.direction * ytyi.direction) == 1
  # write to file
  cat(paste0(c(yi.name, ytxt[xt.consistent.ind, 'SNP'], 'END\n\n'), collapse = '\n'), file=opt$out, append = TRUE)
}
