    knitr::opts_chunk$set(comment='.')

dmutate
=======

Mutate a `data.frame`, adding random variates.

    library(dplyr)
    library(dmutate)

Some variables to use in formulae:

    low_wt <- 70
    high_wt <- 90
    mu_wt <- 80
    sd <- 80
    p.female <- 0.24

Use `mutate_random` to implement formulae in data frame. We can put
bounds on any simulated variable

    data.frame(ID=1:20) %>% mutate_random(WT[low_wt,high_wt] ~ rnorm(mu_wt,sd))

    .    ID       WT
    . 1   1 78.29358
    . 2   2 86.92864
    . 3   3 87.95603
    . 4   4 70.33452
    . 5   5 70.45375
    . 6   6 76.53645
    . 7   7 74.65158
    . 8   8 85.23785
    . 9   9 84.23224
    . 10 10 71.53038
    . 11 11 73.18221
    . 12 12 76.88049
    . 13 13 79.52676
    . 14 14 85.39995
    . 15 15 86.63366
    . 16 16 88.83932
    . 17 17 88.54186
    . 18 18 73.22630
    . 19 19 70.96414
    . 20 20 83.53214

We can simulate from any probability distirbution in `R`

    data.frame(ID=1:20) %>% mutate_random(X ~ rcauchy(0,0.5))

    .    ID            X
    . 1   1   0.81813566
    . 2   2  -0.32488421
    . 3   3   0.02725919
    . 4   4   0.16887629
    . 5   5   0.06641596
    . 6   6 -12.61939519
    . 7   7   1.53366317
    . 8   8  -0.43232578
    . 9   9   0.76372574
    . 10 10   0.04963017
    . 11 11  -0.11935653
    . 12 12   0.17072063
    . 13 13   0.63303319
    . 14 14   0.05832544
    . 15 15  -0.08305310
    . 16 16  -0.48468836
    . 17 17  -0.19166853
    . 18 18   0.10580249
    . 19 19   0.81132590
    . 20 20  -0.15690865

We can add the variate at any level

    data.frame(ID=1:20) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(STUDY_RE ~ rnorm(50,sqrt(50))|GROUP)

    .    ID GROUP STUDY_RE
    . 1   1     1 47.54744
    . 2   2     0 43.01539
    . 3   3     1 47.54744
    . 4   4     0 43.01539
    . 5   5     1 47.54744
    . 6   6     0 43.01539
    . 7   7     1 47.54744
    . 8   8     0 43.01539
    . 9   9     1 47.54744
    . 10 10     0 43.01539
    . 11 11     1 47.54744
    . 12 12     0 43.01539
    . 13 13     1 47.54744
    . 14 14     0 43.01539
    . 15 15     1 47.54744
    . 16 16     0 43.01539
    . 17 17     1 47.54744
    . 18 18     0 43.01539
    . 19 19     1 47.54744
    . 20 20     0 43.01539

Simulate multivariate normal with bounds

    mu <- c(2,200)
    Sigma <- diag(c(10,1000))
    data.frame(ID=1:10000) %>%
      mutate_random(X[0,] + Y[200,300] ~ rmvnorm(mu,Sigma)) %>% 
      summary

    .        ID              X                   Y        
    .  Min.   :    1   Min.   : 0.001265   Min.   :200.0  
    .  1st Qu.: 2501   1st Qu.: 1.550780   1st Qu.:210.1  
    .  Median : 5000   Median : 3.007427   Median :221.0  
    .  Mean   : 5000   Mean   : 3.372328   Mean   :225.1  
    .  3rd Qu.: 7500   3rd Qu.: 4.796418   3rd Qu.:236.3  
    .  Max.   :10000   Max.   :14.951202   Max.   :299.0

An extended example:

    data.frame(ID=1:20) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(WT[low_wt,high_wt] ~ rnorm(mu_wt,1)) %>%
      mutate_random(STUDY_RE ~ rnorm(0,sqrt(50))|GROUP) %>%
      mutate_random(SEX ~ rbinomial(p.female)) %>%
      mutate_random(sigma ~ rgamma(1,1)) %>%
      mutate_random(kappa ~ rgamma(1,1)|GROUP) %>% signif(3)

    .    ID GROUP   WT STUDY_RE SEX  sigma kappa
    . 1   1     1 80.1    -1.52   1 0.0447  1.25
    . 2   2     0 79.9    -1.83   0 1.1900  2.72
    . 3   3     1 79.8    -1.52   0 1.0400  1.25
    . 4   4     0 79.4    -1.83   0 1.3500  2.72
    . 5   5     1 80.5    -1.52   0 0.3980  1.25
    . 6   6     0 80.7    -1.83   1 0.4920  2.72
    . 7   7     1 78.9    -1.52   0 1.3900  1.25
    . 8   8     0 79.7    -1.83   1 0.6970  2.72
    . 9   9     1 80.7    -1.52   0 1.3800  1.25
    . 10 10     0 80.2    -1.83   0 1.5300  2.72
    . 11 11     1 81.1    -1.52   0 0.6720  1.25
    . 12 12     0 79.7    -1.83   1 0.6480  2.72
    . 13 13     1 80.1    -1.52   0 0.3980  1.25
    . 14 14     0 80.9    -1.83   1 0.4740  2.72
    . 15 15     1 79.9    -1.52   0 0.5250  1.25
    . 16 16     0 79.7    -1.83   0 0.2230  2.72
    . 17 17     1 81.4    -1.52   0 0.1310  1.25
    . 18 18     0 78.3    -1.83   0 4.6300  2.72
    . 19 19     1 81.9    -1.52   0 3.8400  1.25
    . 20 20     0 80.7    -1.83   1 0.0748  2.72

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

    data <- data.frame(ID=1:3)

    mutate_random(data,cov1,envir=e) %>% signif(3)

    .   ID    X    Y    A     B
    . 1  1 55.7 30.9 23.5 160.0
    . 2  2 54.1 30.1 43.7  66.2
    . 3  3 52.1 29.0 25.7  95.8
