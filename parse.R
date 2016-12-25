library(dplyr)

#+
low_wt <- 40
high_wt <- 140

mu <- 80
p.female <- 0.24

#+
data.frame(ID=1:20) %>%
  mutate(GROUP = ID%%2) %>%
  dmutate(AGE ~ rnorm(60,20)) %>%
  dmutate(WT[low_wt,high_wt] ~ rnorm(mu,sqrt(80))) %>%
  dmutate(STUDY_RE ~ rnorm(0,sqrt(50)|GROUP)) %>%
  dmutate(SEX ~ dmutate:::Bin(p.female)) %>%
  dmutate(sigma ~ rgamma(1,1))

