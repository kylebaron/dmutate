
is.mt <- function(x) {return(is.null(x) | length(x)==0)}


##' Merge two lists
##'
##' @param x the original list
##' @param y the new list for merging
##' @param wild wild-card name; see details
##' @param warn issue warning if nothing found to update
##' @param context description of usage context
##' @param ... not used
##' @param open logical indicating whether or not new items should be allowed in the list upon merging.
##' @rdname merge
##' @details
##' Wild-card names (\code{wild}) are always retained in \code{x} and are brought along from \code{y} only when \code{open}.
##' @export
merge.list <- function(x,y,...,open=FALSE,
                       warn=TRUE,context="object",wild="...") {

  y <- as.list(y)

  if(!open) {
    y <- y[names(y)!=wild | is.null(names(y))]
  }

  ## Merge two lists
  common <- intersect(names(x), names(y))
  common <- common[common != wild]

  x[common] <- y[common]

  if(open)  {
    nw <- !is.element(names(y),names(x)) | names(y) == wild
    x <- c(x,y[nw])
  } else {
    if(length(common)==0 & warn) {
      warning(paste0("Found nothing to update: ", context), call.=FALSE)
    }
  }
  x
}



cropstr <- function(string, prefix, suffix, bump= "...") {
  nc <- nchar(string)
  total <- prefix+suffix
  if(all(nc <= total)) return(string)
  paste0(substr(string,1,prefix) , bump, substr(string,(nc-suffix+nchar(bump)+1),nc))
}

mytrim <- function(x) {
  gsub("^\\s+|\\s+$", "",x,perl=TRUE)
}
mytriml <- function(x) {
  gsub("^\\s+", "",x,perl=TRUE)
}
mytrimr <- function(x) {
  gsub("\\s$", "",x,perl=TRUE)
}



## Create character vector
## Split on comma or space
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


## Old
as.cvec <- function(x) {
  if(is.null(x)) return(character(0))
  x <- gsub("^\\s+|\\s+$", "", x, perl=TRUE)
  unlist(strsplit(as.character(x),"\\s*(\n|,|\\s+)\\s*",perl=TRUE))
}

is.numeric.data.frame <- function(x) sapply(x, is.numeric)

tolist <- function(x,concat=TRUE,envir=list()) {
  if(is.null(x)) return(list())
  x <- gsub("(,|\\s)+$", "",x,perl=TRUE)
  x <- x[!(grepl("^\\s*$",x,perl=TRUE))]
  x <- x[x!=""]  ## waste?
  if(length(x)>1) x <- paste(x, collapse=',')
  return(eval(parse(text=paste0("list(", x, ")")),envir=envir))
}


tovec <- function(x,concat=TRUE) {
  if(is.null(x)) return(numeric(0))
  ##x <- gsub(eol.comment, "\\1", x)
  x <- gsub("(,|\\s)+$", "", x)
  if(concat) {
    x <- x[!(grepl("^\\s*$",x,perl=TRUE))]
    x <- x[x!=""] # waste?
    if(length(x)>1) x <- paste(x, collapse=',')
  }
  x <- type.convert(unlist(strsplit(x,split="\\,|\n|\\s+",perl=TRUE)), as.is=TRUE)
  x[nchar(x)>0]
}


##' Create create character vectors.
##'
##' @param x comma-separated quoted string (for \code{cvec})
##' @param ... unquoted strings (for \code{ch})
##' @export
##' @examples
##'
##' cvec("A,B,C")
##' ch(A,B,C)
##' s(A,B,C)
##'

##' @export
##' @rdname cvec
cvec <- function(...) as.cvec(...)

##' @export
##' @rdname cvec
ch <- function(...) as.character(match.call(expand.dots=TRUE))[-1]
##' @export
##' @rdname cvec
s <- ch

if.file.remove <- function(x) {
  if(file_exists(x)) file.remove(x)
}


as_character_args <- function(x) {
  x <- deparse(x)
  x <- gsub("^.*\\(|\\)$", "", x)
  x
}



grepn <- function(x,pat,warn=FALSE) {
  if(is.null(names(x))) {
    if(warn) warning("grepn: pattern was specified, but names are NULL.", call.=FALSE)
    return(x)
  }
  if(pat=="*") return(x)
  x[grepl(pat,names(x),perl=TRUE)]
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
s_quote <- function(x) paste0("\'",x,"\'")
d_quote <- function(x) paste0("\"",x,"\"")


mapvalues <- function (x, from, to, warn_missing = FALSE) {
  if (length(from) != length(to)) {
    stop("`from` and `to` vectors are not the same length.")
  }
  if (!is.atomic(x)) {
    stop("`x` must be an atomic vector.")
  }
  if (is.factor(x)) {
    levels(x) <- mapvalues(levels(x), from, to, warn_missing)
    return(x)
  }
  mapidx <- match(x, from)
  mapidxNA <- is.na(mapidx)
  from_found <- sort(unique(mapidx))
  if (warn_missing && length(from_found) != length(from)) {
    message("The following `from` values were not present in `x`: ",
            paste(from[!(1:length(from) %in% from_found)], collapse = ", "))
  }
  x[!mapidxNA] <- to[mapidx[!mapidxNA]]
  x
}


shuffle <- function (x, who, after = NA)  {
  names(x) <- make.unique(names(x))
  who <- names(x[, who, drop = FALSE])
  nms <- names(x)[!names(x) %in% who]
  if (is.null(after))
    after <- length(nms)
  if (is.na(after))
    after <- 0
  if (length(after) == 0)
    after <- length(nms)
  if (is.character(after))
    after <- match(after, nms, nomatch = 0)
  if (after < 0)
    after <- length(nms)
  if (after > length(nms))
    after <- length(nms)
  nms <- append(nms, who, after = after)
  x[nms]
}

filename <-  function (dir, run = NULL, ext = NULL,short=FALSE) {
  if(short) dir <- build_path(dir)
  file.path(dir, paste0(run, ext))
}

charcount <- function(x,w,fx=TRUE) {
  nchar(x) - nchar(gsub(w,"",x,fixed=fx))
}

charthere <- function(x,w,fx=TRUE) {
  grepl(w,x,fixed=fx)
}


null_list <- setNames(list(), character(0))
single.number <- function(x) length(x)==1 & is.numeric(x)


get_option <- function(what,opt,default=FALSE) {
  if(is.element(what,names(opt))) {
    opt[[what]]
  } else {
    return(default)
  }
}

# get_logical <- function(what,opt) {
#   if(is.element(what,names(opt))) {
#     return(opt[[what]])
#   } else {
#     return(FALSE)
#   }
# }

has_name <- function(a,b) {
  is.element(a,names(b))
}

file_exists <- function(x) {
  #file.access(x)==0
  file.exists(x)
}

file_writeable <- function(x) {
  file.access(x,2) == 0
}

file_readable <- function(x) {
  file.access(x,4) == 0
}


where_is <- function(what,x) {
  as.integer(unlist(gregexpr(what,x,fixed=TRUE)))
}
where_first <- function(what,x) {
  as.integer(unlist(regexpr(what,x,fixed=TRUE)))
}

