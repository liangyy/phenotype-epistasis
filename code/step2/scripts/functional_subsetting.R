library(optparse)

help_text = '
This scripts takes the association result of Y_T ~ Y_I, Y_T ~ X_T, Y_I ~ X_T and output the functionally consistent SNPs candidates at the significance level --threshold
'

option_list = list(
  make_option(c('-t', '--ytyi'), type="character",
              help="association Y_T ~ Y_I", metavar="character"),
  make_option(c('-s', '--ytxt'), type='character',
              help='association Y_T ~ X_T', metavar='character'),
  make_option(c('-i', '--yixt'), type='character',
              help='association Y_I ~ X_T', metavar='character'),
  make_option(c('-p', '--pval_theshold'), type='character',
              help='p-value thredhold to call SNP effect', metavar='character'),
  make_option(c('-a', '--pattern'), type='character',
              help='the pattern used to exact file name identifier from ytyi input 1st column', metavar='character'),
  make_option(c('-r', '--prefix'), type='character',
              help='the prefix of output file. Filename = --prefix_[extract-identifier].set', metavar='character')
);

opt_parser = OptionParser(option_list=option_list, usage=help_text);
opt = parse_args(opt_parser);
