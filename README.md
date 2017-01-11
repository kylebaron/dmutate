    knitr::opts_chunk$set(comment='.')

dmutate
=======

Mutate a `data.frame`, adding random variates.

    library(dplyr)
    library(dmutate)

Some variables to use in formulae:

    low_wt <- 70
    high_wt <- 90
    mu <- 80
    p.female <- 0.24

Use `mutate_random` to implement formulae in data frame

    data.frame(ID=1:20) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(WT[low_wt,high_wt] ~ rnorm(mu,1)) %>%
      mutate_random(STUDY_RE ~ rnorm(0,sqrt(50))|GROUP) %>%
      mutate_random(SEX ~ rbinomial(p.female)) %>%
      mutate_random(sigma ~ rgamma(1,1)) %>%
      mutate_random(kappa ~ rgamma(1,1)|GROUP) %>% signif(3)

    .    ID GROUP   WT STUDY_RE SEX  sigma kappa
    . 1   1     1 80.8     8.76   0 5.4900 0.799
    . 2   2     0 79.3    11.80   0 0.3660 3.660
    . 3   3     1 79.2     8.76   0 0.0955 0.799
    . 4   4     0 80.9    11.80   0 0.3710 3.660
    . 5   5     1 81.7     8.76   0 0.7910 0.799
    . 6   6     0 81.1    11.80   0 1.8600 3.660
    . 7   7     1 79.3     8.76   0 0.3990 0.799
    . 8   8     0 79.4    11.80   0 2.4300 3.660
    . 9   9     1 79.2     8.76   0 1.1600 0.799
    . 10 10     0 79.8    11.80   1 0.4750 3.660
    . 11 11     1 80.0     8.76   0 0.6920 0.799
    . 12 12     0 80.2    11.80   0 0.3380 3.660
    . 13 13     1 80.3     8.76   0 0.5090 0.799
    . 14 14     0 79.4    11.80   1 0.3620 3.660
    . 15 15     1 78.7     8.76   0 2.2300 0.799
    . 16 16     0 80.5    11.80   0 1.8500 3.660
    . 17 17     1 79.8     8.76   0 1.0900 0.799
    . 18 18     0 78.8    11.80   0 1.3300 3.660
    . 19 19     1 78.8     8.76   0 1.1800 0.799
    . 20 20     0 79.5    11.80   1 0.9970 3.660

Create formulae with `expr` to calculate new columns in the `data.frame` using `dplyr::mutate`
==============================================================================================

We can easily save formulae to `R` variables. We collect formulae
together into sets called `covset`. For better control for where objects
are found, we can specify an environment where objects can be found.

    a <- X ~ rnorm(50,3)
    b <- Y ~ expr(X/2 + c)
    cov1 <- covset(a,b)
    e <- list(c=3)

Notice that `b` has function `expr`. This assigns the column named `Y`
(in this case) to the result of evaluating the expression in the data
frame using `dplyr::dmutate`.

    data <- data.frame(ID=1:3)

    mutate_random(data,cov1,envir=e) %>% signif(3)

    .   ID    X    Y
    . 1  1 48.8 27.4
    . 2  2 52.8 29.4
    . 3  3 46.2 26.1
