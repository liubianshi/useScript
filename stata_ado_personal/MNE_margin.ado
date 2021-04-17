*! MNE_margin v1.0.1 LW 10may2013
program MNE_margin, rclass
	version 12.0
	syntax varlist(fv ts min=1) [if] [in]
	tempname _phi _Phi _mills _mills2
	quietly probit `varlist'
		predict `_phi', xb
		replace `_phi' = normalden(`_phi')
		predict `_Phi', pr
		gen `_mills' = `_phi' / `_Phi'
		quietly sum `_mills', meanonly
		local _m = r(mean)	
	foreach varl of local varlist {
		local i = `i' + 1
		if `i' == 1 {
			continue
		}
		if strpos("`varl'", ".") == 0 {
			local _beta = _b[`varl']
			di "`varl' `=`_m' * `_beta''"
			return scalar E`i' = `=`_m' * `_beta''
		}
		else {
		//虚拟变量
			local _var = substr("`varl'",3,.)
			levelsof `_var', local(value)
			local j = 0
			foreach v of local value {
				local j = `j' + 1
				if `j' == 1 {
					local fv = `v'
					continue
				}
				tempname _Phi_1 _Phi_0 _mills2
				rename `_var'  `_var'_00
				gen `_var' = `v' 
				predict `_Phi_1', pr
				replace `_var' = `fv'
				predict `_Phi_0', pr
				gen `_mills2' = (`_Phi_1' - `_Phi_0') / `_Phi'
				sum `_mills2', meanonly
				local _m`i'`j' = r(mean)
				drop `_Phi_1' `_Phi_0' `_mills2'
				drop `_var'
				rename `_var'_00 `_var'
				di "`varl' `_m`i'`j''"
				return scalar E`i'_`j' = `_m`i'`j''
			}
		}
	}			
end
