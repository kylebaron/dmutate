
setClass("covset")

##' Add random variates to a data frame.
##'
##' @param data the data.frame to mutate
##' @param input an unquoted R formula; see details
##' @param envir environment for object lookup
##' @param ... additional inputs
##'
##' @importFrom dplyr left_join bind_cols data_frame select_ mutate_ ungroup group_by_
##' @importFrom stats rbinom rnorm setNames
##' @import methods
##' @examples
##'
##' data <- data.frame(ID=1:10, GROUP = sample(c(1,2,3),10,replace=TRUE))
##'
##' mutate_random(data, AGE[40,90] ~ rnorm(55,50))
##' mutate_random(data, RE ~ rbeta(1,1) | GROUP)
##'
##' e <- list(lower=40,upper=140,mu=100,sd=100)
##'
##' egfr <- covset(EGFR[lower,upper] ~ rnorm(mu,sd))
##'
##' mutate_random(data,egfr,envir=e)
##'
##' @export
setGeneric("mutate_random", function(data,input,...) standardGeneric("mutate_random"))

##' @export
##' @rdname mutate_random
##'
setMethod("mutate_random", c("data.frame","formula"), function(data,input,...) {
  x <- new_covobj(input,envir=environment(input))
  do_mutate(data,x=x,...)
})

##' @export
##' @rdname mutate_random
setMethod("mutate_random", c("data.frame", "character"), function(data,input,envir=parent.frame(),...) {
  input <- new_covobj(input,envir=envir)
  args <- input$args
  input$args <- NULL
  args <- c(args,list(x=input,data=data,envir=envir),list(...))
  do.call(do_mutate,args)
})

##' @export
##' @rdname mutate_random
setMethod("mutate_random", c("data.frame", "list"), function(data,input,...) {
  apply_covset(data,input,...)
})

##' @export
##' @rdname mutate_random
setMethod("mutate_random", c("data.frame", "covset"), function(data,input,...) {
  apply_covset(data,input,...)
})

##' @export
##' @rdname mutate_random
setMethod("mutate_random", c("data.frame", "covobj"), function(data,input,envir=parent.frame(),...) {
  do_mutate(data,input,envir=envir,...)
})

parse_left_var <- function(x) {
  m <- regexec("(\\w+)(\\[(\\w+)?\\,(\\w+)?\\])?", x)
  m <- unlist(regmatches(x,m))
  var <- m[2]
  bounds <- m[3]
  lower <- m[4]
  upper <- m[5]
  if(lower=="") lower <- "-Inf"
  if(upper=="") upper <- "Inf"
  return(list(var=var,lower=lower,upper=upper))
}

parse_left <- function(x) {
  x <- unlist(strsplit(x,"+",fixed=TRUE))
  x <- lapply(x,parse_left_var)
  vars <- s_pick(x,"var")
  lower <- s_pick(x,"lower")
  upper <- s_pick(x,"upper")
  if(length(vars) > 1) {
    lower <- paste0("c(",paste(lower,collapse=','),")")
    upper <- paste0("c(",paste(upper,collapse=','),")")
  }
  list(vars=vars,lower=Parse(lower),upper=Parse(upper),n=length(vars))
}


bound <- function(call,n,envir=list(),mult=1.3,mn=-Inf,mx=Inf,tries=10) {
  ngot <- 0
  y <- numeric(0)
  envir$.n <- ceiling(n*mult)
  for(i in seq(1,tries)) {
    yy <- eval(call,envir=envir)
    yy <- yy[yy > mn & yy < mx]
    ngot <- ngot + length(yy)
    y <- c(yy,y)
    if(ngot >= n) break
  }
  if(ngot < n) {
    stop("Could not simulate required variates within given bounds in ", tries, " tries", call.=FALSE)
  }
  return(y[1:n])
}


##' Simulate from binomial distribution.
##'
##' Wrapper for \code{\link{rbinom}}  with trial size of 1.
##'
##' @param n number of variates
##' @param p probability of success
##' @param ... passed along as appropriate
##'
##' @details
##' The \code{size} of each trial is always 1.
##'
##' @export
rbinomial <- function(n,p,...) rbinom(n,1,p)

##' Simulate from multivariate normal distribution.
##'
##' @param n number of variates
##' @param mu vector of means
##' @param Sigma variance-covariance matrix with number of columns equal to
##' length of \code{mu}
##'
##' @details \code{rlmvnorm} is a multivariate log normal.
##'
##' @return Returns a matrix of variates with number of rows
##' equal to \code{n} and mumber of columns equal to length of \code{mu}.
##'
##' @export
rmvnorm <- function(n, mu, Sigma) {
  if(!is.matrix(Sigma)) {
    stop("Sigma should be a matrix.")
  }
  if(length(mu) != ncol(Sigma)) {
    stop("Incompatible inputs.")
  }
  if(det(Sigma) < 0) {
    stop("Determinant: ", det(Sigma))
  }
  ncols <- ncol(Sigma)
  mu <- rep(mu, each = n)
  mu + matrix(rnorm(n * ncols), ncol = ncols) %*% chol(Sigma)
}
##' @rdname rmvnorm
##' @param ... arguments passed to \code{rmvnorm}
##' @export
rlmvnorm <- function(n,...) exp(rmvnorm(n,...))

first_comma <- function(x,start=1) {
  open <- 0
  where <- NULL
  for(i in start:nchar(x)) {
    a <- substr(x,i,i)
    if(a=="(")  {
      open <- open+1
      next
    }
    if(a==")") {
      open <- open-1
      next
    }
    if(a=="," & open==0) return(i)
  }
  return(-1)
}

rm_space <- function(x) gsub(" ", "",x,fixed=TRUE)
peval <- function(x) eval(parse(text=x))

parse_form_3 <- function(x,envir) {

  x <- rm_space(x)

  til <- where_first("~",x)
  bar <- where_first("|",x)
  left <- substr(x,0,til-1)


  if(bar > 0) {
    right <- substr(x,til+1,bar-1)
    group <- substr(x,bar+1,nchar(x))
  } else {
    right <- substr(x,til+1,nchar(x))
    group <- ""
  }

  op <- where_first("(",right)
  dist <- substr(right,0,op-1)

  if(substr(dist,0,1)=="r") {
    if(names(formals(get(dist,envir)))[1]=="n") {
    right <- sub("(", "(.n,",right,fixed=TRUE)
    }
  }

  if(dist=="expr") {
    right <- as.character(right)
    right <- gsub("expr\\((.+)\\)$", "\\1", right)
  }

  right <- parse(text=right)
  left <- parse_left(left)
  c(left,list(call=right,by=group,dist=dist))
}

# @param data a data frame
# @param x a covobj
do_mutate <- function(data,x,envir=parent.frame(),tries=10,mult=1.5,...) {

  data <- ungroup(data)

  if(missing(envir)) {
    envir <- x$envir
  }

  if(call_type(x)==2) {
    .dots <- paste0("list(~",x$call,")")
    .dots <- eval(parse(text=.dots),envir=envir)
    names(.dots) <- x$vars
    if(x$by != "") {
      data <- group_by_(data,.dots=x$by)
    }
    data <- ungroup(mutate_(data, .dots=.dots))
    return(data)
  }

  if(tries <=0) stop("tries must be >= 1")

  x$by <- c(x$by,x$opts$by)
  x$by <- x$by[x$by != ""]

  has.by <- any(nchar(x$by) > 0)

  if(has.by) {
    skele <- dplyr::distinct_(data,.dots=x$by)
    n <- nrow(skele)
  } else {
    n <- nrow(data)
  }

  mn <- eval(x$lower,envir=envir)
  mx <- eval(x$upper,envir=envir)

  if(x$dist %in% c("rmvnorm", "rlmvnorm")) {
    r <- mvrnorm_bound(x$call,n=n,mn=mn,mx=mx,tries=tries,envir=envir)
  } else {
    r <- data_frame(.x=bound(x$call,n=n,mn=mn, mx=mx,tries=tries,envir=envir))
  }
  names(r) <- x$vars
  data <- data[,setdiff(names(data),names(r)),drop=FALSE]
  if(has.by) {
    r <- bind_cols(skele,r)
    return(left_join(data,r,by=x$by))
  } else {
    return(bind_cols(data,r))
  }
}

##' Create a set of covariates.
##' @param ... formulae to use for the covset
##' @param envir for formulae
##'
##' @examples
##' a <- Y ~ runif(0,1)
##' b <- Z ~ rbeta(1,1)
##'
##' set <- covset(a,b)
##'
##' set
##'
##' as.list(set)
##'
##' @export
covset <- function(...,envir=parent.frame()) {
  x <- list(...)
  x <- lapply(x,new_covobj,envir=envir)
  return(structure(x,class="covset"))
}

is.covset <- function(x) return(inherits(x,"covset"))

##' @export
##' @rdname covset
as.covset <- function(x) {
  if(!is.list(x)) stop("x needs to be a list")
  structure(x,class="covset")
}

apply_covset <- function(data,.covset,...) {
  for(i in seq_along(.covset)) {
    data <- do_mutate(data,.covset[[i]],...)
  }
  return(data)
}

get_covsets <- function(x) {
  if(is.environment(x)) {
    x <- as.list(x)
  }
  cl <- sapply(x,class)
  x[cl=="covset"]
}

Parse <- function(x) parse(text=x)

mvrnorm_bound <- function(call,n,envir=list(),mult=1.3,
                          mn=-Inf,mx=Inf,tries=10) {

  if(length(mn) < 2) {
    stop("At least 2 variables required from rmvnorm simulation.",call.=FALSE)
  }

  envir$.n <- ceiling(n*mult)

  if(all(mn==-Inf) & all(mx==Inf)) {
    envir$.n <- n
    return(as.data.frame(eval(call,envir=envir)))
  }

  out <- vector("list", tries)
  ngot <- 0
  for(i in seq(1,tries)) {
    var <- eval(call,envir=envir)
    w <- sapply(seq_along(mn), function(ii) {
      var[,ii] >= mn[ii] & var[,ii] <= mx[ii]
    })
    w <- apply(w,MARGIN=1,all)
    var <- var[w,,drop=FALSE]
    ngot <- ngot+nrow(var)
    out[[i]] <- var
    if(ngot >= n) {
      break
    }
  }

  if(ngot >= n) {
    out <- as.data.frame(do.call("rbind",out)[1:n,])
  } else {
    stop("Couldn't generate the required number of variates.")
  }
  return(out)
}



