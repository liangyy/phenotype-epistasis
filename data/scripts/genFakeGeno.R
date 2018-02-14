library(optparse)

help_text = 'This script generate a collection ([nchr] pairs) of paired two files:
  1. BIMBAM mean genotype file,
  2. SNP information file. The SNP info file takes the followling format:
          [snp-id]\t[position]\t[chr-num]
Note that 10% of mean genotype will be non-integer.
Also, no LD is imposed in the simulated genotype.'

option_list = list(
  make_option(c('-c', '--nchr'), type="numeric", default=22,
              help="the number of chromosomes [default = %default]", metavar="character"),
  make_option(c("-s", "--nsnp"), type="numeric", default=20,
              help="the number of snps [default = %default]", metavar="character"),
  make_option(c("-i", "--nindividuals"), type="numeric", default=200,
              help="the number of individuals [default = %default]", metavar="character"),
  make_option(c('-o', '--out'), type='character', default='genFakeGeno', help='the prefix of outputs [default = %default]', metavar='character')
);

opt_parser = OptionParser(option_list=option_list, usage=help_text);
opt = parse_args(opt_parser);

genGeno <- function(ni, snp.name, allele.set) {
  allele <- strsplit(allele.set[sample(length(allele.set), 1)], ' ')[[1]]
  out <- sample(3, ni, replace = T) - 1
  noise <- (runif(ni) < 0.1) * runif(ni)
  out <- out + noise * (out == 0)
  out <- out - noise * (out == 2)
  out <- out + ((runif(ni) > 0.5) - 0.5) * 2 * noise * (out == 1)
  snp.name <- as.character(snp.name)
  return(c(snp.name, allele, format(round(out, digits = 3), nsmall = 3)))
}

for(c in 1 : opt$nchr) {
  geno.mean.out <- paste0(opt$out, '.genotype-mean.', 'chr', c, '.txt.gz')
  snp.info.out <- paste0(opt$out, '.snp-list.', 'chr', c, '.gz')
  snp.names <- paste0('chr', c, 'snp', 1 : opt$nsnp)
  snp.chr <- rep(c, opt$nsnp) # sample(22, opt$nsnp, replace = T)
  snp.pos <- round(runif(opt$nsnp) * 1e6)
  ordered.snp <- data.frame(x1 = snp.pos, x2 = snp.chr)
  ordered.snp <- ordered.snp[order(ordered.snp[, 1], ordered.snp[, 2]), ]
  snp <- data.frame(snp.names, ordered.snp$x1, ordered.snp$x2)
  bases <- c('A', 'T', 'C', 'G')
  allele.set <- c()
  for(i in bases) {
    for(j in bases) {
      if(i == j) next
      allele.set <- c(allele.set, paste(i, j))
    }
  }
  geno <- t(sapply(snp[,1], genGeno, ni=opt$nindividuals, allele.set=allele.set))
  gz1 <- gzfile(geno.mean.out, 'w')
  write.table(geno, gz1, quote = F, col.names = F, row.names = F)
  close(gz1)
  gz2 <- gzfile(snp.info.out, 'w')
  write.table(snp, gz2, sep = '\t', quote = F, col.names = F, row.names = F)
  close(gz2)
}
