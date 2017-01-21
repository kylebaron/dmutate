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
    sd <- 60
    p.female <- 0.24

Use `mutate_random` to implement formulae in data frame. We can put
bounds on any simulated variable

    data.frame(ID=1:10) %>% mutate_random(WT[low_wt,high_wt] ~ rnorm(mu_wt,sd))

    .    ID       WT
    . 1   1 70.51004
    . 2   2 74.77020
    . 3   3 81.04483
    . 4   4 75.85504
    . 5   5 85.80671
    . 6   6 81.89052
    . 7   7 75.32365
    . 8   8 72.05583
    . 9   9 71.94176
    . 10 10 76.19714

We can simulate from any probability distirbution in `R`

    data.frame(ID=1:10) %>% mutate_random(X ~ rcauchy(0,0.5))

    .    ID           X
    . 1   1  0.78099636
    . 2   2 -0.11531262
    . 3   3 -0.52851269
    . 4   4 -0.32200648
    . 5   5  1.82039851
    . 6   6  0.20278915
    . 7   7  0.05991099
    . 8   8 -0.08821628
    . 9   9 -0.76080347
    . 10 10 -0.26256605

We can add the variate at any level

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(STUDY_RE ~ rnorm(50,sqrt(50))|GROUP)

    .    ID GROUP STUDY_RE
    . 1   1     1 51.51576
    . 2   2     0 36.76890
    . 3   3     1 51.51576
    . 4   4     0 36.76890
    . 5   5     1 51.51576
    . 6   6     0 36.76890
    . 7   7     1 51.51576
    . 8   8     0 36.76890
    . 9   9     1 51.51576
    . 10 10     0 36.76890

Simulate multivariate normal with bounds

    mu <- c(2,200)
    Sigma <- diag(c(10,1000))
    XY <- X[0,] + Y[200,300] ~ rmvnorm(mu,Sigma)

The object

    XY

    . X[0, ] + Y[200, 300] ~ rmvnorm(mu, Sigma)

Simulate

    data.frame(ID=1:10000) %>%
      mutate_random(XY) %>% 
      summary

    .        ID              X                   Y        
    .  Min.   :    1   Min.   : 0.000083   Min.   :200.0  
    .  1st Qu.: 2501   1st Qu.: 1.570921   1st Qu.:210.1  
    .  Median : 5000   Median : 3.016700   Median :221.5  
    .  Mean   : 5000   Mean   : 3.351903   Mean   :225.2  
    .  3rd Qu.: 7500   3rd Qu.: 4.729714   3rd Qu.:236.5  
    .  Max.   :10000   Max.   :15.852501   Max.   :299.9

An extended example:

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(WT[low_wt,high_wt] ~ rnorm(mu_wt,1)) %>%
      mutate_random(STUDY_RE ~ rnorm(0,sqrt(50))|GROUP) %>%
      mutate_random(SEX ~ rbinomial(p.female)) %>%
      mutate_random(sigma ~ rgamma(1,1)) %>%
      mutate_random(kappa ~ rgamma(1,1)|GROUP) %>% signif(3)

    .    ID GROUP   WT STUDY_RE SEX sigma kappa
    . 1   1     1 80.5    -2.41   0 0.275 0.123
    . 2   2     0 81.1    -9.87   1 1.330 0.445
    . 3   3     1 79.2    -2.41   0 0.283 0.123
    . 4   4     0 79.1    -9.87   0 2.080 0.445
    . 5   5     1 80.8    -2.41   0 0.748 0.123
    . 6   6     0 80.4    -9.87   0 0.675 0.445
    . 7   7     1 80.0    -2.41   0 0.286 0.123
    . 8   8     0 78.8    -9.87   0 0.249 0.445
    . 9   9     1 82.3    -2.41   0 0.245 0.123
    . 10 10     0 81.0    -9.87   0 0.476 0.445

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
    . 1  1 51.5 28.8 17.9 153.0
    . 2  2 50.1 28.0 48.5  93.5
    . 3  3 47.5 26.8 42.8  35.4
