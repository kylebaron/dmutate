
library(dplyr)

library(magrittr)

cov1 <- covset(Y~rnorm(0,1), Z ~ runif(2,3))

as_idata(cov1,100)

