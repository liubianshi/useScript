cap program drop testreg
program testreg, nclass
    version 14
    *! use reghdfe for test regression analysis
    * parse syntax {{{1
    gettoken field 0 : 0, parse(", ")
    syntax varlist(min=1 fv) [using/] [if] [in], Test(varlist min=1 fv ts) ///
        [fe(varlist) Accumulate noCONstant vce(passthru) b(integer 3) noAR2 GAP noDEPvars * ]
    if !inlist("`field'", "dep", "core", "control", "fe", "sample") {
        display as error "subcommand must be dep, core, control, fe or sample"
        error 197
    }
    if `"`using'"' == "" {
        local file_ext "txt"
        if `"$TEMPDIR"' == "" {
            local using = "/tmp/Stata_temp_output.`file_ext'"
        }
        else {
            local using = `"$TEMPDIR"' + "/Stata_temp_output.`file_ext'"
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
        if inlist("`field'", "dep", "fe", "sample") {
            local varlist_order = "`varlist'"
        }
        else {
            local varlist_order = "`varlist' `test'"
        }
        if "`field'" == "sample" {
            fvexpand `test' if `basesample'
            local test = r(varlist)
            local test: subinstr local test "b." ".", all
            local addnotes_sample = ""
            local i = 1
            foreach sample_index of local test {
                local addnotes_sample = `"`addnotes_sample'"Model `i' limited the sample by `sample_index'." "'
                local ++i
            }
        }
        if "`fe'" != "" {
            local addnotes_fe: subinstr local fe " " ", ", all
            local addnotes_fe "All model absorbed `addnotes_fe'."
        }
        if `"`addnotes_sample'`addnotes_fe'"' != "" {
            local add_notes = `"addnotes(`addnotes_sample' "`addnotes_fe'")"'
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
            if "`field'" == "sample" {
                tempvar sample
                gen `sample' = `basesample' & `t'
            }
            * run regress {{{3
            eststo, prefix("`R'") noesample: ///
                reghdfe `dep' `indep' if `sample', `absorb_option' `noconstant' `vce'
            * add extra macro {{{3
            quietly {
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
        }
        * export result {{{2
        if "`fixedeffects'" != "" {
            local scalars = "scalars(`fixedeffects')"
        }
        if "`ar2'" != "noar2"         local ar2 = "ar2"
        if "`depvars'" != "nodepvars" local depvars = "depvars"
        if "`gap'" == "gap"           local gap = "nogap"
        esttab `R'* using `"`using'"', `replace' `scalars' `add_notes' ///
            b(`b') `ar2' `depvars' `gap' order(`varlist_order') `options'
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
         shell `shellout' "`using'" >& /dev/null &
    restore // }}}1
end

/* test
 
webuse nlswork, clear

cap gen sample_index = inrange(_n, 1, 10000)


set trace on
set tracedepth 1
testreg sample ln_w grade age ttl_exp tenure not_smsa south ///
    using "/tmp/test sample.txt", ///
    t(i.sample_index) fe(idcode year) append drop(grade) b(4)

* fe
testreg fe ln_w grade age ttl_exp tenure not_smsa south ///
    using /tmp/temp.rtf, ///
    t(idcode year occ idcode#occ) replace

* control
testreg control ln_w age ///
    using "/tmp/test control.txt", ///
    t(ttl_exp tenure not_smsa south) fe(idcode year) replace

*/



