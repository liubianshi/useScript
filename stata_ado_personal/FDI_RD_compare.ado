*! FDI_RD_compare v1.0.1 LW 18Jun2013
program FDI_RD_compare, rclass
	version 12.0
	syntax varlist(min=1) [if] [in] ,CONtrol(varlist) index(varlist) [factor(varlist)]
	local nvar: word count `varlist'
	local ncvar: word count `control'
	local nivar: word count `index'
	local nfvar: word count `factor'
	
	foreach tp of local factor {
		local j = `j' + 1
		tab `tp' if `index' != 1, gen(_f`j')
		drop _f`j'1
	}
	regress `varlist' `control'  _f* if `index' != 1
	drop _f*
	forvalue i = 2/`nvar' {
		local v: word `i' of `varlist'
		return scalar R2`=`i'-1' = _b[`v']
	}	
end
