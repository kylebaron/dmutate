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
    . 1   1 71.33459
    . 2   2 76.79287
    . 3   3 80.82562
    . 4   4 87.87538
    . 5   5 81.93415
    . 6   6 70.13780
    . 7   7 85.00668
    . 8   8 83.34982
    . 9   9 86.66724
    . 10 10 78.63552

We can simulate from any probability distirbution in `R`

    data.frame(ID=1:10) %>% mutate_random(X ~ rcauchy(0,0.5))

    .    ID           X
    . 1   1 -0.25653817
    . 2   2 -5.36468930
    . 3   3 -0.39264382
    . 4   4  0.07782851
    . 5   5  0.32193296
    . 6   6 -0.27398525
    . 7   7  1.43806638
    . 8   8 -0.34525250
    . 9   9 -2.49510487
    . 10 10 19.32487064

We can add the variate at any level

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(STUDY_RE ~ rnorm(50,sqrt(50))|GROUP)

    .    ID GROUP STUDY_RE
    . 1   1     1 55.46985
    . 2   2     0 39.21771
    . 3   3     1 55.46985
    . 4   4     0 39.21771
    . 5   5     1 55.46985
    . 6   6     0 39.21771
    . 7   7     1 55.46985
    . 8   8     0 39.21771
    . 9   9     1 55.46985
    . 10 10     0 39.21771

### Simulate multivariate normal with bounds

    mu <- c(2,200)
    Sigma <- diag(c(10,1000))
    XY <- X[0,] + Y[200,300] ~ rmvnorm(mu,Sigma)

The object

    XY

    . X[0, ] + Y[200, 300] ~ rmvnorm(mu, Sigma)
    . <environment: 0x101dbd140>

Simulate

    data.frame(ID=1:10000) %>%
      mutate_random(XY) %>% 
      summary

    .        ID              X                   Y        
    .  Min.   :    1   Min.   : 0.000392   Min.   :200.0  
    .  1st Qu.: 2501   1st Qu.: 1.584506   1st Qu.:209.8  
    .  Median : 5000   Median : 3.033197   Median :221.2  
    .  Mean   : 5000   Mean   : 3.377885   Mean   :225.1  
    .  3rd Qu.: 7500   3rd Qu.: 4.797250   3rd Qu.:236.6  
    .  Max.   :10000   Max.   :13.102020   Max.   :299.8

### An extended example

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(WT[low_wt,high_wt] ~ rnorm(mu_wt,1)) %>%
      mutate_random(STUDY_RE ~ rnorm(0,sqrt(50))|GROUP) %>%
      mutate_random(SEX ~ rbinomial(p.female)) %>%
      mutate_random(sigma ~ rgamma(1,1)) %>%
      mutate_random(kappa ~ rgamma(1,1)|GROUP) %>% signif(3)

    .    ID GROUP   WT STUDY_RE SEX  sigma kappa
    . 1   1     1 80.6   -10.80   1 3.8100 0.220
    . 2   2     0 79.5     8.53   0 1.1200 0.595
    . 3   3     1 80.8   -10.80   0 0.9660 0.220
    . 4   4     0 79.3     8.53   0 0.5330 0.595
    . 5   5     1 80.8   -10.80   0 0.0757 0.220
    . 6   6     0 79.3     8.53   0 0.1190 0.595
    . 7   7     1 80.6   -10.80   0 0.1340 0.220
    . 8   8     0 79.8     8.53   0 0.4210 0.595
    . 9   9     1 78.8   -10.80   0 1.0800 0.220
    . 10 10     0 78.4     8.53   0 1.1300 0.595

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
    . 1  1 50.9 28.5 15.2  55.7
    . 2  2 49.3 27.7 24.5  50.5
    . 3  3 53.1 29.5 23.1 107.0
