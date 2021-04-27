*********************************************
* Get Cross Sectional Characteristics
*********************************************


************************************************************
* This file loads polygenic scores from two publicly available sources:
*   1) The SSGAC's Public Release of the Educational Attainment Score from 
*      the Lee et al (2018) paper in Nature Genetics,
*
*   2) The Version 3 Release of the Polygenic Score file from the HRS.
* 
************************************************************


* First, load in EA3 (Lee et al 2018) score:
clear all
insheet using "$EA3ScoreDir\Lee_et_al_(2018)_PGS_HRS.txt"

rename hhid HHIDNum
rename pn   PNNum

* Rename the principal components to make the names consistent with previously
* written code.  There is no substantive reason for this:

forvalues pind=1(1)10{
	rename pc`pind' ev`pind'
}

keep HHIDNum PNNum pgs_ea3_gwas ev*


save "$CleanData\EA3_LeeEtAl.dta", replace


clear all
use "$HRSPGS3Dir\PGENSCORE3E_R.dta"

destring HHID, gen(HHIDNum)
destring PN, gen(PNNum)

* Generate a Flag for Genetic Europeans:
gen GeneticEuro=(PC1_5A~=.)	

* Rename the HRS principal components to make them easier to loop over / call
* in commands:

		rename PC1_5A    fv1
		rename PC1_5B    fv2
		rename PC1_5C    fv3
		rename PC1_5D    fv4
		rename PC1_5E    fv5
		rename PC6_10A   fv6
		rename PC6_10B   fv7
		rename PC6_10C   fv8
		rename PC6_10D   fv9
		rename PC6_10E   fv10
		
* merge with the cleaned EA3 score:
merge 1:1 HHIDNum PNNum using "$CleanData\EA3_LeeEtAl.dta", gen (EA3Merge)


keep HHIDNum PNNum EA_PGS3_EDU2_SSGAC16 EA_PGS3_EDU3_SSGAC18 pgs_ea3_gwas ev* fv* GeneticEuro

egen EA3Score=std(pgs_ea3_gwas)
egen EA2Score=std(EA_PGS3_EDU2_SSGAC16)
egen EA3ScoreHRS=std(EA_PGS3_EDU3_SSGAC18)	


save "$CleanData\EA_PGS.dta", replace


clear all


*********************************************
* Load the Cross-Wave Tracker File
* to get basic demographics and Identifiers
*********************************************

clear all

use "$Tracker16\HRS_Tracker16.dta"

destring HHID, gen(HHIDNum)
destring PN, gen(PNNum)
	
* Merge with the PGS File:

merge 1:1 HHIDNum PNNum using "$CleanData\EA_PGS.dta", gen(GW_PGS_Merge)	

keep HHID PN HHIDNum PNNum EA3Score EA2Score EA3ScoreHRS ev* fv* GENETICS* ///
     GENDER SCHLYRS DEGREE BIRTHYR *SUBHH *INSAMP *FINR *WGTR *WGTHH *COUPLE *PPN ///
	 RACE *ALIVE EXDEATHYR FIRSTIW GeneticEuro


/******************************************************************************/
* Clean Variables from Tracker and Demographic Files:	
********************************************************************************


	***********************************
	* DROP MISSING BIRTH YEAR DROPFLAG
	***********************************
	* So far, we have not dropped any individuals.  Here we drop if an individual
	* is missing data on their birthday.  SAMPFLAG

	unique HHID PN
	drop if (BIRTHYR==0 | BIRTHYR==.) 
	unique HHID PN
	keep if BIRTHYR<1965 
	unique HHID PN
	
	* Generate Birth Year Categories:
			gen BirthYearCat=.
				replace BirthYearCat=0 if BIRTHYR<1930 & BIRTHYR~=.
				replace BirthYearCat=1 if BIRTHYR>=1930 & BIRTHYR<1935
				replace BirthYearCat=2 if BIRTHYR>=1935 & BIRTHYR<1940
				replace BirthYearCat=3 if BIRTHYR>=1940 & BIRTHYR<1945
				replace BirthYearCat=4 if BIRTHYR>=1945 & BIRTHYR<1950
				replace BirthYearCat=5 if BIRTHYR>=1950 & BIRTHYR~=.
			* Create a set of categorical variables indicating these birthyear categories
			tab BirthYearCat, gen(BY)
				label var BY1 "<1930"
				label var BY2 "1930-1934"
				label var BY3 "1935-1939"
				label var BY4 "1940-1944"
				label var BY5 "1945-1949"
				label var BY6 "1950-1954"	
	
	
	********************************************
	* Sex and Race Variables 
	********************************************
	gen Male=(GENDER==1)
		replace Male=. if GENDER==.
		
	gen White=(RACE==1)
	gen Black=(RACE==2)
	gen OtherRace=(RACE==7)
	
	***********************************************
	* Clean Education Variables DROPFLAG
	***********************************************
	
	* First, clean years of schooling, SCHLYRS, and rename it Educ 
	gen Educ=SCHLYRS
	replace Educ=. if Educ>=30
	drop if Educ==.

	* Get Educational Categoricals from DEGREE variable:
	/*
			10007           0.  No degree
			  1757           1.  GED
			 16946           2.  High school diploma
			  1637           3.  Two year college degree
			  4086           4.  Four year college degree
			  2050           5.  Master degree
			   686           6.  Professional degree (Ph.D., M.D., J.D.)
			   839           9.  Degree unknown/Some College	  */
			   
	gen NoDegree=0
				replace NoDegree=1 if DEGREE==0
				replace NoDegree=. if DEGREE>=9 

	gen GED=0
				replace GED=1 if (DEGREE==1)
				replace GED=. if DEGREE>=9			

	gen HighSchool=0
				replace HighSchool=1 if (DEGREE==2)
				replace HighSchool=. if DEGREE>=9			
				
	gen TwoYrColl=0
				replace TwoYrColl=1 if (DEGREE==3)
				replace TwoYrColl=. if DEGREE>=9 
				
	gen College=0
				replace College=1 if (DEGREE==4)
				replace College=. if DEGREE>=9			

	gen CollPlus=0
				replace CollPlus=1 if (DEGREE==4 | DEGREE==5 | DEGREE==6)
				replace CollPlus=. if DEGREE>=9				

	gen CollPlusAlt=0
				replace CollPlusAlt=1 if (DEGREE==4 | DEGREE==5 | DEGREE==6)
				replace CollPlusAlt=. if DEGREE>=9					

	gen MoreThanCollege=0
				replace MoreThanCollege=1 if (DEGREE==5 | DEGREE==6)
				replace MoreThanCollege=. if DEGREE>=9			
				
	gen MA=0
				replace MA=1 if (DEGREE==5)
				replace MA=. if  DEGREE>=9			

	gen ProDegree=0
				replace ProDegree=1 if (DEGREE==6)
				replace ProDegree=. if  DEGREE>=9			
				
				
	gen AtLstHSEq=(DEGREE>=1 & DEGREE<9)
		replace AtLstHSEq=. if DEGREE>=9
	gen AtLstHS	  =(DEGREE>=2 & DEGREE<9)
		replace AtLstHS=. if DEGREE>=9
	gen AtLstTwoYr  =(DEGREE>=3 & DEGREE<9)
		replace AtLstTwoYr=. if DEGREE>=9
	gen AtLstColl=(DEGREE>=4 & DEGREE<9)
		replace AtLstColl=. if DEGREE>=9
	gen AtLstGrad   =(DEGREE>=5 & DEGREE<9)	
		replace AtLstGrad=. if DEGREE>=9			

		
	****************************************************************************
	* b) Merge with the Summary Cognition Data 
	****************************************************************************
	
	
	merge m:1 HHID PN using "$CleanData/HRS_CleanCogImpute.dta", gen(CogMerge)
		drop if CogMerge==2
		gen CogScore=CogScoreTotStd	
		
	****************************************************************************
	* c) Merge with Demographic Data (incuding items in "Leave Behind" Surveys 
	****************************************************************************
		
	
	merge m:1 HHID PN      using "$CleanData/EA_DemographicVars.dta", gen(DemoMerge)
		drop if DemoMerge==2	
	
		
		
	gen InGeneticSample=(GENETICS06==1 | GENETICS08==1)
	
	gen InGeneticSampleFull=(GENETICS06==1 | GENETICS08==1 | GENETICS10==1 | GENETICS12==1)
		
	replace REGIONB=9999 if REGIONB==.
	replace FatherEducWithM=9999 if FatherEducWithM==.
	replace MotherEducWithM=9999 if MotherEducWithM==.
	replace FEMiss=1 if FEMiss==.
	replace MEMiss=1 if MEMiss==.
	
	probit InGeneticSample i.REGIONB i.BIRTHYR i.DEGREE Educ FatherEducWithM FEMiss MotherEducWithM MEMiss Male if RACE==1 

	predict InGenoProbXB if e(sample), xb
	gen InGenoProb = normprob(InGenoProbXB)
	gen InGenoWeight=1/InGenoProb

	probit InGeneticSampleFull i.REGIONB i.BIRTHYR i.DEGREE Educ FatherEducWithM FEMiss MotherEducWithM MEMiss Male if RACE==1 

	predict InGenoProbXBFull if e(sample), xb
	gen InGenoProbFull = normprob(InGenoProbXBFull)
	gen InGenoWeightFull=1/InGenoProbFull	
	

	* Get Respondent Weights

	gen RW_1992=AWGTR
	gen RW_1993=BWGTR
	gen RW_1994=CWGTR
	gen RW_1995=DWGTR
	gen RW_1996=EWGTR
	gen RW_1998=FWGTR
	gen RW_2000=GWGTR
	gen RW_2002=HWGTR
	gen RW_2004=JWGTR
	gen RW_2006=KWGTR
	gen RW_2008=LWGTR
	gen RW_2010=MWGTR
	gen RW_2012=NWGTR
	gen RW_2014=OWGTR

	* Get Household Weights

	gen HHW_1992=AWGTHH
	gen HHW_1993=BWGTHH
	gen HHW_1994=CWGTHH
	gen HHW_1995=DWGTHH
	gen HHW_1996=EWGTHH
	gen HHW_1998=FWGTHH
	gen HHW_2000=GWGTHH
	gen HHW_2002=HWGTHH
	gen HHW_2004=JWGTHH
	gen HHW_2006=KWGTHH
	gen HHW_2008=LWGTHH
	gen HHW_2010=MWGTHH
	gen HHW_2012=NWGTHH
	gen HHW_2014=OWGTHH


	gen RWFirst04=.
	gen HWFirst04=.

	gen RWFirstNM=.
	gen HWFirstNM=.


	foreach yr in 2004 2006 2008 2010 2012 2014 {
		replace RWFirst04=RW_`yr' if RWFirst04==. & RW_`yr'~=. & RW_`yr'>0
		replace HWFirst04=HHW_`yr' if HWFirst04==. & HHW_`yr'~=. & HHW_`yr'>0
	}


	foreach yr in 1992 1993 1994 1995 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 {

		replace RWFirstNM=RW_`yr' if RWFirstNM==. & RW_`yr'~=. & RW_`yr'>0
		replace HWFirstNM=HHW_`yr' if HWFirstNM==. & HHW_`yr'~=. & HHW_`yr'>0
		
	}


	gen RWGeno=.
	replace RWGeno=KBIOWGTR if GENETICS06==1 
	replace RWGeno=LBIOWGTR if GENETICS08==1 
	replace RWGeno=MBIOWGTR if GENETICS10==1 
	replace RWGeno=NBIOWGTR if GENETICS12==1 


	replace RWGeno=KBIOWGTR if ((RWGeno==0 | RWGeno==.) & (KBIOWGTR~=. & KBIOWGTR>0))
	replace RWGeno=LBIOWGTR if ((RWGeno==0 | RWGeno==.) & (LBIOWGTR~=. & LBIOWGTR>0))
	replace RWGeno=MBIOWGTR if ((RWGeno==0 | RWGeno==.) & (MBIOWGTR~=. & MBIOWGTR>0))
	replace RWGeno=NBIOWGTR if ((RWGeno==0 | RWGeno==.) & (NBIOWGTR~=. & NBIOWGTR>0))
	replace RWGeno=OBIOWGTR if ((RWGeno==0 | RWGeno==.) & (OBIOWGTR~=. & OBIOWGTR>0))
	
	
	gen EAWeight  =RWFirst04*InGenoWeight
		replace EAWeight=HWFirst04*InGenoWeight if RWFirst04==.
	
	gen EAWeightFull  =RWFirst04*InGenoWeightFull
		replace EAWeightFull=HWFirst04*InGenoWeightFull if RWFirst04==.	
	
	
	gen EAWeightF =RWFirstNM*InGenoWeight	
	gen EAWeightG =RWGeno	
	
	
	***********************************************************************
	* Clean Father's Income variable - make it comparable with 
	* other SES measures
	***********************************************************************
	
	sum FOccIncMasked if (EA3Score~=. & GeneticEuro==1), det
	gen MedFOccIncMasked=r(p50)
	gen FOccIncMasked_High=(FOccIncMasked>MedFOccIncMasked)
	gen FOccIncMasked_Low =(FOccIncMasked<=MedFOccIncMasked)
	gen FOccIncMasked_InSample=(FOccIncMasked~=.)
		replace FOccIncMasked_High=. if FOccIncMasked_InSample==0
		replace FOccIncMasked_Low =. if FOccIncMasked_InSample==0
			

	
	************************************************************************
	* Standardize the EA3 Score and the EA2 Score
	************************************************************************
	
	foreach PGS in EA3Score EA2Score EA3ScoreHRS {
		sum `PGS' if  `PGS'~=. & InGeneticSample==1 & GeneticEuro==1, det
		replace `PGS'=(`PGS'-r(mean))/(r(sd))
	}
	
	
	**************************************************************
	* Create a number of interactions: 
	**************************************************************

	* Interactions between the Principal Components and the Male indicator:
	forvalues PCInd=1(1)10{
		gen ev`PCInd'xMale=ev`PCInd'*Male
	}
	
	* Interactions between the EA3Score and various SES measures:
	gen EA3ScorexFamSES_High=EA3Score*FamSES_High
	gen EA3ScorexFOccIncMasked_High=EA3Score*FOccIncMasked_High
	gen EA3ScorexMove_High=EA3Score*Move_High
	gen EA3ScorexHelp_High=EA3Score*Help_High
	gen EA3ScorexMOrH_High=EA3Score*MOrH_High
	gen EA3ScorexFUnemp_High=EA3Score*FUnemp_High
	gen EA3ScorexMotherEduc_High=EA3Score*MotherEduc_High
	gen EA3ScorexFatherEduc_High=EA3Score*FatherEduc_High	
	
	* Interaction between EA3Score and Male:
	gen EA3ScorexMale=EA3Score*Male
	
	* Interaction between Birth year and Male:
	gen BIRTHYRxMale=BIRTHYR*Male	
	
	
	keep if GeneticEuro==1
	
	save "$CleanData\EA_CrossSection.dta", replace 
	
	
	
		
