library(testthat)
library(dmutate)
library(dplyr)
Sys.setenv(R_TESTS="")



context("test-parse")

test_that("Formula LHS is parsed", {
  x <- dmutate:::parse_left_var("foo[1.2,]")
  expect_equal(x$lower, "1.2")
  expect_equal(x$upper, "Inf")
  expect_equal(x$var, "foo")


  x <- dmutate:::parse_left_var("fo.o[1.2,]")
  expect_equal(x$lower, "1.2")
  expect_equal(x$upper, "Inf")
  expect_equal(x$var, "fo.o")

  x <- dmutate:::parse_left_var("fo_o[1.2,]")
  expect_equal(x$var, "fo_o")
})
