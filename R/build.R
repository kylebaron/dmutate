

build_limits <- function(var,lower,upper) {
  if(is.null(lower) & is.null(upper)) return(var)
  if(length(var)==1) {
    limits <- paste0("[",lower,",",upper,"]")
    return(paste0(var,limits))
  }
  limits <- c()
  lower <- fill_limit(var,lower)
  upper <- fill_limit(var,upper)
  for(v in var) {
    limit <- paste0("[",lower[v],',',upper[v],"]")
    if(limit == "[,]") limit <- ""
    limits <- c(limits,limit)
  }
  if(!(length(limits)==length(var))) {
    stop("length of limits doesn't equal length of var")
  }
  paste0(var,limits)
}

fill_limit <- function(var,limit=NULL,def = "") {
  if(is.null(limit)) {
    limit <- rep(def, length(var))
    names(limit) <- var
    return(limit)
  }
  if(length(var)==1 & length(limit)==1) {
    names(limit) <- var
    return(limit)
  }
  if(is.null(names(limit))) stop("limit vector must be named")
  if(any(names(limit)=="")) stop("all elements of limit vector must be named")
  if(any(!is.element(names(limit),var))) {
    stop("found element in limit that isn't a variable")
  }
  for(v in var) {
    if(!is.element(v,names(limit))) {
      limit[v] <- def
    }
  }
  limit[var]
}

##' Build a object or formula to use with covset.
##'
##' \code{build_covform} formulates then parses a formula that
##' can be used in a covset. \code{build_covobj} just assembles
##' the object directly.
##'
##' @param var variable name, character
##' @param dist distribution function name
##' @param args character vector of arguments for \code{dist}
##' @param lower lower limits for var
##' @param upper upper limits for var
##' @param by grouping variable
##' @param envir environment for resolving symbols in expressions
##'
##' @details
##' When length of \code{var} is greater than one,
##' both \code{lower} and \code{upper} must be named vectors when specifiation is
##' made.  However, it is acceptable to specify nothing or to use unnamed limits
##' when the lenght of var is 1.
##'
##' @examples
##'
##' build_covform("WT", "rnorm", c("mu = 80", "sd = 40"), lower = 40, upper = 140)
##' build_covform("WT", "rnorm", "80,40", lower = 40, upper = 140)
##'
##' build_covobj("WT", "rnorm", "80,40", lower = 40, upper = 140)
##'
##' @export
build_covform <- function(var, dist, args,  lower = NULL, upper = NULL,
                          by = NULL, envir = parent.frame()) {
  if(length(by) > 1) by <- paste(by,collapse = ',')
  if(length(args) > 1) args <- paste(args,collapse = ',')
  if(!is.null(upper) | !is.null(lower)) {
    var <- build_limits(var,lower,upper)
  }
  if(length(var) > 1) var <- paste(var, collapse = "+")
  x <- paste0(var,"~",dist,"(",args,")")
  if(!is.null(by)) x <- paste0(x,"|",by)
  new_covobj(x, envir = envir)
}

##' @rdname build_covform
##' @export
build_covobj <- function(var, dist, args,
                         upper = NULL,
                         lower = NULL,
                         by = NULL,
                         envir = parent.frame()) {

  if(is.null(lower)) {
    lower <- rep(-Inf,length(var))
    names(lower) <- var
  }
  if(is.null(upper)) {
    upper <- rep(Inf,length(var))
    names(upper) <- var
  }

  lower <- fill_limit(var,lower,-Inf)
  upper <- fill_limit(var,upper, Inf)

  lower[lower==""] <- -Inf
  upper[upper==""] <- Inf

  if(length(lower) != length(var)) {
    stop("lower is not the proper length")
  }
  if(length(upper) != length(var)) {
    stop("upper is not the proper length")
  }
  if(length(lower) > 1) {
    lower <- paste(lower, collapse = ',')
    lower <- paste0("c(",lower,")")
  }
  if(length(upper) > 1) {
    upper <- paste(upper, collapse = ',')
    upper <- paste0("c(",upper,")")
  }
  x <- list()
  x$vars <- var
  x$lower <- Parse(lower)
  x$upper <- Parse(upper)
  x$dist <- dist
  x$formula <- "<not-parsed>"
  x$envir <- envir
  x$n <- 1
  if(length(args) > 1) args <- paste(args, collapse = ',')
  x$call <- Parse(paste0(dist, "(.n,",args, ")"))
  if(length(by) > 1) by <- paste(by, collapse="*")
  x$by <- by
  structure(x, class = "covobj")
}

