
library(dplyr)
data(Theoph)
library(magrittr)


x <- "Y[80,90] ~ normal, mean=85, sd=80"


system.time({
  y <- parse2(x)
  z <- bound2(y$dist,y$args,n=10,mn=y$var$lower,mx=y$var$upper,tries=100)
})

data <- data_frame(ID=1:5000)

system.time({
data %<>%
  dmutate2(Y~binomial, p=0.5) %>%
  dmutate2(WT~normal, mean=70,sd=20) %>%
  dmutate2(AGE~normal, mean=50,sd=10) %>%
  dmutate2(SEX~binomial, p=0.51) %>%
  dmutate2(EGFR[40,120] ~ normal, mean=80,sd=100)
})



