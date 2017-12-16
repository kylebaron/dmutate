

##' Create individual data frame from a covset object
##'
##' @param .covset a covset object
##' @param .n number of IDs to simulate
##'
##' @examples
##' cov1 <- covset(Y ~ rbinomial(0.2), Z ~ rnorm(2,2))
##'
##' as_idata(cov1, 10)
##'
##' @export
as_idata <- function(.covset, .n) {
  mutate_random(data_frame(ID = seq_len(.n)), .covset)
}
