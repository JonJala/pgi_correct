clear all

cd "$CleanData"


*****************************
* Get 1950 Census Data
*****************************

use "$Census1950\IPUMS_USCensus_1950.dta"

keep year perwt birthyr educ educd sex age race empstat classwkr inctot incwage occ* cpi99

* Keep men
keep if sex==1
* Keep those aged 18-64
keep if age>=18 & age<=64
* Keep whites
keep if race==1
* Keep those employed
keep if empstat==1
* Keep non-missing and positive values of income from wages / salary
keep if incwage>0 & incwage<999999



save "$CleanData\IncData_1950.dta", replace 



*****************************
* Get 1960 Census Data
*****************************
clear all

use "$Census1960\IPUMS_USCensus_1960.dta"

keep year perwt birthyr educ educd sex age race empstat classwkr inctot incwage occ* cpi99

* Keep men
keep if sex==1
* Keep those aged 18-64
keep if age>=18 & age<=64
* Keep whites
keep if race==1
* Keep those employed
keep if empstat==1
* Keep non-missing and positive values of income from wages / salary
keep if incwage>0 & incwage<999999

save "$CleanData\IncData_1960.dta", replace 

clear all


*****************************
* Get 1970 Census Data
*****************************
clear all

use "$Census1970\IPUMS_USCensus_1970.dta"

keep year perwt birthyr educ educd sex age race empstat classwkr inctot incwage occ1990 cpi99

* Keep men
keep if sex==1
* Keep those aged 18-64
keep if age>=18 & age<=64
* Keep whites
keep if race==1
* Keep those employed
keep if empstat==1
* Keep non-missing and positive values of income from wages / salary
keep if incwage>0 & incwage<999999

save "$CleanData\IncData_1970.dta", replace 

clear all


use           "$CleanData\IncData_1950.dta"
append using  "$CleanData\IncData_1960.dta"
append using  "$CleanData\IncData_1970.dta"

save "$CleanData\CensusFOccIncDataRaw.dta", replace


gen FOcc=.
	replace FOcc=1   if occ1990>=3    & occ1990<=37
	replace FOcc=2   if occ1990>=43   & occ1990<=235
	replace FOcc=3   if occ1990>=243  & occ1990<=285
	replace FOcc=4   if occ1990>=303  & occ1990<=389
	replace FOcc=5   if occ1990>=403  & occ1990<=407
	replace FOcc=6   if occ1990>=413  & occ1990<=427
	replace FOcc=7   if occ1990>=433  & occ1990<=444
	replace FOcc=8   if occ1990>=445  & occ1990<=447
	replace FOcc=9   if occ1990>=448  & occ1990<=469
	replace FOcc=10  if occ1990>=473  & occ1990<=499
	replace FOcc=11  if occ1990>=503  & occ1990<=549
	replace FOcc=12  if occ1990>=553  & occ1990<=617
	replace FOcc=13  if occ1990>=633  & occ1990<=699
	replace FOcc=14  if occ1990>=703  & occ1990<=799
	replace FOcc=15  if occ1990>=803  & occ1990<=874
	replace FOcc=16  if occ1990>=875  & occ1990<=889
	replace FOcc=17  if occ1990>=900  & occ1990<=905

gen EdCat=.
	replace EdCat=1 if educ==0
	replace EdCat=2 if educ==1
	replace EdCat=3 if educ==2
	replace EdCat=4 if educ==3
	replace EdCat=5 if educ==4
	replace EdCat=6 if educ==5
	replace EdCat=7 if educ==6
	replace EdCat=8 if educ>6 & educ<=11
	
	
replace incwage=incwage*cpi99	
	

foreach YR in 1950 1960 1970 {
	forvalues Occ=1(1)17{
	
	sum incwage [fw=perwt] if year==`YR' & FOcc==`Occ'
	gen FInc_YR`YR'_Occ`Occ'=r(mean)	
		

	}
}


gen Temp=_n
keep if Temp==1

keep FInc*

gen Ind=1

reshape long FInc_YR1950_Occ FInc_YR1960_Occ FInc_YR1970_Occ , i(Ind) j(FOcc)

drop Ind

save "$CleanData\FOccIncData.dta", replace


clear all


use "$CleanData\CensusFOccIncDataRaw.dta" 

* Convert to real 1999 dollars:
replace incwage=incwage*cpi99

levels occ1990, local(OccList)


foreach YR in 1950 1960 1970 {
	foreach OC in `OccList' {
	
		sum incwage [fw=round(perwt)] if year==`YR' & occ1990==`OC'
		gen FInc_YR`YR'_Occ1990_`OC'=r(mean)
		
	}
}

gen Temp=_n
keep if Temp==1

keep FInc*

gen Ind=1

reshape long FInc_YR1950_Occ1990_ FInc_YR1960_Occ1990_ FInc_YR1970_Occ1990_, i(Ind) j(FOcc1990)

keep FInc_YR1950_Occ1990_ FInc_YR1960_Occ1990_ FInc_YR1970_Occ1990_ FOcc1990

save "$CleanData\FOcc1990AvgInc.dta", replace 



