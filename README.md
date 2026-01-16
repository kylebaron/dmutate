
# dmutate

Mutate a `data.frame`, adding random variates.

``` r
library(dplyr)
library(dmutate)
```

### Univariate examples

Some variables to use in formulae:

``` r
low_wt <- 70
high_wt <- 90
mu_wt <- 80
sd <- 60
p.female <- 0.24
```

Use `mutate_random` to implement formulae in data frame. We can put
bounds on any simulated variable

``` r
data.frame(ID = 1:10) %>% 
  mutate_random(WT[low_wt, high_wt] ~ rnorm(mu_wt, sd))
```

    .    ID       WT
    . 1   1 87.28619
    . 2   2 74.41711
    . 3   3 80.72592
    . 4   4 89.63599
    . 5   5 72.58696
    . 6   6 86.46300
    . 7   7 80.68241
    . 8   8 84.47482
    . 9   9 78.47417
    . 10 10 88.54634

We can simulate from any probability distribution in `R`

``` r
data.frame(ID = 1:10) %>% mutate_random(X ~ rcauchy(0, 0.5))
```

    .    ID           X
    . 1   1  3.49562264
    . 2   2 -3.87879719
    . 3   3 -0.20956182
    . 4   4 -0.33935718
    . 5   5 -0.02254644
    . 6   6 -0.28627923
    . 7   7  0.66041153
    . 8   8 -0.37298713
    . 9   9  0.61288903
    . 10 10  1.22101132

We can add the variate at any level

``` r
data.frame(ID = 1:10) %>%
  mutate(GROUP = ID%%2) %>%
  mutate_random(STUDY_RE ~ rnorm(50,sqrt(50))|GROUP)
```

    .    ID GROUP STUDY_RE
    . 1   1     1 43.69961
    . 2   2     0 52.61525
    . 3   3     1 43.69961
    . 4   4     0 52.61525
    . 5   5     1 43.69961
    . 6   6     0 52.61525
    . 7   7     1 43.69961
    . 8   8     0 52.61525
    . 9   9     1 43.69961
    . 10 10     0 52.61525

### Simulate multivariate normal with bounds

``` r
mu <- c(2, 200)
Sigma <- diag(c(10, 1000))
XY <- X[0,] + Y[200, 300] ~ rmvnorm(mu, Sigma)
```

The object

``` r
XY
```

    . X[0, ] + Y[200, 300] ~ rmvnorm(mu, Sigma)

Simulate

``` r
data.frame(ID = 1:10000) %>%
  mutate_random(XY) %>% 
  summary()
```

    .        ID              X                   Y        
    .  Min.   :    1   Min.   :2.347e-04   Min.   :200.0  
    .  1st Qu.: 2501   1st Qu.:1.598e+00   1st Qu.:210.0  
    .  Median : 5000   Median :3.089e+00   Median :221.2  
    .  Mean   : 5000   Mean   :3.412e+00   Mean   :225.0  
    .  3rd Qu.: 7500   3rd Qu.:4.840e+00   3rd Qu.:236.4  
    .  Max.   :10000   Max.   :1.414e+01   Max.   :299.8

### An extended example

``` r
data.frame(ID = 1:10) %>%
  mutate(GROUP = ID%%2) %>%
  mutate_random(WT[low_wt, high_wt] ~ rnorm(mu_wt, 1)) %>%
  mutate_random(STUDY_RE ~ rnorm(0, sqrt(50)) | GROUP) %>%
  mutate_random(SEX ~ rbinomial(p.female)) %>%
  mutate_random(sigma ~ rgamma(1,1)) %>%
  mutate_random(kappa ~ rgamma(1,1) | GROUP) %>% 
  signif(3)
```

    .    ID GROUP   WT STUDY_RE SEX sigma kappa
    . 1   1     1 78.2    -4.42   1 0.741  2.41
    . 2   2     0 82.6     3.85   0 0.185  2.77
    . 3   3     1 79.8    -4.42   1 0.649  2.41
    . 4   4     0 80.8     3.85   1 0.623  2.77
    . 5   5     1 79.9    -4.42   0 0.264  2.41
    . 6   6     0 79.9     3.85   0 0.596  2.77
    . 7   7     1 78.7    -4.42   0 0.534  2.41
    . 8   8     0 81.5     3.85   0 1.290  2.77
    . 9   9     1 80.2    -4.42   0 0.180  2.41
    . 10 10     0 79.1     3.85   0 0.496  2.77

# Create formulae with `expr` to calculate new columns in the `data.frame` using `dplyr::mutate`

We can easily save formulae to `R` variables. We collect formulae
together into sets called `covset`. For better control for where objects
are found, we can specify an environment where objects can be found.

``` r
a <- X ~ rnorm(50,3)
b <- Y ~ expr(X/2 + c)
d <- A+B ~ rlmvnorm(log(c(20,80)), diag(c(0.2,0.2)))
cov1 <- covset(a, b, d)
e <- list(c = 3)
```

Notice that `b` has function `expr`. This assigns the column named `Y`
(in this case) to the result of evaluating the expression in the data
frame using `dplyr::dmutate`.

``` r
.data <- data.frame(ID = 1:3)

mutate_random(.data, cov1, envir = e) %>% signif(3)
```

    .   ID    X    Y     A     B
    . 1  1 49.7 27.9 12.70  45.8
    . 2  2 46.1 26.0 26.10 121.0
    . 3  3 53.3 29.6  6.65  57.4
