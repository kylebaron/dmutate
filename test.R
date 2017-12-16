
library(dplyr)

library(magrittr)

cov1 <- covset(Y~rnorm(0,1), Z ~ runif(2,3))
idata <- data_frame(ID = 1:100000)

system.time({
  dmutate(idata, y ~ rbinomial(0.2), wt ~ rnorm(2,3), flag ~ expr(10))
})

cov1 <- covset(y ~ rbinomial(0.2), wt[1.5,2.5] ~ rnorm(2,3), flag ~ expr(10))
system.time(mutate_random(idata,cov1))

idat <- mutate_random(idata, cov1)

