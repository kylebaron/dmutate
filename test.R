
library(dplyr)

library(magrittr)
data(Theoph)
ungroup(Theoph)


age <- AGE ~ rnorm(50,20)
wt <- WT ~ expr(AGE*2 - 5)

a <- covset(age,wt)

data <- data_frame(ID=1:6,ARM = ID%%2)

data %>% mutate_random(a)

test <- function(a) {
 data_frame(ID=1:6) %>% mutate_random(a)
}

test(a)

