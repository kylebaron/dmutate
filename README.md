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
    . 1   1 80.06845
    . 2   2 89.33775
    . 3   3 80.10562
    . 4   4 84.24226
    . 5   5 77.91191
    . 6   6 78.10506
    . 7   7 87.47608
    . 8   8 85.73655
    . 9   9 76.68176
    . 10 10 73.60327

We can simulate from any probability distirbution in `R`

    data.frame(ID=1:10) %>% mutate_random(X ~ rcauchy(0,0.5))

    .    ID           X
    . 1   1  1.90139689
    . 2   2 -0.10051859
    . 3   3  0.70502454
    . 4   4  0.29159943
    . 5   5 -1.28752659
    . 6   6 -0.17683919
    . 7   7  0.10487994
    . 8   8 -0.03835449
    . 9   9 -0.74823471
    . 10 10 -0.05401384

We can add the variate at any level

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(STUDY_RE ~ rnorm(50,sqrt(50))|GROUP)

    .    ID GROUP STUDY_RE
    . 1   1     1 35.51964
    . 2   2     0 57.52245
    . 3   3     1 35.51964
    . 4   4     0 57.52245
    . 5   5     1 35.51964
    . 6   6     0 57.52245
    . 7   7     1 35.51964
    . 8   8     0 57.52245
    . 9   9     1 35.51964
    . 10 10     0 57.52245

### Simulate multivariate normal with bounds

    mu <- c(2,200)
    Sigma <- diag(c(10,1000))
    XY <- X[0,] + Y[200,300] ~ rmvnorm(mu,Sigma)

The object

    XY

    . X[0, ] + Y[200, 300] ~ rmvnorm(mu, Sigma)
    . <environment: 0x107283a30>

Simulate

    data.frame(ID=1:10000) %>%
      mutate_random(XY) %>% 
      summary

    .        ID              X                   Y        
    .  Min.   :    1   Min.   : 0.000705   Min.   :200.0  
    .  1st Qu.: 2501   1st Qu.: 1.630148   1st Qu.:209.9  
    .  Median : 5000   Median : 3.093676   Median :221.0  
    .  Mean   : 5000   Mean   : 3.418346   Mean   :224.9  
    .  3rd Qu.: 7500   3rd Qu.: 4.843010   3rd Qu.:235.9  
    .  Max.   :10000   Max.   :13.981875   Max.   :299.3

### An extended example

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(WT[low_wt,high_wt] ~ rnorm(mu_wt,1)) %>%
      mutate_random(STUDY_RE ~ rnorm(0,sqrt(50))|GROUP) %>%
      mutate_random(SEX ~ rbinomial(p.female)) %>%
      mutate_random(sigma ~ rgamma(1,1)) %>%
      mutate_random(kappa ~ rgamma(1,1)|GROUP) %>% signif(3)

    .    ID GROUP   WT STUDY_RE SEX  sigma kappa
    . 1   1     1 78.1   -0.609   0 1.7200 0.045
    . 2   2     0 79.6    3.740   0 2.1300 0.193
    . 3   3     1 78.7   -0.609   1 0.9670 0.045
    . 4   4     0 82.0    3.740   0 0.1240 0.193
    . 5   5     1 80.9   -0.609   0 0.0672 0.045
    . 6   6     0 79.2    3.740   0 0.5910 0.193
    . 7   7     1 81.0   -0.609   1 0.0549 0.045
    . 8   8     0 79.8    3.740   0 0.9100 0.193
    . 9   9     1 80.0   -0.609   1 0.0262 0.045
    . 10 10     0 79.8    3.740   0 1.9900 0.193

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

    .   ID    X    Y    A     B
    . 1  1 52.1 29.0 15.6  64.4
    . 2  2 41.2 23.6 21.8 100.0
    . 3  3 47.6 26.8 11.4  31.9
