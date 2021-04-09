/* First, load the Cross-Wave Tracker file to get absolute basics: */
clear all
use "$Tracker16\HRS_Tracker16.dta"

keep HHID PN BIRTHYR GENDER DEGREE RACE

gen hhidpn=HHID+PN
destring hhidpn, replace

* Merge with the European ancestry Polygenic Score Data File:
merge 1:1 HHID PN using "$HRSPGS3Dir\PGENSCORE3E_R.dta", gen(PGSMerge)

* Generate a Flag for Genetic Europeans:
gen GeneticEuro=(PGSMerge==3)	

keep HHID PN BIRTHYR GENDER DEGREE RACE GeneticEuro 

save "$CleanData/HRS_CrossVarsForCog.dta", replace
clear all


/* Load the HRS's cleaned, imputed Cross-Wave Cognition File */

clear all
infile using "$CrossWaveCogDir/COGIMP9214A_R.dct" , using("$CrossWaveCogDir/COGIMP9214A_R.da")

keep HHID PN *FLAG *COGTOT *SLFMEM *PSTMEM *TR20

* Merge with the Cross Sectional Demographics: 
merge 1:1 HHID PN using "$CleanData/HRS_CrossVarsForCog.dta"


**********************************************
* Now, actually work with the Cognition Data
**********************************************

* First, duplicate each observation 10 times to create the panel:
expand 11

* Create a Counter to keep track of successive waves of cognition data
bys HHID PN: gen CogCounter=_n

* Now, each wave corresponds to a different year.
* CogCounter 1 = 1994, 2 = 1996, 3 = 1998, 4 = 2000, 
*            5 = 2002, 6 = 2004, 7 = 2006, 8 = 2008,
*            9 = 2010, 10 = 2012, 11=2014

* First, create a time-varying measure CogScoreTot that keeps
* track of the person-specific cognition score over time:
gen CogScoreTot=.
replace CogScoreTot=R2ACOGTOT  if CogCounter==1
replace CogScoreTot=R3COGTOT   if CogCounter==2
replace CogScoreTot=R4COGTOT   if CogCounter==3
replace CogScoreTot=R5COGTOT   if CogCounter==4
replace CogScoreTot=R6COGTOT   if CogCounter==5
replace CogScoreTot=R7COGTOT   if CogCounter==6
replace CogScoreTot=R8COGTOT   if CogCounter==7
replace CogScoreTot=R9COGTOT   if CogCounter==8
replace CogScoreTot=R10COGTOT  if CogCounter==9
replace CogScoreTot=R11COGTOT  if CogCounter==10
replace CogScoreTot=R12COGTOT  if CogCounter==11

gen RecallScore=.
replace RecallScore=R3TR20     if CogCounter==2
replace RecallScore=R4TR20     if CogCounter==3
replace RecallScore=R5TR20     if CogCounter==4
replace RecallScore=R6TR20     if CogCounter==5
replace RecallScore=R7TR20     if CogCounter==6
replace RecallScore=R8TR20     if CogCounter==7
replace RecallScore=R9TR20     if CogCounter==8
replace RecallScore=R10TR20    if CogCounter==9
replace RecallScore=R11TR20    if CogCounter==10
replace RecallScore=R12TR20    if CogCounter==11

* Fill in the year based on the above guide.  NOTE THE EXCEPTIONS
* for waves 1 and 2, some individuals from the AHEAD cohort were asked
* in 1993 and 1995, not 1994 and 1996  (part of AHEAD cohort)  We will
* account for this later when creating the "CogAge" variable 
gen YEAR=.
replace YEAR=1994 if CogCounter==1
replace YEAR=1996 if CogCounter==2
replace YEAR=1998 if CogCounter==3
replace YEAR=2000 if CogCounter==4
replace YEAR=2002 if CogCounter==5
replace YEAR=2004 if CogCounter==6
replace YEAR=2006 if CogCounter==7
replace YEAR=2008 if CogCounter==8
replace YEAR=2010 if CogCounter==9
replace YEAR=2012 if CogCounter==10
replace YEAR=2014 if CogCounter==11

* Need to create an Age variable here from YEAR
* and BIRTHYR ... set it missing for the small number
* of people with 0 values for BIRTHYR
gen      Age=YEAR-BIRTHYR
replace Age=. if BIRTHYR==0

* Create a CogAge variable ... which will allow us to correct
* for the fact that some people's 1994 data was really collected in 1993, and 
* some people's 1996 data was really collected in 1995

gen CogAge=Age
replace CogAge=Age-1 if YEAR==1994 & R2FLAG==93
replace CogAge=Age-1 if YEAR==1996 & R3FLAG==95

* Get a Quartic in Age, interacted with  
gen Male=(GENDER==1)
replace Male=. if GENDER==.

gen CogAge2=CogAge*CogAge/100
gen CogAge3=CogAge*CogAge*CogAge/1000
gen CogAge4=CogAge*CogAge*CogAge*CogAge/10000

gen MalexCogAge=Male*CogAge
gen MalexCogAge2=Male*CogAge2
gen MalexCogAge3=Male*CogAge3
gen MalexCogAge4=Male*CogAge4


* Run Basic Panel Regression - Cognitive Score on quartic in Age interacted with
* Male dummy:
reg CogScoreTot CogAge CogAge2 CogAge3 CogAge4 Male Malex* if GeneticEuro==1
	* Keep an indicator for being in the sample
	gen InCogSample=e(sample)
	* Predict Residuals, but only for the sample. 
	predict  CogResid if InCogSample==1, resid  
	* Now, get total number of observations for each person in the panel regression:
	bys HHID PN: egen NumCogObs=total(InCogSample)
	* Now, get the average residual for each person in the panel:
	bys HHID PN: egen AvgCogResid=mean(CogResid)
	* To avoid double counting based on number of observations in the panel, replace
	* the Average Cognition Residual to missing if the CogCounter is not equal to 1
	replace AvgCogResid=. if CogCounter~=1

* Now, standardize the Cognition Score: 	
egen CogScoreTotStd=std(AvgCogResid)


* Keep a subset of variables to be the main cognition measure:
keep HHID PN CogScoreTotStd NumCogObs CogScoreTot *FLAG* YEAR CogAge CogCounter

save  "$CleanData/HRS_CleanCogImputePanel.dta", replace  

* Now just keep first observation to get a cross-sectional data set: 
keep if CogCounter==1

keep HHID PN CogScoreTotStd NumCogObs

save "$CleanData/HRS_CleanCogImpute.dta", replace



