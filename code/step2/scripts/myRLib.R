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
