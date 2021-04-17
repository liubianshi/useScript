*! myregress v1.0.1 LW 08apr2013
program myregress, rclass
	version 12.0
	syntax varlist(fv ts min=1) [if] [in] [, FACTor(varlist) Margin(varlist)]
	local nfvar: word count `factor'
	local nmvar: word count `margin'
	if `nfvar' == 0 | `nmvar' == 0 {
		error 2000
	}
	tempname rmat
	matrix `rmat' = J(`nmvar', 2, .)
	forvalue i = 1/`nfvar' {
		local v: word `i' of `factor'
		quietly tab `v' `if' `in', gen(_v`i'_)
	}
	quietly regress `varlist' _v?_*
	margins , dydx(`margin') post
	tempname temp
	matrix `temp' = e(V)
	forvalue i = 1/`nmvar' {
		local mvar: word `i' of `margin'
		matrix `rmat'[`i',1] = _b[`mvar']
		matrix `rmat'[`i',2] = `temp'[`i',`i'] ^ 0.5
		return scalar dy_dx`i'= _b[`mvar']
	}
	matrix colnames `rmat' = dy_dx std_err
	matrix rownames `rmat' = `margin'
	drop _v?_*
	return matrix rmat = `rmat'
	return local mvarname `margin'
	return local fvarname `factor'
end
