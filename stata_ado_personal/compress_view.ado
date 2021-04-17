*! version 1.0.0 
// 将变量中的全角字符转换成半角字符

program compress_view
    version 14 
    quietly des, varlist
    local varL = r(varlist)
    foreach v of local varL {
        local vf: format `v'
        format `v' `=ustrregexrf("`vf'", "^%-?", "%-")'
        if ustrregexm("`vf'", "^%-?([1-9][0-9]+|[3-9])[0-9]s$") {
            format `v' %-30s
        }
        if ustrregexm("`vf'", "^%-?([1-9][0-9]+|[2-9])[0-9].[0-9][gf]$") {
            format `v' %-20.`=substr("`vf'", -2, 1)'`=substr("`vf'", -1, 1)'
        }
    }
end
