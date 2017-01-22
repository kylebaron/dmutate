    knitr::opts_chunk$set(comment='.')

dmutate
=======

Mutate a `data.frame`, adding random variates.

    library(dplyr)
    library(dmutate)

### Univariate examples

Some variables to use in formulae:

    low_wt <- 70
    high_wt <- 90
    mu_wt <- 80
    sd <- 60
    p.female <- 0.24

Use `mutate_random` to implement formulae in data frame. We can put
bounds on any simulated variable

    data.frame(ID=1:10) %>% 
      mutate_random(WT[low_wt,high_wt] ~ rnorm(mu_wt,sd))

    .    ID       WT
    . 1   1 87.90649
    . 2   2 82.74646
    . 3   3 70.99114
    . 4   4 79.08665
    . 5   5 88.60874
    . 6   6 70.32462
    . 7   7 70.61804
    . 8   8 74.80325
    . 9   9 80.91838
    . 10 10 77.66639

We can simulate from any probability distirbution in `R`

    data.frame(ID=1:10) %>% mutate_random(X ~ rcauchy(0,0.5))

    .    ID            X
    . 1   1   0.29957246
    . 2   2   0.14823683
    . 3   3  -0.64841641
    . 4   4   0.03012045
    . 5   5  -0.23939540
    . 6   6  -7.57115364
    . 7   7  -1.77437039
    . 8   8 -51.98945505
    . 9   9   0.07208963
    . 10 10  -0.10670473

We can add the variate at any level

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(STUDY_RE ~ rnorm(50,sqrt(50))|GROUP)

    .    ID GROUP STUDY_RE
    . 1   1     1 65.33829
    . 2   2     0 36.47680
    . 3   3     1 65.33829
    . 4   4     0 36.47680
    . 5   5     1 65.33829
    . 6   6     0 36.47680
    . 7   7     1 65.33829
    . 8   8     0 36.47680
    . 9   9     1 65.33829
    . 10 10     0 36.47680

### Simulate multivariate normal with bounds

    mu <- c(2,200)
    Sigma <- diag(c(10,1000))
    XY <- X[0,] + Y[200,300] ~ rmvnorm(mu,Sigma)

The object

    XY

    . X[0, ] + Y[200, 300] ~ rmvnorm(mu, Sigma)
    . <environment: 0x10c222b50>

Simulate

    data.frame(ID=1:10000) %>%
      mutate_random(XY) %>% 
      summary

    .        ID              X                   Y        
    .  Min.   :    1   Min.   : 0.000036   Min.   :200.0  
    .  1st Qu.: 2501   1st Qu.: 1.585378   1st Qu.:210.3  
    .  Median : 5000   Median : 3.070223   Median :221.5  
    .  Mean   : 5000   Mean   : 3.407181   Mean   :225.2  
    .  3rd Qu.: 7500   3rd Qu.: 4.833135   3rd Qu.:236.6  
    .  Max.   :10000   Max.   :13.989362   Max.   :299.8

### An extended example

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(WT[low_wt,high_wt] ~ rnorm(mu_wt,1)) %>%
      mutate_random(STUDY_RE ~ rnorm(0,sqrt(50))|GROUP) %>%
      mutate_random(SEX ~ rbinomial(p.female)) %>%
      mutate_random(sigma ~ rgamma(1,1)) %>%
      mutate_random(kappa ~ rgamma(1,1)|GROUP) %>% signif(3)

    .    ID GROUP   WT STUDY_RE SEX  sigma kappa
    . 1   1     1 80.3    -1.88   1 0.1010 0.412
    . 2   2     0 78.7     2.02   1 0.0410 0.460
    . 3   3     1 81.3    -1.88   1 0.0990 0.412
    . 4   4     0 80.8     2.02   0 4.8300 0.460
    . 5   5     1 78.2    -1.88   0 1.9500 0.412
    . 6   6     0 81.5     2.02   0 0.3710 0.460
    . 7   7     1 80.5    -1.88   0 1.8400 0.412
    . 8   8     0 79.9     2.02   0 0.1770 0.460
    . 9   9     1 79.9    -1.88   0 0.0891 0.412
    . 10 10     0 81.6     2.02   0 0.6930 0.460

Create formulae with `expr` to calculate new columns in the `data.frame` using `dplyr::mutate`
==============================================================================================

We can easily save formulae to `R` variables. We collect formulae
together into sets called `covset`. For better control for where objects
are found, we can specify an environment where objects can be found.

    a <- X ~ rnorm(50,3)
    b <- Y ~ expr(X/2 + c)
    d <- A+B ~ rlmvnorm(log(c(20,80)),diag(c(0.2,0.2)))
    cov1 <- covset(a,b,d)
    e <- list(c=3)

Notice that `b` has function `expr`. This assigns the column named `Y`
(in this case) to the result of evaluating the expression in the data
frame using `dplyr::dmutate`.

    .data <- data.frame(ID=1:3)

    mutate_random(.data,cov1,envir=e) %>% signif(3)

    .   ID    X    Y    A   B
    . 1  1 51.9 29.0 48.6 117
    . 2  2 50.8 28.4 37.9 116
    . 3  3 51.5 28.7 21.4 192
