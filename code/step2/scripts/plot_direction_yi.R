library(optparse)

help_text = '
This script takes the output of direction_yi.R and output a PNG plot that shows the significance of the correlation
'

option_list = list(
  make_option(c('-i', '--input'), type="character",
              help="the output of direction_yi.R", metavar="character"),
  make_option(c('-y', '--hypers'), type="character",
              help="the corresponding hyperparameters for each row in the given input", metavar="character"),
  make_option(c('-o', '--output'), type='character',
              help='the filename of PNG output', metavar='character')
);

opt_parser = OptionParser(option_list=option_list, usage=help_text);
opt = parse_args(opt_parser);

library(ggplot2)
data <- read.table(opt$input, header = T)
ps <- strsplit(opt$hypers, ',')[[1]]
data$causal.fraction <- ps
p <- ggplot(data) + geom_point(aes(x = causal.fraction, y = prs.estmate)) + geom_errorbar(aes(x = causal.fraction, ymin = prs.estmate - 1.96 * prs.std, ymax = prs.estmate + 1.96 * prs.std), colour = "black", width = .1) + geom_hline(yintercept = 0, color = 'red') + coord_flip() + theme(axis.text.x=element_text(angle=90,hjust=1)) + geom_text(aes(x = causal.fraction, y = prs.estmate, label = paste0('pval = ', format(round(prs.pval, 6), nsmall = 6))), vjust = -.5, hjust = -.3, size = 6) + ggtitle('Y ~ I: correlation estimate') + xlab('Correlation coefficient') + ylab('Hyperparameter')
png(opt$output)
print(p)
dev.off()

# ggsave(opt$output)
