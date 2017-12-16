library(testthat)
library(dmutate)
library(dplyr)
Sys.setenv(R_TESTS="")


context("test-rbinomial")

test_that("binomial variate is correctly generated", {
  set.seed(1010121)
  idata <- data_frame(ID=1:5000)
  out <- mutate_random(idata, Y~rbinomial(0.78))
  y <- round(mean(out$Y),2)
  expect_true(y %in% c(0.77,0.78,0.79))

  out <- mutate_random(idata, Y~rbinomial(0.24))
  y <- round(mean(out$Y),2)
  expect_true(y %in% c(0.23,0.24,0.25))
})

