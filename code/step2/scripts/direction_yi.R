library(optparse)

help_text = '
This script takes a collection of covariate files. For each covariate, it performs logit(Pr(case)) = 1 + covariate and record the result.
'

option_list = list(
  make_option(c('-i', '--inputs'), type="character",
              help="a list of covariate files (separated by ':')", metavar="character"),
  make_option(c('-o', '--output'), type='character',
              help='the file name of output file', metavar='character')
);

opt_parser = OptionParser(option_list=option_list, usage=help_text);
opt = parse_args(opt_parser);

stat.container <- c()

inputs <- strsplit(opt$inputs, ':')[[1]]

for(f in inputs) {
  covariate <- read.table(f, sep = ' ', header = T)
  covariate$PHENO <- covariate$PHENO - 1
  model <- glm(PHENO ~ PRS, family=binomial(link='logit'), data = covariate)
  stats <- summary(model)
  stat.container <- rbind(stat.container, c(f, stats$coefficients[1], stats$coefficients[3], stats$coefficients[7], stats$coefficients[2], stats$coefficients[4], stats$coefficients[8]))
}
stat.container <- data.frame(stat.container)
colnames(stat.container) <- c('filename', 'intercept.estmate', 'intercept.std', 'intercept.pval', 'prs.estmate', 'prs.std', 'prs.pval')

write.table(stat.container, file = opt$output, quote = F, row.names = F, col.names = T)
