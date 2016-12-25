
library(dplyr)
data(Theoph)

df <- expand.grid(Subject=1:10000)


df %>% dmutate(SEX ~ binom(0.95|Subject)) %>% summarise(pct=mean(SEX))


