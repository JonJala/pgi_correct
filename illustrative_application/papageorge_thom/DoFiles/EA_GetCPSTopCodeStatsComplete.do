clear all

mat DecadeLimits=J(6,3,9999)

mat DecadeLimits[1,1]=60
mat DecadeLimits[1,2]=1962
mat DecadeLimits[1,3]=1969

mat DecadeLimits[2,1]=70
mat DecadeLimits[2,2]=1970
mat DecadeLimits[2,3]=1979

mat DecadeLimits[3,1]=80
mat DecadeLimits[3,2]=1980
mat DecadeLimits[3,3]=1989

mat DecadeLimits[4,1]=90
mat DecadeLimits[4,2]=1990
mat DecadeLimits[4,3]=1999

mat DecadeLimits[5,1]=2000
mat DecadeLimits[5,2]=2000
mat DecadeLimits[5,3]=2009

mat DecadeLimits[6,1]=2010
mat DecadeLimits[6,2]=2010
mat DecadeLimits[6,3]=2015


local DecCounter=1
foreach DECADE in 1960s 1970s 1980s 1990s 2000s 2010s {

local StartYear=DecadeLimits[`DecCounter',2]
local EndYear=DecadeLimits[`DecCounter',3]


use "$CPSDecades\CPS_`DECADE'\CPS_`DECADE'.dta", replace
gen Year=(year-1)
merge m:1 Year using "$ExternalDir\SSATopCodeLevels.dta", gen(TopCodeMerge)
keep if TopCodeMerge==3

	gen    IncWageClean=incwage 
		   replace IncWageClean=. if incwage>=9999998
		   
	gen    IncBusClean=incbus
		   replace IncBusClean=.  if  incbus>=9999998

	gen    IncFarmClean=incfarm
		   replace IncFarmClean=. if incfarm>=9999998		   
		   
	egen EarnedIncome=rowtotal(IncWageClean IncBusClean IncFarmClean), missing
	
	gen CPIYear=Year
	merge m:1 CPIYear using "$CPIDir\CPI_U_1913_2016_2k10.dta", gen(CPIMerge)
	drop if CPIMerge==2	
	
	gen IsTopCoded=.
	replace IsTopCoded=0 if EarnedIncome~=. & wtsupp>0
	replace IsTopCoded=1 if EarnedIncome~=. & wtsupp>0 & EarnedIncome>=SSATopCode	
	
	gen RealEarnedIncome=EarnedIncome/CPIFactor
	
	gen birthyr=year-age
	
	gen RealIncAbove10k=.
	replace RealIncAbove10k=0 if RealEarnedIncome~=. & RealEarnedIncome<=10000
	replace RealIncAbove10k=1 if RealEarnedIncome~=. & RealEarnedIncome>10000	

	drop if wtsupp<0

forvalues yr=`StartYear'(1)`EndYear'{



	sum EarnedIncome if year==`yr' & EarnedIncome~=. & wtsupp>0 & EarnedIncome>=SSATopCode [fw=round(wtsupp)], det
	gen TopCodeMean`yr'=r(mean)
	gen TopCodeMedian`yr'=r(p50)
	
	sum SSATopCode if year==`yr', det
	gen SSATopCode`yr'=r(p50)
	
	sum IsTopCoded if year==`yr'               & age>=25 & age<65 [fw=round(wtsupp)], det
	gen FracTopCoded`yr'=r(mean)
	
	sum IsTopCoded if year==`yr'      & sex==1 & age>=25 & age<65 [fw=round(wtsupp)], det
	gen FracTopCodedMen`yr'=r(mean)
	
	sum IsTopCoded if year==`yr'      & sex==1 & age>=25 & age<65 & birthyr>=1907 & birthyr<=1964 [fw=round(wtsupp)], det
	gen FracTopCodedMenBC`yr'=r(mean)	

	sum IsTopCoded if year==`yr'      & sex==1 & age>=25 & age<65 & birthyr>=1907 & birthyr<=1964 & RealEarnedIncome>10000 [fw=round(wtsupp)], det
	gen FracTopCodedMenBCInLF`yr'=r(mean)	
	
	sum RealIncAbove10k if year==`yr' & sex==1 & age>=25 & age<65 & birthyr>=1907 & birthyr<=1964 [fw=round(wtsupp)], det
	gen FracAbove10kMenBC`yr'=r(mean)		
	
}


gen ID=_n
keep if ID==1
drop SSATopCode
keep TopCodeM* *TopCode* FracAbove* ID
reshape long TopCodeMean TopCodeMedian SSATopCode FracTopCoded FracTopCodedMen FracTopCodedMenBC FracTopCodedMenBCInLF FracAbove10kMenBC, i(ID) j(Year)

keep Year TopCodeMean TopCodeMedian SSATopCode FracTopCoded FracTopCodedMen FracTopCodedMenBC FracTopCodedMenBCInLF FracAbove10kMenBC

save "$CleanData\TopCodeStats`DECADE'Complete.dta", replace

clear

di `DecCounter'

local DecCounter=`DecCounter'+1

}



clear all


use "$CleanData\TopCodeStats1960sComplete.dta"
append using "$CleanData\TopCodeStats1970sComplete.dta"
append using "$CleanData\TopCodeStats1980sComplete.dta"
append using "$CleanData\TopCodeStats1990sComplete.dta"
append using "$CleanData\TopCodeStats2000sComplete.dta"
append using "$CleanData\TopCodeStats2010sComplete.dta"

* Correct for Year reflecting PREVIOUS YEAR Outcomes:

replace Year=(Year-1)

save "$CleanData\EA_TopCodeStatsComplete.dta", replace




