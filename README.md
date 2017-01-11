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

Use `mutate_random` to implement formulae in data frame. We can put
bounds on any simulated variable:

    data.frame(ID=1:20) %>% mutate_random(WT[low_wt,high_wt] ~ rnorm(mu,1))

    .    ID       WT
    . 1   1 82.35687
    . 2   2 82.49118
    . 3   3 82.44642
    . 4   4 78.84393
    . 5   5 80.60083
    . 6   6 79.51241
    . 7   7 81.31857
    . 8   8 78.82209
    . 9   9 79.93120
    . 10 10 80.96321
    . 11 11 79.40980
    . 12 12 79.94292
    . 13 13 79.49772
    . 14 14 78.45513
    . 15 15 80.28865
    . 16 16 79.63708
    . 17 17 79.82455
    . 18 18 79.45321
    . 19 19 80.22568
    . 20 20 79.75725

We can simulate from any probability distirbution in `R`:

    data.frame(ID=1:20) %>% mutate_random(X ~ rcauchy(0,0.5))

    .    ID            X
    . 1   1   0.36151990
    . 2   2   1.33924841
    . 3   3   0.85343590
    . 4   4   0.68015589
    . 5   5  -0.61381640
    . 6   6  -1.77302361
    . 7   7   1.69802400
    . 8   8  -0.10267398
    . 9   9   0.49216921
    . 10 10   1.18869397
    . 11 11   0.88619374
    . 12 12   0.62158887
    . 13 13 -48.19525036
    . 14 14  15.40878211
    . 15 15  -0.07622647
    . 16 16   0.43909473
    . 17 17  -0.06288918
    . 18 18  -0.96774334
    . 19 19  -0.22044008
    . 20 20  -3.73142953

We can add the variate at any level

    data.frame(ID=1:20) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(STUDY_RE ~ rnorm(50,sqrt(50))|GROUP)

    .    ID GROUP STUDY_RE
    . 1   1     1 43.96670
    . 2   2     0 53.24053
    . 3   3     1 43.96670
    . 4   4     0 53.24053
    . 5   5     1 43.96670
    . 6   6     0 53.24053
    . 7   7     1 43.96670
    . 8   8     0 53.24053
    . 9   9     1 43.96670
    . 10 10     0 53.24053
    . 11 11     1 43.96670
    . 12 12     0 53.24053
    . 13 13     1 43.96670
    . 14 14     0 53.24053
    . 15 15     1 43.96670
    . 16 16     0 53.24053
    . 17 17     1 43.96670
    . 18 18     0 53.24053
    . 19 19     1 43.96670
    . 20 20     0 53.24053

An extended example:

    data.frame(ID=1:20) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(WT[low_wt,high_wt] ~ rnorm(mu,1)) %>%
      mutate_random(STUDY_RE ~ rnorm(0,sqrt(50))|GROUP) %>%
      mutate_random(SEX ~ rbinomial(p.female)) %>%
      mutate_random(sigma ~ rgamma(1,1)) %>%
      mutate_random(kappa ~ rgamma(1,1)|GROUP) %>% signif(3)

    .    ID GROUP   WT STUDY_RE SEX  sigma  kappa
    . 1   1     1 80.1     2.31   0 0.5680 0.0626
    . 2   2     0 80.8    -4.59   0 0.2990 0.2270
    . 3   3     1 79.9     2.31   0 1.4400 0.0626
    . 4   4     0 81.8    -4.59   0 1.6900 0.2270
    . 5   5     1 80.7     2.31   0 0.7800 0.0626
    . 6   6     0 81.3    -4.59   0 0.3490 0.2270
    . 7   7     1 80.0     2.31   0 0.7920 0.0626
    . 8   8     0 81.6    -4.59   1 0.0849 0.2270
    . 9   9     1 80.7     2.31   1 0.4520 0.0626
    . 10 10     0 78.7    -4.59   1 0.0418 0.2270
    . 11 11     1 80.3     2.31   1 0.9240 0.0626
    . 12 12     0 81.1    -4.59   0 3.0100 0.2270
    . 13 13     1 81.0     2.31   1 0.3810 0.0626
    . 14 14     0 78.9    -4.59   1 0.1300 0.2270
    . 15 15     1 79.9     2.31   0 0.1770 0.0626
    . 16 16     0 80.5    -4.59   0 1.1600 0.2270
    . 17 17     1 79.7     2.31   0 1.0300 0.0626
    . 18 18     0 79.4    -4.59   1 0.1150 0.2270
    . 19 19     1 79.6     2.31   0 0.9020 0.0626
    . 20 20     0 79.9    -4.59   0 0.7590 0.2270

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
    . 1  1 45.8 25.9
    . 2  2 47.6 26.8
    . 3  3 52.6 29.3
