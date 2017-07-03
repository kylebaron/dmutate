
library(dplyr)

library(magrittr)
#' data(Theoph)
#' ungroup(Theoph)
#'
#' z <- 1
#' age <- AGE ~ rnorm(50,20)
#' wt <- WT ~ expr(AGE*2 - 5)
#'
#' a <- covset(age,wt)
#'
#' data <- data_frame(ID=1:6,ARM = ID%%2)
#'
#' a <- 10
#' b <- 10
#' data <- data.frame(ID=1:5)
#'
#' test <- function(obj,envir) {
#'
#'   a <- 100
#'
#'   if(missing(obj)) {
#'     obj <- Y~runif(a,a+b)
#'   }
#'
#'   if(missing(envir)) {
#'     data %>% mutate_random(obj)
#'   } else {
#'     data %>% mutate_random(obj,envir=envir)
#'   }
#' }
#'
#' #' # Case 0
#' data %>% mutate_random(Y~runif(a,a+b))
#' data %>% mutate_random(Y~runif(a,a+b),list(a=10000,b=300))
#'
#' #' # Case 1
#' obj <- Y~runif(a,a+b)
#' test(obj)
#'
#' #' Case 2
#' test()
#'
#' #' Case 3
#' test(obj, list(a=-1000,b=300))

library(purrr)
library(tidyr)



library(rbenchmark)
mu <- c(0,0,0)
Sigma <- mrgsolve::dmat(1,1,1)
x <- covset(A+B+C~rmvnorm(mu,Sigma)|VPOP)
y <- covset(A+B+C~rmvnorm(mu,Sigma)|ID)
z <- covset(A+B+C~rmvnorm(mu,Sigma))
idata <- data_frame(ID=1:1000)
vp <- readr::read_csv("~/git/metrumresearchgroup/devmodels/mapk/s10vpop.csv")


all.equal(vp[,names(vp)],select_(vp,.dots=names(vp)))

vp2 <- vp[,1:30]
#undebug(dmutate:::do_mutate)
ggplot(profr(mutate_random(vp,x)))
mutate_random(idata,y)
system.time(mutate_random(vp,x))
system.time(mutate_random(vp2,x))
system.time(mutate_random(vp,z))

system.time(mutate_random(idata,y))

benchmark(mutate_random(idata,x))



