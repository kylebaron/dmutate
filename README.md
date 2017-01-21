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

    data.frame(ID=1:10) %>% mutate_random(WT[low_wt,high_wt] ~ rnorm(mu_wt,sd))

    .    ID       WT
    . 1   1 73.74197
    . 2   2 80.21811
    . 3   3 76.76447
    . 4   4 71.25025
    . 5   5 84.90590
    . 6   6 85.68872
    . 7   7 70.50496
    . 8   8 79.47146
    . 9   9 80.87770
    . 10 10 81.78786

We can simulate from any probability distirbution in `R`

    data.frame(ID=1:10) %>% mutate_random(X ~ rcauchy(0,0.5))

    .    ID           X
    . 1   1  1.21283656
    . 2   2  0.17784736
    . 3   3 -0.09226413
    . 4   4 -2.39699832
    . 5   5 -0.27801132
    . 6   6  4.04663029
    . 7   7  1.02476585
    . 8   8  0.65891848
    . 9   9  1.65798317
    . 10 10  0.17429262

We can add the variate at any level

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(STUDY_RE ~ rnorm(50,sqrt(50))|GROUP)

    .    ID GROUP STUDY_RE
    . 1   1     1 40.95348
    . 2   2     0 53.60148
    . 3   3     1 40.95348
    . 4   4     0 53.60148
    . 5   5     1 40.95348
    . 6   6     0 53.60148
    . 7   7     1 40.95348
    . 8   8     0 53.60148
    . 9   9     1 40.95348
    . 10 10     0 53.60148

### Simulate multivariate normal with bounds

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
    .  Min.   :    1   Min.   : 0.001509   Min.   :200.0  
    .  1st Qu.: 2501   1st Qu.: 1.592103   1st Qu.:210.0  
    .  Median : 5000   Median : 3.012502   Median :221.2  
    .  Mean   : 5000   Mean   : 3.383010   Mean   :225.2  
    .  3rd Qu.: 7500   3rd Qu.: 4.860364   3rd Qu.:236.3  
    .  Max.   :10000   Max.   :14.382681   Max.   :299.2

### An extended example

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(WT[low_wt,high_wt] ~ rnorm(mu_wt,1)) %>%
      mutate_random(STUDY_RE ~ rnorm(0,sqrt(50))|GROUP) %>%
      mutate_random(SEX ~ rbinomial(p.female)) %>%
      mutate_random(sigma ~ rgamma(1,1)) %>%
      mutate_random(kappa ~ rgamma(1,1)|GROUP) %>% signif(3)

    .    ID GROUP   WT STUDY_RE SEX sigma kappa
    . 1   1     1 79.5    -3.91   0 0.318 1.380
    . 2   2     0 79.6    16.70   0 0.858 0.337
    . 3   3     1 80.3    -3.91   0 0.877 1.380
    . 4   4     0 79.6    16.70   1 0.912 0.337
    . 5   5     1 81.3    -3.91   0 0.575 1.380
    . 6   6     0 79.0    16.70   1 0.809 0.337
    . 7   7     1 80.5    -3.91   0 0.282 1.380
    . 8   8     0 80.7    16.70   0 0.732 0.337
    . 9   9     1 77.2    -3.91   0 0.615 1.380
    . 10 10     0 78.0    16.70   0 0.426 0.337

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
    . 1  1 47.3 26.6 19.4  91.9
    . 2  2 44.5 25.3 33.5  59.0
    . 3  3 48.8 27.4 13.5 133.0
