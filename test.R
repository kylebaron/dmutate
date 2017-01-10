
library(dplyr)

library(magrittr)

age <- AGE ~ rnorm(50,20)
wt <- WT ~ mutate(AGE*2 - 5)

a <- covset(age,wt)

data <- data_frame(ID=1:6,ARM = ID%%2)

#debug(dmutate:::parse_random_string)
#debug(dmutate:::do_mutate)
data %>% mutate_random(a)

