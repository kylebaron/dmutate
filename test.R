
library(dplyr)
data(Theoph)
library(magrittr)
library(mrgsolve)

l <- list(WT ~ rnorm(50,100)|ID,
          AGE ~ runif(20,100)|ARM,
          SEX ~ binomial(0.5))

wt <- WT ~ rnorm(50,10) |ID
age <- AGE ~ runif(20,180)|ARM
sex <- SEX ~ rbinomial(0.5)|ID
a <- covset(wt,age,sex)
b <- covset(sex)

data <- data_frame(ID=1:6,ARM = ID%%2)

data %>% mutate_random(age)

data %>% as.tbl %>% mutate_random("AGE ~ runif(20,190)")

