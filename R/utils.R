
is.mt <- function(x) {return(is.null(x) | length(x)==0)}

mytrim <- function(x) {
  gsub("^\\s+|\\s+$", "",x,perl=TRUE)
}

mytriml <- function(x) {
  gsub("^\\s+", "",x,perl=TRUE)
}

mytrimr <- function(x) {
  gsub("\\s$", "",x,perl=TRUE)
}

cvec_cs <- function(x) {
  if(is.null(x) | length(x)==0) return(character(0))
  x <- unlist(strsplit(as.character(x),",",fixed=TRUE),use.names=FALSE)
  x <- unlist(strsplit(x," ",fixed=TRUE),use.names=FALSE)
  x <- x[x!=""]
  if(length(x)==0) {
    return(character(0))
  } else {
    return(x)
  }
}

## Create a character vector
## Split on comma and trim
cvec_c_tr <- function(x) {
  if(is.null(x) | length(x)==0) return(character(0))
  x <- unlist(strsplit(as.character(x),",",fixed=TRUE),use.names=FALSE)
  x <- gsub("^\\s+|\\s+$", "",x, perl=TRUE)
  x <- x[x!=""]
  if(length(x)==0) {
    return(character(0))
  } else {
    return(x)
  }
}

## Create a character vector
## Split on comma and rm whitespace
cvec_c_nws <- function(x) {
  if(is.null(x) | length(x)==0) return(character(0))
  x <- unlist(strsplit(as.character(x),",",fixed=TRUE),use.names=FALSE)
  x <- gsub(" ", "",x, fixed=TRUE)
  x <- x[x!=""]
  if(length(x)==0) {
    return(character(0))
  } else {
    return(x)
  }
}

as_character_args <- function(x) {
  x <- deparse(x,width.cutoff=500)
  x <- gsub("^.*\\(|\\)$", "", x)
  x
}


nonull <- function(x,...) UseMethod("nonull")
##' @export
nonull.default <- function(x,...) x[!is.null(x)]
##' @export
nonull.list <- function(x,...) x[!sapply(x,is.null)]

s_pick <- function(x,name) {
  stopifnot(is.list(x))
  nonull(unlist(sapply(x,"[[",name)))
}

ll_pick <- function(x,name) {
  stopifnot(is.list(x))
  lapply(x,"[[",name)
}

l_pick <- function(x,name) {
  stopifnot(is.list(x))
  lapply(x,"[",name)
}

charcount <- function(x,w,fx=TRUE) {
  nchar(x) - nchar(gsub(w,"",x,fixed=fx))
}

charthere <- function(x,w,fx=TRUE) {
  grepl(w,x,fixed=fx)
}

where_is <- function(what,x) {
  as.integer(unlist(gregexpr(what,x,fixed=TRUE)))
}

where_first <- function(what,x) {
  as.integer(unlist(regexpr(what,x,fixed=TRUE)))
}

mt <- function(.n=1) rep(0,.n)
