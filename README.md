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
    sd <- 80
    p.female <- 0.24

Use `mutate_random` to implement formulae in data frame. We can put
bounds on any simulated variable:

    data.frame(ID=1:20) %>% mutate_random(WT[low_wt,high_wt] ~ rnorm(mu,sd))

    .    ID       WT
    . 1   1 84.60810
    . 2   2 70.62642
    . 3   3 81.64210
    . 4   4 82.86923
    . 5   5 77.19342
    . 6   6 70.30473
    . 7   7 77.13273
    . 8   8 72.05964
    . 9   9 88.89150
    . 10 10 82.94305
    . 11 11 74.80186
    . 12 12 78.44500
    . 13 13 85.95285
    . 14 14 70.02314
    . 15 15 71.56168
    . 16 16 81.35471
    . 17 17 74.15018
    . 18 18 81.53450
    . 19 19 79.41624
    . 20 20 81.56166

We can simulate from any probability distirbution in `R`:

    data.frame(ID=1:20) %>% mutate_random(X ~ rcauchy(0,0.5))

    .    ID           X
    . 1   1   0.3937821
    . 2   2  -0.3715774
    . 3   3  -0.2854400
    . 4   4   0.7853453
    . 5   5   4.1381906
    . 6   6  -5.4513985
    . 7   7   0.5072419
    . 8   8   0.1571958
    . 9   9   2.5170773
    . 10 10   1.5443067
    . 11 11   2.2559932
    . 12 12  -1.0437451
    . 13 13  -0.2433889
    . 14 14   0.5321312
    . 15 15  -0.1847379
    . 16 16   0.2301603
    . 17 17 245.8585043
    . 18 18  -0.3045617
    . 19 19   1.0444326
    . 20 20  -0.3575777

We can add the variate at any level

    data.frame(ID=1:20) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(STUDY_RE ~ rnorm(50,sqrt(50))|GROUP)

    .    ID GROUP STUDY_RE
    . 1   1     1 41.35843
    . 2   2     0 49.02249
    . 3   3     1 41.35843
    . 4   4     0 49.02249
    . 5   5     1 41.35843
    . 6   6     0 49.02249
    . 7   7     1 41.35843
    . 8   8     0 49.02249
    . 9   9     1 41.35843
    . 10 10     0 49.02249
    . 11 11     1 41.35843
    . 12 12     0 49.02249
    . 13 13     1 41.35843
    . 14 14     0 49.02249
    . 15 15     1 41.35843
    . 16 16     0 49.02249
    . 17 17     1 41.35843
    . 18 18     0 49.02249
    . 19 19     1 41.35843
    . 20 20     0 49.02249

An extended example:

    data.frame(ID=1:20) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(WT[low_wt,high_wt] ~ rnorm(mu,1)) %>%
      mutate_random(STUDY_RE ~ rnorm(0,sqrt(50))|GROUP) %>%
      mutate_random(SEX ~ rbinomial(p.female)) %>%
      mutate_random(sigma ~ rgamma(1,1)) %>%
      mutate_random(kappa ~ rgamma(1,1)|GROUP) %>% signif(3)

    .    ID GROUP   WT STUDY_RE SEX sigma kappa
    . 1   1     1 80.1     7.91   0 0.300 0.153
    . 2   2     0 79.9    10.50   1 0.182 0.864
    . 3   3     1 80.3     7.91   0 2.940 0.153
    . 4   4     0 81.6    10.50   0 0.683 0.864
    . 5   5     1 80.2     7.91   1 0.462 0.153
    . 6   6     0 78.6    10.50   0 1.360 0.864
    . 7   7     1 79.4     7.91   0 0.494 0.153
    . 8   8     0 80.6    10.50   0 0.385 0.864
    . 9   9     1 79.6     7.91   0 1.230 0.153
    . 10 10     0 82.3    10.50   0 0.684 0.864
    . 11 11     1 80.7     7.91   0 0.363 0.153
    . 12 12     0 79.7    10.50   1 0.321 0.864
    . 13 13     1 79.4     7.91   0 5.240 0.153
    . 14 14     0 78.7    10.50   0 1.730 0.864
    . 15 15     1 80.7     7.91   0 2.130 0.153
    . 16 16     0 79.5    10.50   0 1.440 0.864
    . 17 17     1 79.0     7.91   0 1.150 0.153
    . 18 18     0 79.8    10.50   1 0.750 0.864
    . 19 19     1 80.7     7.91   0 0.468 0.153
    . 20 20     0 79.8    10.50   0 0.360 0.864

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
    . 2  2 50.7 28.4
    . 3  3 48.3 27.1
