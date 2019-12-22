library("tidyverse")
require("data.table")
fLabel <- function(df, variables, attri.list, attri = "label") {
    # Set attributes for variables in data.frame
    # df: data.table 
    # variable: one bare variabel name or character vector of variable names
    # attri.list: numeric or character vector, length must equal variables
    nn <- deparse(substitute(variables)) 
    if (!is.data.table(df)) 
       stop("df must be a data.table") 
    if (nn %in% names(df)) {
        variables <- nn
    } 
    if (length(variables) != length(attri.list))
        stop("'variables' number must equal 'attri.list' number")
    if (any(! variables %in% names(df)))
        stop("some variable not exist") 
    if (length(attri) != 1 || !is.character(attri)) 
        stop("attributes must be one string")
    for (i in seq_along(variables)) {
        variable <- variables[i]
        label    <- attri.list[i]
        setattr(df[[variable]], attri, label)
    }
}

#> stata style describe 
fPrint <- function(z, digits = getOption("digits"), nsmall = 3,
                   width = 7, big.mark = ",", na.replace = "n.a.") {
        if (is.na(z)) 
            return(na.replace)
        t <- abs(z)
        if (t == 0) {
            x <- format(z, digits = 0, 
                        nsmall = nsmall, width = width, scientific = FALSE)
        } else if (t < 1) {
            x <- format(z, digits = max(0, digits - as.integer(log10(1/t))), 
                        nsmall = nsmall, width = width, scientific = FALSE)
        } else if (t < 10) {
            x <- format(z, digits = digits, nsmall = nsmall,
                        width = width, scientific = FALSE)
        } else if (log10(t) < digits + 1) {
            x <- format(z, digits = digits - as.integer(log10(t)),
                        nsmall = max(0, nsmall - as.integer(log10(t))),
                        width = width, scientific = FALSE, big.mark = big.mark)
        } else {
            x <- format(z, digits = 0, scientific = FALSE, big.mark = big.mark)
        }
        x
}

fDes.default <- function(x, na.rm = TRUE, format = TRUE,
                 digits = getOption("digits"),
                 nsmall = 3L, width = 7L, big.mark = ",") {
    y <- vector("numeric", 8)
    if (na.rm == TRUE) x <- x[!is.na(x)]
    y[1] <- length(x)
    y[2] <- mean(x)
    y[3] <- sd(x)
    y[4] <- min(x)
    y[5] <- quantile(x, 0.250)
    y[6] <- quantile(x, 0.500)
    y[7] <- quantile(x, 0.750)
    y[8] <- max(x)
    z <- vector("character", 8)
    if (format == TRUE) {
        z <- y %>% map_chr(fPrint, digits, nsmall, width, big.mark)
    }
    names(z) <- c("obs", "mean", "sd", "min", "p25", "p50", "p75", "max")
    z
}

fDes.data.frame <- function(df, variable, label = NULL, na.rm = TRUE, 
                            format = TRUE, digits = getOption("digits"),
                            nsmall = 3, width = 7, big.mark = ",") {
    nn <- deparse(substitute(variable)) 
    if (!is.data.frame(df)) 
       stop("df must be a data.frame") 
    if (nn %in% names(df)) {
        variable <- nn
    } else if (!grepl("[\"']", nn) & !exists(nn, mode = "character")) {
        stop(nn, " is not a character object") 
    }
    if (any(! variable %in% names(df)))
        stop("some variable not exist") 
    if (!is.null(label) && label != TRUE) {
        if (length(variable) != length(label))
            stop("'label' must NULL or having same length with variables")
    } else if (!is.null(label) && label == TRUE) {
        label <- map_chr(variable, ~ {
                             temp <- attr(df[[.]], "label") 
                             if (is.null(temp)) temp <- "d"
                             temp
                        })
    } 
    f.temp <- function(x) {
        fDes.default(df[[x]], na.rm, format, digits, nsmall, width, big.mark)
    }
    m.temp <- sapply(variable, f.temp)
    df.new <- t(m.temp)
    df.new <- as.data.frame(df.new, row.names = "")
    df.new <- if (!is.null(label)) {
        cbind(variable = format(label, justify = "left", width = 7), df.new)
    } else {
        cbind(variable = format(variable, justify = "left", width = 7), df.new)
    }
    df.new
}

fDes <- function(object, ...) {
    UseMethod("fDes")
}

# 回归公式生成函数
fFormula <- function(dep, indep_ex, fe = NULL, cluster = NULL,
                     indep_in = NULL, iv = NULL, method = "felm") {
    #> dep: dependent variable, require
    #> indep_ex: exogeneous independent variables, require 
    #> fe: fixed effect, optional
    #> cluster: cluster varaible, optional
    #> indep_in: endogenous independent variables, optional
    #> iv: Instrumental variables, must longer than `indep_in`
    #> method: Formula usage scenario, default is felm
    if (!is.null(indep_in) && length(iv) < length(indep_in))
        stop("IV number less then Endogenous")
    if (method == "felm") {
        k.dep_indep <- paste(dep, "~", paste0(indep_ex, collapse = " + "))
        k.fe <- if (is.null(fe)) {
            "0"
        } else {
            paste0(fe, collapse = " + ")
        }
        k.cluster <- if (is.null(cluster)) {
            "0"
        } else {
            paste0(cluster, collapse = " + ")
        }
        k.indep_in <- if (is.null(indep_in)) {
            "0"
        } else {
            if (length(indep_in) == 1) {
                paste0("\\(", indep_in, " ~ ",
                       paste0(iv, collapse = " + "), "\\)")
            } else {
                paste0("(", paste0(indep_in, collapse = "|"), " ~ ",
                       paste0(iv, collapse = " + "), ")")
            }
        }
        as.formula(paste0(c(k.dep_indep, k.fe, k.indep_in, k.cluster),
                          collapse = " | ")) 
    }
}

# 基于对象名清除对象
fDrop <- function(pattern, regex = FALSE) {
    d.env <- as.environment(-1)
    if (!regex) pattern = glob2rx(pattern)
    rm(list = ls(pattern = pattern, envir = d.env), envir = d.env)
}

