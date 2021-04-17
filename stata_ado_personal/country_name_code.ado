*! version 1.0.0  `date +%d%b%Y | tr '[A-Z]' '[a-z]'`
// 国家名称和编码的相互转化

program country_name_code
    version 14.0
    syntax varlist(min=1 max=1) [if] [in] [, New(name) ///
        Type(string) Sheet(string) Cellrange(string) ]

    // 处理类型
    if "`type'" == "" ///
        local type "ISO2 Zh"
    if ustrregexm("`type'", ///
        "^\s*(ISO2|ISO3|Num|En|Zh|COW)\s+(ISO2|ISO3|Num|En|Zh|COW)\s*$", 1) {
            local A = strupper(ustrregexs(1))
            local B = strupper(ustrregexs(2))
        }
    else {
        di as error _newline ///
            "转化类型设定错误，应该满足如下正则模式：" ///
            _newline ///
            "^\s*(ISO2|ISO3|Num|En|Zh|COW)\s+(ISO2|ISO3|Num|En|Zh|COW)\s*$"
        error
    }

    // 处理变量名
    local ori: word 1 of `varlist'
    if "`new'" == "" ///
        local new = "`ori'_`B'"
    confirm string  variable `ori'
    confirm new variable `new'

    // 表格名
    if "`sheet'" == "" local sheet = "国家编码"

    // Cellrange
    /* if "`cellrange'" == "" local cellrange = "A1" */
    if !ustrregexm("`cellrange'", ///
        "^([A-Z]+[1-9][0-9]*)*([A-Z]+[1-9][0-9]*)*$") {
            di as error _newline ///
                "Cellrange 设置错误，应该满足如下正则模式：" ///
                _newline ///
                "^([A-Z]+[1-9][0-9]*)*(:[A-Z]+[1-9][0-9]*)*$"
            error
        }

     // 条件设置
     if "`if' `in'" != "" quietly count `if' `in'

    // 导入数据
    preserve
        import excel using ///
            "$NutStore/Data/数据标准/编码及其转换/国家编码.xlsx", ///
            sheet("`sheet'") clear firstrow case(upper) allstring ///
            locale("zh_CN")
        if "`A'" == "COW" {
            // 处理南斯拉夫、塞尔维亚和黑山、塞尔维亚的国家编码问题
            // 南斯拉夫、塞尔维亚和黑山均已经不存在，而塞尔维亚是它的法定继承
            // 所以塞尔维亚继承 COW 编码，而黑山，包括其他南斯拉夫成员有其他 COW 编码
            drop if ECONOMY`A' == "345" & ECONOMYISO3 != "SRB"
        }
        keep ECONOMY`A' ECONOMY`B'
        di as input _newline "变量 ECONOMY`A' 的情况："
        codebook ECONOMY`A'
        drop if ECONOMY`A' == ""
        if inlist("`A'", "COW", "NUM") {
            replace ECONOMY`A' = ///
                cond( length(ECONOMY`A') == 1, "00" + ECONOMY`A',       ///
                    cond( length(ECONOMY`A') == 2, "0" + ECONOMY`A',    ///
                        ECONOMY`A' ) )
        }
        di as input _newline "变量 ECONOMY`B' 的情况："
        codebook ECONOMY`B'
        if inlist("`B'", "COW", "NUM") {
            replace ECONOMY`B' = ///
                cond( length(ECONOMY`B') == 1, "00" + ECONOMY`B',       ///
                    cond( length(ECONOMY`B') == 2, "0" + ECONOMY`B',    ///
                        ECONOMY`B' ) )
        }
        rename ECONOMY`A' `ori'
        rename ECONOMY`B' `new'
        di as input _newline "变量 ECONOMY`A' 重复的情况："
        duplicates tag `ori', gen(flag)
        list if flag > 0
        drop flag
        duplicates drop `ori', force
        tempfile __country_name_code
        save `__country_name_code'
    restore

    // 合并数据
    di as input _newline "变量 ECONOMY`B' 的匹配情况："
    merge m:1 `ori' using `__country_name_code', ///
        nogen keep(master match)
    if ustrregexm("`if' `in'", "^(if/in)") {
        replace `new' = "" `if' `in'
    }
end
