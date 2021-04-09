* NOTE : FILL IN PATH TO EA_CrossSection.dta below, otherwise script won't run.
*****************************************************
use "EA_CrossSection.dta", clear
*****************************************************

bys HHID PN: gen PersCounter=_n
gen HHIDPN = HHID+PN
gen InCrossSample=(EA3Score~=. & Educ~=. & EAWeight~=. & PersCounter==1)
keep if InCrossSample == 1

* Normalize EA Score and Cog Score:
sum EA3Score if InCrossSample==1
replace EA3Score=(EA3Score-r(mean))/(r(sd))

sum CogScore if InCrossSample==1
replace CogScore=(CogScore-r(mean))/(r(sd))

gen GenderSample1=1
gen GenderSample2=(Male==1)
gen GenderSample3=(Male==0)

* birth year dummy, gender dummy, birth year x gender
tab BIRTHYR, gen(iBIRTHYR)
tab Male, gen(iMale)
qui levelsof BIRTHYR, local(birthyr)
qui levelsof Male, local(male)
foreach b of local birthyr {
foreach m of local male {
	gen interact_`m'_`b' = (BIRTHYR == `b' & Male == `m')
	}
}
* drop collinear interaction terms (ie just keep when Male == 1)
drop interact_0*

* REGRESSIONS OF EA ON EA PGI (WITH/WITHOUT PARENTAL EA)

preserve
	keep Educ EA3Score iBIRTHYR* iMale* interact* ev1-ev10 HHIDPN EAWeight
	drop if mi(EA3Score)
	_rmcoll Educ EA3Score ev* interact* iBIRTHYR* iMale1, forcedrop
	keep `r(varlist)' HHIDPN EAWeight
 	export delimited "./reg1/reg1.txt", delim(" ") replace
restore

preserve
	keep Educ EA3Score iBIRTHYR* iMale* interact* ev1-ev10 FEMiss MEMiss FatherEduc MotherEduc HHIDPN EAWeight
	replace MotherEduc = 0 if mi(MotherEduc)
	replace FatherEduc = 0 if mi(FatherEduc)
	_rmcoll Educ EA3Score iBIRTHYR* iMale* interact* ev1-ev10 FEMiss MEMiss FatherEduc MotherEduc, forcedrop
	keep `r(varlist)' HHIDPN EAWeight
 	export delimited "./reg2/reg2.txt", delim(" ") replace
restore

* GENE X ENVIRONMENT REGRESSIONS

gen EA3Score_Sq=EA3Score*EA3Score
gen EA3Score_Cb=EA3Score*EA3Score*EA3Score

sum EA3Score if InCrossSample==1, det
gen EA3Score_P5=r(p5)
gen EA3Score_P95=r(p95)

gen HighSES=FamSES_High
gen LowSES =FamSES_Low
gen EA3ScorexHighSES=EA3Score*HighSES
gen CogScorexHighSES=CogScore*HighSES

* Generate interactions between the PCs and the High SES measure:
forvalues PCInd=1(1)10{
	gen ev`PCInd'xHighSES=ev`PCInd'*HighSES
}

	tab BIRTHYRxMale, gen(iBIRTHYRxMale)
	keep if InCrossSample==1  &  (HighSES==1 | LowSES==1)
	keep AtLstHS AtLstColl ev1-ev10 ev*HighSES iBIRTHYR* iMale* iBIRTHYRxMale* FatherEducWithM FEMiss MotherEducWithM MEMiss HighSES EA3Score EA3Score_Sq EA3Score_Cb EA3ScorexHighSES EAWeight InCrossSample LowSES HighSES HHIDPN
	drop if mi(EA3Score)
	local counter 3
	foreach DepVar in AtLstHS AtLstColl {
		di `counter'
		preserve
		_rmcoll `DepVar' ev1-ev10 ev*HighSES iBIRTHYR*  iBIRTHYRxMale* iMale*              ///
					 FatherEducWithM FEMiss MotherEducWithM MEMiss                     ///
					 HighSES EA3Score EA3Score_Sq EA3Score_Cb EA3ScorexHighSES, forcedrop
		keep `r(varlist)' EAWeight HHIDPN InCrossSample LowSES
 		export delimited "/disk/genetics/dbgap/ggoldman/replication/reg`counter'/reg`counter'.txt", delim(" ") replace
		restore
		local counter 4

}