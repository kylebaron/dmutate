
library(dplyr)

library(magrittr)

cov1 <- covset(Y~rnorm(0,1), Z ~ runif(2,3))

as_idata(cov1,100)

foo <- function(...) {
  x <- list(...)
  fm <- sapply(x,class) == "formula"
  .covs <- lapply(x[fm], new_covobj)
  .covs <- as.covset(.covs)
  args <- x[!fm]
  return(list(.covs,args))
}

foo(Y ~ rbinomial(0.2), x = 2, Z ~ rnorm(1,2))



build_covform(c("x", "y", "z"), "mvrnorm", c("mu", "sigma"),
              upper = c(y=200,y=100), lower = c(x = 1))

build_covobj(var = "y", args = c("mu = 1", "sd = 3"), dist = "rnorm") %>% as.list


build_covobj(var = c("x","y"), args = c("mu = 1", "sd = 3"),
             lower = c(x=1), upper  = c(y=3),
             dist = "rnorm") %>% as.list


new_covobj("Y[2,3]+X[0,1] ~ rmvnorm(mu,Sigma)") %>% as.list



build_covobj("y", "rnorm", c(12,22), upper = 2, by = c("ID")) %>% as.list


build_covobj(c("x", "y", "z"), "mvrnorm", c("mu", "sigma"),
             lower = c(z=1), upper = c(x=200, z = 10))

build_covobj(c("x", "y", "z"), "mvrnorm", c("mu", "sigma"),
             lower = c(z=1, x = 2), upper = c(x=200, z = 200)) %>% as.list

build_covobj(c("x", "y", "z"), "mvrnorm", c("mu", "sigma"))

mutate_random(data_frame(ID = 1:3), x)


