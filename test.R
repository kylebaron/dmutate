
library(dplyr)
data(Theoph)
library(magrittr)
library(mrgsolve)

d <- data_frame(ID=1:5000, GROUP = ID%%2)


x <- "EGFR[0,] ~ rnorm(20,30), foo=2"
dmutate_(d,x)

set.seed(10)
d %>% dmutate_("EGFR[0,] ~ rnorm(20,30) | GROUP ")

set.seed(10)
out <-
  d %>%
  dmutate(EGFR[0,] ~ rnorm(20,30) | GROUP)

out

mod <- mread("irm1", modlib())
p <- as.list(param(mod))
e <- new.env()
e$d <- 2
e$mat <- dmat(1,1,2)
e$z <- 123
e$matt <- dmat(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17)


system.time({
  e <- as.environment(c(p,as.list(e)))
})



code <- '
EGFR[40,140] ~ rnorm(mu.egfr, 25)
AGE[18,80] ~ runif(20,80)
sigma ~ rgamma(1,1)
WT[40,140]  ~ rnorm(80,20)
SEX ~ binomial(0.5)
tik ~ rbeta(0.1,0.1)
flag ~ runif(0,1)
'

d <- data_frame(ID=1:10000, GROUP = ID%%2)
mu.egfr <- 100
system.time(d %>% dmutate_list(code))



