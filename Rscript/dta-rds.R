require("haven")
fTrans.dtaRds <- function(path, name = NULL) {
    if (is.null(name)) {
        name <- sub("\\.dta$", ".Rds", basename(path)) 
    }
    dir <- dirname(path)
    saveRDS(haven::read_dta(path), file = paste(dir, name, sep = "/"))
}


