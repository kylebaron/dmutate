
library(dplyr)

library(magrittr)

x <- "fo.o[1.1,2.3]"
m <- regexec("([\\w.]+)(\\[(\\S+)?\\,(\\S+)?\\])?", x,perl=TRUE)
m <- unlist(regmatches(x,m))
m

