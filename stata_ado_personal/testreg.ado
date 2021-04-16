cap program drop testreg
program testreg, nclass
    version 14
    *! use reghdfe for test regression analysis
    * parse syntax {{{1
    gettoken field 0 : 0, parse(", ")
    syntax varlist(min=1 fv) [using] [if] [in], Test(varlist min=2 fv) ///
        [fe(varlist) Accumulate replace noconstant vce(passthru) Other(string)]
    if !inlist("`field'", "dep", "core", "control", "fe", "sample") {
        display as error "subcommand must be dep, core, control, fe or sample"
        error 197
    }
    if `"`using'"' == "" {
        local file_ext "txt"
        if `"$TEMPDIR"' == "" {
            local using = "using " + "/tmp/Stata_temp_output.`file_ext'"
        }
        else {
            local using = "using " + `"$TEMPDIR"' + "/Stata_temp_output.`file_ext'"
        }
    }
    preserve // handle regression {{{1
        * initialize {{{2
        marksample basesample
        local sample "`basesample'"
        if "`field'" != "dep" {
            gettoken dep varlist : varlist
        }
        local indep "`varlist'"
        local absorb = "`fe'"
        * control export format {{{2
        tempname R
        if "`field'" == "fe" {
            local fixedeffects = ""
            foreach femacro of local test {
                local fixedeffects = "`fixedeffects' FE_`=ustrregexra("`femacro'", "[^\w]", "_")'"
            }
        }
        if inlist("`field'", "dep", "fe") {
            local varlist_order = "`varlist'"
        }
        else {
            local varlist_order = "`test' `varlist'"
        }
        if "`fe'" != "" {
            local add_notes: subinstr local fe " " ", ", all
            local add_notes `"addnotes("All model absorbed `add_notes'.")"'
        }
        * loop test variables {{{2
        foreach t of local test {
            * construct dependent variable {{{3
            if "`field'" == "dep" {
                local dep = "`t'"
            }
            * construct independent variables {{{3
            if inlist("`field'", "core", "control") {
                if "`accumulate'" == "" {
                    local indep = "`t' `varlist'"
                }
                else {
                    local indep = "`t' `indep'"
                }
            }
            * construct absorb factor variables {{{3
            if "`field'" == "fe" {
                if "`accumulate'" == "" {
                    local absorb = "`t' `fe'"
                }
                else {
                    local absorb = "`t' `absorb'"
                }
            }
            if "`absorb'" == "" {
                local absorb_option = "noabsorb"
            }
            else {
                local absorb_option = "absorb(`absorb')"
            }
            * construct sample index {{{3
            if "`filed'" == "sample" {
                tempvar sample
                gen `sample' == `basesample' & `t'
            }
            * run regress {{{3
            eststo, prefix("`R'") noesample: ///
                reghdfe `dep' `indep' if `sample', ///
                    `absorb_option' `noconstant' `vce' `other'
            * add extra macro {{{3
            if "`field'" == "fe" {
                local absvars = e(extended_absvars)
                foreach femacro of local test {
                    local femacro_value = "N"
                    foreach absvar of local absvars {
                        if `"`=ustrregexra("`femacro'", "i\.", "")'"' == "`absvar'" {
                            local femacro_value = "Y"
                        }
                    }
                    estadd local FE_`=ustrregexra("`femacro'", "[^\w]", "_")' = "`femacro_value'"
                }
            }
        }
        * export result {{{2
        if "`fixedeffects'" != "" {
            local scalars = "scalars(`fixedeffects')"
        }
        esttab `R'* `using', `replace' `scalars' `add_notes' ///
            b(3) ar2 depvars nogap order(`varlist_order')
        * open result {{{2
        if "`c(os)'" == "Unix" {
            local shellout "xdg-open"
        }
        else if "`c(os)'" == "MacOSX" {
            local shellout "open"
        }
        else if "`c(os)'" == "MacOSX" {
            local shellout "start"
        }
        local tempfile `=ustrregexrf(`"`using'"', "^using ", "")'
        winexec `shellout' `tempfile'
    restore // }}}1
end

/* test


 */
webuse nlswork, clear

winexec st -e nvim +RainbowAlign /tmp/stata_preview.csv

set trace on
set tracedepth 1
testreg fe ln_w grade age ttl_exp tenure not_smsa south ///
    using /tmp/test.html, ///
    t(idcode year occ idcode#occ) replace


reghdfe ln_w grade age ttl_exp tenure not_smsa south , absorb(idcode year)
reghdfe ln_w grade age ttl_exp tenure not_smsa south , absorb(idcode year occ)
reghdfe ln_w grade age ttl_exp tenure not_smsa south , absorb(FE1=idcode FE2=year)
reghdfe ln_w grade age ttl_exp tenure not_smsa , absorb(idcode occ) groupv(mobility_occ)
reghdfe ln_w i.grade#i.age ttl_exp tenure not_smsa , absorb(idcode occ)

reghdfe ln_w grade age ttl_exp tenure not_smsa , absorb(idcode#occ)
ereturn list

help reghdfe
in 1/10


local t "FE_i.idcode#i.occ_code"
di "`=ustrregexra("`t'", "[^\w]", "_")'"

help regexinstr


