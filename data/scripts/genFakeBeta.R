library(optparse)

help_text = '
This script generates a fake GWAS summary statistic data sheet in GZ format.
The following process is assumed:
  \\beta_i \\sim \\pi N(0, \\sigma^2) + (1 - \\pi) \\delta_0 \\beta_i\'s are iid
  \\tilde\\beta_i | \\beta_i \\sim N(\\beta_i, (1 - h^2 / M) / N) \\tilde\\beta_i\'s are iid
Namely it implicitly assumes that there is no LD structure among loci.

Note that a reference SNP list (consider the format SNP list output by genFakeGeno.R) is required to match the SNP ID in downstream analysis
'

option_list = list(
  make_option(c('-s', '--sigma'), type="numeric", default=0.5,
              help="variance of prior [default = %default]", metavar="numeric"),
  make_option(c("-f", "--fraction"), type="numeric", default=0.1,
              help="fraction of causal variants [default = %default]", metavar="numeric"),
  make_option(c("-e", "--heritability"), type="numeric", default=0.1,
              help="heritability of the trait of the GWAS [default = %default]", metavar="numeric"),
  make_option(c('-n', '--gwas_sample_size'), type='numeric', default=20000,
              help='the mean sample size of the GWAS to simulate (standard deviation is 10% of mean) [default = %default]', metavar='numeric'),
  make_option(c('-r', '--reference_snp_list_prefix'), type='character',
              help='the prefix of the reference SNP list files [default = %default]', metavar='character'),
  make_option(c('-c', '--nchr'), type="numeric", default=22,
              help="the number of chromosomes in reference SNP list [default = %default]", metavar="numeric"),
  make_option(c('-i', '--drop_rate'), type='numeric', default=0.2,
              help='the fraction of SNPs dropped in output and the same number of new SNPs will be included [default = %default]', metavar='numeric'),
  make_option(c('-o', '--out'), type='character', default='genFakeBeta',
              help='the prefix of outputs [default = %default]', metavar='character')
);

opt_parser = OptionParser(option_list=option_list, usage=help_text);
opt = parse_args(opt_parser);

# drop some SNPs and add some new SNPs
min.pval <- 1e-10
af <- 0.11
snp.list <- c()
for(c in 1 : opt$nchr) {
  snp.list.c <- read.table(paste0(opt$reference_snp_list_prefix, '.chr', c, '.gz'), sep = '\t', header = T)
  snp.list <- rbind(snp.list, snp.list.c)
}
selected.snp.indicator <- rbinom(nrow(snp.list), 1, 1 - opt$drop_rate)
snp.selected.list <- snp.list[selected.snp.indicator == 1, ]
nsnp.new <- sum(selected.snp.indicator == 0)
chr.new <- sample(1 : opt$nchr, nsnp.new, replace = T)
snpid.new <- paste0('snp.new', 1 : nsnp.new)
pos.new <- round(runif(nsnp.new) * 1e6)
A.new <- 'G'
B.new <- 'T'
snp.new.list <- data.frame(rs = snpid.new, A = A.new, B = B.new, af = af, chr = chr.new, pos = pos.new)
snp.out.list <- rbind(snp.selected.list, snp.new.list)
snp.out.list <- snp.out.list[order(snp.out.list$chr, snp.out.list$pos), ]

# simulate summary statistic
M <- nrow(snp.out.list)
N <- round(rnorm(M, opt$gwas_sample_size, 0.1 * opt$gwas_sample_size))
h_square <- opt$heritability
p.i <- opt$fraction
sigma <- opt$sigma
sigma.tilde <- (1 - h_square / M) / N
beta.norm <- rnorm(M, 0, sqrt(sigma))
beta.binary <- rbinom(M, 1, p.i)
beta <- beta.norm * beta.binary
beta.tilde <- sapply(beta, function(x) {
  return(rnorm(n = 1, mean = x, sd = sqrt(sigma.tilde)))
})
beta.tilde.z <- beta.tilde * sqrt(N)  # sqrt((1 - 2 * af * (1 - af) * beta) / (2 * af * (1 - af)))
beta.tilde.pval <- pnorm(-abs(beta.tilde.z)) * 2
beta.tilde.pval[beta.tilde.pval < min.pval] <- min.pval
snp.out.list <- data.frame(chr = snp.out.list$chr,
                          pos = snp.out.list$pos,
                          ref = snp.out.list$A,
                          alt = snp.out.list$B,
                          reffrq = 0.1,
                          info = 1,
                          rs = snp.out.list$rs,
                          pval = beta.tilde.pval,
                          effalt = beta.tilde,
                          n = N)

# write to file
out.filename <- paste0(opt$out, '.summary-statistic', '.txt.gz')
gz1 <- gzfile(out.filename, 'w')
write.table(snp.out.list, gz1, sep = '\t', quote = F, col.names = F, row.names = F)
close(gz1)
