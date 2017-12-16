library(testthat)
library(dmutate)
library(dplyr)
Sys.setenv(R_TESTS="")

context("test-build")

var <- c("x", "z", "y")

test_that("fill limits", {
  expect_error(dmutate:::fill_limit(var,c(1,2,3)))
  expect_error(dmutate:::fill_limit(var,c(1,2,x=3)))
  expect_error(dmutate:::fill_limit(var,c(z=1,a=2,x=3)))
  x <- dmutate:::fill_limit(var, c(z = 1, x = 30), def = 12)
  expect_identical(names(x),var)
  expect_equivalent(x,c(30,1,12))
})


test_that("build limits", {
  expect_error(dmutate:::build_limits(var, c(1), c(2,3)))
  x <- dmutate:::build_limits(var, lower = c(y = 2), upper = c(z = 30))
  expect_equal(x, c("x", "z[,30]", "y[2,]"))
  x <- dmutate:::build_limits(var, lower = c(y = 2, z=0.3), upper = c(z = 30))
  expect_equal(x, c("x", "z[0.3,30]", "y[2,]"))
  x <- dmutate:::build_limits(var, lower = c(y = 2, z=0.3, x = 20), upper = NULL)
  expect_equal(x, c("x[20,]", "z[0.3,]", "y[2,]"))
  x <- dmutate:::build_limits(var, lower = NULL, upper = NULL)
  expect_equal(x, var)
})

test_that("build_covform", {
  x <- build_covform("y", dist = "rnorm", args = "mu = 2, sd = 3", upper = 100, by = "GRP")
  x <- as.list(x)
  expect_equal(x$formula,"y[,100]~rnorm(mu = 2, sd = 3)|GRP")
  expect_equal(x$dist, "rnorm")
  expect_equal(x$vars, "y")
  expect_equal(x$by, "GRP")
  y <- list(lower = parse(text="-Inf"), upper = parse(text = "100"))
  expect_equivalent(eval(x[["lower"]]), eval(y[["lower"]]))
  expect_equivalent(eval(x[["upper"]]), eval(y[["upper"]]))
})


test_that("build_covobj", {
  x <- as.list(new_covobj("Y[2,5] ~ rnorm(2,3)|ID"))
  y <- build_covobj(var = "Y", lower = 2, upper = 5, by = "ID",
                    dist = "rnorm", args = c(2,3))
  y <- as.list(y)
  expect_equal(x$dist, y$dist)
  expect_equal(eval(x$lower), eval(y$lower))
  expect_equal(eval(x$upper), eval(y$upper))
  expect_equal(x$dist,y$dist)
  expect_equal(x$by,y$by)
})



