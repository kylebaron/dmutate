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
dmutate <- function(data,form,tries=10) {

  if(is.language(form)) form <- deparse(form)

  form <- parse_form(form)

  if(form$right$has.cond) {
    skele <- data %>% dplyr::distinct_(.dots=form$right$cond)
    n <- nrow(skele)

  } else {
    n <- nrow(data)
  }


  mn <- eval(parse(text=form$left$lower))
  mx <- eval(parse(text=form$left$upper))
  y <- bound(form$right$call,n=n,mn=mn,mx=mx,tries=tries)
  r <- data_frame(y=y)
  names(r) <- form$left$vars

  if(form$right$has.cond) {
    r <- bind_cols(skele,r)
    return(left_join(data,r,by=form$right$cond))
  } else {
    return(bind_cols(data,r))
  }
}


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

parse_form <- function(x) {
  x <- gsub(" ", "",x,fixed=TRUE)
  # Split formula on tilde
  til <- strsplit(x=x,"~")[[1]]
  left <- til[1]
  right <- til[2]
  list(left=parse_left(left),right=parse_right(right))
}


bound <- function(texpr,n,e=.GlobalEnv,mult=1.2,mn=-Inf,mx=Inf,tries=10) {
  expr <- parse(text=texpr)
  n0 <- n
  n <- n*mult
  ngot <- 0
  y <- numeric(0)
  e$internal <- list(N=n)
  for(i in seq(1,tries)) {
    yy <- eval(expr,envir=e)
    yy <- yy[yy > mn & yy < mx]
    ngot <- ngot + length(yy)
    y <- c(yy,y)
    if(ngot > n0) break
  }
  return(y[1:n0])
}

Bin <- function(...) rbinom(size=1,...)

