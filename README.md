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
    . 1   1 70.68523
    . 2   2 75.43621
    . 3   3 78.50943
    . 4   4 81.78408
    . 5   5 70.39273
    . 6   6 75.66402
    . 7   7 78.82507
    . 8   8 77.39417
    . 9   9 82.31973
    . 10 10 75.95589

We can simulate from any probability distirbution in `R`

    data.frame(ID=1:10) %>% mutate_random(X ~ rcauchy(0,0.5))

    .    ID          X
    . 1   1  1.1405978
    . 2   2 41.3435220
    . 3   3 -0.9845103
    . 4   4 -0.1706075
    . 5   5  0.2887833
    . 6   6 -1.7892419
    . 7   7 -1.8984130
    . 8   8  0.1598052
    . 9   9 -1.0433192
    . 10 10  2.4274533

We can add the variate at any level

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(STUDY_RE ~ rnorm(50,sqrt(50))|GROUP)

    .    ID GROUP STUDY_RE
    . 1   1     1 55.74335
    . 2   2     0 34.75074
    . 3   3     1 55.74335
    . 4   4     0 34.75074
    . 5   5     1 55.74335
    . 6   6     0 34.75074
    . 7   7     1 55.74335
    . 8   8     0 34.75074
    . 9   9     1 55.74335
    . 10 10     0 34.75074

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
    .  Min.   :    1   Min.   : 0.000089   Min.   :200.0  
    .  1st Qu.: 2501   1st Qu.: 1.595738   1st Qu.:209.9  
    .  Median : 5000   Median : 3.054478   Median :221.1  
    .  Mean   : 5000   Mean   : 3.399750   Mean   :225.0  
    .  3rd Qu.: 7500   3rd Qu.: 4.855527   3rd Qu.:236.3  
    .  Max.   :10000   Max.   :14.316092   Max.   :297.8

### An extended example

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(WT[low_wt,high_wt] ~ rnorm(mu_wt,1)) %>%
      mutate_random(STUDY_RE ~ rnorm(0,sqrt(50))|GROUP) %>%
      mutate_random(SEX ~ rbinomial(p.female)) %>%
      mutate_random(sigma ~ rgamma(1,1)) %>%
      mutate_random(kappa ~ rgamma(1,1)|GROUP) %>% signif(3)

    .    ID GROUP   WT STUDY_RE SEX  sigma kappa
    . 1   1     1 80.5    -4.02   1 0.7150 0.484
    . 2   2     0 78.3     2.55   0 0.5140 0.133
    . 3   3     1 79.3    -4.02   0 0.0235 0.484
    . 4   4     0 79.4     2.55   0 0.1930 0.133
    . 5   5     1 81.8    -4.02   0 3.5600 0.484
    . 6   6     0 78.4     2.55   0 0.3760 0.133
    . 7   7     1 78.7    -4.02   1 0.4940 0.484
    . 8   8     0 79.6     2.55   0 0.7930 0.133
    . 9   9     1 80.9    -4.02   0 0.4410 0.484
    . 10 10     0 80.5     2.55   0 0.7090 0.133

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
    . 1  1 44.5 25.2 19.70  65.4
    . 2  2 48.7 27.4 20.10  93.0
    . 3  3 49.4 27.7  9.71 117.0
