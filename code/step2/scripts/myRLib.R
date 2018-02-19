flipStrand <- function(x) {
  x[x == 'A'] <- 'T'
  x[x == 'T'] <- 'A'
  x[x == 'C'] <- 'G'
  x[x == 'G'] <- 'C'
  return(x)
}
isNotIdentifiable <- function(x, y) {
  x <- flipStrand(x)
  return( x == y )
}
correctAllele <- function(ref.ref, ref.alt, now.alt, now.eff) {
  ref.ref.flip <- flipStrand(ref.ref)
  need.flip <- rep(FALSE, length(now.eff))
  need.flip[ref.ref == now.alt] <- TRUE
  need.flip[ref.ref.flip == now.alt] <- TRUE
  now.eff[need.flip] <- - now.eff[need.flip]
  return(now.eff)
}
trimString <- function(string, pattern) {
  string <- as.character(string)
  string <- basename(string)
  parts <- strsplit(pattern, ':')[[1]]
  for(p in parts) {
    string <- sub(p, '', string)
  }
  return(string)
}

getDirection <- function(x) {
  return(((x > 0) * 1 - 0.5) * 2)
}

parseFuncSet <- function(str) {
  out <- list()
  i <- 0
  state <- NA
  while(i <= length(str)) {
    i <- i + 1
    if(is.na(state)) {
      state <- str[i]
      out[[state]] <- c()
    } else {
      if(str[i] == '') {
        state <- NA
      } else if(str[i] == 'END') {
        next 
      } else {
        out[[state]] <- c(out[[state]], str[i])
      }
    }
  }
  return(out)
}

getStdFromPval <- function(pval, beta) {
  # assuming two-tail p-value
  zval <- abs(pnorm(pval / 2))
  beta.std <- abs(beta) / zval
  return(beta.std)
}

getMeanStd <- function(name, pval, or, type) {
  o <- cbind(log(or), getStdFromPval(pval, log(or)))
  df <- data.frame(SNP = name, Mean = o[, 1], Std = o[, 2], Type = type)
  return(df)
}

# revised from https://stackoverflow.com/questions/7549694/adding-regression-line-equation-and-r2-on-graph
lm_eqn_nointer <- function(df){
  m <- lm(y ~ 0 + x, df);
  eq <- substitute(italic(y) == a %.% italic(x)*","~~italic(r)^2~"="~r2, 
                   list(a = format(coef(m)[1], digits = 2), 
                        r2 = format(summary(m)$r.squared, digits = 3)))
  as.character(as.expression(eq));                 
}

