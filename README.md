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
    . 1   1 83.89062
    . 2   2 83.89177
    . 3   3 85.91495
    . 4   4 84.18830
    . 5   5 87.98526
    . 6   6 86.17794
    . 7   7 88.48437
    . 8   8 79.22966
    . 9   9 70.55973
    . 10 10 88.02533

We can simulate from any probability distirbution in `R`

    data.frame(ID=1:10) %>% mutate_random(X ~ rcauchy(0,0.5))

    .    ID           X
    . 1   1 -5.90570404
    . 2   2  0.39120703
    . 3   3  0.17019535
    . 4   4 -0.98593114
    . 5   5  0.46266157
    . 6   6 -0.54815000
    . 7   7 -0.12903556
    . 8   8 -0.01365122
    . 9   9 -0.16284835
    . 10 10  0.42695029

We can add the variate at any level

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(STUDY_RE ~ rnorm(50,sqrt(50))|GROUP)

    .    ID GROUP STUDY_RE
    . 1   1     1 57.19321
    . 2   2     0 44.30111
    . 3   3     1 57.19321
    . 4   4     0 44.30111
    . 5   5     1 57.19321
    . 6   6     0 44.30111
    . 7   7     1 57.19321
    . 8   8     0 44.30111
    . 9   9     1 57.19321
    . 10 10     0 44.30111

### Simulate multivariate normal with bounds

    mu <- c(2,200)
    Sigma <- diag(c(10,1000))
    XY <- X[0,] + Y[200,300] ~ rmvnorm(mu,Sigma)

The object

    XY

    . X[0, ] + Y[200, 300] ~ rmvnorm(mu, Sigma)
    . <environment: 0x1115a19b8>

Simulate

    data.frame(ID=1:10000) %>%
      mutate_random(XY) %>% 
      summary

    .        ID              X                   Y        
    .  Min.   :    1   Min.   : 0.002774   Min.   :200.0  
    .  1st Qu.: 2501   1st Qu.: 1.567587   1st Qu.:209.9  
    .  Median : 5000   Median : 3.106607   Median :221.4  
    .  Mean   : 5000   Mean   : 3.415481   Mean   :225.2  
    .  3rd Qu.: 7500   3rd Qu.: 4.886991   3rd Qu.:236.3  
    .  Max.   :10000   Max.   :13.232817   Max.   :299.9

### An extended example

    data.frame(ID=1:10) %>%
      mutate(GROUP = ID%%2) %>%
      mutate_random(WT[low_wt,high_wt] ~ rnorm(mu_wt,1)) %>%
      mutate_random(STUDY_RE ~ rnorm(0,sqrt(50))|GROUP) %>%
      mutate_random(SEX ~ rbinomial(p.female)) %>%
      mutate_random(sigma ~ rgamma(1,1)) %>%
      mutate_random(kappa ~ rgamma(1,1)|GROUP) %>% signif(3)

    .    ID GROUP   WT STUDY_RE SEX  sigma kappa
    . 1   1     1 78.7    -6.31   0 4.5200  1.48
    . 2   2     0 80.1     4.96   1 0.4530  1.39
    . 3   3     1 81.3    -6.31   1 2.0500  1.48
    . 4   4     0 80.4     4.96   0 0.5980  1.39
    . 5   5     1 78.8    -6.31   1 0.0832  1.48
    . 6   6     0 81.3     4.96   0 3.3400  1.39
    . 7   7     1 79.3    -6.31   0 0.3940  1.48
    . 8   8     0 78.8     4.96   0 1.9200  1.39
    . 9   9     1 81.3    -6.31   0 1.0800  1.48
    . 10 10     0 81.9     4.96   0 0.4830  1.39

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
    . 1  1 49.8 27.9 54.7  43.4
    . 2  2 45.3 25.7 24.3 108.0
    . 3  3 49.7 27.9 66.3 123.0
