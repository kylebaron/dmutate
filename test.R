
library(dplyr)

library(magrittr)


a <- X ~ rnorm(50,3)
b <- Y ~ expr(X/2 + c)
d <- A+B ~ rlmvnorm(log(c(20,80)),diag(c(0.2,0.2)))
cov1 <- covset(a,b,d)
e <- list(c=3)

.data <- data.frame(ID=1:3)

debugonce(dmutate:::apply_covset)
mutate_random(.data, cov1, envir = e) %>% signif(3)





cov1 <- covset(Y~rnorm(0,1), Z ~ runif(2,3))
idata <- tibble(ID = 1:100000)

dmutate(idata, y ~ rbinomial(0.2), wt ~ rnorm(2,3), flag ~ expr(10))


cov1 <- covset(y ~ rbinomial(0.2), wt[1.5,2.5] ~ rnorm(2,3), flag ~ expr(10))
data <- mutate_random(idata,cov1)

idat <- mutate_random(idata, cov1)

id <- data.frame(ID = 1:100)

mutate_random(id, WT ~ rnorm(40,sqrt(40)))


