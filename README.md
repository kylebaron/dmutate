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

    data.frame(ID=1:10) %>% mutate_random(WT[low_wt,high_wt] ~ rnorm(mu_wt,sd))

    .    ID       WT
    . 1   1 84.28682
    . 2   2 87.97055
    . 3   3 86.37275
    . 4   4 89.08535
    . 5   5 72.70595
    . 6   6 82.69501
    . 7   7 81.04754
    . 8   8 74.39132
    . 9   9 81.21900
    . 10 10 78.15123

We can simulate from any probability distirbution in `R`

    data.frame(ID=1:10) %>% mutate_random(X ~ rcauchy(0,0.5))

    .    ID          X
    . 1   1 -0.0291187
    . 2   2  1.2625849
    . 3   3  0.5110553
    . 4   4  0.7310809
    . 5   5 -1.0632271
    . 6   6 -1.0492207
    . 7   7 -0.4480000
    . 8   8 -0.6258141
    . 9   9  0.4612144
    . 10 10 -0.1909018

We can add the variate at any level

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(STUDY_RE ~ rnorm(50,sqrt(50))|GROUP)

    .    ID GROUP STUDY_RE
    . 1   1     1 44.98894
    . 2   2     0 60.70585
    . 3   3     1 44.98894
    . 4   4     0 60.70585
    . 5   5     1 44.98894
    . 6   6     0 60.70585
    . 7   7     1 44.98894
    . 8   8     0 60.70585
    . 9   9     1 44.98894
    . 10 10     0 60.70585

Simulate multivariate normal with bounds

    mu <- c(2,200)
    Sigma <- diag(c(10,1000))
    data.frame(ID=1:10000) %>%
      mutate_random(X[0,] + Y[200,300] ~ rmvnorm(mu,Sigma)) %>% 
      summary

    .        ID              X                   Y        
    .  Min.   :    1   Min.   : 0.000927   Min.   :200.0  
    .  1st Qu.: 2501   1st Qu.: 1.561327   1st Qu.:210.2  
    .  Median : 5000   Median : 3.037287   Median :221.5  
    .  Mean   : 5000   Mean   : 3.389094   Mean   :225.1  
    .  3rd Qu.: 7500   3rd Qu.: 4.842027   3rd Qu.:236.2  
    .  Max.   :10000   Max.   :14.241299   Max.   :299.9

An extended example:

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(WT[low_wt,high_wt] ~ rnorm(mu_wt,1)) %>%
      mutate_random(STUDY_RE ~ rnorm(0,sqrt(50))|GROUP) %>%
      mutate_random(SEX ~ rbinomial(p.female)) %>%
      mutate_random(sigma ~ rgamma(1,1)) %>%
      mutate_random(kappa ~ rgamma(1,1)|GROUP) %>% signif(3)

    .    ID GROUP   WT STUDY_RE SEX  sigma kappa
    . 1   1     1 79.6    -7.19   1 0.0189 0.588
    . 2   2     0 79.2   -14.30   0 0.9710 0.279
    . 3   3     1 81.4    -7.19   0 2.0000 0.588
    . 4   4     0 80.7   -14.30   0 0.8310 0.279
    . 5   5     1 80.2    -7.19   1 0.8460 0.588
    . 6   6     0 81.3   -14.30   0 1.8700 0.279
    . 7   7     1 79.7    -7.19   0 4.6000 0.588
    . 8   8     0 80.1   -14.30   0 0.2950 0.279
    . 9   9     1 79.8    -7.19   1 0.4500 0.588
    . 10 10     0 80.3   -14.30   0 0.2810 0.279

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
    . 1  1 49.5 27.8 37.5 110.0
    . 2  2 51.5 28.8 17.2  77.6
    . 3  3 53.8 29.9 21.0  70.5
