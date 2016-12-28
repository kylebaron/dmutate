##'
##'
##' @importFrom dplyr left_join
##' @importFrom MASS mvrnorm
##'
NULL



##' Add random variates to your data frame.
##'
##' @param data the data.frame to mutate
##' @param x an unquoted R formula; see details.
##'
##' @export
##'
##'
##' @examples
##'
##'
##' data(Theoph)
##'
##' Theoph %>% dmutate(SEX~binom(0.3|ID)) %>% head
##' mu <- c(1,30)
##' Sigma <- diag(c(1,1))
##'
##' Theoph %>% dmutate(CL+VC ~ MvLN(mu,Sigma|ID)) %>% head
##'
##'
dmutate <- function(data,form,...) {
  if(is.language(form)) form <- deparse(form)
  object <- parse_form(form)
  do_mutate(data,object,...)
}

##' @export
dmutate_ <- function(data,string,envir=.GlobalEnv,...) {
  form <- parse_random_string(string)
  args <- paste0("list(",form$args,")")
  args <- eval(parse(text=args),envir=envir)
  args <- c(args,list(...),list(data=data,object=form,envir=envir))
  do.call(do_mutate,args)
}

##' @export
do_mutate <- function(data,object,tries=10,envir=.GlobalEnv,...) {
  args <- list(...)

  args$by <- unique(c(args$by,object$by.bar))

  has.cond <- is.character(args$by)

  if(has.cond) {
    skele <- data %>% dplyr::distinct_(.dots=args$by)
    n <- nrow(skele)

  } else {
    n <- nrow(data)
  }

  mn <- eval(parse(text=object$lower))
  mx <- eval(parse(text=object$upper))
  y <- bound(object$dist,n=n,mn=mn,mx=mx,tries=tries,args=args)
  r <- data_frame(y=y)

  names(r) <- object$vars
  data <- data %>% select_(.dots=setdiff(names(data),names(r)))

  if(has.cond) {
    r <- bind_cols(skele,r)
    return(left_join(data,r,by=args$by))
  } else {
    return(bind_cols(data,r))
  }

}



# dmutate <- function(data,form,tries=10) {
#
#   if(is.language(form)) form <- deparse(form)
#
#   form <- parse_form(form)
#
#   if(form$right$has.cond) {
#     skele <- data %>% dplyr::distinct_(.dots=form$right$cond)
#     n <- nrow(skele)
#
#   } else {
#     n <- nrow(data)
#   }
#
#
#   mn <- eval(parse(text=form$left$lower))
#   mx <- eval(parse(text=form$left$upper))
#   y <- bound(form$right$call,n=n,mn=mn,mx=mx,tries=tries)
#   r <- data_frame(y=y)
#   names(r) <- form$left$vars
#
#   if(form$right$has.cond) {
#     r <- bind_cols(skele,r)
#     return(left_join(data,r,by=form$right$cond))
#   } else {
#     return(bind_cols(data,r))
#   }
# }


parse_right <- function(x) {
  bar <- where_is("|",x)
  op <- where_is("(",x)
  cl <- where_is(")",x)
  if(sum(op>0) != sum(cl>0)) {
    stop("Unmatched parens: ", x)
  }

  lclose <- cl[length(cl)]

  cond <- ""
  if(bar[1] > 0) {
    cond <- substr(x, bar[1], cl[length(cl)])
    x <- sub(cond,"",x,fixed=TRUE)
    x <- paste0(x,")")
  }
  x <- sub("(", "(internal$N,",x,fixed=TRUE)
  cond <- sub("|", "", cond, fixed=TRUE)
  cond <- sub(")", "", cond, fixed=TRUE)
  dist <- substr(x,0,op[1]-1)
  list(cond = cond, call=x,dist=dist,has.cond = nchar(cond) > 0)
}


parse_left_var <- function(x) {
  m <- regexec("(\\w+)(\\[(\\w+)?\\,(\\w+)?\\])?", x)
  m <- unlist(regmatches(x,m))
  var <- m[2]
  bounds <- m[3]
  lower <- m[4]
  upper <- m[5]
  if(lower=="") lower <- -Inf
  if(upper=="") upper <- Inf
  return(list(var=var,bounds=bounds,lower=lower,upper=upper))
}

parse_left <- function(x) {
  x <- unlist(strsplit(x,"+",fixed=TRUE))
  x <- lapply(x,parse_left_var)
  vars <- s_pick(x,"var")
  bounds <- s_pick(x,"bounds")
  lower <- s_pick(x,"lower")
  upper <- s_pick(x,"upper")
  list(vars=vars,lower=lower,upper=upper,n=length(vars))
}

# parse_form <- function(x) {
#   x <- gsub(" ", "",x,fixed=TRUE)
#   # Split formula on tilde
#   til <- strsplit(x=x,"~")[[1]]
#   left <- til[1]
#   right <- til[2]
#   list(left=parse_left(left),right=parse_right(right))
# }


# bound <- function(texpr,n,e=.GlobalEnv,mult=1.2,mn=-Inf,mx=Inf,tries=10) {
#   expr <- parse(text=texpr)
#   n0 <- n
#   n <- n*mult
#   ngot <- 0
#   y <- numeric(0)
#   e$internal <- list(N=n)
#   for(i in seq(1,tries)) {
#     yy <- eval(expr,envir=e)
#     yy <- yy[yy > mn & yy < mx]
#     ngot <- ngot + length(yy)
#     y <- c(yy,y)
#     if(ngot > n0) break
#   }
#   return(y[1:n0])
# }

##' @export
bound <- function(fun,n,args,e=.GlobalEnv,mult=1.2,mn=-Inf,mx=Inf,tries=10) {

  n0 <- n
  n <- n*mult
  ngot <- 0
  y <- numeric(0)
  args$n <- n
  mn <- eval(parse(text=mn),envir=e)
  mx <- eval(parse(text=mx),envir=e)
  for(i in seq(1,tries)) {
    yy <- do.call(fun,args)
    yy <- yy[yy > mn & yy < mx]
    ngot <- ngot + length(yy)
    y <- c(yy,y)
    if(ngot > n0) break
  }
  return(y[1:n0])
}

binomial <- function(n,p,...) {
  rbinom(n,1,p)
}
Bin <- function(...) binomial
bernoulli <- binomial
normal <- function(n,mean,sd,...) {
  rnorm(n,mean,sd)
}
gamma <- function(n,shape,rate,...) {
  rgamma(n,shape,rate)
}
beta <- function(n,shape1,shape2,ncp=0,...) {
  rbeta(n,shape1,shape2,ncp)
}
uniform <- function(n,min,max,...) {
  runif(n,min,max)
}
lognormal <- function(n,mean,sd,...) {
  exp(rnorm(n,mean,sd))
}


parse_form <- function(x) {
  x <- gsub(" ", "",x, fixed=TRUE)
  form <- strsplit(x,"~",fixed=TRUE)[[1]]
  var <- parse_left(form[1])

  bar <- where_first("|",form[2])

  if(bar > 0) {
    form <- strsplit(form[2], "|", fixed=TRUE)[[1]]
    dist <- form[1]
    by <- form[2]
    by <- unlist(strsplit(by, "[*+]+"),use.names=FALSE)
  } else {
    dist <- form[2]
    by <- character(0)
  }
  c(list(dist=dist,by.bar = by),var)
}

parse_random_string <- function(x) {
  x <- gsub(" ", "", x, fixed=TRUE)
  w <- where_is(',',x)
  til <- where_is("~",x)[1]
  w <- w[w > til]
  form <- substr(x,0,w[1]-1)
  args <- substr(x,w[1]+1,nchar(x))
  c(list(args=args),parse_form(form))
}

parse_random_block <- function(x) {
  x <- unlist(strsplit(x, "\n",x,fixed=TRUE),use.names=FALSE)
  x <- x[x!=""]
  x <- lapply(x,dmutate:::parse_random_string)
  x
}



