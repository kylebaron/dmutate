


library(testthat)
library(dmutate)
library(dplyr)
Sys.setenv(R_TESTS="")

context("test-dmutate")

cov1 <- covset(y ~ rbinomial(0.2), wt[30,70] ~ rnorm(mu,30), flag ~ expr(10))
idata <- data_frame(ID = 1:10)
En <- list(mu = 50)

test_that("dmutate", {
  set.seed(1010121)
  out1 <- mutate_random(idata,cov1,envir = En)
  set.seed(1010121)
  out2 <- dmutate(idata,
                  y ~ rbinomial(0.2), wt[30,70] ~ rnorm(mu,30), flag ~ expr(10),
                  envir = En)
  identical(out1,out2)
})


