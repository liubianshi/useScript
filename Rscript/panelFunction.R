require("data.table")
#> 函数列表
#> fXTSet 将 `data.table` 数据设置为面板数据

fXTSet <- function(data, id, time) {
    #> 将 `data.table` 数据标记为面板数据
    #> data `data.table` 
    #> id   变量名, 用于指示个体
    #> time 变量名, 用于指示时间
    #> 将 `data.table` 的 `key` 设置为 `id` + `time`
    #> 增加一个属性 `Panel`, 设置成功后, 将该属性标记为 `TRUE`
    #> 增加参数的 robust
    if (!is.data.table(data))
        stop("data is not a data.table")
    id_name <- gsub("[\"']", "", deparse(substitute(id)))
    time_name <- gsub("[\"']", "", deparse(substitute(time)))
    if (! id_name %in% names(data)) id_name <- id
    if (! time_name %in% names(data)) time_name <- time
    #> 检验数据，时间变量必须是整数，且 id 和 time 必须能够唯一识别所有观测
    if (!is.integer(data[[time_name]]))
        stop("\nvariable time must integer")
    if (anyDuplicated(data[, c(id_name, time_name)]) != 0)
        stop("\nexist duplicates by `", id_name, "` and `", time_name, "`")
    #> 将数据转为 `data.table` 格式, 并且设置好属性
    setkeyv(data, cols = c(id_name, time_name))
    setattr(data, "Panel", TRUE)
    invisible(data)
}

fLag <- function(x, time, n = 1L) {
    #> 时间算子即基础函数
    #> x    操作向量
    #> time 时间变量
    #> n    时间间隔
    if (! is.integer(n) | n == 0)
        stop("n must be a non-zero interge")
    index <- match(time - n, time, incomparables = NA)
    x[index]
}



fXTLag <- function(panel.dt, varlist, n = 1L, new.dt = FALSE) {
    #> panel.dt `data.table`     标记为面版数据的 `data.table`
    #> varlist  character vector 待处理变量, 可以单个变量名裸字符串, 可以是带引号
    #>                           的字符串, 也可以是字符串向量
    #> n        滞后期, 必须为整数
    #> new.dt   是否生成新 `data.table`, 如果否, 则在原数据库上更新
    if (is.symbol(substitute(varlist)) & 
        as.character(substitute(varlist)) %in% names(panel.dt)) 
        varlist <- as.character(substitute(varlist))
    if (!is.integer(n) | n == 0)
        stop("n must be a non-zero interge")
    if (attr(panel.dt, "Panel") != TRUE || 
        length(key(panel.dt)) != 2 )
        stop("Must set data to panel data: `fXTSet`")
    if (! all(varlist %in% names(panel.dt)))
        stop("Some value in varlist isnot exist!")
    id <- key(panel.dt)[1]
    time <- key(panel.dt)[2]
    k.lag.varlist <- if (n > 0) {
        paste0("L", n, "_", varlist)
    } else {
        paste0("F", -n, "_", varlist)
    }
    if (new.dt == TRUE) {
        panel.dt <- panel.dt[, lapply(.SD[, -1], fLag, .SD[[time]], n),
                             by = c(id), .SDcols = c(time, varlist)][, -1]
        names(panel.dt) <- k.lag.varlist
    } else {
        panel.dt[, (k.lag.varlist) := lapply(.SD[, -1], fLag, .SD[[time]], n),
                 by = c(id), .SDcols = c(time, varlist)]
    }
    invisible(panel.dt)
}

