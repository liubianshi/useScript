program sample_panel, rclass
    syntax, Ratio(real) Panel(string) Time(string)
    local i "`panel'"
    local t "`time'"
    local r = `ratio'
    confirm variable `i' `t'
    if `r' > 1 | `r' < 0 break
    snapshot save, label(sample)
    local sample_snap = r(snapshot)

    keep `i'
    duplicates drop
    tempname index
    gen `index' = runiform() <= `r'
    drop if `index' == 0
    drop `index'
    tempfile sample
    save `sample', replace

    snapshot restore `sample_snap'
    merge m:1 `i' using `sample', nogen keep(match)
    return scalar sample_snap = `sample_snap'
end
