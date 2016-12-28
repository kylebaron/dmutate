
library(dplyr)
data(Theoph)
library(magrittr)
library(mrgsolve)

data <- data_frame(ID=1:10,GROUP=ID%%2,FOO=ID)
data(exTheoph)

x <- "y ~ normal | ID, mean=50, sd = 2"

data %>%
  dmutate(y[0,] ~ normal | GROUP+FOO, mean=50, sd = 100)




