*! State_effect v1.0.1 LW 23may2013
program State_effect, rclass
	version 12.0
	syntax varlist(min=1) [if] [in]
	preserve
		tempname Reg Eff Eff2 intr
		di "xin"
		keep ID year `varlist'
		probit EX i.prov i.inds2 i.year i.ownership lntfp interrate intpayrate, robust
		esti store `Reg'
		margins, dydx(ownership lntfp interrate) predict(pr) post
		esti store `Eff'
		esti restore `Reg'		
		margins, dyex(intpayrate) predict(pr) post
		esti store `Eff2'
		esti restore `Eff'
		return scalar ED2 = _b[2.ownership] // 非生产效率效应
		
		quietly regress lnintpayrate i.prov i.inds2 i.year i.ownership i.gc ln_interrate
		esti store `Intr'
		local temp = _b[2.ownership]
		esti restore `Eff2'
		return scalar ED1 = `temp' * _b[intpayrate]	// 信贷偏好效应	
		
		quietly regress lntfp i.prov i.inds2 i.year i.gc interrate i.ownership // 计算所有制所导致的效率差异
		local temp = _b[2.ownership]
		esti restore `Eff'
		return scalar EI1 = `temp' * _b[lntfp] // 生产效率效应
		
		quietly regress interrate i.prov i.inds2 i.year i.gc i.lntfp i.ownership
		local temp = _b[2.ownership]
		esti restore `Eff'
		local temp = `temp' * _b[interrate]
		esti restore `Intr'
		local temp2 = _b[ln_interrate]
		quietly regress ln_interrate i.prov i.inds2 i.year i.gc i.lntfp i.ownership
		local temp2 = `temp2' * _b[2.ownership]
		esti restore `Eff2'
		return scalar EI2 = `temp' + `temp2' * _b[intpayrate] // 内部融资能力效应
		
		quietly probit EX i.prov i.inds2 i.year i.ownership
		margins, dydx(ownership)
		return scalar E = _b[2.ownership] // 总效应
		
		return scalar EI3 = E - ED1 - ED2 - EI1 -EI2 // 外部融资效应
	restore
end 	
	