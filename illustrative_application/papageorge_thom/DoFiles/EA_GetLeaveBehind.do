********************************************
* Get Items from the "Leave-Behind" Survey Items
* For our analyses, we really only use the
* item on whether the respondent ever
* had to redo a grade as a child:
********************************************


/* Leave Behind from 2012  */
clear all
infile using "$HRSSurveys12/h12sta/H12LB_R.dct" , using("$HRSSurveys12/h12da/H12LB_R.da")

gen ChildRedoGrade_2012LB=NLB037K
	replace ChildRedoGrade_2012LB=0 if ChildRedoGrade_2012LB==5
	
keep HHID PN Child* 

save "$CleanData/HRS_LB_2012.dta", replace


/* Leave Behind from 2010  */
clear all
infile using "$HRSSurveys10/h10sta/H10LB_R.dct" , using("$HRSSurveys10/h10da/H10LB_R.da")


gen ChildRedoGrade_2010LB=MLB037K
	replace ChildRedoGrade_2010LB=0 if ChildRedoGrade_2010LB==5
	
keep HHID PN Child* 

save "$CleanData/HRS_LB_2010.dta", replace


/* Leave Behind from 2008  */
clear all
infile using "$HRSSurveys08/h08sta/H08LB_R.dct" , using("$HRSSurveys08/h08da/H08LB_R.da")

gen ChildRedoGrade_2008LB=LLB037K
	replace ChildRedoGrade_2008LB=0 if ChildRedoGrade_2008LB==5
	
	
keep HHID PN Child* 

save "$CleanData/HRS_LB_2008.dta", replace


/* Leave Behind from 2006  */
clear all
infile using "$HRSSurveys06/h06sta/H06LB_R.dct" , using("$HRSSurveys06/h06da/H06LB_R.da")


gen ChildRedoGrade_2006LB=KLB037H
	replace ChildRedoGrade_2006LB=0 if ChildRedoGrade_2006LB==5
	

keep HHID PN Child* 

save "$CleanData/HRS_LB_2006.dta", replace


/**************************************
***************************************
  Here we merge the Demographic Files
***************************************
***************************************/
clear all
use "$CleanData/HRS_LB_2006.dta"
merge 1:1 HHID PN using "$CleanData/HRS_LB_2008.dta", gen (MergeLB08)
merge 1:1 HHID PN using "$CleanData/HRS_LB_2010.dta", gen (MergeLB10)
merge 1:1 HHID PN using "$CleanData/HRS_LB_2012.dta", gen (MergeLB12)



gen ChildRedoGrade=ChildRedoGrade_2006LB


foreach YR in 2008 2010 2012{
   foreach VAR in ChildRedoGrade {
		replace `VAR'=`VAR'_`YR' if `VAR'==. & `VAR'_`YR'~=.
   }
}



keep HHID PN ChildRedoGrade


saveold "$CleanData/HRS_RedoGrade.dta", replace


clear all




