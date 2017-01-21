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
    . 1   1 89.55391
    . 2   2 70.75067
    . 3   3 75.81632
    . 4   4 73.80809
    . 5   5 84.13964
    . 6   6 89.90634
    . 7   7 82.97467
    . 8   8 80.58647
    . 9   9 86.18475
    . 10 10 72.71269

We can simulate from any probability distirbution in `R`

    data.frame(ID=1:10) %>% mutate_random(X ~ rcauchy(0,0.5))

    .    ID           X
    . 1   1 -0.61843848
    . 2   2 -0.17868237
    . 3   3 10.49298108
    . 4   4 25.69108476
    . 5   5  0.04242832
    . 6   6 -0.73984452
    . 7   7  0.08945519
    . 8   8  0.42061215
    . 9   9  1.38881599
    . 10 10  0.53675318

We can add the variate at any level

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(STUDY_RE ~ rnorm(50,sqrt(50))|GROUP)

    .    ID GROUP STUDY_RE
    . 1   1     1  55.6356
    . 2   2     0  48.4398
    . 3   3     1  55.6356
    . 4   4     0  48.4398
    . 5   5     1  55.6356
    . 6   6     0  48.4398
    . 7   7     1  55.6356
    . 8   8     0  48.4398
    . 9   9     1  55.6356
    . 10 10     0  48.4398

Simulate multivariate normal with bounds

    mu <- c(2,200)
    Sigma <- diag(c(10,1000))
    data.frame(ID=1:10000) %>%
      mutate_random(X[0,] + Y[200,300] ~ rmvnorm(mu,Sigma)) %>% 
      summary

    .        ID              X                   Y        
    .  Min.   :    1   Min.   : 0.000363   Min.   :200.0  
    .  1st Qu.: 2501   1st Qu.: 1.612586   1st Qu.:209.8  
    .  Median : 5000   Median : 3.094325   Median :221.1  
    .  Mean   : 5000   Mean   : 3.428005   Mean   :224.9  
    .  3rd Qu.: 7500   3rd Qu.: 4.905171   3rd Qu.:236.0  
    .  Max.   :10000   Max.   :15.335277   Max.   :297.7

An extended example:

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(WT[low_wt,high_wt] ~ rnorm(mu_wt,1)) %>%
      mutate_random(STUDY_RE ~ rnorm(0,sqrt(50))|GROUP) %>%
      mutate_random(SEX ~ rbinomial(p.female)) %>%
      mutate_random(sigma ~ rgamma(1,1)) %>%
      mutate_random(kappa ~ rgamma(1,1)|GROUP) %>% signif(3)

    .    ID GROUP   WT STUDY_RE SEX  sigma kappa
    . 1   1     1 80.2    0.893   0 0.4690 0.165
    . 2   2     0 79.4    2.590   0 0.0700 0.179
    . 3   3     1 80.6    0.893   0 0.5060 0.165
    . 4   4     0 78.4    2.590   1 0.4040 0.179
    . 5   5     1 80.6    0.893   0 0.9050 0.165
    . 6   6     0 78.7    2.590   0 0.1110 0.179
    . 7   7     1 78.9    0.893   0 0.6800 0.165
    . 8   8     0 79.1    2.590   1 0.8930 0.179
    . 9   9     1 81.4    0.893   0 1.4000 0.165
    . 10 10     0 79.0    2.590   0 0.0173 0.179

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

    .   ID    X    Y     A     B
    . 1  1 46.6 26.3 86.10 107.0
    . 2  2 53.2 29.6 15.10  48.4
    . 3  3 51.1 28.6  9.31  66.8
