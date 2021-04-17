*! version 1.0.0  20170622
// 从变量中挑选出APEC经济体，并命名和编码
program apec_filter
    version 14
    syntax varname(string) [, cn iso(namelist min=1) date]
    if "`iso'" != "" & !ustrregexm("`iso'", "\ba3\b|\ba2\b|\bnum\b") {
        di "ISO 设定错误"
        error
    }
    local varname "`varlist'"
    gen _apecEn = ""
    replace _apecEn = "Australia" if ustrregexm(`varname', "Australia", 1)
    replace _apecEn = "Brunei" if ustrregexm(`varname', "Brunei", 1)
    replace _apecEn = "Canada" if ustrregexm(`varname', "Canada", 1)
    replace _apecEn = "Chile" if ustrregexm(`varname', "Chile", 1)
    replace _apecEn = "China" if ustrregexm(`varname', "China", 1) ///
        & !ustrregexm(`varname', "Hong\s*Kong", 1) ///
        & !ustrregexm(`varname', "Tai(wan|Bei)", 1) ///
        & !ustrregexm(`varname', "Ma\s*Cao", 1)
    replace _apecEn = "Hong Kong, China" if ///
        ustrregexm(`varname', "Hong\s*Kong", 1)
    replace _apecEn = "Indonesia" if ustrregexm(`varname', "Indonesia", 1)
    replace _apecEn = "Japan" if ustrregexm(`varname', "Japan", 1)
    replace _apecEn = "Korea" if ustrregexm(`varname', "Korea", 1) ///
       & !ustrregexm(`varname', "Dem", 1)
    replace _apecEn = "Malaysia" if ustrregexm(`varname', "Malaysia", 1)
    replace _apecEn = "Mexico" if ustrregexm(`varname', "Mexico", 1)
    replace _apecEn = "New Zealand" if ///
        ustrregexm(`varname', "New\s*Zealand", 1)
    replace _apecEn = "Papua New Guinea" if ///
        ustrregexm(`varname', "Papua\s*New\s*Guinea", 1)
    replace _apecEn = "Peru" if ustrregexm(`varname', "Peru", 1)
    replace _apecEn = "Philippines" if ///
        ustrregexm(`varname', "Philippines", 1)
    replace _apecEn = "Russian" if ustrregexm(`varname', "Russia", 1)
    replace _apecEn = "Singapore" if ustrregexm(`varname', "Singapore", 1)
    replace _apecEn = "Taipei, China" if ///
        ustrregexm(`varname', "Tai(wan|Pei)", 1)
    replace _apecEn = "Thailand" if ustrregexm(`varname', "Thailand", 1)
    replace _apecEn = "United States" if ///
        ustrregexm(`varname', "United\s*States|USA", 1) ///
        & !ustrregexm(`varname', "Minor", 1)

    replace _apecEn = "Viet Nam" if ustrregexm(`varname', "Viet\s*Nam", 1)

    if "`cn'" != "" {
        gen _apecCN = ""
        replace _apecCN = "澳大利亚" if _apecEn == "Australia"
        replace _apecCN = "文莱" if _apecEn == "Brunei"
        replace _apecCN = "加拿大" if _apecEn == "Canada"
        replace _apecCN = "智利" if _apecEn == "Chile"
        replace _apecCN = "中国内地" if _apecEn == "China"
        replace _apecCN = "中国香港" if _apecEn == "Hong Kong, China"
        replace _apecCN = "印度尼西亚" if _apecEn == "Indonesia"
        replace _apecCN = "日本" if _apecEn == "Japan"
        replace _apecCN = "韩国" if _apecEn == "Korea"
        replace _apecCN = "马来西亚" if _apecEn == "Malaysia"
        replace _apecCN = "墨西哥" if _apecEn == "Mexico"
        replace _apecCN = "新西兰" if _apecEn == "New Zealand"
        replace _apecCN = "巴布亚新几内亚" if _apecEn == "Papua New Guinea"
        replace _apecCN = "秘鲁" if _apecEn == "Peru"
        replace _apecCN = "菲律宾" if _apecEn == "Philippines"
        replace _apecCN = "俄罗斯" if _apecEn == "Russian"
        replace _apecCN = "新加坡" if _apecEn == "Singapore"
        replace _apecCN = "中国台湾" if _apecEn == "Taipei, China"
        replace _apecCN = "泰国" if _apecEn == "Thailand"
        replace _apecCN = "美国" if _apecEn == "United States"
        replace _apecCN = "越南" if _apecEn == "Viet Nam"
    }
    if ustrregexm("`iso'", "\ba3\b" ) {
        gen _apecISOa3 = ""
        replace _apecISOa3 = "AUS" if _apecEn == "Australia"
        replace _apecISOa3 = "BRN" if _apecEn == "Brunei"
        replace _apecISOa3 = "CAN" if _apecEn == "Canada"
        replace _apecISOa3 = "CHL" if _apecEn == "Chile"
        replace _apecISOa3 = "CHN" if _apecEn == "China"
        replace _apecISOa3 = "HKG" if _apecEn == "Hong Kong, China"
        replace _apecISOa3 = "IDN" if _apecEn == "Indonesia"
        replace _apecISOa3 = "JPN" if _apecEn == "Japan"
        replace _apecISOa3 = "KOR" if _apecEn == "Korea"
        replace _apecISOa3 = "MYS" if _apecEn == "Malaysia"
        replace _apecISOa3 = "MEX" if _apecEn == "Mexico"
        replace _apecISOa3 = "NZL" if _apecEn == "New Zealand"
        replace _apecISOa3 = "PNG" if _apecEn == "Papua New Guinea"
        replace _apecISOa3 = "PER" if _apecEn == "Peru"
        replace _apecISOa3 = "PHL" if _apecEn == "Philippines"
        replace _apecISOa3 = "RUS" if _apecEn == "Russian"
        replace _apecISOa3 = "SGP" if _apecEn == "Singapore"
        replace _apecISOa3 = "TWN" if _apecEn == "Taipei, China"
        replace _apecISOa3 = "THA" if _apecEn == "Thailand"
        replace _apecISOa3 = "USA" if _apecEn == "United States"
        replace _apecISOa3 = "VNM" if _apecEn == "Viet Nam"
    }
    if ustrregexm("`iso'", "\ba2\b" ) {
        gen _apecISOa2 = ""
        replace _apecISOa2 = "AU" if _apecEn == "Australia"
        replace _apecISOa2 = "BN" if _apecEn == "Brunei"
        replace _apecISOa2 = "CA" if _apecEn == "Canada"
        replace _apecISOa2 = "CL" if _apecEn == "Chile"
        replace _apecISOa2 = "CN" if _apecEn == "China"
        replace _apecISOa2 = "HK" if _apecEn == "Hong Kong, China"
        replace _apecISOa2 = "ID" if _apecEn == "Indonesia"
        replace _apecISOa2 = "JP" if _apecEn == "Japan"
        replace _apecISOa2 = "KR" if _apecEn == "Korea"
        replace _apecISOa2 = "MY" if _apecEn == "Malaysia"
        replace _apecISOa2 = "MX" if _apecEn == "Mexico"
        replace _apecISOa2 = "NZ" if _apecEn == "New Zealand"
        replace _apecISOa2 = "PG" if _apecEn == "Papua New Guinea"
        replace _apecISOa2 = "PE" if _apecEn == "Peru"
        replace _apecISOa2 = "PH" if _apecEn == "Philippines"
        replace _apecISOa2 = "RU" if _apecEn == "Russian"
        replace _apecISOa2 = "SG" if _apecEn == "Singapore"
        replace _apecISOa2 = "TW" if _apecEn == "Taipei, China"
        replace _apecISOa2 = "TH" if _apecEn == "Thailand"
        replace _apecISOa2 = "US" if _apecEn == "United States"
        replace _apecISOa2 = "VN" if _apecEn == "Viet Nam"
    }
    if ustrregexm("`iso'", "\bnum\b" ) {
        gen _apecISOnum = ""
        replace _apecISOnum = "036" if _apecEn == "Australia"
        replace _apecISOnum = "096" if _apecEn == "Brunei"
        replace _apecISOnum = "124" if _apecEn == "Canada"
        replace _apecISOnum = "152" if _apecEn == "Chile"
        replace _apecISOnum = "156" if _apecEn == "China"
        replace _apecISOnum = "344" if _apecEn == "Hong Kong, China"
        replace _apecISOnum = "360" if _apecEn == "Indonesia"
        replace _apecISOnum = "392" if _apecEn == "Japan"
        replace _apecISOnum = "410" if _apecEn == "Korea"
        replace _apecISOnum = "458" if _apecEn == "Malaysia"
        replace _apecISOnum = "484" if _apecEn == "Mexico"
        replace _apecISOnum = "554" if _apecEn == "New Zealand"
        replace _apecISOnum = "598" if _apecEn == "Papua New Guinea"
        replace _apecISOnum = "604" if _apecEn == "Peru"
        replace _apecISOnum = "608" if _apecEn == "Philippines"
        replace _apecISOnum = "643" if _apecEn == "Russian"
        replace _apecISOnum = "702" if _apecEn == "Singapore"
        replace _apecISOnum = "158" if _apecEn == "Taipei, China"
        replace _apecISOnum = "764" if _apecEn == "Thailand"
        replace _apecISOnum = "840" if _apecEn == "United States"
        replace _apecISOnum = "704" if _apecEn == "Viet Nam"
    }

    if "`date'" != "" {
        gen _apecDate = ""
        replace _apecDate = "6-7 Nov 1989" if _apecEn == "Australia"
        replace _apecDate = "6-7 Nov 1989" if _apecEn == "Brunei"
        replace _apecDate = "6-7 Nov 1989" if _apecEn == "Canada"
        replace _apecDate = "11-12 Nov 1994" if _apecEn == "Chile"
        replace _apecDate = "12-14 Nov 1991" if _apecEn == "China"
        replace _apecDate = "12-14 Nov 1991" if _apecEn == "Hong Kong, China"
        replace _apecDate = "6-7 Nov 1989" if _apecEn == "Indonesia"
        replace _apecDate = "6-7 Nov 1989" if _apecEn == "Japan"
        replace _apecDate = "6-7 Nov 1989" if _apecEn == "Korea"
        replace _apecDate = "6-7 Nov 1989" if _apecEn == "Malaysia"
        replace _apecDate = "17-19 Nov 1993" if _apecEn == "Mexico"
        replace _apecDate = "6-7 Nov 1989" if _apecEn == "New Zealand"
        replace _apecDate = "17-19 Nov 1993" if _apecEn == "Papua New Guinea"
        replace _apecDate = "14-15 Nov 1998" if _apecEn == "Peru"
        replace _apecDate = "6-7 Nov 1989" if _apecEn == "Philippines"
        replace _apecDate = "14-15 Nov 1998" if _apecEn == "Russian"
        replace _apecDate = "6-7 Nov 1989" if _apecEn == "Singapore"
        replace _apecDate = "12-14 Nov 1991" if _apecEn == "Taipei, China"
        replace _apecDate = "6-7 Nov 1989" if _apecEn == "Thailand"
        replace _apecDate = "6-7 Nov 1989" if _apecEn == "United States"
        replace _apecDate = "14-15 Nov 1998" if _apecEn == "Viet Nam"
    }
end
