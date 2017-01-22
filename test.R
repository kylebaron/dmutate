
library(dplyr)

library(magrittr)
data(Theoph)
ungroup(Theoph)

z <- 1
age <- AGE ~ rnorm(50,20)
wt <- WT ~ expr(AGE*2 - 5)

a <- covset(age,wt)

data <- data_frame(ID=1:6,ARM = ID%%2)

a <- 10
b <- 10
data <- data.frame(ID=1:5)

test <- function(obj,envir) {

  a <- 100

  if(missing(obj)) {
    obj <- Y~runif(a,a+b)
  }

  if(missing(envir)) {
    data %>% mutate_random(obj)
  } else {
    data %>% mutate_random(obj,envir=envir)
  }
}

#' # Case 0
data %>% mutate_random(Y~runif(a,a+b))
data %>% mutate_random(Y~runif(a,a+b),list(a=10000,b=300))

#' # Case 1
obj <- Y~runif(a,a+b)
test(obj)

#' Case 2
test()

#' Case 3
test(obj, list(a=-1000,b=300))


