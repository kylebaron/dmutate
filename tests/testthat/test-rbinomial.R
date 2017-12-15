library(testthat)
library(dmutate)
library(dplyr)
Sys.setenv(R_TESTS="")

context("test-as_idata")

test_that("generate idata set from covset", {
  set.seed(1010121)
  out <- as_idata(covset(Y~rbinomial(0.78)),100000)
  y <- round(mean(out$Y),2)
  expect_true(y %in% c(0.77,0.78,0.79))
})


