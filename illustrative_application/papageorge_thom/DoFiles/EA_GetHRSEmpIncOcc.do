*************************************
* Employment Panel / Income Totals
*************************************

* This file loops over the waves of the HRS employment file and creates, 
* for each wave, a data set with cleaned employment and income variables. 


/* Employment from 1992 */
clear all
infile using "$HRSSurveys92/h92sta/EMPLOYER.dct" , using("$HRSSurveys92/h92da/EMPLOYER.da")

* Get indicators for whether the respondent is currently  Working / Retired / HomeMaker, 
* which are recorded as binary variables from the F1A-F1F survey items. 
* In the data set, the variables V2701, V2705, and V2706 contain information on these three activities

gen Working_92=0
gen Retired_92=0
gen HomeMaker_92=0

replace Working_92=1   if V2701==1
replace Retired_92=1   if V2705==1
replace HomeMaker_92=1 if V2706==1

gen MonthRetired_92=V2715
gen YearRetired_92 =V2716

* WorkForPay - item F2, asks whether the individual is doing any work for pay
* at the present time.  This variable is almost identical to Working above, but
* there are some respodnents who are coded as "1" for WorkForPay, but "0" for 
* Working.  These are mostly individuals who are on sick leave, retired, etc. 
gen WorkForPay_92=V2717
	replace WorkForPay_92=0 if WorkForPay_92==5
	replace WorkForPay_92=0 if WorkForPay_92==2
	replace WorkForPay_92=. if WorkForPay_92>5
		
* Self Employed - item F3.  This item and future items ask about "current, main job"
* This item asks if individuals work for someone else or are self-employed / run own business	
gen SelfEmp_92=V2718
	replace SelfEmp=0 if SelfEmp==1
	replace SelfEmp=1 if SelfEmp==2
	replace SelfEmp=. if SelfEmp>2
	
* HoursPerWeek - item F8.  How many hours a week do you usually work on this job? (98 / 99 are DK / NA)
* Notice that HoursPerWeek is set to 0 for individuals who are self-employed.  We set 0 to missing here:
gen HoursPerWeek_92=V2722
	replace HoursPerWeek_92=. if HoursPerWeek_92>95 | HoursPerWeek_92==0
	
* WeeksPerYear - item F10.  How many weeks do you work per year, including paid vacations.  
* This is set to zero for self-employees.  We set 0 to missing. 
gen WeeksPerYear_92=V2726
		replace WeeksPerYear_92=. if WeeksPerYear_92>=97 | WeeksPerYear_92==0
		
* How Paid - item F16.  Are you salaried, paid by the hour, or what?  Vast majority
* of respondents answer 10 (salaried), or 20 (hourly).  This question is only asked 
* of individuals who are paid employees. 
gen HowPaidPE_92=V2734
		replace HowPaidPE_92=. if HowPaidPE_92>=97

	
***********************************
* Industry and Occupation
***********************************	
	
gen Job_Ind_92=V2719
replace Job_Ind_92=. if Job_Ind_92==0

/* F4.     What kind of business or industry do you work in --
                        that is, what do they make or do at the place where
                        you work?
                ____________________________________________________________

                [NOTE: These data have been masked for confidentiality.
                The values in parentheses indicate the original U.S. Census
                codes, as found in the Master Codes section of the
                codebook.]

                001.  Agriculture, Forestry, Fishing (010-031)
                002.  Mining and Construction (040-060)
                003.  Manufacturing: Non-durable (100-222)
                004.  Manufacturing: Durable (230-392)
                005.  Transportation (400-572)
                006.  Wholesale (500-571)
                007.  Retail (580-691)
                008.  Finance, Insurance, and Real Estate (700-712)
                009.  Business and Repair Services (721-760)
                010.  Personal Services (761-791)
                011.  Entertainment and Recreation (800-802)
                012.  Professional and Related Services (812-892)
                013.  Public Administration (900)  */
				
				
gen Job_Occ_92=V2720
replace Job_Occ_92=. if Job_Occ_92==0

 /* 2720    F5.     What is the official title of your job?  (The title
                        that your employer uses?)
                F6.     What sort of work do you do?  (Tell me a little more
                        about what you do.)
                ____________________________________________________________

                [NOTE: These data have been masked for confidentiality.
                The values in parentheses indicate the original U.S. Census
                codes, as found in the Master Codes section of the
                codebook.]

                001.  Managerial specialty operation (003-037)
                002.  Professional specialty operation and technical
                      support (043-235)
                003.  Sales (243-285)
                004.  Clerical, administrative support (303-389)
                005.  Service: private household, cleaning and building
                      services (403-407)
                006.  Service: protection (413-427)
                007.  Service: food preparation (433-444)
                008.  Health services (445-447)
                009.  Personal services (448-469)
                010.  Farming, forestry, fishing (473-499)
                011.  Mechanics and repair (503-549)
                012.  Construction trade and extractors (553-617)
                013.  Precision production (633-699)
                014.  Operators: machine (703-799)
                015.  Operators: transport, etc. (803-859)
                016.  Operators: handlers, etc. (863-889)
                017.  Member of Armed Forces (900)  */

gen SE_Job_Ind_92=V2820				
replace SE_Job_Ind_92=. if SE_Job_Ind_92==0

gen SE_Job_Occ_92=V2821
replace SE_Job_Occ_92=. if SE_Job_Occ_92==0	
	
	
********************************************************************************
* Workers could receive income either from salary, hourly wages, commission, or 
* other compensation schemes, and here we create separate earnings variables for 
* each kind of earnings flow.		
********************************************************************************		
		
*********************
* Salaried Workers
*********************		
		
* Salary - item F16a.  How much is your SALARY before taxes and other deductions.
* This will be zero for those who are paid hourly, and those who are self-employed.
* We set 0 equal to missings 	
gen Salary_92=V2735
		replace Salary_92=. if Salary_92>=9999998 | Salary_92==0

* PayPeriod - item F16a.  In the previous question, how often is the reported
* salary received:   
/* 						2.  Week
                        3.  Every 2 weeks
                        4.  Month
                        6.  Year
                        8.  Lump sum; one-time payment

                        9.  NA (incl. DK amount)	*/
gen PayPeriodSal_92=V2736
		replace PayPeriodSal_92=. if PayPeriodSal_92>=9
		
		
* Calculate Annual Salary based on responses, with different calculations
* for each pay period:		
gen AnnualInc_Salary_92=.
replace AnnualInc_Salary_92=WeeksPerYear_92*Salary_92     if PayPeriodSal_92==2
replace AnnualInc_Salary_92=(WeeksPerYear_92/2)*Salary_92 if PayPeriodSal_92==3		
replace AnnualInc_Salary_92=12*Salary_92                  if PayPeriodSal_92==4		
replace AnnualInc_Salary_92=Salary_92                     if PayPeriodSal_92==6



		
*********************
* Hourly Workers
*********************		
	
* Hourly Wage Rate - item F16d.  We set zeros equal to missing.
gen HourlyPay_92=V2739
		replace HourlyPay_92=. if HourlyPay_92>=99998 
		replace HourlyPay_92=. if HourlyPay_92==0 
		
gen AnnualInc_Hourly_92=HoursPerWeek_92*WeeksPerYear_92*HourlyPay_92


					
************************
* PIECEWORK/COMMISSION 	
************************

gen PieceworkPay_92=V2743	
	replace PieceworkPay_92=. if PieceworkPay_92>=9999998
	replace PieceworkPay_92=. if PieceworkPay_92==0
		
gen PayPeriodPW_92=V2744		
	replace PayPeriodPW_92=. if PayPeriodPW_92>=9
	replace PayPeriodPW_92=. if PayPeriodPW_92==0
		
/*
                        2.  Week
                        3.  Every 2 weeks
                        4.  Month
                        6.  Year

                        9.  NA (incl. DK amount)

                        0.  Inap, 5, 8-9 in V2717; 2, 8-9 in V2718;
                            10, 15-20, 26-29, 70-72, 96 in V2734
*/		

gen AnnualInc_Piecework_92=.
replace AnnualInc_Piecework_92=WeeksPerYear_92*PieceworkPay_92     if PayPeriodPW_92==2
replace AnnualInc_Piecework_92=(WeeksPerYear_92/2)*PieceworkPay_92 if PayPeriodPW_92==3
replace AnnualInc_Piecework_92=12*PieceworkPay_92                  if PayPeriodPW_92==4
replace AnnualInc_Piecework_92=PieceworkPay_92                     if PayPeriodPW_92==6		 
	
*****************************
* Other
*****************************

gen OtherPay_92=V2748
		replace OtherPay_92=. if OtherPay_92>=9999996
		replace OtherPay_92=. if OtherPay_92==0
		
gen PayPeriodOther_92=V2749
		replace PayPeriodOther_92=. if PayPeriodOther_92>=8
		replace PayPeriodOther_92=. if PayPeriodOther_92==0
		
/*
                        1.  Hourly
                        2.  Week
                        3.  Every 2 weeks
                        4.  Month
                        6.  Year

                        8.  Mile (distance)

                        9.  NA (incl. DK amount)

                        0.  Inap, 5, 8-9 in V2717; 2, 8-9 in V2718; 10, 14,
                            20-24 or 30-32 in V2734; X96 in V2748
*/	
	
gen AnnualInc_Other_92=.
	replace AnnualInc_Other_92=HoursPerWeek_92*WeeksPerYear_92*(OtherPay_92/100) if PayPeriodOther_92==1
	replace AnnualInc_Other_92=WeeksPerYear_92*OtherPay_92                       if PayPeriodOther_92==2
	replace AnnualInc_Other_92=(WeeksPerYear_92/2)*OtherPay_92                   if PayPeriodOther_92==3	
	replace AnnualInc_Other_92=12*OtherPay_92                                    if PayPeriodOther_92==4
	replace AnnualInc_Other_92=OtherPay_92                                       if PayPeriodOther_92==6		
	
*******************************
* Second Job 
*******************************

gen Job2_HoursPerWeek_92=V3332
	replace Job2_HoursPerWeek_92=. if Job2_HoursPerWeek_92>=96
	
gen Job2_WeeksPerYear_92=V3333
	replace Job2_WeeksPerYear_92=. if Job2_WeeksPerYear_92>=98
	
gen Job2Pay_92=V3334
    replace Job2Pay_92=. if Job2Pay_92>=9999995
	
gen PayPeriodJob2_92=V3335
	replace PayPeriodJob2_92=. if PayPeriodJob2_92>=9
	
/*
                        1.  Hour
                        2.  Week
                        3.  Every 2 weeks
                        4.  Month
                        6.  Year
                        8.  Lump sum; one-time payment

                        9.  NA (incl. DK amount)

                        0.  Inap, 5, 8-9 in V2717; 2, 5, 8-9 in V3327;
                            0 in V3334
*/	

gen AnnualInc_Job2=.
replace AnnualInc_Job2=Job2_HoursPerWeek_92*Job2_WeeksPerYear_92*(Job2Pay_92/100) if PayPeriodJob2_92==1
replace AnnualInc_Job2=Job2_WeeksPerYear_92*Job2Pay_92                            if PayPeriodJob2_92==2
replace AnnualInc_Job2=(Job2_WeeksPerYear_92/2)*Job2Pay_92                        if PayPeriodJob2_92==3
replace AnnualInc_Job2=12*Job2Pay_92                                              if PayPeriodJob2_92==4	
replace AnnualInc_Job2=Job2Pay_92                                                 if (PayPeriodJob2_92==6 | PayPeriodJob2_92==8)	
	
* Sum these income sources for paid employees, treating missings as zeros. 
egen AnnualInc_PE_92=rowtotal(AnnualInc_Salary_92 AnnualInc_Hourly_92 AnnualInc_Piecework_92 AnnualInc_Other_92 AnnualInc_Job2), missing

egen AnnualInc_PEJ1_92=rowtotal(AnnualInc_Salary_92 AnnualInc_Hourly_92 AnnualInc_Piecework_92 AnnualInc_Other_92), missing
	
***********************************************************
* Now, clean variables related to Self-Employment Income
***********************************************************
	
	
* Hours Per Week for Self Employees - item F28.  Codes 98/99 are DK/NA
gen HoursPerWeekSE_92=V2822
	replace HoursPerWeekSE_92=. if HoursPerWeekSE_92>95
	replace HoursPerWeekSE_92=. if HoursPerWeekSE_92==0

* Weeks Per Year for Self Employees - item F29	 Codes 98/99 are DK/NA
gen WeeksPerYearSE_92=V2823
		replace WeeksPerYearSE_92=. if WeeksPerYearSE_92>=97
		replace WeeksPerYearSE_92=. if WeeksPerYearSE_92==0

* Binary Variable indicating whether the self-employee gets a regular salary or
* wages for their work in the business - item F30.  1 Yes, 5 No, 8/9 DK/NA		
gen SelfEmp_BinaryForSalary92=V2824

	
* Salary Amount - Self Employees - item F30a	
gen SelfEmp_Salary92=V2825 	
	replace SelfEmp_Salary92=. if SelfEmp_Salary92>=9999998
	replace SelfEmp_Salary92=. if SelfEmp_Salary92==0
	
* Salary Pay Period - Self Employees - item F30a
gen SelfEmp_PayPeriod92=V2826
	replace SelfEmp_PayPeriod92=. if SelfEmp_PayPeriod92>=9

/*
                        1.  Hour
                        2.  Week
                        3.  Every 2 weeks
                        4.  Month
                        6.  Year

                        9.  NA (incl. DK amount)

                        0.  Inap, 5, 8-9 in V2717; 1 in V2718; 5, 8-9 in
                            V2824
*/							
	
* Construct Annual Salary for Self-Employees

gen AnnualSalSE_92=.
		replace AnnualSalSE=WeeksPerYearSE*HoursPerWeekSE*(SelfEmp_Salary/100)    if SelfEmp_PayPeriod==1
		replace AnnualSalSE=WeeksPerYearSE*SelfEmp_Salary                         if SelfEmp_PayPeriod==2
		replace AnnualSalSE=(WeeksPerYearSE/2)*SelfEmp_Salary                     if SelfEmp_PayPeriod==3
		replace AnnualSalSE=12*SelfEmp_Salary                                     if SelfEmp_PayPeriod==4
		replace AnnualSalSE=SelfEmp_Salary                                        if SelfEmp_PayPeriod==6	
	
	
	
* Binary Variable Indicating whether the self-employee gets profits from the business - item F31
gen SelfEmp_GetProfit92=V2827
	replace SelfEmp_GetProfit92=. if SelfEmp_GetProfit92>=7 

* Profit Amount - item F31a
gen SelfEmp_Profit92=V2828
	replace SelfEmp_Profit92=. if SelfEmp_Profit92>=9999995
	
gen SelfEmp_ProfitPeriod92=V2829 
	replace SelfEmp_ProfitPeriod92=. if SelfEmp_ProfitPeriod92>=9
	
/*
                        1.  Hour
                        2.  Week
                        3.  Every 2 weeks
                        4.  Month
                        5.  Quarter
                        6.  Year

                        9.  NA (incl. DK amount)

                        0.  Inap, 5, 8-9 in V2717; 1 in V2718; 5, 8-9
                            in V2827 */	

* Construct Annual Profit for Self-Employees:
		
gen AnnualProfSE_92=.
		replace AnnualProfSE_92=WeeksPerYearSE_92*HoursPerWeekSE*(SelfEmp_Profit92/100)  if SelfEmp_ProfitPeriod==1
		replace AnnualProfSE_92=WeeksPerYearSE_92*SelfEmp_Profit92                       if SelfEmp_ProfitPeriod==2
		replace AnnualProfSE_92=(WeeksPerYearSE_92/2)*SelfEmp_Profit92                   if SelfEmp_ProfitPeriod==3
		replace AnnualProfSE_92=12*SelfEmp_Profit92                                      if SelfEmp_ProfitPeriod==4
		replace AnnualProfSE_92=4*SelfEmp_Profit92                                       if SelfEmp_ProfitPeriod==5
		replace AnnualProfSE_92=SelfEmp_Profit92                                         if SelfEmp_ProfitPeriod==6
	

		
egen AnnualInc_SE_92=rowtotal(AnnualSalSE_92 AnnualProfSE_92), missing

egen AnnualIncTot_92=rowtotal(AnnualInc_PE_92 AnnualInc_SE_92), missing
		
		
keep HHID PN *SUBHH *FINR Working *Retired* HomeMaker WorkForPay SelfEmp_92 AnnualInc_PE_92 AnnualInc_PEJ1_92 AnnualInc_SE_92 AnnualIncTot_92 *Job_Ind* *Job_Occ* WeeksPerYear* *HoursPerWeek*

gen YEAR=1992

		
save "$CleanData/HRSEmpInc92.dta", replace


/* Employment from 1994 */
clear all
infile using "$HRSSurveys94/h94sta/W2FA.dct" , using("$HRSSurveys94/h94da/W2FA.da")

* Get indicators for whether the respondent is currently  Working / Retired / HomeMaker, 
* which are recorded as binary variables 

gen Working_94=0
gen Retired_94=0
gen HomeMaker_94=0

* These recorded in items FA1
forvalues QN=0(1)2{

replace Working_94=1   if W330`QN'==1
replace Retired_94=1   if W330`QN'==5
replace HomeMaker_94=1 if W330`QN'==6

}

gen MonthRetired_94=W3314
gen YearRetired_94=W3315

* WorkForPay - item FA2, asks whether the individual is doing any work for pay
* at the present time.  This variable is almost identical to Working above, but
* there are some respodnents who are coded as "1" for WorkForPay, but "0" for 
* Working.  These are mostly individuals who are on sick leave, retired, etc. 
gen WorkForPay_94=W3316
	replace WorkForPay_94=0 if WorkForPay_94==5
	replace WorkForPay_94=. if WorkForPay_94>5

		
* Self Employed - item FA3.  This item and future items ask about "current, main job"
* This item asks if individuals work for someone else or are self-employed / run own business
gen SelfEmp_94=W3317
	replace SelfEmp=. if SelfEmp>2 | SelfEmp==0
	replace SelfEmp=0 if SelfEmp==1
	replace SelfEmp=1 if SelfEmp==2
	
	
* Hours Per Week (Paid Employees) - FA44	
gen HoursPerWeek_94=W3617
	replace HoursPerWeek_94=. if HoursPerWeek_94>95 | HoursPerWeek_94==0
	
* Weeks Per Year (Paid Employees) - FA47	
gen WeeksPerYear_94=W3623
		replace WeeksPerYear_94=. if WeeksPerYear_94>52 | WeeksPerYear_94==0
		
* How Paid - FA52, 	
gen HowPaidPE_94=W3631
		replace HowPaidPE_94=. if HowPaidPE_94>=8 | HowPaidPE_94==0

/*
        W3631   FA52.   Are you salaried on this job, paid by the hour, or
                        what?
                ____________________________________________________________

                        1.      Salaried
                        2.      Hourly [GO TO FA52f]
                        3.      Piecework/Commission [GO TO FA52m]

                        7.      Other/Combination [GO TO FA52q]
                        8.      Don't Know; DK [GO TO FA52r]
                        9.      Refused; RF [GO TO FA52r]

                        0.      Inap. */		
		
********************************************************************************
* Workers could receive income either from salary, hourly wages, commission, or 
* other compensation schemes, and here we create separate earnings variables for 
* each kind of earnings flow.		
********************************************************************************		
				
				
				
gen Job_Ind_94=W3608
replace Job_Ind_94=. if Job_Ind_94==0

gen Job_Occ_94=W3609
replace Job_Occ_94=. if Job_Occ_94==0
		
		
*********************
* Salaried Workers
*********************		
		
* Salary Pay - FA52a	
gen Salary_94=W3632
		replace Salary_94=. if Salary_94>=9999997 | Salary_94==0

* Pay Period for Salary - FA52b		
gen PayPeriodSal_94=W3633
		replace PayPeriodSal_94=. if PayPeriodSal_94>=97
	
/*	
        W3633   FA52b.  Is that per hour, week, month, or year?

                        [NOTE: PROBE IF NECESSARY]
                ____________________________________________________________

                        AMOUNT GIVEN IN FA52a PER

                        1.      Hour
                        2.      Week
                        3.      Every two weeks/Bi-weekly
                        4.      Month
                        5.      Twice a month
                        6.      Year
                        11.     Day

                        97.     Other (Specify)
                        98.     Don't Know; DK
                        99.     Refused; RF

                        0.      Inap. */
	
* Calculate Annual Salary based on responses, with different calculations
* for each pay period:		
gen AnnualInc_Salary_94=.
replace AnnualInc_Salary_94=HoursPerWeek_94*WeeksPerYear_94*Salary_94     if PayPeriodSal_94==1
replace AnnualInc_Salary_94=WeeksPerYear_94*Salary_94                     if PayPeriodSal_94==2
replace AnnualInc_Salary_94=(WeeksPerYear_94/2)*Salary_94                 if PayPeriodSal_94==3		
replace AnnualInc_Salary_94=12*Salary_94                                  if PayPeriodSal_94==4
replace AnnualInc_Salary_94=24*Salary_94                                  if PayPeriodSal_94==5		
replace AnnualInc_Salary_94=Salary_94                                     if PayPeriodSal_94==6	
replace AnnualInc_Salary_94=5*WeeksPerYear_94*Salary_94                   if PayPeriodSal_94==11	
	
*********************
* Hourly Workers
*********************	
	
* Hourly Wage Rate for Hourly Workers: FA52f.  We set zeros equal to missing - also set some 	
gen HourlyPay_94=W3637
		replace HourlyPay_94=. if HourlyPay_94>=9994
		replace HourlyPay_94=. if HourlyPay_94==0 
		
gen AnnualInc_Hourly_94=HoursPerWeek_94*WeeksPerYear_94*HourlyPay_94		
	
	
************************
* PIECEWORK/COMMISSION 	
************************

gen PieceworkPay_94=W3642	
	replace PieceworkPay_94=. if PieceworkPay_94>=9999997
	replace PieceworkPay_94=. if PieceworkPay_94==0
		
gen PayPeriodPW_94=W3643		
	replace PayPeriodPW_94=. if PayPeriodPW_94>=7
	replace PayPeriodPW_94=. if PayPeriodPW_94==0	

/*
        W3643   FA52n.  Was that per week or month?
                        [NOTE: PROBE IF NECESSARY]
                ____________________________________________________________

                        AMOUNT GIVEN IN FA52m PER

                        1.      Hour
                        2.      Week
                        3.      Every two weeks/Bi-weekly
                        4.      Month
                        6.      Year

                        7.      Other (Specify)
                        8.      Don't Know; DK
                        9.      Refused; RF
*/	
	
	
gen AnnualInc_Piecework_94=.
replace AnnualInc_Piecework_94=HoursPerWeek_94*WeeksPerYear_94*PieceworkPay_94     if PayPeriodPW_94==1
replace AnnualInc_Piecework_94=WeeksPerYear_94*PieceworkPay_94                     if PayPeriodPW_94==2
replace AnnualInc_Piecework_94=(WeeksPerYear_94/2)*PieceworkPay_94                 if PayPeriodPW_94==3
replace AnnualInc_Piecework_94=12*PieceworkPay_94                                  if PayPeriodPW_94==4
replace AnnualInc_Piecework_94=PieceworkPay_94                                     if PayPeriodPW_94==6		
	
	
*****************************
* Other
*****************************	
	
gen OtherPay_94=W3645
		replace OtherPay_94=. if OtherPay_94>=9999997
		replace OtherPay_94=. if OtherPay_94==0
		
gen PayPeriodOther_94=W3646
		replace PayPeriodOther_94=. if PayPeriodOther_94>11
		replace PayPeriodOther_94=. if PayPeriodOther_94==0	
	
/*
                        AMOUNT GIVEN IN FA52r PER

                        1.      Hour
                        2.      Week
                        3.      Every two weeks/Bi-weekly
                        4.      Month
                        5.      Twice a month
                        6.      Year
                        11.     Day

                        97.     Other (Specify)
                        98.     Don't Know; DK
                        99.     Refused; RF
*/	
	
gen AnnualInc_Other_94=.
	replace AnnualInc_Other_94=HoursPerWeek_94*WeeksPerYear_94*(OtherPay_94)     if PayPeriodOther_94==1
	replace AnnualInc_Other_94=WeeksPerYear_94*OtherPay_94                       if PayPeriodOther_94==2
	replace AnnualInc_Other_94=(WeeksPerYear_94/2)*OtherPay_94                   if PayPeriodOther_94==3	
	replace AnnualInc_Other_94=12*OtherPay_94                                    if PayPeriodOther_94==4
	replace AnnualInc_Other_94=24*OtherPay_94                                    if PayPeriodOther_94==5
	replace AnnualInc_Other_94=OtherPay_94                                       if PayPeriodOther_94==6		
	replace AnnualInc_Other_94=5*WeeksPerYear_94*OtherPay_94                     if PayPeriodOther_94==11
	

*************************************************
* Indicator for Same Job Title as Previous Wave:	
*************************************************

	/*	
	
        W3458   FA19a.  According to our records, you were employed in
                        WAVE-1 MONTH/YEAR. Are you still working for that
                        same employer?

                FA19b.  According to our records, in WAVE-1 MONTH/YEAR you
                        were working for WAVE-1 EMPLOYER NAME. Are you still
                        working there?
                ____________________________________________________________

                        1.      Yes
                        5.      No [GO TO FA26]
                        7.      Denies working for Wave I employer
                                [GO TO FA39]	
	
        W3502   FA21.   In WAVE-1 MONTH/YEAR our records indicate that your
                        job title was JOB TITLE GIVEN AT WAVE 1. Is this
                        still the case?
                ____________________________________________________________

                        1.      Yes [GO TO FA44]
                        5.      No [GO TO FA41b]
                        7.      Denies having this job title at Wave I
                                [GO TO FA41b]

                        8.      Don't Know; DK [GO TO FA41b]
                        9.      Refused; RF [GO TO FA41b]		*/
						

gen SameEmp_94=W3458
gen SameJob_94=W3502		
	
	
*******************************
* Second Job 
*******************************

gen Job2_HoursPerWeek_94=W3961
	replace Job2_HoursPerWeek_94=. if Job2_HoursPerWeek_94>96
	
gen Job2_WeeksPerYear_94=W3962
	replace Job2_WeeksPerYear_94=. if Job2_WeeksPerYear_94>52
	
gen Job2Pay_94=W3963
    replace Job2Pay_94=. if Job2Pay_94>=9999994
	* Note - 9999994 is technically not a missing code, but one indivdual claims to 
	* be paid 10 million dollars per hour and work hourly so we drop them
	
gen PayPeriodJob2_94=W3964
	replace PayPeriodJob2_94=. if PayPeriodJob2_94>11
	replace PayPeriodJob2_94=. if PayPeriodJob2_94==0
	
/*
                        AMOUNT GIVEN IN FA PER

                        1.      Hour
                        2.      Week
                        3.      Every two weeks/Bi-weekly
                        4.      Month
                        5.      Twice a month
                        6.      Year
                        11.     Day

                        97.     Other (Specify)
                        98.     Don't Know; DK
                        99.     Refused; RF

*/	

gen AnnualInc_Job2_94=.
replace AnnualInc_Job2=Job2_HoursPerWeek_94*Job2_WeeksPerYear_94*(Job2Pay_94)     if PayPeriodJob2_94==1
replace AnnualInc_Job2=Job2_WeeksPerYear_94*Job2Pay_94                            if PayPeriodJob2_94==2
replace AnnualInc_Job2=(Job2_WeeksPerYear_94/2)*Job2Pay_94                        if PayPeriodJob2_94==3
replace AnnualInc_Job2=12*Job2Pay_94                                              if PayPeriodJob2_94==4
replace AnnualInc_Job2=24*Job2Pay_94                                              if PayPeriodJob2_94==5	
replace AnnualInc_Job2=Job2Pay_94                                                 if PayPeriodJob2_94==6
replace AnnualInc_Job2=5*Job2_WeeksPerYear_94*Job2Pay_94                          if PayPeriodJob2_94==11
	
* Sum these income sources for paid employees, treating missings as zeros. 
egen AnnualInc_PE_94=rowtotal(AnnualInc_Salary_94 AnnualInc_Hourly_94 AnnualInc_Piecework_94 AnnualInc_Other_94 AnnualInc_Job2_94), missing

egen AnnualInc_PEJ1_94=rowtotal(AnnualInc_Salary_94 AnnualInc_Hourly_94 AnnualInc_Piecework_94 AnnualInc_Other_94), missing

gen YEAR=1994

		
save "$CleanData/HRSEmpInc94_Part1.dta", replace		

clear all   
		   
* Now load the data on Self Employees:

infile using "$HRSSurveys94/h94sta/W2FB.dct" , using("$HRSSurveys94/h94da/W2FB.da")		   

* Hours Per Week - Self Employees - FB17
gen HoursPerWeekSE_94=W4313
	replace HoursPerWeekSE_94=. if HoursPerWeekSE_94>95 

* Weeks Per Year - Self Employees - FB18	
gen WeeksPerYearSE_94=W4314
		replace WeeksPerYearSE_94=. if WeeksPerYearSE_94>52


* Binary Indicating whether they receive a salary from this business: FB19		
gen SelfEmp_RegSalary94=W4317
	replace SelfEmp_RegSalary94=. if SelfEmp_RegSalary94>5 | SelfEmp_RegSalary94==0
	replace SelfEmp_RegSalary94=0 if SelfEmp_RegSalary94==5
	
* Salary Amount - Self Employees - FB19a	
gen SelfEmp_Salary94= W4318	
	replace SelfEmp_Salary94=. if SelfEmp_Salary94>=9999997
	replace SelfEmp_Salary94=. if SelfEmp_Salary94==0
	
* Salary Pay Period - Self Employees - FB19b	
gen SelfEmp_PayPeriod94=W4319
	replace SelfEmp_PayPeriod94=. if SelfEmp_PayPeriod94>=97 | SelfEmp_PayPeriod94==0

/*
                        AMOUNT GIVEN IN FB19a PER

                        1.      Hour
                        2.      Week
                        3.      Every two weeks/Bi-weekly
                        4.      Month
                        5.      Twice a month
                        6.      Year
                        11.     Day

                        97.     Other (Specify)
                        98.     Don't Know; DK
                        99.     Refused; RF

                        0.      Inap. */	
	
	
* Construct Annual Salary for Self-Employees

gen AnnualSalSE_94=.
		replace AnnualSalSE=WeeksPerYearSE*HoursPerWeekSE*(SelfEmp_Salary)        if SelfEmp_PayPeriod==1
		replace AnnualSalSE=WeeksPerYearSE*SelfEmp_Salary                         if SelfEmp_PayPeriod==2
		replace AnnualSalSE=(WeeksPerYearSE/2)*SelfEmp_Salary                     if SelfEmp_PayPeriod==3
		replace AnnualSalSE=12*SelfEmp_Salary                                     if SelfEmp_PayPeriod==4
		replace AnnualSalSE=24*SelfEmp_Salary                                     if SelfEmp_PayPeriod==5
		replace AnnualSalSE=SelfEmp_Salary                                        if SelfEmp_PayPeriod==6
		replace AnnualSalSE=5*WeeksPerYearSE*SelfEmp_Salary                       if SelfEmp_PayPeriod==11
	
	
* Binary Variable Indicating whether the self-employee gets profits from the business FB20
gen SelfEmp_GetProfit94=W4320
	replace SelfEmp_GetProfit94=. if SelfEmp_GetProfit94>=8 | SelfEmp_GetProfit94==0

* Profit Amount - FB20a	
gen SelfEmp_Profit94=W4321
	replace SelfEmp_Profit94=. if SelfEmp_Profit94>=9999940
	* Note, 9999940 is technically a valid code, but this response is given by one respondent, and 
	* it appears to be a mistake in a special code (e.g. the top code is 9999994)
	
gen SelfEmp_ProfitPeriod94=W4322 
	replace SelfEmp_ProfitPeriod94=. if SelfEmp_ProfitPeriod94>=97 | SelfEmp_ProfitPeriod94==0
	
/*
                        AMOUNT GIVEN IN FB20a PER

                        1.      Hour
                        2.      Week
                        3.      Every two weeks/Bi-weekly
                        4.      Month
                        5.      Twice a month
                        6.      Year

                        97.     Other (Specify)
                        98.     Don't Know; DK
                        99.     Refused; RF */
						
		
gen AnnualProfSE_94=.
		replace AnnualProfSE_94=WeeksPerYearSE_94*HoursPerWeekSE*SelfEmp_Profit94  if SelfEmp_ProfitPeriod==1
		replace AnnualProfSE_94=WeeksPerYearSE_94*SelfEmp_Profit94                 if SelfEmp_ProfitPeriod==2
		replace AnnualProfSE_94=(WeeksPerYearSE_94/2)*SelfEmp_Profit94             if SelfEmp_ProfitPeriod==3
		replace AnnualProfSE_94=12*SelfEmp_Profit94                                if SelfEmp_ProfitPeriod==4
		replace AnnualProfSE_94=24*SelfEmp_Profit94                                if SelfEmp_ProfitPeriod==5
		replace AnnualProfSE_94=SelfEmp_Profit94                                   if SelfEmp_ProfitPeriod==6
	


egen AnnualInc_SE_94=rowtotal(AnnualSalSE_94 AnnualProfSE_94), missing
	

gen SE_Job_Ind_94=W4312A
replace SE_Job_Ind_94=. if SE_Job_Ind_94==0

gen SE_Job_Occ_94= W4312B
replace SE_Job_Occ_94=. if SE_Job_Occ_94==0	
	

keep HHID PN AnnualProfSE AnnualSalSE AnnualInc_SE_94 HoursPerWeekSE WeeksPerYearSE SE_Job_Ind* SE_Job_Occ*

save "$CleanData/HRSEmpInc94_Part2.dta", replace

clear all

use "$CleanData/HRSEmpInc94_Part1.dta"

merge 1:1 HHID PN using "$CleanData/HRSEmpInc94_Part2", gen(TempMerge)

egen AnnualIncTot_94=rowtotal(AnnualInc_PE_94 AnnualInc_SE_94), missing


	
keep HHID PN *SUBHH *FINR Working *Retired* HomeMaker WorkForPay SelfEmp_94 AnnualInc_PE_94 AnnualInc_PEJ1_94 AnnualInc_SE_94 AnnualIncTot_94 *Same*Emp* *SameJob* *Job_Ind* *Job_Occ* WeeksPerYear* *HoursPerWeek*

gen YEAR=1994

		
save "$CleanData/HRSEmpInc94.dta", replace



/* Employment from 1996 - New Format */
clear all
infile using "$HRSSurveys96/h96sta/H96G_R.dct" , using("$HRSSurveys96/h96da/H96G_R.da")

* Get indicators for whether the respondent is currently  Working / Retired / HomeMaker, 
* which are recorded as binary variables from the F1A-F1F survey items. 
* In the data set, the variables V2701, V2705, and V2706 contain information on these three activities

gen Working_96=0
gen Retired_96=0
gen HomeMaker_96=0

forvalues QN=1(1)3{

replace Working_96=1   if E2611M`QN'==1
replace Retired_96=1   if E2611M`QN'==5
replace HomeMaker_96=1 if E2611M`QN'==6

}

gen MonthRetired_96=E2622
gen YearRetired_96=E2623


* WorkForPay - item G2, asks whether the individual is doing any work for pay
* at the present time.  This variable is almost identical to Working above, but
* there are some respodnents who are coded as "1" for WorkForPay, but "0" for 
* Working.  These are mostly individuals who are on sick leave, retired, etc. 

gen WorkForPay_96=E2627
	replace WorkForPay_96=0 if WorkForPay_96==5
	replace WorkForPay_96=. if WorkForPay_96>5

* Self Employed - item G3.  This item and future items ask about "current, main job"
* This item asks if individuals work for someone else or are self-employed / run own business	
	
gen SelfEmp_96=E2628
	replace SelfEmp=0 if SelfEmp==1
	replace SelfEmp=1 if SelfEmp==2
	replace SelfEmp=. if SelfEmp>2
	
* HoursPerWeek - item G44.  How many hours a week do you usually work on this job? (98 / 99 are DK / NA)
* Notice that HoursPerWeek is set to 0 for individuals who are self-employed.  We set 0 to missing here:

gen HoursPerWeek_96=E2736
	replace HoursPerWeek_96=. if HoursPerWeek_96>95
	
* WeeksPerYear - item G47.  How many weeks do you work per year, including paid vacations.  
* This is set to zero for self-employees.  We set 0 to missing.

gen WeeksPerYear_96=E2746
		replace WeeksPerYear_96=. if WeeksPerYear_96>52
	
* How Paid - item G56.  Are you salaried, paid by the hour, or what?  
/*           1784         1. SALARIED
           2788         2. HOURLY
            120         3. PIECEWORK/COMMISSION
            211         7. OTHER/COMBINATION
              8         8. DK (don't know); NA (not ascertained)
              4         9. RF (refused) */
			  
gen HowPaidPE_96=E2772
		replace HowPaidPE_96=. if HowPaidPE_96>=8

********************************************************************************
* Workers could receive income either from salary, hourly wages, commission, or 
* other compensation schemes, and here we create separate earnings variables for 
* each kind of earnings flow.		
********************************************************************************		
		
*********************
* Salaried Workers
*********************			
		
* Salary - item G56a.  How much is your SALARY before taxes and other deductions.
* This will be zero for those who are paid hourly, and those who are self-employed.
* We set 0 equal to missings 		
		
gen Salary_96=E2774
		replace Salary_96=. if Salary_96>=9999997
		replace Salary_96=. if Salary_96==0

gen PayPeriodSal_96=E2775
		replace PayPeriodSal_96=. if PayPeriodSal_96>=97
		
* PayPeriod - item F16a.  In the previous question, how often is the reported
* salary received: 		
/*
          ................................................................................
             30         1. HOUR
            208         2. WEEK
             73         3. EVERY TWO WEEKS/BI-WEEKLY
            222         4. MONTH
           1084         6. YEAR
              7        11. Day
                       97. OTHER (SPECIFY); Including per job; mile; session; class;
                           piecework etc.
                       98. DK (don't know); NA (not ascertained)
                       99. RF (refused)
					   */

* Calculate Annual Salary based on responses, with different calculations
* for each pay period:		
gen AnnualInc_Salary_96=.
replace AnnualInc_Salary_96=HoursPerWeek_96*WeeksPerYear_96*Salary_96     if PayPeriodSal_96==1
replace AnnualInc_Salary_96=WeeksPerYear_96*Salary_96                     if PayPeriodSal_96==2
replace AnnualInc_Salary_96=(WeeksPerYear_96/2)*Salary_96                 if PayPeriodSal_96==3		
replace AnnualInc_Salary_96=12*Salary_96                                  if PayPeriodSal_96==4
replace AnnualInc_Salary_96=Salary_96                                     if PayPeriodSal_96==6	
replace AnnualInc_Salary_96=5*WeeksPerYear_96*Salary_96                   if PayPeriodSal_96==11	
						   

*********************
* Hourly Workers
*********************						   
	* Hourly Wage Rate - item F16d.  We set zeros equal to missing.
gen HourlyPay_96=E2781
		replace HourlyPay_96=. if HourlyPay_96>=15000
		replace HourlyPay_96=. if HourlyPay_96==0
				
gen AnnualInc_Hourly_96=HoursPerWeek_96*WeeksPerYear_96*HourlyPay_96
				
				
************************
* PIECEWORK/COMMISSION 	
************************		
	
gen PieceworkPay_96=E2791	
	replace PieceworkPay_96=. if PieceworkPay_96>=9999997
	replace PieceworkPay_96=. if PieceworkPay_96==0
		
gen PayPeriodPW_96=E2792		
	replace PayPeriodPW_96=. if PayPeriodPW_96>11
	replace PayPeriodPW_96=. if PayPeriodPW_96==0	
	
/*
              3         1. HOUR
             39         2. WEEK
              2         3. EVERY TWO WEEKS/BI-WEEKLY
             41         4. MONTH
             17         6. YEAR
              1        11. Day
              1        97. OTHER (SPECIFY); Including per job; mile; session; class;
                           piecework etc.
              7        98. DK (don't know); NA (not ascertained)
                       99. RF (refused) */
					   
gen AnnualInc_Piecework_96=.
replace AnnualInc_Piecework_96=HoursPerWeek_96*WeeksPerYear_96*PieceworkPay_96     if PayPeriodPW_96==1
replace AnnualInc_Piecework_96=WeeksPerYear_96*PieceworkPay_96                     if PayPeriodPW_96==2
replace AnnualInc_Piecework_96=(WeeksPerYear_96/2)*PieceworkPay_96                 if PayPeriodPW_96==3
replace AnnualInc_Piecework_96=12*PieceworkPay_96                                  if PayPeriodPW_96==4
replace AnnualInc_Piecework_96=PieceworkPay_96                                     if PayPeriodPW_96==6		
replace AnnualInc_Piecework_96=5*WeeksPerYear_96*PieceworkPay_96                   if PayPeriodPW_96==11
		
*****************************
* Other
*****************************

gen OtherPay_96=E2796
		replace OtherPay_96=. if OtherPay_96>=9999996
		replace OtherPay_96=. if OtherPay_96==0
		
gen PayPeriodOther_96=E2797
		replace PayPeriodOther_96=. if PayPeriodOther_96>11
		replace PayPeriodOther_96=. if PayPeriodOther_96==0	
	
	
/*           16         1. HOUR
             36         2. WEEK
              8         3. EVERY TWO WEEKS/BI-WEEKLY
             25         4. MONTH
             59         6. YEAR
             25        11. Day
             14        97. OTHER (SPECIFY); Including per job; mile; session; class;
                           piecework etc.
              3        98. DK (don't know); NA (not ascertained)
                       99. RF (refused)	 */
	
gen AnnualInc_Other_96=.
	replace AnnualInc_Other_96=HoursPerWeek_96*WeeksPerYear_96*(OtherPay_96)     if PayPeriodOther_96==1
	replace AnnualInc_Other_96=WeeksPerYear_96*OtherPay_96                       if PayPeriodOther_96==2
	replace AnnualInc_Other_96=(WeeksPerYear_96/2)*OtherPay_96                   if PayPeriodOther_96==3	
	replace AnnualInc_Other_96=12*OtherPay_96                                    if PayPeriodOther_96==4
	replace AnnualInc_Other_96=OtherPay_96                                       if PayPeriodOther_96==6		
	replace AnnualInc_Other_96=5*WeeksPerYear_96*OtherPay_96 	                 if PayPeriodOther_96==11
	

*************************************************
* Indicator for Same Job Title as Previous Wave:	
*************************************************	
	
/* 
E2654     G19A.STILL WORKNG FOR PREV WAVE EMPLOYER  
          Section: G            Level: Respondent      CAI Reference: Q2654
          Type: Numeric         Width: 1               Decimals: 0

          G19a. According to our records, you were employed in [Q95-PREV WAVE IW
          MONTH][Q96-PREV WAVE IW YEAR]. Are you still working for that same employer?
          ................................................................................
                        1. YES
                        5. NO
                        7. DENIES WORKING AT PREVIOUS IW
                        8. DK (don't know); NA (not ascertained)
                        9. RF (refused)

E2662     G21.SAME JOB TITLE AS PREVIOUS WAVE       
          Section: G            Level: Respondent      CAI Reference: Q2662
          Type: Numeric         Width: 1               Decimals: 0

          G21. In [Q95-PREV WAVE IW MONTH][Q96-PREV WAVE IW YEAR] our records indicate
          that your job title was [Q168.PREV WAVE JOB TITLE] Is this still the case?

          INTERVIEWER: IF JOB TITLE IS SLIGHTLY INACCURATE BUT DOES DESCRIBE R'S
          CURRENT JOB, ANSWER "YES" HERE AND NOTE CORRECTIONS AS A COMMENT.
          ................................................................................
           3319         1. YES
            359         5. NO
              4         7. DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE
                        8. DK (don't know); NA (not ascertained)
                        9. RF (refused)	*/
	
gen SameEmp_96=E2655
gen SameJob_96=E2662
		 /*            
		   3319         1. YES
            359         5. NO
              4         7. DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE  */ 
gen SameJobTBranch_96=E2750
	     /*E2750     G49_.BRANCHPOINT                          
          Section: G            Level: Respondent      CAI Reference: Q2750
          Type: Numeric         Width: 1               Decimals: 0
          ................................................................................
           3319         1. SAME EMPLOYER AND JOB TITLE AS PREV WAVE: GO TO G56
           1266         2. SELF EMPLOYED: GO TO G52
           1596         3. OTHERWISE: GO TO G49  */


gen Job_Ind_96=E2730M
gen Job_Occ_96=E2732M
	
*******************************
* Second Job 
*******************************

gen Job2_HoursPerWeek_96=E3021
	replace Job2_HoursPerWeek_96=. if Job2_HoursPerWeek_96>96
	
gen Job2_WeeksPerYear_96=E3022
	replace Job2_WeeksPerYear_96=. if Job2_WeeksPerYear_96>52
	
gen Job2Pay_96=E3023
    replace Job2Pay_96=. if Job2Pay_96>=9999997

	
gen PayPeriodJob2_96=E3024
	replace PayPeriodJob2_96=. if PayPeriodJob2_96>11
	replace PayPeriodJob2_96=. if PayPeriodJob2_96==0
	
/*
E3024     G131A.PER                                 
          Section: G            Level: Respondent      CAI Reference: Q3024
          Type: Numeric         Width: 2               Decimals: 0
          ................................................................................
            107         1. HOUR
             66         2. WEEK
              9         3. EVERY TWO WEEKS/BI-WEEKLY
             51         4. MONTH
            277         6. YEAR
             19        97. OTHER (SPECIFY)
                       98. DK (don't know); NA (not ascertained)
                       99. RF (refused) */
					   
	
gen AnnualInc_Job2_96=.
replace AnnualInc_Job2=Job2_HoursPerWeek_96*Job2_WeeksPerYear_96*(Job2Pay_96)     if PayPeriodJob2_96==1
replace AnnualInc_Job2=Job2_WeeksPerYear_96*Job2Pay_96                            if PayPeriodJob2_96==2
replace AnnualInc_Job2=(Job2_WeeksPerYear_96/2)*Job2Pay_96                        if PayPeriodJob2_96==3
replace AnnualInc_Job2=12*Job2Pay_96                                              if PayPeriodJob2_96==4
replace AnnualInc_Job2=Job2Pay_96                                                 if PayPeriodJob2_96==6
replace AnnualInc_Job2=5*Job2_WeeksPerYear_96*Job2Pay_96                          if PayPeriodJob2_96==11
		
* Sum these income sources for paid employees, treating missings as zeros. 
egen AnnualInc_PE_96=rowtotal(AnnualInc_Salary_96 AnnualInc_Hourly_96 AnnualInc_Piecework_96 AnnualInc_Other_96 AnnualInc_Job2_96), missing

egen AnnualInc_PEJ1_96=rowtotal(AnnualInc_Salary_96 AnnualInc_Hourly_96 AnnualInc_Piecework_96 AnnualInc_Other_96), missing
	
**************************
* Self Employees
**************************	
	
	
* Hours Per Week - Self Employees - (Same as for Paid Employees from this wave on *
* Weeks Per Year - Self Employees - (Same as for Paid Employees from this wave on *
gen HoursPerWeekSE_96=.
replace HoursPerWeekSE_96=HoursPerWeek_96 if SelfEmp==1

gen WeeksPerYearSE_96=.
replace WeeksPerYearSE_96=WeeksPerYear_96 if SelfEmp==1


* Binary Indicating whether they receive a salary from this business: G52		
gen SelfEmp_RegSalary96=E2756
	replace SelfEmp_RegSalary96=. if SelfEmp_RegSalary96>5 | SelfEmp_RegSalary96==0
	replace SelfEmp_RegSalary96=0 if SelfEmp_RegSalary96==5
	
* Salary Amount - Self Employees - G52A	
gen SelfEmp_Salary96= E2757	
	replace SelfEmp_Salary96=. if SelfEmp_Salary96>=9999997
	replace SelfEmp_Salary96=. if SelfEmp_Salary96==0
	
* Salary Pay Period - Self Employees - G52B	
gen SelfEmp_PayPeriod96=E2758
	replace SelfEmp_PayPeriod96=. if SelfEmp_PayPeriod96>11 | SelfEmp_PayPeriod96==0

/*
E2758     G52B.SELF-EMPLOYMENT SALARY-PER           
          Section: G            Level: Respondent      CAI Reference: Q2758
          Type: Numeric         Width: 2               Decimals: 0
          ................................................................................
             56         1. HOUR
            111         2. WEEK
              6         3. EVERY TWO WEEKS/BI-WEEKLY
             85         4. MONTH
            127         6. YEAR
              6        11. Day
              4        97. OTHER (SPECIFY); Including per job; mile; session; class;
                           piecework etc.
              1        98. DK (don't know); NA (not ascertained)
              1        99. RF (refused) */	
	
	
* Construct Annual Salary for Self-Employees

gen AnnualSalSE_96=.
		replace AnnualSalSE=WeeksPerYearSE*HoursPerWeekSE*(SelfEmp_Salary)        if SelfEmp_PayPeriod==1
		replace AnnualSalSE=WeeksPerYearSE*SelfEmp_Salary                         if SelfEmp_PayPeriod==2
		replace AnnualSalSE=(WeeksPerYearSE/2)*SelfEmp_Salary                     if SelfEmp_PayPeriod==3
		replace AnnualSalSE=12*SelfEmp_Salary                                     if SelfEmp_PayPeriod==4
		replace AnnualSalSE=SelfEmp_Salary                                        if SelfEmp_PayPeriod==6
		replace AnnualSalSE=5*WeeksPerYearSE*SelfEmp_Salary                       if SelfEmp_PayPeriod==11
	
	
* Binary Variable Indicating whether the self-employee gets profits from the business G53
gen SelfEmp_GetProfit96=E2760
	replace SelfEmp_GetProfit96=. if SelfEmp_GetProfit96>5 | SelfEmp_GetProfit96==0

* Profit Amount - G53A
gen SelfEmp_Profit96=E2761
	replace SelfEmp_Profit96=. if SelfEmp_Profit96>=9999997
	* Note, 9999940 is technically a valid code, but this response is given by one respondent, and 
	* it appears to be a mistake in a special code (e.g. the top code is 9999994)
	
gen SelfEmp_ProfitPeriod96=E2762 
	replace SelfEmp_ProfitPeriod96=. if SelfEmp_ProfitPeriod96>11 | SelfEmp_ProfitPeriod96==0
	
/*
E2762     G53B.NET EARNINGS/PROFITS-PER             
          Section: G            Level: Respondent      CAI Reference: Q2762
          Type: Numeric         Width: 2               Decimals: 0
          ................................................................................
             13         1. HOUR
             17         2. WEEK
              1         3. EVERY TWO WEEKS/BI-WEEKLY
             30         4. MONTH
            633         6. YEAR
              1        11. Day
              8        97. OTHER (SPECIFY); Including per job; mile; session; class;
                           piecework etc.
              2        98. DK (don't know); NA (not ascertained)
                       99. RF (refused)*/
						
		
gen AnnualProfSE_96=.
		replace AnnualProfSE_96=WeeksPerYearSE_96*HoursPerWeekSE*SelfEmp_Profit96  if SelfEmp_ProfitPeriod==1
		replace AnnualProfSE_96=WeeksPerYearSE_96*SelfEmp_Profit96                 if SelfEmp_ProfitPeriod==2
		replace AnnualProfSE_96=(WeeksPerYearSE_96/2)*SelfEmp_Profit96             if SelfEmp_ProfitPeriod==3
		replace AnnualProfSE_96=12*SelfEmp_Profit96                                if SelfEmp_ProfitPeriod==4
		replace AnnualProfSE_96=SelfEmp_Profit96                                   if SelfEmp_ProfitPeriod==6
		replace AnnualProfSE_96=5*WeeksPerYearSE_96*SelfEmp_Profit96               if SelfEmp_ProfitPeriod==11
	


egen AnnualInc_SE_96=rowtotal(AnnualSalSE_96 AnnualProfSE_96), missing
	

egen AnnualIncTot_96=rowtotal(AnnualInc_PE_96 AnnualInc_SE_96), missing

	
keep HHID PN *SUBHH *FINR Working *Retired* HomeMaker WorkForPay SelfEmp_96 AnnualInc_PE_ AnnualInc_PEJ1_ AnnualInc_SE_ AnnualIncTot_ *Same*Emp* *SameJob* *Job_Ind* *Job_Occ* WeeksPerYear* *HoursPerWeek*

gen YEAR=1996

		
save "$CleanData/HRSEmpInc96.dta", replace


/* Employment from 1998 - New Format */
clear all
infile using "$HRSSurveys98/h98sta/H98G_R.dct" , using("$HRSSurveys98/h98da/H98G_R.da")


* Get indicators for whether the respondent is currently  Working / Retired / HomeMaker, 
* which are recorded as binary variables from the F1A-F1F survey items. 
* In the data set, the variables V2701, V2705, and V2706 contain information on these three activities

gen Working_98=0
gen Retired_98=0
gen HomeMaker_98=0

forvalues QN=1(1)3{

replace Working_98=1   if F3115M`QN'==1
replace Retired_98=1   if F3115M`QN'==5
replace HomeMaker_98=1 if F3115M`QN'==6

}

gen MonthRetired_98=F3126
gen YearRetired_98=F3127


* WorkForPay - item G2, asks whether the individual is doing any work for pay
* at the present time.  This variable is almost identical to Working above, but
* there are some respodnents who are coded as "1" for WorkForPay, but "0" for 
* Working.  These are mostly individuals who are on sick leave, retired, etc. 

gen WorkForPay_98=F3131
	replace WorkForPay_98=0 if WorkForPay_98==5
	replace WorkForPay_98=. if WorkForPay_98>5

* Self Employed - item G3.  This item and future items ask about "current, main job"
* This item asks if individuals work for someone else or are self-employed / run own business	
	
gen SelfEmp_98=F3132
	replace SelfEmp=0 if SelfEmp==1
	replace SelfEmp=1 if SelfEmp==2
	replace SelfEmp=. if SelfEmp>2
	
* HoursPerWeek - item G44.  How many hours a week do you usually work on this job? (98 / 99 are DK / NA)
* Notice that HoursPerWeek is set to 0 for individuals who are self-employed.  We set 0 to missing here:

gen HoursPerWeek_98=F3259
	replace HoursPerWeek_98=. if HoursPerWeek_98>168
	
* WeeksPerYear - item G47.  How many weeks do you work per year, including paid vacations.  
* This is set to zero for self-employees.  We set 0 to missing.

gen WeeksPerYear_98=F3269
		replace WeeksPerYear_98=. if WeeksPerYear_98>52
				  
gen HowPaidPE_98=F3295
		replace HowPaidPE_98=. if HowPaidPE_98>=8
		
/*          G56.  Are you salaried on this job, paid by the hour, or what?
          ................................................................................
           2343         1. SALARIED
           3727         2. HOURLY
            171         3. PIECEWORK/COMMISSION
            268         7. OTHER/COMBINATION
              8         8. DK (don't know); NA (not ascertained)
              6         9. RF (refused) */		

********************************************************************************
* Workers could receive income either from salary, hourly wages, commission, or 
* other compensation schemes, and here we create separate earnings variables for 
* each kind of earnings flow.		
********************************************************************************		
		
		
		
*********************
* Salaried Workers
*********************			
		
* Salary - item G56a.  How much is your SALARY before taxes and other deductions.
* This will be zero for those who are paid hourly, and those who are self-employed.
* We set 0 equal to missings 		
		
gen Salary_98=F3297
		replace Salary_98=. if Salary_98>=9999997
		replace Salary_98=. if Salary_98==0

gen PayPeriodSal_98=F3298
		replace PayPeriodSal_98=. if PayPeriodSal_98>11
		
* PayPeriod - item G56B.  In the previous question, how often is the reported
* salary received: 		
/*
F3298     G56B.AMOUNT SALARY-PER                    
          Section: G            Level: Respondent      CAI Reference: Q3298
          Type: Numeric         Width: 2               Decimals: 0
          ................................................................................
             48         1. HOUR
            246         2. WEEK
            104         3. EVERY TWO WEEKS/BI-WEEKLY
            237         4. MONTH
           1474         6. YEAR
             21        11. Day
              4        97. OTHER (SPECIFY)
             10        98. DK (don't know); NA (not ascertained)
                       99. RF (refused)
					   */

* Calculate Annual Salary based on responses, with different calculations
* for each pay period:		
gen AnnualInc_Salary_98=.
replace AnnualInc_Salary_98=HoursPerWeek_98*WeeksPerYear_98*Salary_98     if PayPeriodSal_98==1
replace AnnualInc_Salary_98=WeeksPerYear_98*Salary_98                     if PayPeriodSal_98==2
replace AnnualInc_Salary_98=(WeeksPerYear_98/2)*Salary_98                 if PayPeriodSal_98==3		
replace AnnualInc_Salary_98=12*Salary_98                                  if PayPeriodSal_98==4
replace AnnualInc_Salary_98=Salary_98                                     if PayPeriodSal_98==6	
replace AnnualInc_Salary_98=5*WeeksPerYear_98*Salary_98                   if PayPeriodSal_98==11	
						   

*********************
* Hourly Workers
*********************						   
	* Hourly Wage Rate - item G56F.  We set zeros equal to missing.
gen HourlyPay_98=F3304
		replace HourlyPay_98=. if HourlyPay_98>=10000
		replace HourlyPay_98=. if HourlyPay_98==0
				
gen AnnualInc_Hourly_98=HoursPerWeek_98*WeeksPerYear_98*HourlyPay_98
				
				
************************
* PIECEWORK/COMMISSION 	
************************		
* Piecework Pay - Item G56m	
gen PieceworkPay_98=F3314	
	replace PieceworkPay_98=. if PieceworkPay_98>=9999997
	replace PieceworkPay_98=. if PieceworkPay_98==0
* Piecework Pay Time Period - Item G56N		
gen PayPeriodPW_98=F3315		
	replace PayPeriodPW_98=. if PayPeriodPW_98>11
	replace PayPeriodPW_98=. if PayPeriodPW_98==0	
	
/*
F3315     G56N.AMOUNT PER TIME PERIOD-PER           
          Section: G            Level: Respondent      CAI Reference: Q3315
          Type: Numeric         Width: 2               Decimals: 0
          ................................................................................
              2         1. HOUR
             54         2. WEEK
              3         3. EVERY TWO WEEKS/BI-WEEKLY
             46         4. MONTH
             43         6. YEAR
              3        11. Day
                       97. Other (including per visit, class, mile, job)
                       98. DK (don't know); NA (not ascertained)
                       99. RF (refused) */
					   
gen AnnualInc_Piecework_98=.
replace AnnualInc_Piecework_98=HoursPerWeek_98*WeeksPerYear_98*PieceworkPay_98     if PayPeriodPW_98==1
replace AnnualInc_Piecework_98=WeeksPerYear_98*PieceworkPay_98                     if PayPeriodPW_98==2
replace AnnualInc_Piecework_98=(WeeksPerYear_98/2)*PieceworkPay_98                 if PayPeriodPW_98==3
replace AnnualInc_Piecework_98=12*PieceworkPay_98                                  if PayPeriodPW_98==4
replace AnnualInc_Piecework_98=PieceworkPay_98                                     if PayPeriodPW_98==6		
replace AnnualInc_Piecework_98=5*WeeksPerYear_98*PieceworkPay_98                   if PayPeriodPW_98==11
		
*****************************
* Other
*****************************
* Other Pay - Item G56R
gen OtherPay_98=F3319
		replace OtherPay_98=. if OtherPay_98>9999996
		replace OtherPay_98=. if OtherPay_98==0
* Other Pay - Item G56S		
gen PayPeriodOther_98=F3320
		replace PayPeriodOther_98=. if PayPeriodOther_98>11
		replace PayPeriodOther_98=. if PayPeriodOther_98==0	
	
	
/*     
F3320     G56S.AMOUNT PAID-PER                      
          Section: G            Level: Respondent      CAI Reference: Q3320
          Type: Numeric         Width: 2               Decimals: 0
          ................................................................................
             17         1. HOUR
             35         2. WEEK
              6         3. EVERY TWO WEEKS/BI-WEEKLY
             25         4. MONTH
             98         6. YEAR
             32        11. Day
             28        97. Other (including per visit, class, mile, job)
                       98. DK (don't know); NA (not ascertained)
                       99. RF (refused)	 */
	
gen AnnualInc_Other_98=.
	replace AnnualInc_Other_98=HoursPerWeek_98*WeeksPerYear_98*(OtherPay_98)     if PayPeriodOther_98==1
	replace AnnualInc_Other_98=WeeksPerYear_98*OtherPay_98                       if PayPeriodOther_98==2
	replace AnnualInc_Other_98=(WeeksPerYear_98/2)*OtherPay_98                   if PayPeriodOther_98==3	
	replace AnnualInc_Other_98=12*OtherPay_98                                    if PayPeriodOther_98==4
	replace AnnualInc_Other_98=OtherPay_98                                       if PayPeriodOther_98==6		
	replace AnnualInc_Other_98=5*WeeksPerYear_98*OtherPay_98 	                 if PayPeriodOther_98==11
	

*************************************************
* Indicator for Same Job Title as Previous Wave:	
*************************************************

/*

F3158     G19A.STILL WORKING FOR PREV WAVE EMPLOYE  
          Section: G            Level: Respondent      CAI Reference: Q3158
          Type: Numeric         Width: 1               Decimals: 0

          G19a.  According to our records, you were employed in [Q218-PREV WAVE IW
          MONTH] [Q219-PREV WAVE IW YEAR]. Are you still working for that same
          employer?

          User note:  This question is not asked after version 2. See F454A and F6697A
          for product version information.
          ................................................................................
             41         1. YES
              2         5. NO
                        7. DENIES WORKING AT PREVIOUS IW
                        8. DK (don't know); NA (not ascertained)
                        9. RF (refused)
          21341     Blank. INAP (Inapplicable): [Q456:CS CONTINUE] IS (5); [Q497:CS2b] IS
                           (A) OR [Q542:CS15C2] IS (A) OR [Q518:CS11a] IS (A); [Q3133:G3
                           BRANCHPOINT] IS (2); [Q3133:G3 BRANCHPOINT] IS (4); [Q3138:G5B
                           BRANCHPOINT] IS (1); [Q3138:G5B BRANCHPOINT] IS (0);
                           [Q3139:G5b] IS (5 OR DK OR RF); [Q3140:G5c] IS (A); [Q3154:G7]
                           IS (5 OR DK OR RF); [Q3155:G7a] IS (A); [Q217:EMP NAME PREV
                           WAVE] IS (NE "|");; partial interview




F3166     G19B.STILL WORKING PREV EMPLOYER          
          Section: G            Level: Respondent      CAI Reference: Q3166
          Type: Numeric         Width: 1               Decimals: 0

          G19b. According to our records, in [Q218-PREV WAVE IW MONTH] [Q219-PREV WAVE
          IW YEAR]  you were working

          IF Q217 IS (NE"| ")
                  for [Q217-EMP NAME PREV WAVE].
          ELSE
                  for an employer.
          END
                  Are you still working there?
          ................................................................................
           3491         1. YES
            618         5. NO
             18         7. DENIES WORKING AT PREVIOUS IW
              3         8. DK (don't know); NA (not ascertained)
                        9. RF (refused)
          17254     Blank. INAP (Inapplicable): [Q456:CS CONTINUE] IS (5); [Q497:CS2b] IS
                           (A) OR [Q542:CS15C2] IS (A) OR [Q518:CS11a] IS (A); [Q3133:G3
                           BRANCHPOINT] IS (2); [Q3133:G3 BRANCHPOINT] IS (4); [Q3138:G5B
                           BRANCHPOINT] IS (1); [Q3138:G5B BRANCHPOINT] IS (0);
                           [Q3139:G5b] IS (5 OR DK OR RF); [Q3140:G5c] IS (A); [Q3154:G7]
                           IS (5 OR DK OR RF); [Q3155:G7a] IS (A); [Q3159:G19a1] IS (DK OR
                           RF); [Q3158:G19a] IS (A); partial interview


F3183     G21.SAME JOB TITLE AS PREVIOUS WAVE       
          Section: G            Level: Respondent      CAI Reference: Q3183
          Type: Numeric         Width: 1               Decimals: 0

          G21. In [Q218-PREV WAVE IW MONTH] [Q219-PREV WAVE IW YEAR] our records
          indicate that your job title was [Q275-PREV WAVE JOB TITLE]. Is this still
          the case?

                  IWER:  IF JOB TITLE IS SLIGHTLY INACCURATE BUT DOES DESCRIBES R'S
          CURRENT JOB, ANSWER "YES" HERE AND NOTE CORRECTIONS AS A COMMENT.
          ................................................................................
           2607         1. YES
            545         5. NO
             69         7. DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE
                        8. DK (don't know); NA (not ascertained)
                        9. RF (refused) */
						
					
* Item G19B
gen SameEmp_98=F3166
	

* Items on Job Characterisitcs

gen SameJob_98=F3183
		 /*            
		   2607         1. YES
            545         5. NO
             69         7. DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE  */ 
gen SameJobTBranch_98=F3273
	     /*F3273     G49 BRANCHPOINT                           
          Section: G            Level: Respondent      CAI Reference: Q3273
          Type: Numeric         Width: 1               Decimals: 0
          ................................................................................
           2607         1. GO TO G56 IF SAME EMPLOYER AND JOB TITLE AS PREV WAVE
           1809         2. GO TO G52 IF SELF EMPLOYED
           3916         3. GO TO G49 OTHERWISE  */

gen Job_Ind_98=F3253M
gen Job_Occ_98=F3255HM	
	
	
*******************************
* Second Job 
*******************************
* Second Job Hours Per Week - G129
gen Job2_HoursPerWeek_98=F3551
	replace Job2_HoursPerWeek_98=. if Job2_HoursPerWeek_98>96
* Second Job Weeks Per Year - G130
gen Job2_WeeksPerYear_98=F3552
	replace Job2_WeeksPerYear_98=. if Job2_WeeksPerYear_98>52
* Pay Second Job - G131	
gen Job2Pay_98=F3553
    replace Job2Pay_98=. if Job2Pay_98>=9999997

* Pay Period Second Job - G131A	
gen PayPeriodJob2_98=F3554
	replace PayPeriodJob2_98=. if PayPeriodJob2_98>11
	replace PayPeriodJob2_98=. if PayPeriodJob2_98==0
	
/*
F3554     G131A.EARNINGS ON 2ND JOB-PER             
          Section: G            Level: Respondent      CAI Reference: Q3554
          Type: Numeric         Width: 2               Decimals: 0
          ................................................................................
            148         1. HOUR
             67         2. WEEK
              9         3. EVERY TWO WEEKS/BI-WEEKLY
             75         4. MONTH
            426         6. YEAR
              2        11. Day
             34        97. OTHER (SPECIFY)
              1        98. DK (don't know); NA (not ascertained)
                       99. RF (refused) */
					   
	
gen AnnualInc_Job2_98=.
replace AnnualInc_Job2=Job2_HoursPerWeek_98*Job2_WeeksPerYear_98*(Job2Pay_98)     if PayPeriodJob2_98==1
replace AnnualInc_Job2=Job2_WeeksPerYear_98*Job2Pay_98                            if PayPeriodJob2_98==2
replace AnnualInc_Job2=(Job2_WeeksPerYear_98/2)*Job2Pay_98                        if PayPeriodJob2_98==3
replace AnnualInc_Job2=12*Job2Pay_98                                              if PayPeriodJob2_98==4
replace AnnualInc_Job2=Job2Pay_98                                                 if PayPeriodJob2_98==6
replace AnnualInc_Job2=5*Job2_WeeksPerYear_98*Job2Pay_98                          if PayPeriodJob2_98==11
		
* Sum these income sources for paid employees, treating missings as zeros. 
egen AnnualInc_PE_98=rowtotal(AnnualInc_Salary_98 AnnualInc_Hourly_98 AnnualInc_Piecework_98 AnnualInc_Other_98 AnnualInc_Job2_98), missing

egen AnnualInc_PEJ1_98=rowtotal(AnnualInc_Salary_98 AnnualInc_Hourly_98 AnnualInc_Piecework_98 AnnualInc_Other_98), missing
	
**************************
* Self Employees
**************************	
	
	
* Hours Per Week - Self Employees - (Same as for Paid Employees from this wave on *
* Weeks Per Year - Self Employees - (Same as for Paid Employees from this wave on *
gen HoursPerWeekSE_98=.
replace HoursPerWeekSE_98=HoursPerWeek_98 if SelfEmp==1

gen WeeksPerYearSE_98=.
replace WeeksPerYearSE_98=WeeksPerYear_98 if SelfEmp==1


* Binary Indicating whether they receive a salary from this business: G52		
gen SelfEmp_RegSalary98=F3279
	replace SelfEmp_RegSalary98=. if SelfEmp_RegSalary98>5 | SelfEmp_RegSalary98==0
	replace SelfEmp_RegSalary98=0 if SelfEmp_RegSalary98==5
	
* Salary Amount - Self Employees - G52A	
gen SelfEmp_Salary98= F3280	
	replace SelfEmp_Salary98=. if SelfEmp_Salary98>=9999997
	replace SelfEmp_Salary98=. if SelfEmp_Salary98==0
	
* Salary Pay Period - Self Employees - G52B	
gen SelfEmp_PayPeriod98=F3281
	replace SelfEmp_PayPeriod98=. if SelfEmp_PayPeriod98>11 | SelfEmp_PayPeriod98==0

/*
F3281     G52B.SELF-EMPLOYMENT SALARY-PER           
          Section: G            Level: Respondent      CAI Reference: Q3281
          Type: Numeric         Width: 2               Decimals: 0
          ................................................................................
             82         1. HOUR
            141         2. WEEK
              6         3. EVERY TWO WEEKS/BI-WEEKLY
             83         4. MONTH
            172         6. YEAR
              9        11. Day
             11        97. Other (including per visit, class, mile, job)
              2        98. DK (don't know); NA (not ascertained)
              1        99. RF (refused) */	
	
	
* Construct Annual Salary for Self-Employees

gen AnnualSalSE_98=.
		replace AnnualSalSE=WeeksPerYearSE*HoursPerWeekSE*(SelfEmp_Salary)        if SelfEmp_PayPeriod==1
		replace AnnualSalSE=WeeksPerYearSE*SelfEmp_Salary                         if SelfEmp_PayPeriod==2
		replace AnnualSalSE=(WeeksPerYearSE/2)*SelfEmp_Salary                     if SelfEmp_PayPeriod==3
		replace AnnualSalSE=12*SelfEmp_Salary                                     if SelfEmp_PayPeriod==4
		replace AnnualSalSE=SelfEmp_Salary                                        if SelfEmp_PayPeriod==6
		replace AnnualSalSE=5*WeeksPerYearSE*SelfEmp_Salary                       if SelfEmp_PayPeriod==11
	
	
* Binary Variable Indicating whether the self-employee gets profits from the business G53
gen SelfEmp_GetProfit98=F3283
	replace SelfEmp_GetProfit98=. if SelfEmp_GetProfit98>5 | SelfEmp_GetProfit98==0

* Profit Amount - G53A
gen SelfEmp_Profit98=F3284
	replace SelfEmp_Profit98=. if SelfEmp_Profit98>=9999997
	* Note, 9999940 is technically a valid code, but this response is given by one respondent, and 
	* it appears to be a mistake in a special code (e.g. the top code is 9999994)
	
gen SelfEmp_ProfitPeriod98=F3285 
	replace SelfEmp_ProfitPeriod98=. if SelfEmp_ProfitPeriod98>11 | SelfEmp_ProfitPeriod98==0
	
/*
F3285     G53B.NET EARNINGS/PROFITS-PER             
          Section: G            Level: Respondent      CAI Reference: Q3285
          Type: Numeric         Width: 2               Decimals: 0
          ................................................................................
             22         1. HOUR
             43         2. WEEK
              3         3. EVERY TWO WEEKS/BI-WEEKLY
             45         4. MONTH
            871         6. YEAR
              1        11. Day
             31        97. OTHER (SPECIFY)
              2        98. DK (don't know); NA (not ascertained)
              1        99. RF (refused)*/
						
		
gen AnnualProfSE_98=.
		replace AnnualProfSE_98=WeeksPerYearSE_98*HoursPerWeekSE*SelfEmp_Profit98  if SelfEmp_ProfitPeriod==1
		replace AnnualProfSE_98=WeeksPerYearSE_98*SelfEmp_Profit98                 if SelfEmp_ProfitPeriod==2
		replace AnnualProfSE_98=(WeeksPerYearSE_98/2)*SelfEmp_Profit98             if SelfEmp_ProfitPeriod==3
		replace AnnualProfSE_98=12*SelfEmp_Profit98                                if SelfEmp_ProfitPeriod==4
		replace AnnualProfSE_98=SelfEmp_Profit98                                   if SelfEmp_ProfitPeriod==6
		replace AnnualProfSE_98=5*WeeksPerYearSE_98*SelfEmp_Profit98               if SelfEmp_ProfitPeriod==11
	


egen AnnualInc_SE_98=rowtotal(AnnualSalSE_98 AnnualProfSE_98), missing
	

egen AnnualIncTot_98=rowtotal(AnnualInc_PE_98 AnnualInc_SE_98), missing

	
keep HHID PN *SUBHH *FINR Working *Retired* HomeMaker WorkForPay SelfEmp_98 AnnualInc_PE_ AnnualInc_PEJ1_ AnnualInc_SE_ AnnualIncTot_ *Same*Emp* *SameJob* *Job_Ind* *Job_Occ* WeeksPerYear* *HoursPerWeek*


gen YEAR=1998

save "$CleanData/HRSEmpInc98.dta", replace




/* Employment Answers from 2000 - New Format */
clear all
infile using "$HRSSurveys00/h00sta/H00G_R.dct" , using("$HRSSurveys00/h00da/H00G_R.da")


* Get indicators for whether the respondent is currently  Working / Retired / HomeMaker, 
* which are recorded as binary variables from the G1 survey items. 

gen Working_00=0
gen Retired_00=0
gen HomeMaker_00=0

forvalues QN=1(1)3{

replace Working_00=1   if G3365M`QN'==1
replace Retired_00=1   if G3365M`QN'==5
replace HomeMaker_00=1 if G3365M`QN'==6

}

gen MonthRetired_00=G3376
gen YearRetired_00=G3377


* WorkForPay - item G2, asks whether the individual is doing any work for pay
* at the present time.  This variable is almost identical to Working above, but
* there are some respodnents who are coded as "1" for WorkForPay, but "0" for 
* Working.  These are mostly individuals who are on sick leave, retired, etc. 

gen WorkForPay_00=G3381
	replace WorkForPay_00=0 if WorkForPay_00==5
	replace WorkForPay_00=. if WorkForPay_00>5

* Self Employed - item G3.  This item and future items ask about "current, main job"
* This item asks if individuals work for someone else or are self-employed / run own business	
	
gen SelfEmp_00=G3382
	replace SelfEmp=0 if SelfEmp==1
	replace SelfEmp=1 if SelfEmp==2
	replace SelfEmp=. if SelfEmp>2
	
* HoursPerWeek - item G44.  How many hours a week do you usually work on this job? (98 / 99 are DK / NA)
* Notice that HoursPerWeek is set to 0 for individuals who are self-employed.  We set 0 to missing here:

gen HoursPerWeek_00=G3509
	replace HoursPerWeek_00=. if HoursPerWeek_00>168
	
* WeeksPerYear - item G47.  How many weeks do you work per year, including paid vacations.  
* This is set to zero for self-employees.  We set 0 to missing.

gen WeeksPerYear_00=G3519
		replace WeeksPerYear_00=. if WeeksPerYear_00>52
				  
gen HowPaidPE_00=G3555
		replace HowPaidPE_00=. if HowPaidPE_00>=8
		
/*         
G3555     G56.HOW PAID ON JOB                       
          Section: G            Level: Respondent      CAI Reference: Q3555
          Type: Numeric         Width: 1               Decimals: 0

          G56.
                  Are you salaried on this job, paid by the hour, or what?
          ................................................................................
           2027         1. SALARIED
           3236         2. HOURLY
            157         3. PIECEWORK/COMMISSION
            206         7. OTHER/COMBINATION
             13         8. DK (don't know); NA (not ascertained)
              6         9. RF (refused) */		

********************************************************************************
* Workers could receive income either from salary, hourly wages, commission, or 
* other compensation schemes, and here we create separate earnings variables for 
* each kind of earnings flow.		
********************************************************************************		
		
*********************
* Salaried Workers
*********************			
		
* Salary - item G56a.  How much is your SALARY before taxes and other deductions.
* This will be zero for those who are paid hourly, and those who are self-employed.
* We set 0 equal to missings 		
		
gen Salary_00=G3557
		replace Salary_00=. if Salary_00>=9999997
		replace Salary_00=. if Salary_00==0

gen PayPeriodSal_00=G3558
		replace PayPeriodSal_00=. if PayPeriodSal_00>11
		
* PayPeriod - item G56B.  In the previous question, how often is the reported
* salary received: 		
/*
G3558     G56B.PER                                  
          Section: G            Level: Respondent      CAI Reference: Q3558
          Type: Numeric         Width: 2               Decimals: 0
          ................................................................................
             44         1. HOUR
            199         2. WEEK
             74         3. EVERY TWO WEEKS/BI-WEEKLY
            206         4. MONTH
           1311         6. YEAR
             18        11. Day
              7        97. OTHER (SPECIFY)
              2        98. DK (don't know); NA (not ascertained)
                       99. RF (refused)
					   */

* Calculate Annual Salary based on responses, with different calculations
* for each pay period:		
gen AnnualInc_Salary_00=.
replace AnnualInc_Salary=HoursPerWeek_*WeeksPerYear_*Salary     if PayPeriodSal==1
replace AnnualInc_Salary=WeeksPerYear_*Salary                   if PayPeriodSal==2
replace AnnualInc_Salary=(WeeksPerYear_/2)*Salary               if PayPeriodSal==3		
replace AnnualInc_Salary=12*Salary                              if PayPeriodSal==4
replace AnnualInc_Salary=Salary                                 if PayPeriodSal==6	
replace AnnualInc_Salary=5*WeeksPerYear_*Salary                 if PayPeriodSal==11	
						   

*********************
* Hourly Workers
*********************						   
	* Hourly Wage Rate - item G56F.  We set zeros equal to missing.
gen HourlyPay_00=G3564
		replace HourlyPay_00=. if HourlyPay_00>=10000
		replace HourlyPay_00=. if HourlyPay_00==0
				
gen AnnualInc_Hourly_00=HoursPerWeek_*WeeksPerYear_*HourlyPay_
				
				
************************
* PIECEWORK/COMMISSION 	
************************		
* Piecework Pay - Item G56m	
gen PieceworkPay_00=G3574	
	replace PieceworkPay_00=. if PieceworkPay_00>=9999997
	replace PieceworkPay_00=. if PieceworkPay_00==0
* Piecework Pay Time Period - Item G56N		
gen PayPeriodPW_00=G3575		
	replace PayPeriodPW_00=. if PayPeriodPW_00>11
	replace PayPeriodPW_00=. if PayPeriodPW_00==0	
	
/*
G3575     G56N.PER                                  
          Section: G            Level: Respondent      CAI Reference: Q3575
          Type: Numeric         Width: 2               Decimals: 0
          ................................................................................
              5         1. HOUR
             45         2. WEEK
              3         3. EVERY TWO WEEKS/BI-WEEKLY
             45         4. MONTH
             25         6. YEAR
              3         7. OTHER (SPECIFY)
              3        11. Day
              6        97. Other (including per visit, class, mile, job)
              1        98. DK (don't know); NA (not ascertained)
                       99. RF (refused) */
					   
gen AnnualInc_Piecework_00=.
replace AnnualInc_Piecework_=HoursPerWeek_*WeeksPerYear_*PieceworkPay_     if PayPeriodPW==1
replace AnnualInc_Piecework_=WeeksPerYear_*PieceworkPay_                   if PayPeriodPW==2
replace AnnualInc_Piecework_=(WeeksPerYear_/2)*PieceworkPay_               if PayPeriodPW==3
replace AnnualInc_Piecework_=12*PieceworkPay_                              if PayPeriodPW==4
replace AnnualInc_Piecework_=PieceworkPay_                                 if PayPeriodPW==6		
replace AnnualInc_Piecework_=5*WeeksPerYear_*PieceworkPay_                 if PayPeriodPW==11
		
*****************************
* Other
*****************************
* Other Pay - Item G56R
gen OtherPay_00=G3579
		replace OtherPay_00=. if OtherPay_00>9999996
		replace OtherPay_00=. if OtherPay_00==0
* Other Pay - Item G56S		
gen PayPeriodOther_00=G3580
		replace PayPeriodOther_00=. if PayPeriodOther_00>11
		replace PayPeriodOther_00=. if PayPeriodOther_00==0	
	
	
/*     
G3580     G56S.PER                                  
          Section: G            Level: Respondent      CAI Reference: Q3580
          Type: Numeric         Width: 2               Decimals: 0
          ................................................................................
             11         1. HOUR
             29         2. WEEK
              4         3. EVERY TWO WEEKS/BI-WEEKLY
             22         4. MONTH
             61         6. YEAR
             32        11. Day
             20        97. Other (including per visit, class, mile, job)
                       98. DK (don't know); NA (not ascertained)
                       99. RF (refused)	 */
	
gen AnnualInc_Other_00=.
	replace AnnualInc_Other_=HoursPerWeek_*WeeksPerYear_*(OtherPay_)     if PayPeriodOther==1
	replace AnnualInc_Other_=WeeksPerYear_*OtherPay_                     if PayPeriodOther==2
	replace AnnualInc_Other_=(WeeksPerYear_/2)*OtherPay_                 if PayPeriodOther==3	
	replace AnnualInc_Other_=12*OtherPay_                                if PayPeriodOther==4
	replace AnnualInc_Other_=OtherPay_                                   if PayPeriodOther==6		
	replace AnnualInc_Other_=5*WeeksPerYear_*OtherPay_ 	                 if PayPeriodOther==11
	
	
*************************************************
* Indicator for Same Job Title as Previous Wave:	
*************************************************	

/* 

G3416     G19B.STILL WORKING PREV EMPLOYER          
          Section: G            Level: Respondent      CAI Reference: Q3416
          Type: Numeric         Width: 1               Decimals: 0

          G19b.
                  According to our records, in
                  [Q218-PR218.PREV WAVE IW MONTH]
                  [Q219-PR219.PREV WAVE IW YEAR]  you were
          IF Q217 IS (NE"| ")
                  working for
                  [Q217.].
          ELSE
                  also working for someone else.
          END

                  Are you still working there?
          ................................................................................
           4249         1. YES
            664         5. NO

G3432     G21.SAME JOB TITLE AS PREVIOUS WAVE       
          Section: G            Level: Respondent      CAI Reference: Q3432
          Type: Numeric         Width: 1               Decimals: 0

          G21.
                  In
                  [Q218-PR218.PREV WAVE IW MONTH]
                  [Q219-PR219.PREV WAVE IW YEAR]  our records indicate that your job
                  title was

                  [Q275.].  Is this still the case?

                  IWER:  IF JOB TITLE IS SLIGHTLY INACCURATE BUT DESCRIBES
                  R'S CURRENT JOB, ANSWER "YES" HERE AND NOTE CORRECTIONS
                  AS A COMMENT. */
				  
* Item G19B
         /*         Are you still working there?
          ..............................................
           4249         1. YES
            664         5. NO
             41         7. DENIES WORKING/WORKING FOR NAMED EMPLOYER  */
gen SameEmp_00=G3416
	
* Items on Job Characterisitcs

gen SameJob_00=G3432
		 /*            
			3660         1. YES
             387         5. NO
              18         7. DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE  */ 
gen SameJobTBranch_00=G3799 
	     /* G3799     G115Y1.G115 BRANCHPOINT                   
          Section: G            Level: Respondent      CAI Reference: Q3799
          Type: Numeric         Width: 1               Decimals: 0
          ................................................................................
           3377         1. SAME JOB TITLE AS IN PREV WAVE, GO TO G127
           1086         2. SELF EMPLOYED AND SELF EMPLOYED IN PREV WAVE, GO TO G127
           2138         3. ALL OTHERS, GO TO G126  */


gen Job_Ind_00=G3503M
gen Job_Occ_00=G3505M
				  
	
*******************************
* Second Job 
*******************************
* Second Job Hours Per Week - G129
gen Job2_HoursPerWeek_00=G3840
	replace Job2_HoursPerWeek_00=. if Job2_HoursPerWeek_00>96
* Second Job Weeks Per Year - G130
gen Job2_WeeksPerYear_00=G3841
	replace Job2_WeeksPerYear_00=. if Job2_WeeksPerYear_00>52
* Pay Second Job - G131	
gen Job2Pay_00=G3842
    replace Job2Pay_00=. if Job2Pay_00>=9999997

* Pay Period Second Job - G131A	
gen PayPeriodJob2_00=G3843
	replace PayPeriodJob2_00=. if PayPeriodJob2_00>11
	replace PayPeriodJob2_00=. if PayPeriodJob2_00==0
	
/*
G3843     G131A.PER                                 
          Section: G            Level: Respondent      CAI Reference: Q3843
          Type: Numeric         Width: 2               Decimals: 0
          ................................................................................
            139         1. HOUR
             57         2. WEEK
              8         3. EVERY TWO WEEKS/BI-WEEKLY
             46         4. MONTH
            305         6. YEAR
              3        11. Day
             22        97. OTHER (SPECIFY)
              1        98. DK (don't know); NA (not ascertained)
                       99. RF (refused) */
					   
	
gen AnnualInc_Job2_00=.
replace AnnualInc_Job2=Job2_HoursPerWeek_*Job2_WeeksPerYear_*(Job2Pay_)     if PayPeriodJob2==1
replace AnnualInc_Job2=Job2_WeeksPerYear_*Job2Pay_                          if PayPeriodJob2==2
replace AnnualInc_Job2=(Job2_WeeksPerYear_/2)*Job2Pay_                      if PayPeriodJob2==3
replace AnnualInc_Job2=12*Job2Pay_                                          if PayPeriodJob2==4
replace AnnualInc_Job2=Job2Pay_                                             if PayPeriodJob2==6
replace AnnualInc_Job2=5*Job2_WeeksPerYear_*Job2Pay_                        if PayPeriodJob2==11
		
* Sum these income sources for paid employees, treating missings as zeros. 
egen AnnualInc_PE_00=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ AnnualInc_Job2_), missing

egen AnnualInc_PEJ1_00=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ ), missing

	
**************************
* Self Employees
**************************	
	
	
* Hours Per Week - Self Employees - (Same as for Paid Employees from this wave on *
* Weeks Per Year - Self Employees - (Same as for Paid Employees from this wave on *
gen HoursPerWeekSE_00=.
replace HoursPerWeekSE_00=HoursPerWeek_00 if SelfEmp==1

gen WeeksPerYearSE_00=.
replace WeeksPerYearSE_00=WeeksPerYear_00 if SelfEmp==1


* Binary Indicating whether they receive a salary from this business: G52		
gen SelfEmp_RegSalary00=G3539
	replace SelfEmp_RegSalary00=. if SelfEmp_RegSalary00>5 | SelfEmp_RegSalary00==0
	replace SelfEmp_RegSalary00=0 if SelfEmp_RegSalary00==5
	
* Salary Amount - Self Employees - G52A	
gen SelfEmp_Salary00=G3540	
	replace SelfEmp_Salary00=. if SelfEmp_Salary00>=9999997
	replace SelfEmp_Salary00=. if SelfEmp_Salary00==0
	
* Salary Pay Period - Self Employees - G52B	
gen SelfEmp_PayPeriod00=G3541
	replace SelfEmp_PayPeriod00=. if SelfEmp_PayPeriod00>11 | SelfEmp_PayPeriod00==0

/*
G3541     G52B.SELF-EMPLOYMENT SALARY-PER           
          Section: G            Level: Respondent      CAI Reference: Q3541
          Type: Numeric         Width: 2               Decimals: 0
          ................................................................................
             65         1. HOUR
            108         2. WEEK
             10         3. EVERY TWO WEEKS/BI-WEEKLY
             77         4. MONTH
            140         6. YEAR
              5        11. Day
              2        97. Other (including per visit, class, mile, job)
              1        98. DK (don't know); NA (not ascertained)
                       99. RF (refused) */	
	
	
* Construct Annual Salary for Self-Employees

gen AnnualSalSE_00=.
		replace AnnualSalSE=WeeksPerYearSE*HoursPerWeekSE*(SelfEmp_Salary)        if SelfEmp_PayPeriod==1
		replace AnnualSalSE=WeeksPerYearSE*SelfEmp_Salary                         if SelfEmp_PayPeriod==2
		replace AnnualSalSE=(WeeksPerYearSE/2)*SelfEmp_Salary                     if SelfEmp_PayPeriod==3
		replace AnnualSalSE=12*SelfEmp_Salary                                     if SelfEmp_PayPeriod==4
		replace AnnualSalSE=SelfEmp_Salary                                        if SelfEmp_PayPeriod==6
		replace AnnualSalSE=5*WeeksPerYearSE*SelfEmp_Salary                       if SelfEmp_PayPeriod==11
	
	
* Binary Variable Indicating whether the self-employee gets profits from the business G53
gen SelfEmp_GetProfit00=G3543
	replace SelfEmp_GetProfit00=. if SelfEmp_GetProfit00>5 | SelfEmp_GetProfit00==0

* Profit Amount - G53A
gen SelfEmp_Profit_00=G3544
	replace SelfEmp_Profit_00=. if SelfEmp_Profit_00>=9999997

gen SelfEmp_ProfitPeriod00=G3545 
	replace SelfEmp_ProfitPeriod00=. if SelfEmp_ProfitPeriod00>11 | SelfEmp_ProfitPeriod00==0
	
/*
G3545     G53B.NET EARNINGS/PROFITS-PER             
          Section: G            Level: Respondent      CAI Reference: Q3545
          Type: Numeric         Width: 2               Decimals: 0
          ................................................................................
             20         1. HOUR
             32         2. WEEK
              1         3. EVERY TWO WEEKS/BI-WEEKLY
             41         4. MONTH
            802         6. YEAR
              4        11. Day
             21        97. OTHER (SPECIFY)
              3        98. DK (don't know); NA (not ascertained)
                       99. RF (refused)*/
						
		
gen AnnualProfSE_00=.
		replace AnnualProfSE_=WeeksPerYearSE_*HoursPerWeekSE*SelfEmp_Profit_  if SelfEmp_ProfitPeriod==1
		replace AnnualProfSE_=WeeksPerYearSE_*SelfEmp_Profit_                 if SelfEmp_ProfitPeriod==2
		replace AnnualProfSE_=(WeeksPerYearSE_/2)*SelfEmp_Profit_             if SelfEmp_ProfitPeriod==3
		replace AnnualProfSE_=12*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==4
		replace AnnualProfSE_=SelfEmp_Profit_                                 if SelfEmp_ProfitPeriod==6
		replace AnnualProfSE_=5*WeeksPerYearSE_*SelfEmp_Profit_               if SelfEmp_ProfitPeriod==11
	


egen AnnualInc_SE_00=rowtotal(AnnualSalSE_ AnnualProfSE_), missing
	

egen AnnualIncTot_00=rowtotal(AnnualInc_PE_ AnnualInc_SE_), missing

	
keep HHID PN *SUBHH *FINR Working *Retired* HomeMaker WorkForPay SelfEmp_00 AnnualInc_PE_ AnnualInc_PEJ1_ AnnualInc_SE_ AnnualIncTot_ *Same*Emp* *SameJob* *Job_Ind* *Job_Occ* WeeksPerYear* *HoursPerWeek*


gen YEAR=2000

save "$CleanData/HRSEmpInc00.dta", replace



/* Employment Answers from 2002 - New Format */
clear all
infile using "$HRSSurveys02/h02sta/H02J_R.dct" , using("$HRSSurveys02/h02da/H02J_R.da")


* Get indicators for whether the respondent is currently  Working / Retired / HomeMaker, 
* which are recorded as binary variables from the G1 survey items. 

gen Working_02=0
gen Retired_02=0
gen HomeMaker_02=0

forvalues QN=1(1)5{

replace Working_02=1   if HJ005M`QN'==1
replace Retired_02=1   if HJ005M`QN'==5
replace HomeMaker_02=1 if HJ005M`QN'==6

}

gen MonthRetired_02=HJ017
gen YearRetired_02=HJ018


* WorkForPay - item G2, asks whether the individual is doing any work for pay
* at the present time.  This variable is almost identical to Working above, but
* there are some respodnents who are coded as "1" for WorkForPay, but "0" for 
* Working.  These are mostly individuals who are on sick leave, retired, etc. 

gen WorkForPay_02=HJ020
	replace WorkForPay_02=0 if WorkForPay_02==5
	replace WorkForPay_02=. if WorkForPay_02>5

* Self Employed - item G3.  This item and future items ask about "current, main job"
* This item asks if individuals work for someone else or are self-employed / run own business	
	
gen SelfEmp_02=HJ021
	replace SelfEmp=0 if SelfEmp==1
	replace SelfEmp=1 if SelfEmp==2
	replace SelfEmp=. if SelfEmp>2
	
* HoursPerWeek - item G44.  How many hours a week do you usually work on this job? (98 / 99 are DK / NA)
* Notice that HoursPerWeek is set to 0 for individuals who are self-employed.  We set 0 to missing here:

gen HoursPerWeek_02=HJ172
	replace HoursPerWeek_02=. if HoursPerWeek_02>168
	
* WeeksPerYear - item G47.  How many weeks do you work per year, including paid vacations.  
* This is set to zero for self-employees.  We set 0 to missing.

gen WeeksPerYear_02=HJ179
		replace WeeksPerYear_02=. if WeeksPerYear_02>52
				  
gen HowPaidPE_02=HJ205
		replace HowPaidPE_02=. if HowPaidPE_02>=8
		
/*         
HJ205    HOW PAID ON JOB
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: BJ_CURRJOBELSEEMPD.J205_                     Ref 2000: G3555

        Are you salaried on this job, paid by the hour, or what?
        ..................................................................................
         1607           1. SALARIED
         2670           2. HOURLY
          122           3. PIECEWORK/COMMISSION
          211           7. OTHER/COMBINATION
           10           8. DK (Don't Know); NA (Not Ascertained)
           15           9. RF (Refused)
        13532       Blank. INAP (Inapplicable) */		

********************************************************************************
* Workers could receive income either from salary, hourly wages, commission, or 
* other compensation schemes, and here we create separate earnings variables for 
* each kind of earnings flow.		
********************************************************************************		
		
*********************
* Salaried Workers
*********************			
		
* Salary - item G56a.  How much is your SALARY before taxes and other deductions.
* This will be zero for those who are paid hourly, and those who are self-employed.
* We set 0 equal to missings 		
		
gen Salary_02=HJ206
		replace Salary_02=. if Salary_02>=999999998
		replace Salary_02=. if Salary_02==0

gen PayPeriodSal_02=HJ210
		replace PayPeriodSal_02=. if PayPeriodSal_02>11
		
* PayPeriod - item G56B.  In the previous question, how often is the reported
* salary received: 		
/*
HJ210    AMOUNT OF SALARY ON JOB PER
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: BJ_CURRJOBELSEEMPD.J210_                     Ref 2000: G3558

        (How much is your salary, before taxes and other deductions?)

        IWER: IF RESPONDENT IS A TEACHER, RECORD ANNUAL SALARY

        PROBE IF NECESSARY: Is that per hour, week, month, or year?

        PER:
        ..................................................................................
           43           1. HOUR
          132           2. WEEK
           60           3. EVERY TWO WEEKS/BI-WEEKLY
          148           4. MONTH
            2           5. TWICE A MONTH
         1052           6. YEAR
           20           7. OTHER (SPECIFY)
            2           8. DK (Don't Know); NA (Not Ascertained)
                        9. RF (Refused)
        16708       Blank. INAP (Inapplicable)
					   */

* Calculate Annual Salary based on responses, with different calculations
* for each pay period:		
gen AnnualInc_Salary_02=.
replace AnnualInc_Salary=HoursPerWeek_*WeeksPerYear_*Salary     if PayPeriodSal==1
replace AnnualInc_Salary=WeeksPerYear_*Salary                   if PayPeriodSal==2
replace AnnualInc_Salary=(WeeksPerYear_/2)*Salary               if PayPeriodSal==3		
replace AnnualInc_Salary=12*Salary                              if PayPeriodSal==4
replace AnnualInc_Salary=24*Salary                              if PayPeriodSal==5
replace AnnualInc_Salary=Salary                                 if PayPeriodSal==6	
replace AnnualInc_Salary=5*WeeksPerYear_*Salary                 if PayPeriodSal==11
						   

*********************
* Hourly Workers
*********************						   
	* Hourly Wage Rate - item G56F.  We set zeros equal to missing.
gen HourlyPay_02=HJ216
		replace HourlyPay_02=. if HourlyPay_02>=10000
		replace HourlyPay_02=. if HourlyPay_02==0
				
gen AnnualInc_Hourly_02=HoursPerWeek_*WeeksPerYear_*HourlyPay_
				
				
************************
* PIECEWORK/COMMISSION 	
************************		
* Piecework Pay - Note that in the code book this is listed as "Overtime Pay"
* but this is only non-missing for individuals who have a value of 3 for HJ205
gen PieceworkPay_02=HJ225	
	replace PieceworkPay_02=. if PieceworkPay_02>=99999998
	replace PieceworkPay_02=. if PieceworkPay_02==0
* Piecework Pay Time Period - Item G56N		
gen PayPeriodPW_02=HJ226		
	replace PayPeriodPW_02=. if PayPeriodPW_02>11
	replace PayPeriodPW_02=. if PayPeriodPW_02==0	
	
/*
HJ226    AMOUNT PAID FOR OVERTIME PER
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: BJ_CURRJOBELSEEMPD.J226_                     Ref 2000: G3575

        IWER: PROBE IF NECESSARY: Was that per week or month?


        PER:
        ..................................................................................
            4           1. HOUR
           41           2. WEEK
            3           3. EVERY TWO WEEKS/BI-WEEKLY
           46           4. MONTH
                        5. TWICE A MONTH
            4           6. YEAR
            5           7. OTHER (SPECIFY); including per visit, class, mile, job
                        8. DK (Don't Know)
                        9. RF (Refused)
        18064       Blank. INAP (Inapplicable)*/
					   
gen AnnualInc_Piecework_02=.
replace AnnualInc_Piecework_=HoursPerWeek_*WeeksPerYear_*PieceworkPay_     if PayPeriodPW==1
replace AnnualInc_Piecework_=WeeksPerYear_*PieceworkPay_                   if PayPeriodPW==2
replace AnnualInc_Piecework_=(WeeksPerYear_/2)*PieceworkPay_               if PayPeriodPW==3
replace AnnualInc_Piecework_=12*PieceworkPay_                              if PayPeriodPW==4
replace AnnualInc_Piecework_=24*PieceworkPay_                              if PayPeriodPW==5
replace AnnualInc_Piecework_=PieceworkPay_                                 if PayPeriodPW==6		
replace AnnualInc_Piecework_=5*WeeksPerYear_*PieceworkPay_                 if PayPeriodPW==11

		
*****************************
* Other
*****************************
* Other Pay - Item G56R
gen OtherPay_02=HJ230
		replace OtherPay_02=. if OtherPay_02>999999998
		replace OtherPay_02=. if OtherPay_02==0
* Other Pay - Item G56S		
gen PayPeriodOther_02=HJ231
		replace PayPeriodOther_02=. if PayPeriodOther_02>11
		replace PayPeriodOther_02=. if PayPeriodOther_02==0	
	
	
/*     
HJ231    AMOUNT PAID- OTHER- PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         CAI Reference: BJ_CURRJOBELSEEMPD.J231_                     Ref 2000: G3580

        IWER: PROBE IF NECESSARY: Was that per hour, week, month, or year?

        PER:
        ..................................................................................
           15           1. HOUR
           22           2. WEEK
            8           3. EVERY TWO WEEKS/BI-WEEKLY
           28           4. MONTH
                        5. TWICE A MONTH
           44           6. YEAR
           37          11. Day
           17          97. OTHER (SPECIFY); including per visit, class, mile, job
                       98. DK (Don't Know); NA (Not Ascertained)
                       99. RF (Refused)
        17996       Blank. INAP (Inapplicable)	 */
	
gen AnnualInc_Other_02=.
	replace AnnualInc_Other_=HoursPerWeek_*WeeksPerYear_*(OtherPay_)     if PayPeriodOther==1
	replace AnnualInc_Other_=WeeksPerYear_*OtherPay_                     if PayPeriodOther==2
	replace AnnualInc_Other_=(WeeksPerYear_/2)*OtherPay_                 if PayPeriodOther==3	
	replace AnnualInc_Other_=12*OtherPay_                                if PayPeriodOther==4
	replace AnnualInc_Other_=24*OtherPay_                                if PayPeriodOther==5	
	replace AnnualInc_Other_=OtherPay_                                   if PayPeriodOther==6		
	replace AnnualInc_Other_=5*WeeksPerYear_*OtherPay_ 	                 if PayPeriodOther==11
	
*************************************************
* Indicator for Same Job Title as Previous Wave:	
*************************************************	

/* 
HJ045    STILL WORKING PREV EMPLOYER
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: BJ_PWELSENOWELSE.J045_StillWrkPrevEmp        Ref 2000: G3416

        According to our records, in [R LAST IW MONTH], [R LAST IW YEAR] you were
        (working for [R LAST IW EMPLOYER NAME]/also working for someone else).

        Are you still working there?
        ..................................................................................
         3184           1. YES
          768           5. NO
          110           7. DENIES WORKING (FOR NAMED EMPLOYER)
                        8. DK (Don't Know); NA (Not Ascertained)
            3           9. RF (Refused)
        14102       Blank. INAP (Inapplicable)


HJ058    SAME JOB TITLE AS PREVIOUS WAVE
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: BJ_PWELSENOWELSE.J058_SameJobTitle           Ref 2000: G3432

        In [R LAST IW MONTH], [R LAST IW YEAR] our records indicate that your job
        title was [R LAST IW JOB TITLE]. Is this still the case?

        IWER: IF JOB TITLE IS SLIGHTLY INACCURATE BUT DESCRIBES R'S CURRENT JOB,
        ANSWER 'YES' HERE AND NOTE CORRECTIONS AS A COMMENT */
		
	
* Item G19B
gen SameEmp_02=HJ045


* Items on Job Characterisitcs

gen SameJob_02=HJ058
		 /*            
			 2691           1. YES
			   11           3. RETIRED & WORKING FOR SAME EMPLOYER/BUSINESS
			  256           5. NO
			   11           7. DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE  */ 
gen SameJobTBranch_02=HJ516 
	     /*  J516 BRANCHPOINT
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: BJ_FINDINGAJOB.J516_                         Ref 2000: G3799
        ..................................................................................
         2677           1. SAME JOB TITLE AS PREVIOUS WAVE
         1064           2. SELF EMPLOYED NOW AND SELF EMPLOYED PREV WAVE
        13896           3. ALL OTHERS  */


gen Job_Ind_02=HJ166M
gen Job_Occ_02=HJ168M	
	
	
*******************************
* Second Job 
*******************************
* Second Job Hours Per Week - G129
gen Job2_HoursPerWeek_02=HJ556
	replace Job2_HoursPerWeek_02=. if Job2_HoursPerWeek_02>96
* Second Job Weeks Per Year - G130
gen Job2_WeeksPerYear_02=HJ557
	replace Job2_WeeksPerYear_02=. if Job2_WeeksPerYear_02>52
* Pay Second Job - G131	
gen Job2Pay_02=HJ558
    replace Job2Pay_02=. if Job2Pay_02>=999999998

* Pay Period Second Job - G131A	
gen PayPeriodJob2_02=HJ562
	replace PayPeriodJob2_02=. if PayPeriodJob2_02>11
	replace PayPeriodJob2_02=. if PayPeriodJob2_02==0
	
/*
HJ562    EARNINGS ON SECOND JOB - PER
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: BJ_2NDJOBANDPLANTORETIRE.J562_               Ref 2000: G3843

        (About how much do you earn before taxes from (this other job/these other
        jobs)?)

        IWER: PROBE IF NECESSARY: Is that per hour, week, month, year, or what?

        PER:
        ..................................................................................
           94           1. HOUR
           47           2. WEEK
           10           3. EVERY TWO WEEKS/BI-WEEKLY
           34           4. MONTH
            1           5. TWICE A MONTH
          251           6. YEAR
           20           7. OTHER (SPECIFY)
                        8. DK (Don't Know)
                        9. RF (Refused)
        17710       Blank. INAP (Inapplicable) */
					   
	
gen AnnualInc_Job2_02=.
replace AnnualInc_Job2=Job2_HoursPerWeek_*Job2_WeeksPerYear_*(Job2Pay_)     if PayPeriodJob2==1
replace AnnualInc_Job2=Job2_WeeksPerYear_*Job2Pay_                          if PayPeriodJob2==2
replace AnnualInc_Job2=(Job2_WeeksPerYear_/2)*Job2Pay_                      if PayPeriodJob2==3
replace AnnualInc_Job2=12*Job2Pay_                                          if PayPeriodJob2==4
replace AnnualInc_Job2=24*Job2Pay_                                          if PayPeriodJob2==5
replace AnnualInc_Job2=Job2Pay_                                             if PayPeriodJob2==6
replace AnnualInc_Job2=5*Job2_WeeksPerYear_*Job2Pay_                        if PayPeriodJob2==11
		
* Sum these income sources for paid employees, treating missings as zeros. 
egen AnnualInc_PE_02=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ AnnualInc_Job2_), missing

egen AnnualInc_PEJ1_02=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ ), missing
	
**************************
* Self Employees
**************************	
	
	
* Hours Per Week - Self Employees - (Same as for Paid Employees from this wave on *
* Weeks Per Year - Self Employees - (Same as for Paid Employees from this wave on *
gen HoursPerWeekSE_02=.
replace HoursPerWeekSE_02=HoursPerWeek_02 if SelfEmp==1

gen WeeksPerYearSE_02=.
replace WeeksPerYearSE_02=WeeksPerYear_02 if SelfEmp==1


* Binary Indicating whether they receive a salary from this business: G52		
gen SelfEmp_RegSalary02=HJ187
	replace SelfEmp_RegSalary02=. if SelfEmp_RegSalary02>5 | SelfEmp_RegSalary02==0
	replace SelfEmp_RegSalary02=0 if SelfEmp_RegSalary02==5
	
* Salary Amount - Self Employees - G52A	
gen SelfEmp_Salary02=HJ188	
	replace SelfEmp_Salary02=. if SelfEmp_Salary02>=999999998
	replace SelfEmp_Salary02=. if SelfEmp_Salary02==0
	
* Salary Pay Period - Self Employees - G52B	
gen SelfEmp_PayPeriod02=HJ192
	replace SelfEmp_PayPeriod02=. if SelfEmp_PayPeriod02>11 | SelfEmp_PayPeriod02==0

/*
HJ192    SELF-EMPLOYMENT SALARY AMOUNT PER
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: BJ_CURRJOBSELFEMPD.J192_                     Ref 2000: G3541

        (How much are you paid before taxes and other deductions?)



        PER:
        ..................................................................................
           82           1. HOUR
           88           2. WEEK
            6           3. EVERY TWO WEEKS/BI-WEEKLY
           59           4. MONTH
            2           5. TWICE A MONTH
          111           6. YEAR
           14           7. OTHER (SPECIFY); including per visit, class, mile, job
                        8. DK (Don't Know); NA (Not Ascertained)
                        9. RF (Refused) */	
	
	
* Construct Annual Salary for Self-Employees

gen AnnualSalSE_02=.
		replace AnnualSalSE=WeeksPerYearSE*HoursPerWeekSE*(SelfEmp_Salary)        if SelfEmp_PayPeriod==1
		replace AnnualSalSE=WeeksPerYearSE*SelfEmp_Salary                         if SelfEmp_PayPeriod==2
		replace AnnualSalSE=(WeeksPerYearSE/2)*SelfEmp_Salary                     if SelfEmp_PayPeriod==3
		replace AnnualSalSE=12*SelfEmp_Salary                                     if SelfEmp_PayPeriod==4
		replace AnnualSalSE=24*SelfEmp_Salary                                     if SelfEmp_PayPeriod==5		
		replace AnnualSalSE=SelfEmp_Salary                                        if SelfEmp_PayPeriod==6
		replace AnnualSalSE=5*WeeksPerYearSE*SelfEmp_Salary                       if SelfEmp_PayPeriod==11
	
	
* Binary Variable Indicating whether the self-employee gets profits from the business G53
gen SelfEmp_GetProfit02=HJ194
	replace SelfEmp_GetProfit02=. if SelfEmp_GetProfit02>5 | SelfEmp_GetProfit02==0

* Profit Amount - G53A
gen SelfEmp_Profit_02=HJ195
	replace SelfEmp_Profit_02=. if SelfEmp_Profit_02>=9999999998

gen SelfEmp_ProfitPeriod02=HJ199 
	replace SelfEmp_ProfitPeriod02=. if SelfEmp_ProfitPeriod02>11 | SelfEmp_ProfitPeriod02==0
	
/*
HJ199    AMT NET EARNINGS/PROFITS PER
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: BJ_CURRJOBSELFEMPD.J199_                     Ref 2000: G3545

        (In addition to your regular salary, how/How) much do you receive from net
        earnings or profits?


        PER:
        ..................................................................................
           10           1. HOUR
           23           2. WEEK
            3           3. EVERY TWO WEEKS/BI-WEEKLY
           33           4. MONTH
                        5. TWICE A MONTH
          573           6. YEAR
           12           7. OTHER (SPECIFY)
                        8. DK (Don't Know); NA (Not Ascertained)
                        9. RF (Refused)*/
						
		
gen AnnualProfSE_02=.
		replace AnnualProfSE_=WeeksPerYearSE_*HoursPerWeekSE*SelfEmp_Profit_  if SelfEmp_ProfitPeriod==1
		replace AnnualProfSE_=WeeksPerYearSE_*SelfEmp_Profit_                 if SelfEmp_ProfitPeriod==2
		replace AnnualProfSE_=(WeeksPerYearSE_/2)*SelfEmp_Profit_             if SelfEmp_ProfitPeriod==3
		replace AnnualProfSE_=12*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==4
		replace AnnualProfSE_=24*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==5		
		replace AnnualProfSE_=SelfEmp_Profit_                                 if SelfEmp_ProfitPeriod==6
		replace AnnualProfSE_=5*WeeksPerYearSE_*SelfEmp_Profit_               if SelfEmp_ProfitPeriod==11
	


egen AnnualInc_SE_02=rowtotal(AnnualSalSE_ AnnualProfSE_), missing
	

egen AnnualIncTot_02=rowtotal(AnnualInc_PE_ AnnualInc_SE_), missing

keep HHID PN *SUBHH *FINR Working *Retired* HomeMaker WorkForPay SelfEmp_02 AnnualInc_PE_ AnnualInc_PEJ1_ AnnualInc_SE_ AnnualIncTot_ *Same*Emp* *SameJob* *Job_Ind* *Job_Occ* WeeksPerYear* *HoursPerWeek*

gen YEAR=2002

save "$CleanData/HRSEmpInc02.dta", replace






/* Employment Answers from 2004 - New Format */
clear all
infile using "$HRSSurveys04/h04sta/H04J_R.dct" , using("$HRSSurveys04/h04da/H04J_R.da")


* Get indicators for whether the respondent is currently  Working / Retired / HomeMaker, 
* which are recorded as binary variables from the G1 survey items. 

gen Working_04=0
gen Retired_04=0
gen HomeMaker_04=0

forvalues QN=1(1)5{

replace Working_04=1   if JJ005M`QN'==1
replace Retired_04=1   if JJ005M`QN'==5
replace HomeMaker_04=1 if JJ005M`QN'==6

}

gen MonthRetired_04=JJ017
gen YearRetired_04=JJ018


* WorkForPay - item G2, asks whether the individual is doing any work for pay
* at the present time.  This variable is almost identical to Working above, but
* there are some respodnents who are coded as "1" for WorkForPay, but "0" for 
* Working.  These are mostly individuals who are on sick leave, retired, etc. 

gen WorkForPay_04=JJ020
	replace WorkForPay_04=0 if WorkForPay_04==5
	replace WorkForPay_04=. if WorkForPay_04>5

* Self Employed - item G3.  This item and future items ask about "current, main job"
* This item asks if individuals work for someone else or are self-employed / run own business	
	
gen SelfEmp_04=JJ021
	replace SelfEmp=0 if SelfEmp==1
	replace SelfEmp=1 if SelfEmp==2
	replace SelfEmp=. if SelfEmp>2
	
* HoursPerWeek - item G44.  How many hours a week do you usually work on this job? (98 / 99 are DK / NA)
* Notice that HoursPerWeek is set to 0 for individuals who are self-employed.  We set 0 to missing here:

gen HoursPerWeek_04=JJ172
	replace HoursPerWeek_04=. if HoursPerWeek_04>168
	
* WeeksPerYear - item G47.  How many weeks do you work per year, including paid vacations.  
* This is set to zero for self-employees.  We set 0 to missing.

gen WeeksPerYear_04=JJ179
		replace WeeksPerYear_04=. if WeeksPerYear_04>52
				  
gen HowPaidPE_04=JJ205
		replace HowPaidPE_04=. if HowPaidPE_04>=8
		
/*         
JJ205    HOW PAID ON JOB
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J205_
         2000 Link: G3555 2002 Link: HJ205

        Are you salaried on this job, paid by the hour, or what?
        ..................................................................................
         2138           1. SALARIED
         3492           2. HOURLY
          168           3. PIECEWORK/COMMISSION
          259           7. OTHER/COMBINATION
            5           8. DK (Don't Know); NA (Not Ascertained)
           10           9. RF (Refused)
        14057       Blank. INAP (Inapplicable)) */		

********************************************************************************
* Workers could receive income either from salary, hourly wages, commission, or 
* other compensation schemes, and here we create separate earnings variables for 
* each kind of earnings flow.		
********************************************************************************		
		
*********************
* Salaried Workers
*********************			
		
* Salary - item G56a.  How much is your SALARY before taxes and other deductions.
* This will be zero for those who are paid hourly, and those who are self-employed.
* We set 0 equal to missings 		
		
gen Salary_04=JJ206
		replace Salary_04=. if Salary_04>=999999998
		replace Salary_04=. if Salary_04==0

gen PayPeriodSal_04=JJ210
		replace PayPeriodSal_04=. if PayPeriodSal_04>11
		
* PayPeriod - item G56B.  In the previous question, how often is the reported
* salary received: 		
/*
JJ210    AMOUNT OF SALARY ON JOB PER
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J210_
         2000 Link: G3558 2002 Link: HJ210

        (How much is your salary, before taxes and other deductions?)
        INTERVIEWER: IF RESPONDENT IS A TEACHER, RECORD ANNUAL SALARY
        PROBE IF NECESSARY: Is that per hour, week, month, or year?
        AMOUNT:  (AMOUNT OF SALARY ON JOB)
        PER:
        ..................................................................................
           27           1. HOUR
          164           2. WEEK
           65           3. EVERY TWO WEEKS/BI-WEEKLY
          232           4. MONTH
            3           5. TWICE A MONTH
         1351           6. YEAR
           20           7. OTHER (SPECIFY)
            1           8. DK (Don't Know); NA (Not Ascertained)
                        9. RF (Refused)
        18266       Blank. INAP (Inapplicable)
					   */

* Calculate Annual Salary based on responses, with different calculations
* for each pay period:		
gen AnnualInc_Salary_04=.
replace AnnualInc_Salary=HoursPerWeek_*WeeksPerYear_*Salary     if PayPeriodSal==1
replace AnnualInc_Salary=WeeksPerYear_*Salary                   if PayPeriodSal==2
replace AnnualInc_Salary=(WeeksPerYear_/2)*Salary               if PayPeriodSal==3		
replace AnnualInc_Salary=12*Salary                              if PayPeriodSal==4
replace AnnualInc_Salary=24*Salary                              if PayPeriodSal==5
replace AnnualInc_Salary=Salary                                 if PayPeriodSal==6	
replace AnnualInc_Salary=5*WeeksPerYear_*Salary                 if PayPeriodSal==11
						   

*********************
* Hourly Workers
*********************						   
	* Hourly Wage Rate - item G56F.  We set zeros equal to missing.
gen HourlyPay_04=JJ216
		replace HourlyPay_04=. if HourlyPay_04>=10000
		replace HourlyPay_04=. if HourlyPay_04==0
				
gen AnnualInc_Hourly_04=HoursPerWeek_*WeeksPerYear_*HourlyPay_
				
				
************************
* PIECEWORK/COMMISSION 	
************************		
* Piecework Pay - Note that in the code book this is listed as "Overtime Pay"
* but this is only non-missing for individuals who have a value of 3 for JJ205
gen PieceworkPay_04=JJ225	
	replace PieceworkPay_04=. if PieceworkPay_04>=99999998
	replace PieceworkPay_04=. if PieceworkPay_04==0
* Piecework Pay Time Period - Item G56N		
gen PayPeriodPW_04=JJ226		
	replace PayPeriodPW_04=. if PayPeriodPW_04>11
	replace PayPeriodPW_04=. if PayPeriodPW_04==0	
	
/*
JJ226    AMOUNT PAID FOR OVERTIME PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         CAI Reference: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J226_
         2000 Link: G3575 2002 Link: HJ226

        INTERVIEWER: PROBE IF NECESSARY: Is that per week or month?
        AMOUNT:  (AMOUNT PAID FOR OVERTIME)
        PER:
        ..................................................................................
                        1. HOUR
           42           2. WEEK
                        3. EVERY TWO WEEKS/BI-WEEKLY
           65           4. MONTH
            1           5. TWICE A MONTH
           17           6. YEAR
            2          11. Day
            8          97. OTHER (SPECIFY); including per visit, class, mile, job
                       98. DK (Don't Know); NA (Not Ascertained)
                       99. RF (Refused)
        19994       Blank. INAP (Inapplicable)
*/
					   
gen AnnualInc_Piecework_04=.
replace AnnualInc_Piecework_=HoursPerWeek_*WeeksPerYear_*PieceworkPay_     if PayPeriodPW==1
replace AnnualInc_Piecework_=WeeksPerYear_*PieceworkPay_                   if PayPeriodPW==2
replace AnnualInc_Piecework_=(WeeksPerYear_/2)*PieceworkPay_               if PayPeriodPW==3
replace AnnualInc_Piecework_=12*PieceworkPay_                              if PayPeriodPW==4
replace AnnualInc_Piecework_=24*PieceworkPay_                              if PayPeriodPW==5
replace AnnualInc_Piecework_=PieceworkPay_                                 if PayPeriodPW==6		
replace AnnualInc_Piecework_=5*WeeksPerYear_*PieceworkPay_                 if PayPeriodPW==11

		
*****************************
* Other
*****************************
* Other Pay - Item G56R
gen OtherPay_04=JJ230
		replace OtherPay_04=. if OtherPay_04>999999998
		replace OtherPay_04=. if OtherPay_04==0
* Other Pay - Item G56S		
gen PayPeriodOther_04=JJ231
		replace PayPeriodOther_04=. if PayPeriodOther_04>11
		replace PayPeriodOther_04=. if PayPeriodOther_04==0	
	
	
/*     
JJ231    AMOUNT PAID- OTHER- PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         CAI Reference: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J231_
         2000 Link: G3580 2002 Link: HJ231

        INTERVIEWER: PROBE IF NECESSARY: Was that per hour, week, month, or year?
        AMOUNT:  (AMOUNT PAID- OTHER)
        PER:
        ..................................................................................
           22           1. HOUR
           27           2. WEEK
            9           3. EVERY TWO WEEKS/BI-WEEKLY
           25           4. MONTH
            1           5. TWICE A MONTH
           69           6. YEAR
           35          11. Day
           22          97. OTHER (SPECIFY); including per visit, class, mile, job
            1          98. DK (Don't Know); NA (Not Ascertained)
                       99. RF (Refused)
        19918       Blank. INAP (Inapplicable)	 */
	
gen AnnualInc_Other_04=.
	replace AnnualInc_Other_=HoursPerWeek_*WeeksPerYear_*(OtherPay_)     if PayPeriodOther==1
	replace AnnualInc_Other_=WeeksPerYear_*OtherPay_                     if PayPeriodOther==2
	replace AnnualInc_Other_=(WeeksPerYear_/2)*OtherPay_                 if PayPeriodOther==3	
	replace AnnualInc_Other_=12*OtherPay_                                if PayPeriodOther==4
	replace AnnualInc_Other_=24*OtherPay_                                if PayPeriodOther==5	
	replace AnnualInc_Other_=OtherPay_                                   if PayPeriodOther==6		
	replace AnnualInc_Other_=5*WeeksPerYear_*OtherPay_ 	                 if PayPeriodOther==11
	
	
*************************************************
* Indicator for Same Job Title as Previous Wave:	
*************************************************	



/* JJ058    SAME JOB TITLE AS PREVIOUS WAVE
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: SecJ.PREVIOUSJOBANDPENSION.PWELSENOWELSE.J058_SameJobTitle
         2000 Link: G3432 2002 Link: HJ058

        In  ([See Blaise Specifications for piRvarsZ092_IwMo_V assignment])  ([See
        Blaise Specifications for piRvarsZ093_IwYr_V assignment]) our records indicate
        that your job title was  ([See Blaise Specifications for
        piRvarsZ128_JobTitle_V assignment]) Is this still the case?
        INTERVIEWER: IF JOB TITLE IS SLIGHTLY INACCURATE BUT DESCRIBES R'S CURRENT
        JOB, ANSWER 'YES' HERE AND NOTE CORRECTIONS AS A COMMENT */
		
		
* Item G19B
gen SameEmp_04=JJ045

* Job Characteristics

gen SameJob_04=JJ058
		 /*            
		 2691           1. YES
           15           3. RETIRED & WORKING FOR SAME EMPLOYER/BUSINESS
          240           5. NO
           14           7. DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE */ 
gen SameJobTBranch_04=JJ516 
	     /*  JJ516    J516 BRANCHPOINT
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: SecJ.FINDINGAJOB.J516_
         2000 Link: G3799 2002 Link: HJ516
        ..................................................................................
         2487           1. SAME JOB TITLE AS PREVIOUS WAVE
          673           2. SELF EMPLOYED NOW AND SELF EMPLOYED PREV WAVE
         7579           3. ALL OTHERS
         9390       Blank. INAP (Inapplicable)  */

gen Job_Ind_04=JJ166M
gen Job_Occ_04=JJ168M	
	
*******************************
* Second Job 
*******************************
* Second Job Hours Per Week - G129
gen Job2_HoursPerWeek_04=JJ556
	replace Job2_HoursPerWeek_04=. if Job2_HoursPerWeek_04>96
* Second Job Weeks Per Year - G130
gen Job2_WeeksPerYear_04=JJ557
	replace Job2_WeeksPerYear_04=. if Job2_WeeksPerYear_04>52
* Pay Second Job - G131	
gen Job2Pay_04=JJ558
    replace Job2Pay_04=. if Job2Pay_04>=999999998

* Pay Period Second Job - G131A	
gen PayPeriodJob2_04=JJ562
	replace PayPeriodJob2_04=. if PayPeriodJob2_04>11
	replace PayPeriodJob2_04=. if PayPeriodJob2_04==0
	
/*
JJ562    EARNINGS ON SECOND JOB - PER
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: SecJ.SECONDJOBANDPLANTORETIRE.J562_
         2000 Link: G3843 2002 Link: HJ562

        (About how much do you earn before taxes from (this other job/these other
        jobs)?)
        INTERVIEWER: PROBE IF NECESSARY: Is that per hour, week, month, year, or what?
        AMOUNT:  (EARNINGS ON SECOND JOB)
        PER:
        ..................................................................................
          149           1. HOUR
           54           2. WEEK
           10           3. EVERY TWO WEEKS/BI-WEEKLY
           79           4. MONTH
                        5. TWICE A MONTH
          352           6. YEAR
           26           7. OTHER (SPECIFY)
                        8. DK (Don't Know); NA (Not Ascertained)
                        9. RF (Refused)
        19459       Blank. INAP (Inapplicable) */
					   
	
gen AnnualInc_Job2_04=.
replace AnnualInc_Job2=Job2_HoursPerWeek_*Job2_WeeksPerYear_*(Job2Pay_)     if PayPeriodJob2==1
replace AnnualInc_Job2=Job2_WeeksPerYear_*Job2Pay_                          if PayPeriodJob2==2
replace AnnualInc_Job2=(Job2_WeeksPerYear_/2)*Job2Pay_                      if PayPeriodJob2==3
replace AnnualInc_Job2=12*Job2Pay_                                          if PayPeriodJob2==4
replace AnnualInc_Job2=24*Job2Pay_                                          if PayPeriodJob2==5
replace AnnualInc_Job2=Job2Pay_                                             if PayPeriodJob2==6
replace AnnualInc_Job2=5*Job2_WeeksPerYear_*Job2Pay_                        if PayPeriodJob2==11
		
* Sum these income sources for paid employees, treating missings as zeros. 
egen AnnualInc_PE_04=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ AnnualInc_Job2_), missing

egen AnnualInc_PEJ1_04=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ ), missing
	
**************************
* Self Employees
**************************	
	
	
* Hours Per Week - Self Employees - (Same as for Paid Employees from this wave on *
* Weeks Per Year - Self Employees - (Same as for Paid Employees from this wave on *
gen HoursPerWeekSE_04=.
replace HoursPerWeekSE_04=HoursPerWeek_04 if SelfEmp==1

gen WeeksPerYearSE_04=.
replace WeeksPerYearSE_04=WeeksPerYear_04 if SelfEmp==1


* Binary Indicating whether they receive a salary from this business: G52		
gen SelfEmp_RegSalary04=JJ187
	replace SelfEmp_RegSalary04=. if SelfEmp_RegSalary04>5 | SelfEmp_RegSalary04==0
	replace SelfEmp_RegSalary04=0 if SelfEmp_RegSalary04==5
	
* Salary Amount - Self Employees - G52A	
gen SelfEmp_Salary04=JJ188	
	replace SelfEmp_Salary04=. if SelfEmp_Salary04>=999999998
	replace SelfEmp_Salary04=. if SelfEmp_Salary04==0
	
* Salary Pay Period - Self Employees - G52B	
gen SelfEmp_PayPeriod04=JJ192
	replace SelfEmp_PayPeriod04=. if SelfEmp_PayPeriod04>11 | SelfEmp_PayPeriod04==0

/*
JJ192    SELF-EMPLOYMENT SALARY AMOUNT PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         CAI Reference: SecJ.CURRENTJOB.CURRJOBSELFEMPD.J192_
         2000 Link: G3541 2002 Link: HJ192

        (How much are you paid before taxes and other deductions?)
        AMOUNT:  (SELF-EMPLOYMENT SALARY AMOUNT)
        PER:
        ..................................................................................
          107           1. HOUR
          121           2. WEEK
           10           3. EVERY TWO WEEKS/BI-WEEKLY
           91           4. MONTH
            2           5. TWICE A MONTH
          122           6. YEAR
            1          11. Day
           20          97. OTHER (SPECIFY); including per visit, class, mile, job
                       98. DK (Don't Know); NA (Not Ascertained)
                       99. RF (Refused)
        19655       Blank. INAP (Inapplicable) */
	
	
* Construct Annual Salary for Self-Employees

gen AnnualSalSE_04=.
		replace AnnualSalSE=WeeksPerYearSE*HoursPerWeekSE*(SelfEmp_Salary)        if SelfEmp_PayPeriod==1
		replace AnnualSalSE=WeeksPerYearSE*SelfEmp_Salary                         if SelfEmp_PayPeriod==2
		replace AnnualSalSE=(WeeksPerYearSE/2)*SelfEmp_Salary                     if SelfEmp_PayPeriod==3
		replace AnnualSalSE=12*SelfEmp_Salary                                     if SelfEmp_PayPeriod==4
		replace AnnualSalSE=24*SelfEmp_Salary                                     if SelfEmp_PayPeriod==5		
		replace AnnualSalSE=SelfEmp_Salary                                        if SelfEmp_PayPeriod==6
		replace AnnualSalSE=5*WeeksPerYearSE*SelfEmp_Salary                       if SelfEmp_PayPeriod==11
	
	
* Binary Variable Indicating whether the self-employee gets profits from the business G53
gen SelfEmp_GetProfit04=JJ194
	replace SelfEmp_GetProfit04=. if SelfEmp_GetProfit04>5 | SelfEmp_GetProfit04==0

* Profit Amount - G53A
gen SelfEmp_Profit_04=JJ195
	replace SelfEmp_Profit_04=. if SelfEmp_Profit_04>=99999999998

gen SelfEmp_ProfitPeriod04=JJ199 
	replace SelfEmp_ProfitPeriod04=. if SelfEmp_ProfitPeriod04>11 | SelfEmp_ProfitPeriod04==0
	
/*
JJ199    AMT NET EARNINGS/PROFITS PER
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: SecJ.CURRENTJOB.CURRJOBSELFEMPD.J199_
         2000 Link: G3545 2002 Link: HJ199

        ( (In addition to your regular salary, how\How) much do you receive from net
        earnings or profits?)
        AMOUNT:  (AMT NET EARNINGS/PROFITS)
        PER:
        ..................................................................................
           22           1. HOUR
           48           2. WEEK
            3           3. EVERY TWO WEEKS/BI-WEEKLY
           64           4. MONTH
                        5. TWICE A MONTH
          685           6. YEAR
           19           7. OTHER (SPECIFY)
            1           8. DK (Don't Know); NA (Not Ascertained)
                        9. RF (Refused)
        19287       Blank. INAP (Inapplicable)*/
						
		
gen AnnualProfSE_04=.
		replace AnnualProfSE_=WeeksPerYearSE_*HoursPerWeekSE*SelfEmp_Profit_  if SelfEmp_ProfitPeriod==1
		replace AnnualProfSE_=WeeksPerYearSE_*SelfEmp_Profit_                 if SelfEmp_ProfitPeriod==2
		replace AnnualProfSE_=(WeeksPerYearSE_/2)*SelfEmp_Profit_             if SelfEmp_ProfitPeriod==3
		replace AnnualProfSE_=12*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==4
		replace AnnualProfSE_=24*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==5		
		replace AnnualProfSE_=SelfEmp_Profit_                                 if SelfEmp_ProfitPeriod==6
		replace AnnualProfSE_=5*WeeksPerYearSE_*SelfEmp_Profit_               if SelfEmp_ProfitPeriod==11
	


egen AnnualInc_SE_04=rowtotal(AnnualSalSE_ AnnualProfSE_), missing
	

egen AnnualIncTot_04=rowtotal(AnnualInc_PE_ AnnualInc_SE_), missing

keep HHID PN *SUBHH *FINR Working *Retired* HomeMaker WorkForPay SelfEmp_04 AnnualInc_PE_ AnnualInc_PEJ1_ AnnualInc_SE_ AnnualIncTot_ *Same*Emp* *SameJob* *Job_Ind* *Job_Occ* WeeksPerYear* *HoursPerWeek*

gen YEAR=2004

save "$CleanData/HRSEmpInc04.dta", replace




/* Employment Answers from 2006 - New Format */
clear all
infile using "$HRSSurveys06/h06sta/H06J_R.dct" , using("$HRSSurveys06/h06da/H06J_R.da")

* Get indicators for whether the respondent is currently  Working / Retired / HomeMaker, 
* which are recorded as binary variables from the G1 survey items. 

gen Working_06=0
gen Retired_06=0
gen HomeMaker_06=0

forvalues QN=1(1)5{

replace Working_06=1   if KJ005M`QN'==1
replace Retired_06=1   if KJ005M`QN'==5
replace HomeMaker_06=1 if KJ005M`QN'==6

}

gen MonthRetired_06=KJ017
gen YearRetired_06=KJ018


* WorkForPay - item G2, asks whether the individual is doing any work for pay
* at the present time.  This variable is almost identical to Working above, but
* there are some respodnents who are coded as "1" for WorkForPay, but "0" for 
* Working.  These are mostly individuals who are on sick leave, retired, etc. 

gen WorkForPay_06=KJ020
	replace WorkForPay_06=0 if WorkForPay_06==5
	replace WorkForPay_06=. if WorkForPay_06>5

* Self Employed - item G3.  This item and future items ask about "current, main job"
* This item asks if individuals work for someone else or are self-employed / run own business	
	
gen SelfEmp_06=KJ021
	replace SelfEmp=0 if SelfEmp==1
	replace SelfEmp=1 if SelfEmp==2
	replace SelfEmp=. if SelfEmp>2
	
* HoursPerWeek - item G44.  How many hours a week do you usually work on this job? (98 / 99 are DK / NA)
* Notice that HoursPerWeek is set to 0 for individuals who are self-employed.  We set 0 to missing here:

gen HoursPerWeek_06=KJ172
	replace HoursPerWeek_06=. if HoursPerWeek_06>168
	
* WeeksPerYear - item G47.  How many weeks do you work per year, including paid vacations.  
* This is set to zero for self-employees.  We set 0 to missing.

gen WeeksPerYear_06=KJ179
		replace WeeksPerYear_06=. if WeeksPerYear_06>52
				  
gen HowPaidPE_06=KJ205
		replace HowPaidPE_06=. if HowPaidPE_06>=8
		
/*         
KJ205          HOW PAID ON JOB
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J205_

         Are you salaried on this job, paid by the hour, or what?

         .................................................................................
          1773           1.  SALARIED
          2983           2.  HOURLY
           146           3.  PIECEWORK/COMMISSION
           178           7.  OTHER/COMBINATION
             5           8.  DK (Don't Know); NA (Not Ascertained)
             6           9.  RF (Refused)
         13378       Blank.  INAP (Inapplicable); */		

********************************************************************************
* Workers could receive income either from salary, hourly wages, commission, or 
* other compensation schemes, and here we create separate earnings variables for 
* each kind of earnings flow.		
********************************************************************************		
		
*********************
* Salaried Workers
*********************			
		
* Salary - item G56a.  How much is your SALARY before taxes and other deductions.
* This will be zero for those who are paid hourly, and those who are self-employed.
* We set 0 equal to missings 		
		
gen Salary_06=KJ206
		replace Salary_06=. if Salary_06>=99999999998
		replace Salary_06=. if Salary_06==0

gen PayPeriodSal_06=KJ210
		replace PayPeriodSal_06=. if PayPeriodSal_06>11
		
* PayPeriod - item G56B.  In the previous question, how often is the reported
* salary received: 		
/*
KJ210          AMOUNT OF SALARY ON JOB PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J210_

         (How much is your salary, before taxes and other deductions?)
         
            If respondent is a teacher, record annual salary
         
           PROBE if necessary:  Is that per hour, week, month, or year?
         
         Amount: [AMOUNT OF SALARY ON JOB]
         
          Per:

         .................................................................................
            27           1.  HOUR
           151           2.  WEEK
            64           3.  EVERY TWO WEEKS/BI-WEEKLY
           181           4.  MONTH
             3           5.  TWICE A MONTH
          1152           6.  YEAR
             1          11.  Day
            19          97.  OTHER (SPECIFY)
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         16871       Blank.  INAP (Inapplicable); Partial Interview

					   */

* Calculate Annual Salary based on responses, with different calculations
* for each pay period:		
gen AnnualInc_Salary_06=.
replace AnnualInc_Salary=HoursPerWeek_*WeeksPerYear_*Salary     if PayPeriodSal==1
replace AnnualInc_Salary=WeeksPerYear_*Salary                   if PayPeriodSal==2
replace AnnualInc_Salary=(WeeksPerYear_/2)*Salary               if PayPeriodSal==3		
replace AnnualInc_Salary=12*Salary                              if PayPeriodSal==4
replace AnnualInc_Salary=24*Salary                              if PayPeriodSal==5
replace AnnualInc_Salary=Salary                                 if PayPeriodSal==6	
replace AnnualInc_Salary=5*WeeksPerYear_*Salary                 if PayPeriodSal==11
						   

*********************
* Hourly Workers
*********************						   
	* Hourly Wage Rate - item G56F.  We set zeros equal to missing.
gen HourlyPay_06=KJ216
		replace HourlyPay_06=. if HourlyPay_06>=10000
		replace HourlyPay_06=. if HourlyPay_06==0
				
gen AnnualInc_Hourly_06=HoursPerWeek_*WeeksPerYear_*HourlyPay_
				
				
************************
* PIECEWORK/COMMISSION 	
************************		
* Piecework Pay - Note that in the code book this is listed as "Overtime Pay"
* but this is only non-missing for individuals who have a value of 3 for KJ205
gen PieceworkPay_06=KJ225	
	replace PieceworkPay_06=. if PieceworkPay_06>=99999999998
	replace PieceworkPay_06=. if PieceworkPay_06==0
* Piecework Pay Time Period - Item G56N		
gen PayPeriodPW_06=KJ226		
	replace PayPeriodPW_06=. if PayPeriodPW_06>11
	replace PayPeriodPW_06=. if PayPeriodPW_06==0	
	
/*
KJ226          AMOUNT PAID FOR OVERTIME PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J226_

         PROBE if necessary:  Is that per week or month?
         
         Amount: [AMOUNT PAID FOR OVERTIME]
         
          Per:

         .................................................................................
             1           1.  HOUR
            50           2.  WEEK
                         3.  EVERY TWO WEEKS/BI-WEEKLY
            49           4.  MONTH
                         5.  TWICE A MONTH
            12           6.  YEAR
             8          11.  Day
             5          97.  OTHER (SPECIFY); including per visit, class, mile, job
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         18344       Blank.  INAP (Inapplicable); Partial Interview

*/
					   
gen AnnualInc_Piecework_06=.
replace AnnualInc_Piecework_=HoursPerWeek_*WeeksPerYear_*PieceworkPay_     if PayPeriodPW==1
replace AnnualInc_Piecework_=WeeksPerYear_*PieceworkPay_                   if PayPeriodPW==2
replace AnnualInc_Piecework_=(WeeksPerYear_/2)*PieceworkPay_               if PayPeriodPW==3
replace AnnualInc_Piecework_=12*PieceworkPay_                              if PayPeriodPW==4
replace AnnualInc_Piecework_=24*PieceworkPay_                              if PayPeriodPW==5
replace AnnualInc_Piecework_=PieceworkPay_                                 if PayPeriodPW==6		
replace AnnualInc_Piecework_=5*WeeksPerYear_*PieceworkPay_                 if PayPeriodPW==11

		
*****************************
* Other
*****************************
* Other Pay - Item G56R
gen OtherPay_06=KJ230
		replace OtherPay_06=. if OtherPay_06>99999999998
		replace OtherPay_06=. if OtherPay_06==0
* Other Pay - Item G56S		
gen PayPeriodOther_06=KJ231
		replace PayPeriodOther_06=. if PayPeriodOther_06>11
		replace PayPeriodOther_06=. if PayPeriodOther_06==0	
	
	
/*     
KJ231          AMOUNT PAID- OTHER- PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J231_

         PROBE if necessary:  Was that per hour, week, month, or year?
         
         Amount: [AMOUNT PAID- OTHER]
         
          Per:

         .................................................................................
            20           1.  HOUR
            15           2.  WEEK
             6           3.  EVERY TWO WEEKS/BI-WEEKLY
            14           4.  MONTH
             1           5.  TWICE A MONTH
            38           6.  YEAR
            39          11.  Day
            14          97.  OTHER (SPECIFY); including per visit, class, mile, job
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         18322       Blank.  INAP (Inapplicable); Partial Interview
	 */
	
gen AnnualInc_Other_06=.
	replace AnnualInc_Other_=HoursPerWeek_*WeeksPerYear_*(OtherPay_)     if PayPeriodOther==1
	replace AnnualInc_Other_=WeeksPerYear_*OtherPay_                     if PayPeriodOther==2
	replace AnnualInc_Other_=(WeeksPerYear_/2)*OtherPay_                 if PayPeriodOther==3	
	replace AnnualInc_Other_=12*OtherPay_                                if PayPeriodOther==4
	replace AnnualInc_Other_=24*OtherPay_                                if PayPeriodOther==5	
	replace AnnualInc_Other_=OtherPay_                                   if PayPeriodOther==6		
	replace AnnualInc_Other_=5*WeeksPerYear_*OtherPay_ 	                 if PayPeriodOther==11
	
	
*************************************************
* Indicator for Same Job Title as Previous Wave:	
*************************************************	



/* KJ058          SAME JOB TITLE AS PREVIOUS WAVE
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         Ref: SecJ.PREVIOUSJOBANDPENSION.PWELSENOWELSE.J058_SameJobTitle

         In [PREV WAVE FIRST R IW MONTH]/[/Prev Wave Iw Mo] [Previous Wave First R
         Interview Year]/[Prev Wave Iw Yr] our records indicate that your job title was
         [PREV WAVE JOB TITLE]. Is this still the case?
         
            If job title is slightly inaccurate but describes R's current job, answer
         'yes' here and note corrections as a comment

         .................................................................................
          1890           1.  YES
             5           3.  RETIRED & WORKING FOR SAME EMPLOYER/BUSINESS
           224           5.  NO
             6           7.  DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE
                         8.  DK (Don't Know); NA (Not Ascertained)
                         9.  RF (Refused)
         16344       Blank.  INAP (Inapplicable); Partial Interview*/
		 

* Item G19B
gen SameEmp_06=KJ045
	
* Job Characteristics

gen SameJob_06=KJ058
		 /*            
		  1890           1.  YES
             5           3.  RETIRED & WORKING FOR SAME EMPLOYER/BUSINESS
           224           5.  NO
             6           7.  DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE */ 
gen SameJobTBranch_06=KJ516 
	     /* J516 BRANCHPOINT
         Section: J     Level: Respondent      Type: Numeric    Width: 10  Decimals: 0
         Ref: SecJ.FINDINGAJOB.J516_

         .................................................................................
          1793           1.  J058_SameJobTitle = YES
           751           2.  (J021 = SLFEMPD) AND (Z136 = SLF)) AND (J712 <= A502) AND
                             712 <> EMPTY
          6831           3.  All Others
          9094       Blank.  INAP (Inapplicable); Partial Interview  */


gen Job_Ind_06=KJ166M
gen Job_Occ_06=KJ168M		 
		 
*******************************
* Second Job 
*******************************
* Second Job Hours Per Week - G129
gen Job2_HoursPerWeek_06=KJ556
	replace Job2_HoursPerWeek_06=. if Job2_HoursPerWeek_06>96
* Second Job Weeks Per Year - G130
gen Job2_WeeksPerYear_06=KJ557
	replace Job2_WeeksPerYear_06=. if Job2_WeeksPerYear_06>52
* Pay Second Job - G131	
gen Job2Pay_06=KJ558
    replace Job2Pay_06=. if Job2Pay_06>=99999999998

* Pay Period Second Job - G131A	
gen PayPeriodJob2_06=KJ562
	replace PayPeriodJob2_06=. if PayPeriodJob2_06>11
	replace PayPeriodJob2_06=. if PayPeriodJob2_06==0
	
/*
KJ562          EARNINGS ON SECOND JOB - PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.SECONDJOBANDPLANTORETIRE.J562_

         (About how much do you earn before taxes from (this other job/these other
         jobs)?)
         
            PROBE if necessary:  Is that per hour, week, month, year, or what?
         
         Amount: [EARNINGS ON SECOND JOB]
         
          Per:

         .................................................................................
           119           1.  HOUR
            61           2.  WEEK
            13           3.  EVERY TWO WEEKS/BI-WEEKLY
            61           4.  MONTH
             3           5.  TWICE A MONTH
           272           6.  YEAR
             9          11.  Day
             9          97.  OTHER (SPECIFY); including per visit, class, mile, job
             1          98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         17921       Blank.  INAP (Inapplicable); Partial Interview

 */
					   
	
gen AnnualInc_Job2_06=.
replace AnnualInc_Job2=Job2_HoursPerWeek_*Job2_WeeksPerYear_*(Job2Pay_)     if PayPeriodJob2==1
replace AnnualInc_Job2=Job2_WeeksPerYear_*Job2Pay_                          if PayPeriodJob2==2
replace AnnualInc_Job2=(Job2_WeeksPerYear_/2)*Job2Pay_                      if PayPeriodJob2==3
replace AnnualInc_Job2=12*Job2Pay_                                          if PayPeriodJob2==4
replace AnnualInc_Job2=24*Job2Pay_                                          if PayPeriodJob2==5
replace AnnualInc_Job2=Job2Pay_                                             if PayPeriodJob2==6
replace AnnualInc_Job2=5*Job2_WeeksPerYear_*Job2Pay_                        if PayPeriodJob2==11
		
* Sum these income sources for paid employees, treating missings as zeros. 
egen AnnualInc_PE_06=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ AnnualInc_Job2_), missing

egen AnnualInc_PEJ1_06=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ ), missing
	
**************************
* Self Employees
**************************	
	
	
* Hours Per Week - Self Employees - (Same as for Paid Employees from this wave on *
* Weeks Per Year - Self Employees - (Same as for Paid Employees from this wave on *
gen HoursPerWeekSE_06=.
replace HoursPerWeekSE_06=HoursPerWeek_06 if SelfEmp==1

gen WeeksPerYearSE_06=.
replace WeeksPerYearSE_06=WeeksPerYear_06 if SelfEmp==1


* Binary Indicating whether they receive a salary from this business: G52		
gen SelfEmp_RegSalary06=KJ187
	replace SelfEmp_RegSalary06=. if SelfEmp_RegSalary06>5 | SelfEmp_RegSalary06==0
	replace SelfEmp_RegSalary06=0 if SelfEmp_RegSalary06==5
	
* Salary Amount - Self Employees - G52A	
gen SelfEmp_Salary06=KJ188	
	replace SelfEmp_Salary06=. if SelfEmp_Salary06>=99999999998
	replace SelfEmp_Salary06=. if SelfEmp_Salary06==0
	
* Salary Pay Period - Self Employees - G52B	
gen SelfEmp_PayPeriod06=KJ192
	replace SelfEmp_PayPeriod06=. if SelfEmp_PayPeriod06>11 | SelfEmp_PayPeriod06==0

/*
KJ192          SELF-EMPLOYMENT SALARY AMOUNT PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBSELFEMPD.J192_

         (How much are you paid before taxes and other deductions?)
         
         Amount: [SELF-EMPLOYMENT SALARY AMOUNT]
         
          Per:

         .................................................................................
            82           1.  HOUR
           103           2.  WEEK
            13           3.  EVERY TWO WEEKS/BI-WEEKLY
            82           4.  MONTH
             3           5.  TWICE A MONTH
           119           6.  YEAR
             4          11.  Day
             8          97.  OTHER (SPECIFY); including per visit, class, mile, job
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         18055       Blank.  INAP (Inapplicable); Partial Interview

 */
	
	
* Construct Annual Salary for Self-Employees

gen AnnualSalSE_06=.
		replace AnnualSalSE=WeeksPerYearSE*HoursPerWeekSE*(SelfEmp_Salary)        if SelfEmp_PayPeriod==1
		replace AnnualSalSE=WeeksPerYearSE*SelfEmp_Salary                         if SelfEmp_PayPeriod==2
		replace AnnualSalSE=(WeeksPerYearSE/2)*SelfEmp_Salary                     if SelfEmp_PayPeriod==3
		replace AnnualSalSE=12*SelfEmp_Salary                                     if SelfEmp_PayPeriod==4
		replace AnnualSalSE=24*SelfEmp_Salary                                     if SelfEmp_PayPeriod==5		
		replace AnnualSalSE=SelfEmp_Salary                                        if SelfEmp_PayPeriod==6
		replace AnnualSalSE=5*WeeksPerYearSE*SelfEmp_Salary                       if SelfEmp_PayPeriod==11
	
	
* Binary Variable Indicating whether the self-employee gets profits from the business G53
gen SelfEmp_GetProfit06=KJ194
	replace SelfEmp_GetProfit06=. if SelfEmp_GetProfit06>5 | SelfEmp_GetProfit06==0

* Profit Amount - G53A
gen SelfEmp_Profit_06=KJ195
	replace SelfEmp_Profit_06=. if SelfEmp_Profit_06>=99999999998

gen SelfEmp_ProfitPeriod06=KJ199 
	replace SelfEmp_ProfitPeriod06=. if SelfEmp_ProfitPeriod06>11 | SelfEmp_ProfitPeriod06==0
	
/*
KJ199          AMT NET EARNINGS/PROFITS PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBSELFEMPD.J199_

         ( [In addition to your regular salary, how/How]  much do you receive from net
         earnings or profits?)
         
         Amount: [AMT NET EARNINGS/PROFITS]
         
          Per:

         .................................................................................
            15           1.  HOUR
            39           2.  WEEK
             1           3.  EVERY TWO WEEKS/BI-WEEKLY
            44           4.  MONTH
             4           5.  TWICE A MONTH
           606           6.  YEAR
             3          11.  Day
            14          97.  OTHER (SPECIFY)
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         17743       Blank.  INAP (Inapplicable); Partial Interview
*/
						
		
gen AnnualProfSE_06=.
		replace AnnualProfSE_=WeeksPerYearSE_*HoursPerWeekSE*SelfEmp_Profit_  if SelfEmp_ProfitPeriod==1
		replace AnnualProfSE_=WeeksPerYearSE_*SelfEmp_Profit_                 if SelfEmp_ProfitPeriod==2
		replace AnnualProfSE_=(WeeksPerYearSE_/2)*SelfEmp_Profit_             if SelfEmp_ProfitPeriod==3
		replace AnnualProfSE_=12*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==4
		replace AnnualProfSE_=24*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==5		
		replace AnnualProfSE_=SelfEmp_Profit_                                 if SelfEmp_ProfitPeriod==6
		replace AnnualProfSE_=5*WeeksPerYearSE_*SelfEmp_Profit_               if SelfEmp_ProfitPeriod==11
	


egen AnnualInc_SE_06=rowtotal(AnnualSalSE_ AnnualProfSE_), missing
	

egen AnnualIncTot_06=rowtotal(AnnualInc_PE_ AnnualInc_SE_), missing

keep HHID PN *SUBHH *FINR Working *Retired* HomeMaker WorkForPay SelfEmp_06 AnnualInc_PE_ AnnualInc_PEJ1_ AnnualInc_SE_ AnnualIncTot_  *Same*Emp* *SameJob* *Job_Ind* *Job_Occ* WeeksPerYear* *HoursPerWeek*

gen YEAR=2006


save "$CleanData/HRSEmpInc06.dta", replace







/* Employment Answers from 2008 - New Format */
clear all
infile using "$HRSSurveys08/h08sta/H08J_R.dct" , using("$HRSSurveys08/h08da/H08J_R.da")

* Get indicators for whether the respondent is currently  Working / Retired / HomeMaker, 
* which are recorded as binary variables from the G1 survey items. 

gen Working_08=0
gen Retired_08=0
gen HomeMaker_08=0

forvalues QN=1(1)4{

replace Working_08=1   if LJ005M`QN'==1
replace Retired_08=1   if LJ005M`QN'==5
replace HomeMaker_08=1 if LJ005M`QN'==6

}

gen MonthRetired_08=LJ017
gen YearRetired_08=LJ018


* WorkForPay - item G2, asks whether the individual is doing any work for pay
* at the present time.  This variable is almost identical to Working above, but
* there are some respodnents who are coded as "1" for WorkForPay, but "0" for 
* Working.  These are mostly individuals who are on sick leave, retired, etc. 

gen WorkForPay_08=LJ020
	replace WorkForPay_08=0 if WorkForPay_08==5
	replace WorkForPay_08=. if WorkForPay_08>5

* Self Employed - item G3.  This item and future items ask about "current, main job"
* This item asks if individuals work for someone else or are self-employed / run own business	
	
gen SelfEmp_08=LJ021
	replace SelfEmp=0 if SelfEmp==1
	replace SelfEmp=1 if SelfEmp==2
	replace SelfEmp=. if SelfEmp>2
	
* HoursPerWeek - item G44.  How many hours a week do you usually work on this job? (98 / 99 are DK / NA)
* Notice that HoursPerWeek is set to 0 for individuals who are self-employed.  We set 0 to missing here:

gen HoursPerWeek_08=LJ172
	replace HoursPerWeek_08=. if HoursPerWeek_08>168
	
* WeeksPerYear - item G47.  How many weeks do you work per year, including paid vacations.  
* This is set to zero for self-employees.  We set 0 to missing.

gen WeeksPerYear_08=LJ179
		replace WeeksPerYear_08=. if WeeksPerYear_08>52
				  
gen HowPaidPE_08=LJ205
		replace HowPaidPE_08=. if HowPaidPE_08>=8
		
/*         
LJ205               HOW PAID ON JOB
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J205_

         Are you salaried on this job, paid by the hour, or what?

         .................................................................................
          1497           1.  SALARIED
          2670           2.  HOURLY
            96           3.  PIECEWORK/COMMISSION
           168           7.  OTHER/COMBINATION
             3           8.  DK (Don't Know); NA (Not Ascertained)
             9           9.  RF (Refused)
         12774       Blank.  INAP (Inapplicable); Partial Interview
 */		

********************************************************************************
* Workers could receive income either from salary, hourly wages, commission, or 
* other compensation schemes, and here we create separate earnings variables for 
* each kind of earnings flow.		
********************************************************************************		
		
*********************
* Salaried Workers
*********************			
		
* Salary - item G56a.  How much is your SALARY before taxes and other deductions.
* This will be zero for those who are paid hourly, and those who are self-employed.
* We set 0 equal to missings 		
		
gen Salary_08=LJ206
		replace Salary_08=. if Salary_08>=99999999998
		replace Salary_08=. if Salary_08==0

gen PayPeriodSal_08=LJ210
		replace PayPeriodSal_08=. if PayPeriodSal_08>11
		
* PayPeriod - item G56B.  In the previous question, how often is the reported
* salary received: 		
/*
LJ210               AMOUNT OF SALARY ON JOB PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J210_

         (How much is your salary, before taxes and other deductions?)
         
          If respondent is a teacher, record annual salary
         
          PROBE if necessary: Is that per hour, week, month, or year?
         
         Amount: [AMOUNT OF SALARY ON JOB]
         
         Per:

         .................................................................................
            33           1.  HOUR
           125           2.  WEEK
            62           3.  EVERY TWO WEEKS/BI-WEEKLY
           139           4.  MONTH
             4           5.  TWICE A MONTH
           968           6.  YEAR
            16          11.  Day
             4          97.  OTHER (SPECIFY)
             1          98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         15865       Blank.  INAP (Inapplicable); Partial Interview


					   */

* Calculate Annual Salary based on responses, with different calculations
* for each pay period:		
gen AnnualInc_Salary_08=.
replace AnnualInc_Salary=HoursPerWeek_*WeeksPerYear_*Salary     if PayPeriodSal==1
replace AnnualInc_Salary=WeeksPerYear_*Salary                   if PayPeriodSal==2
replace AnnualInc_Salary=(WeeksPerYear_/2)*Salary               if PayPeriodSal==3		
replace AnnualInc_Salary=12*Salary                              if PayPeriodSal==4
replace AnnualInc_Salary=24*Salary                              if PayPeriodSal==5
replace AnnualInc_Salary=Salary                                 if PayPeriodSal==6	
replace AnnualInc_Salary=5*WeeksPerYear_*Salary                 if PayPeriodSal==11
						   

*********************
* Hourly Workers
*********************						   
	* Hourly Wage Rate - item G56F.  We set zeros equal to missing.
gen HourlyPay_08=LJ216
		replace HourlyPay_08=. if HourlyPay_08>=10000
		replace HourlyPay_08=. if HourlyPay_08==0
				
gen AnnualInc_Hourly_08=HoursPerWeek_*WeeksPerYear_*HourlyPay_
				
				
************************
* PIECEWORK/COMMISSION 	
************************		
* Piecework Pay - Note that in the code book this is listed as "Overtime Pay"
* but this is only non-missing for individuals who have a value of 3 for LJ205
gen PieceworkPay_08=LJ225	
	replace PieceworkPay_08=. if PieceworkPay_08>=99999999998
	replace PieceworkPay_08=. if PieceworkPay_08==0
* Piecework Pay Time Period - Item G56N		
gen PayPeriodPW_08=LJ226		
	replace PayPeriodPW_08=. if PayPeriodPW_08>11
	replace PayPeriodPW_08=. if PayPeriodPW_08==0	
	
/*
LJ226               AMOUNT PAID FOR OVERTIME PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J226_

         PROBE if necessary: Is that per week or month?
         
         Amount: [AMOUNT PAID FOR OVERTIME]
         
         Per:

         .................................................................................
             4           1.  HOUR
            32           2.  WEEK
             2           3.  EVERY TWO WEEKS/BI-WEEKLY
            40           4.  MONTH
                         5.  TWICE A MONTH
             6           6.  YEAR
             2          11.  Day
             1          97.  OTHER (SPECIFY); including per visit, class, mile, job
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         17130       Blank.  INAP (Inapplicable); Partial Interview


*/
					   
gen AnnualInc_Piecework_08=.
replace AnnualInc_Piecework_=HoursPerWeek_*WeeksPerYear_*PieceworkPay_     if PayPeriodPW==1
replace AnnualInc_Piecework_=WeeksPerYear_*PieceworkPay_                   if PayPeriodPW==2
replace AnnualInc_Piecework_=(WeeksPerYear_/2)*PieceworkPay_               if PayPeriodPW==3
replace AnnualInc_Piecework_=12*PieceworkPay_                              if PayPeriodPW==4
replace AnnualInc_Piecework_=24*PieceworkPay_                              if PayPeriodPW==5
replace AnnualInc_Piecework_=PieceworkPay_                                 if PayPeriodPW==6		
replace AnnualInc_Piecework_=5*WeeksPerYear_*PieceworkPay_                 if PayPeriodPW==11

		
*****************************
* Other
*****************************
* Other Pay - Item G56R
gen OtherPay_08=LJ230
		replace OtherPay_08=. if OtherPay_08>99999999998
		replace OtherPay_08=. if OtherPay_08==0
* Other Pay - Item G56S		
gen PayPeriodOther_08=LJ231
		replace PayPeriodOther_08=. if PayPeriodOther_08>11
		replace PayPeriodOther_08=. if PayPeriodOther_08==0	
	
	
/*     
LJ231               AMOUNT PAID- OTHER- PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J231_

         PROBE if necessary: Was that per hour, week, month, or year?
         
         Amount: [AMOUNT PAID- OTHER]
         
         Per:

         .................................................................................
            10           1.  HOUR
            23           2.  WEEK
             6           3.  EVERY TWO WEEKS/BI-WEEKLY
             9           4.  MONTH
             1           5.  TWICE A MONTH
            40           6.  YEAR
            37          11.  Day
            15          97.  OTHER (SPECIFY); including per visit, class, mile, job
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         17076       Blank.  INAP (Inapplicable); Partial Interview

	 */
	
gen AnnualInc_Other_08=.
	replace AnnualInc_Other_=HoursPerWeek_*WeeksPerYear_*(OtherPay_)     if PayPeriodOther==1
	replace AnnualInc_Other_=WeeksPerYear_*OtherPay_                     if PayPeriodOther==2
	replace AnnualInc_Other_=(WeeksPerYear_/2)*OtherPay_                 if PayPeriodOther==3	
	replace AnnualInc_Other_=12*OtherPay_                                if PayPeriodOther==4
	replace AnnualInc_Other_=24*OtherPay_                                if PayPeriodOther==5	
	replace AnnualInc_Other_=OtherPay_                                   if PayPeriodOther==6		
	replace AnnualInc_Other_=5*WeeksPerYear_*OtherPay_ 	                 if PayPeriodOther==11
	
	
*************************************************
* Indicator for Same Job Title as Previous Wave:	
*************************************************	



/* LJ058               SAME JOB TITLE AS PREVIOUS WAVE
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         Ref: SecJ.PREVIOUSJOBANDPENSION.PWELSENOWELSE.J058_SameJobTitle

         In [PREV WAVE FIRST R IW MONTH]/[/Prev Wave Iw Mo] [Previous Wave First R
                  Interview Year]/[Prev Wave Iw Yr] our records indicate that your job
         title was
                  [PREV WAVE JOB TITLE]. Is this still the case?*/
				  

* Item G19B
gen SameEmp_08=LJ045

	
* Job Characteristics

gen SameJob_08=LJ058
		 /*            
		  3084           1.  YES
             7           3.  RETIRED & WORKING FOR SAME EMPLOYER/BUSINESS
           332           5.  NO
            10           7.  DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE */ 
gen SameJobTBranch_08=LJ182 
	     /* LJ182               BRANCHPOINT FOR J182
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         Ref: SecJ.CURRENTJOB.J182_

         .................................................................................
          3101           1.  SAME EMPLOYER AND JOB TITLE AS PREV WAVE
          1411           2.  SELF-EMPLOYED
                         3.  OTHERWISE
         12705       Blank.  INAP (Inapplicable); Partial Interview */


gen Job_Ind_08=LJ166M
gen Job_Occ_08=LJ168M			  
	
	
*******************************
* Second Job 
*******************************
* Second Job Hours Per Week - G129
gen Job2_HoursPerWeek_08=LJ556
	replace Job2_HoursPerWeek_08=. if Job2_HoursPerWeek_08>96
* Second Job Weeks Per Year - G130
gen Job2_WeeksPerYear_08=LJ557
	replace Job2_WeeksPerYear_08=. if Job2_WeeksPerYear_08>52
* Pay Second Job - G131	
gen Job2Pay_08=LJ558
    replace Job2Pay_08=. if Job2Pay_08>=99999999998

* Pay Period Second Job - G131A	
gen PayPeriodJob2_08=LJ562
	replace PayPeriodJob2_08=. if PayPeriodJob2_08>11
	replace PayPeriodJob2_08=. if PayPeriodJob2_08==0
	
/*
LJ562               EARNINGS ON SECOND JOB - PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.SECONDJOBANDPLANTORETIRE.J562_

         (About how much do you earn before taxes from (this other job/these other
         jobs)?)
         
          PROBE if necessary: Is that per hour, week, month, year, or what?
         
         Amount: [EARNINGS ON SECOND JOB]
         
         Per:

         .................................................................................
           117           1.  HOUR
            50           2.  WEEK
             7           3.  EVERY TWO WEEKS/BI-WEEKLY
            64           4.  MONTH
             1           5.  TWICE A MONTH
           250           6.  YEAR
             6          11.  Day
             7          97.  OTHER (SPECIFY); including per visit, class, mile, job
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         16715       Blank.  INAP (Inapplicable); Partial Interview


 */
					   
	
gen AnnualInc_Job2_08=.
replace AnnualInc_Job2=Job2_HoursPerWeek_*Job2_WeeksPerYear_*(Job2Pay_)     if PayPeriodJob2==1
replace AnnualInc_Job2=Job2_WeeksPerYear_*Job2Pay_                          if PayPeriodJob2==2
replace AnnualInc_Job2=(Job2_WeeksPerYear_/2)*Job2Pay_                      if PayPeriodJob2==3
replace AnnualInc_Job2=12*Job2Pay_                                          if PayPeriodJob2==4
replace AnnualInc_Job2=24*Job2Pay_                                          if PayPeriodJob2==5
replace AnnualInc_Job2=Job2Pay_                                             if PayPeriodJob2==6
replace AnnualInc_Job2=5*Job2_WeeksPerYear_*Job2Pay_                        if PayPeriodJob2==11
		
* Sum these income sources for paid employees, treating missings as zeros. 
egen AnnualInc_PE_08=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ AnnualInc_Job2_), missing

egen AnnualInc_PEJ1_08=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ ), missing
	
**************************
* Self Employees
**************************	
	
	
* Hours Per Week - Self Employees - (Same as for Paid Employees from this wave on *
* Weeks Per Year - Self Employees - (Same as for Paid Employees from this wave on *
gen HoursPerWeekSE_08=.
replace HoursPerWeekSE_08=HoursPerWeek_08 if SelfEmp==1

gen WeeksPerYearSE_08=.
replace WeeksPerYearSE_08=WeeksPerYear_08 if SelfEmp==1


* Binary Indicating whether they receive a salary from this business: G52		
gen SelfEmp_RegSalary08=LJ187
	replace SelfEmp_RegSalary08=. if SelfEmp_RegSalary08>5 | SelfEmp_RegSalary08==0
	replace SelfEmp_RegSalary08=0 if SelfEmp_RegSalary08==5
	
* Salary Amount - Self Employees - G52A	
gen SelfEmp_Salary08=LJ188	
	replace SelfEmp_Salary08=. if SelfEmp_Salary08>=99999999998
	replace SelfEmp_Salary08=. if SelfEmp_Salary08==0
	
* Salary Pay Period - Self Employees - G52B	
gen SelfEmp_PayPeriod08=LJ192
	replace SelfEmp_PayPeriod08=. if SelfEmp_PayPeriod08>11 | SelfEmp_PayPeriod08==0

/*
LJ192               SELF-EMPLOYMENT SALARY AMOUNT PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBSELFEMPD.J192_

         (How much are you paid before taxes and other deductions?)
         
         Amount: [SELF-EMPLOYMENT SALARY AMOUNT]
         
         Per:

         .................................................................................
            83           1.  HOUR
            91           2.  WEEK
            13           3.  EVERY TWO WEEKS/BI-WEEKLY
            74           4.  MONTH
             2           5.  TWICE A MONTH
            94           6.  YEAR
             9          11.  Day
             8          97.  OTHER (SPECIFY); including per visit, class, mile, job
             1          98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         16842       Blank.  INAP (Inapplicable); Partial Interview


 */
	
	
* Construct Annual Salary for Self-Employees

gen AnnualSalSE_08=.
		replace AnnualSalSE=WeeksPerYearSE*HoursPerWeekSE*(SelfEmp_Salary)        if SelfEmp_PayPeriod==1
		replace AnnualSalSE=WeeksPerYearSE*SelfEmp_Salary                         if SelfEmp_PayPeriod==2
		replace AnnualSalSE=(WeeksPerYearSE/2)*SelfEmp_Salary                     if SelfEmp_PayPeriod==3
		replace AnnualSalSE=12*SelfEmp_Salary                                     if SelfEmp_PayPeriod==4
		replace AnnualSalSE=24*SelfEmp_Salary                                     if SelfEmp_PayPeriod==5		
		replace AnnualSalSE=SelfEmp_Salary                                        if SelfEmp_PayPeriod==6
		replace AnnualSalSE=5*WeeksPerYearSE*SelfEmp_Salary                       if SelfEmp_PayPeriod==11
	
	
* Binary Variable Indicating whether the self-employee gets profits from the business G53
gen SelfEmp_GetProfit08=LJ194
	replace SelfEmp_GetProfit08=. if SelfEmp_GetProfit08>5 | SelfEmp_GetProfit08==0

* Profit Amount - G53A
gen SelfEmp_Profit_08=LJ195
	replace SelfEmp_Profit_08=. if SelfEmp_Profit_08>=99999999998

gen SelfEmp_ProfitPeriod08=LJ199 
	replace SelfEmp_ProfitPeriod08=. if SelfEmp_ProfitPeriod08>11 | SelfEmp_ProfitPeriod08==0
	
/*
LJ199               AMT NET EARNINGS/PROFITS PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBSELFEMPD.J199_

         ([In addition to your regular salary, how/How] much do you receive from net
         earnings or profits?)
         
         Amount: [AMT NET EARNINGS/PROFITS]
         
         Per:

         .................................................................................
             9           1.  HOUR
            47           2.  WEEK
             4           3.  EVERY TWO WEEKS/BI-WEEKLY
            47           4.  MONTH
             1           5.  TWICE A MONTH
           567           6.  YEAR
             2          11.  Day
             8          97.  OTHER (SPECIFY)
             2          98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         16530       Blank.  INAP (Inapplicable); Partial Interview

*/
						
		
gen AnnualProfSE_08=.
		replace AnnualProfSE_=WeeksPerYearSE_*HoursPerWeekSE*SelfEmp_Profit_  if SelfEmp_ProfitPeriod==1
		replace AnnualProfSE_=WeeksPerYearSE_*SelfEmp_Profit_                 if SelfEmp_ProfitPeriod==2
		replace AnnualProfSE_=(WeeksPerYearSE_/2)*SelfEmp_Profit_             if SelfEmp_ProfitPeriod==3
		replace AnnualProfSE_=12*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==4
		replace AnnualProfSE_=24*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==5		
		replace AnnualProfSE_=SelfEmp_Profit_                                 if SelfEmp_ProfitPeriod==6
		replace AnnualProfSE_=5*WeeksPerYearSE_*SelfEmp_Profit_               if SelfEmp_ProfitPeriod==11
	


egen AnnualInc_SE_08=rowtotal(AnnualSalSE_ AnnualProfSE_), missing
	

egen AnnualIncTot_08=rowtotal(AnnualInc_PE_ AnnualInc_SE_), missing

keep HHID PN *SUBHH *FINR Working *Retired* HomeMaker WorkForPay SelfEmp_08 AnnualInc_PE_ AnnualInc_PEJ1_ AnnualInc_SE_ AnnualIncTot_ *Same*Emp* *SameJob* *Job_Ind* *Job_Occ* WeeksPerYear* *HoursPerWeek*

gen YEAR=2008


save "$CleanData/HRSEmpInc08.dta", replace





/* Employment Answers from 2010 - New Format */
clear all
infile using "$HRSSurveys10/h10sta/H10J_R.dct" , using("$HRSSurveys10/h10da/H10J_R.da")

* Get indicators for whether the respondent is currently  Working / Retired / HomeMaker, 
* which are recorded as binary variables from the G1 survey items. 

gen Working_10=0
gen Retired_10=0
gen HomeMaker_10=0

forvalues QN=1(1)5{

replace Working_10=1   if MJ005M`QN'==1
replace Retired_10=1   if MJ005M`QN'==5
replace HomeMaker_10=1 if MJ005M`QN'==6

}

gen MonthRetired_10=MJ017
gen YearRetired_10=MJ018


* WorkForPay - item G2, asks whether the individual is doing any work for pay
* at the present time.  This variable is almost identical to Working above, but
* there are some respodnents who are coded as "1" for WorkForPay, but "0" for 
* Working.  These are mostly individuals who are on sick leave, retired, etc. 

gen WorkForPay_10=MJ020
	replace WorkForPay_10=0 if WorkForPay_10==5
	replace WorkForPay_10=. if WorkForPay_10>5

* Self Employed - item G3.  This item and future items ask about "current, main job"
* This item asks if individuals work for someone else or are self-employed / run own business	
	
gen SelfEmp_10=MJ021
	replace SelfEmp=0 if SelfEmp==1
	replace SelfEmp=1 if SelfEmp==2
	replace SelfEmp=. if SelfEmp>2
	
* HoursPerWeek - item G44.  How many hours a week do you usually work on this job? (98 / 99 are DK / NA)
* Notice that HoursPerWeek is set to 0 for individuals who are self-employed.  We set 0 to missing here:

gen HoursPerWeek_10=MJ172
	replace HoursPerWeek_10=. if HoursPerWeek_10>168
	
* WeeksPerYear - item G47.  How many weeks do you work per year, including paid vacations.  
* This is set to zero for self-employees.  We set 0 to missing.

gen WeeksPerYear_10=MJ179
		replace WeeksPerYear_10=. if WeeksPerYear_10>52
				  
gen HowPaidPE_10=MJ205
		replace HowPaidPE_10=. if HowPaidPE_10>=8
		
/*         
MJ205                         HOW PAID ON JOB
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J205_

         Are you salaried on this job, paid by the hour, or what?

         .................................................................................
          2263           1.  SALARIED
          4288           2.  HOURLY
           147           3.  PIECEWORK/COMMISSION
           308           7.  OTHER/COMBINATION
             8           8.  DK (Don't Know); NA (Not Ascertained)
            10           9.  RF (Refused)
         15010       Blank.  INAP (Inapplicable); Partial Interview

 */		

********************************************************************************
* Workers could receive income either from salary, hourly wages, commission, or 
* other compensation schemes, and here we create separate earnings variables for 
* each kind of earnings flow.		
********************************************************************************		
		
*********************
* Salaried Workers
*********************			
		
* Salary - item G56a.  How much is your SALARY before taxes and other deductions.
* This will be zero for those who are paid hourly, and those who are self-employed.
* We set 0 equal to missings 		
		
gen Salary_10=MJ206
		replace Salary_10=. if Salary_10>=9999999998
		replace Salary_10=. if Salary_10==0

gen PayPeriodSal_10=MJ210
		replace PayPeriodSal_10=. if PayPeriodSal_10>11
		
* PayPeriod - item G56B.  In the previous question, how often is the reported
* salary received: 		
/*
MJ210                         AMOUNT OF SALARY ON JOB PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J210_

         (How much is your salary, before taxes and other deductions?)
         
         If respondent is a teacher, record annual salary
         
         PROBE if necessary: Is that per hour, week, month, or year?
         
         Amount: [AMOUNT OF SALARY ON JOB]
         
         Per:

         .................................................................................
            38           1.  HOUR
           154           2.  WEEK
           105           3.  EVERY TWO WEEKS/BI-WEEKLY
           191           4.  MONTH
             6           5.  TWICE A MONTH
          1522           6.  YEAR
            21          11.  Day
             1          97.  OTHER (SPECIFY)
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         19996       Blank.  INAP (Inapplicable); Partial Interview



					   */

* Calculate Annual Salary based on responses, with different calculations
* for each pay period:		
gen AnnualInc_Salary_10=.
replace AnnualInc_Salary=HoursPerWeek_*WeeksPerYear_*Salary     if PayPeriodSal==1
replace AnnualInc_Salary=WeeksPerYear_*Salary                   if PayPeriodSal==2
replace AnnualInc_Salary=(WeeksPerYear_/2)*Salary               if PayPeriodSal==3		
replace AnnualInc_Salary=12*Salary                              if PayPeriodSal==4
replace AnnualInc_Salary=24*Salary                              if PayPeriodSal==5
replace AnnualInc_Salary=Salary                                 if PayPeriodSal==6	
replace AnnualInc_Salary=5*WeeksPerYear_*Salary                 if PayPeriodSal==11
						   

*********************
* Hourly Workers
*********************						   
	* Hourly Wage Rate - item G56F.  We set zeros equal to missing.
gen HourlyPay_10=MJ216
		replace HourlyPay_10=. if HourlyPay_10>=10000
		replace HourlyPay_10=. if HourlyPay_10==0
				
gen AnnualInc_Hourly_10=HoursPerWeek_*WeeksPerYear_*HourlyPay_
				
				
************************
* PIECEWORK/COMMISSION 	
************************		
* Piecework Pay - Note that in the code book this is listed as "Overtime Pay"
* but this is only non-missing for individuals who have a value of 3 for MJ205
gen PieceworkPay_10=MJ225	
	replace PieceworkPay_10=. if PieceworkPay_10>=99999998
	replace PieceworkPay_10=. if PieceworkPay_10==0
* Piecework Pay Time Period - Item G56N		
gen PayPeriodPW_10=MJ226		
	replace PayPeriodPW_10=. if PayPeriodPW_10>11
	replace PayPeriodPW_10=. if PayPeriodPW_10==0	
	
/*
MJ226                         AMOUNT PAID FOR OVERTIME PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J226_

         PROBE if necessary: Is that per week or month?
         
         Amount: [AMOUNT PAID FOR OVERTIME]
         
         Per:

         .................................................................................
             1           1.  HOUR
            51           2.  WEEK
             3           3.  EVERY TWO WEEKS/BI-WEEKLY
            62           4.  MONTH
                         5.  TWICE A MONTH
             6           6.  YEAR
             1          11.  Day
             3          97.  OTHER (SPECIFY); including per visit, class, mile, job
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         21907       Blank.  INAP (Inapplicable); Partial Interview



*/
					   
gen AnnualInc_Piecework_10=.
replace AnnualInc_Piecework_=HoursPerWeek_*WeeksPerYear_*PieceworkPay_     if PayPeriodPW==1
replace AnnualInc_Piecework_=WeeksPerYear_*PieceworkPay_                   if PayPeriodPW==2
replace AnnualInc_Piecework_=(WeeksPerYear_/2)*PieceworkPay_               if PayPeriodPW==3
replace AnnualInc_Piecework_=12*PieceworkPay_                              if PayPeriodPW==4
replace AnnualInc_Piecework_=24*PieceworkPay_                              if PayPeriodPW==5
replace AnnualInc_Piecework_=PieceworkPay_                                 if PayPeriodPW==6		
replace AnnualInc_Piecework_=5*WeeksPerYear_*PieceworkPay_                 if PayPeriodPW==11

		
*****************************
* Other
*****************************
* Other Pay - Item G56R
gen OtherPay_10=MJ230
		replace OtherPay_10=. if OtherPay_10>999999998
		replace OtherPay_10=. if OtherPay_10==0
* Other Pay - Item G56S		
gen PayPeriodOther_10=MJ231
		replace PayPeriodOther_10=. if PayPeriodOther_10>11
		replace PayPeriodOther_10=. if PayPeriodOther_10==0	
	
	
/*     
MJ231                         AMOUNT PAID- OTHER- PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J231_

         PROBE if necessary: Was that per hour, week, month, or year?
         
         Amount: [AMOUNT PAID-OTHER]
         
         Per:

         .................................................................................
            15           1.  HOUR
            47           2.  WEEK
            16           3.  EVERY TWO WEEKS/BI-WEEKLY
            28           4.  MONTH
             2           5.  TWICE A MONTH
            79           6.  YEAR
            49          11.  Day
            20          97.  OTHER (SPECIFY); including per visit, class, mile, job
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         21778       Blank.  INAP (Inapplicable); Partial Interview


	 */
	
gen AnnualInc_Other_10=.
	replace AnnualInc_Other_=HoursPerWeek_*WeeksPerYear_*(OtherPay_)     if PayPeriodOther==1
	replace AnnualInc_Other_=WeeksPerYear_*OtherPay_                     if PayPeriodOther==2
	replace AnnualInc_Other_=(WeeksPerYear_/2)*OtherPay_                 if PayPeriodOther==3	
	replace AnnualInc_Other_=12*OtherPay_                                if PayPeriodOther==4
	replace AnnualInc_Other_=24*OtherPay_                                if PayPeriodOther==5	
	replace AnnualInc_Other_=OtherPay_                                   if PayPeriodOther==6		
	replace AnnualInc_Other_=5*WeeksPerYear_*OtherPay_ 	                 if PayPeriodOther==11
	
	
*************************************************
* Indicator for Same Job Title as Previous Wave:	
*************************************************	



/* MJ058                         SAME JOB TITLE AS PREVIOUS WAVE
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         Ref: SecJ.PREVIOUSJOBANDPENSION.PWELSENOWELSE.J058_SameJobTitle

         In [PREV WAVE FIRST R IW MONTH]/[/Prev Wave Iw Mo] [Previous Wave First R.
         Interview Year]/[Prev Wave Iw Yr] our records indicate that your job title was
         [PREV WAVE JOB TITLE]. Is this still the case?
                 
         If job title is slightly inaccurate but describes R's current job, answer 'yes'
         here and note corrections as a comment*/
		 
* Item G19B
gen SameEmp_10=MJ045

* Job Characteristics

gen SameJob_10=MJ058
		 /*            
		  2570           1.  YES
             8           3.  RETIRED & WORKING FOR SAME EMPLOYER/BUSINESS
           233           5.  NO
             5           7.  DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE */ 
gen SameJobTBranch_10=.

gen Job_Ind_10=MJ166M
gen Job_Occ_10=MJ168M 
	
	
*******************************
* Second Job 
*******************************
* Second Job Hours Per Week - G129
gen Job2_HoursPerWeek_10=MJ556
	replace Job2_HoursPerWeek_10=. if Job2_HoursPerWeek_10>96
* Second Job Weeks Per Year - G130
gen Job2_WeeksPerYear_10=MJ557
	replace Job2_WeeksPerYear_10=. if Job2_WeeksPerYear_10>52
* Pay Second Job - G131	
gen Job2Pay_10=MJ558
    replace Job2Pay_10=. if Job2Pay_10>=999999998

* Pay Period Second Job - G131A	
gen PayPeriodJob2_10=MJ562
	replace PayPeriodJob2_10=. if PayPeriodJob2_10>11
	replace PayPeriodJob2_10=. if PayPeriodJob2_10==0
	
/*
MJ562                         EARNINGS ON SECOND JOB - PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.SECONDJOBANDPLANTORETIRE.J562_

         (About how much do you earn before taxes from (this other job/these other
         jobs)?)
         
         PROBE if necessary: Is that per hour, week, month, year, or what?
         
         Amount: [EARNINGS ON SECOND JOB]
         
         Per:

         .................................................................................
           178           1.  HOUR
           107           2.  WEEK
            32           3.  EVERY TWO WEEKS/BI-WEEKLY
           123           4.  MONTH
                         5.  TWICE A MONTH
           441           6.  YEAR
            17          11.  Day
            14          97.  OTHER (SPECIFY); including per visit, class, mile, job
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         21122       Blank.  INAP (Inapplicable); Partial Interview



 */
					   
	
gen AnnualInc_Job2_10=.
replace AnnualInc_Job2=Job2_HoursPerWeek_*Job2_WeeksPerYear_*(Job2Pay_)     if PayPeriodJob2==1
replace AnnualInc_Job2=Job2_WeeksPerYear_*Job2Pay_                          if PayPeriodJob2==2
replace AnnualInc_Job2=(Job2_WeeksPerYear_/2)*Job2Pay_                      if PayPeriodJob2==3
replace AnnualInc_Job2=12*Job2Pay_                                          if PayPeriodJob2==4
replace AnnualInc_Job2=24*Job2Pay_                                          if PayPeriodJob2==5
replace AnnualInc_Job2=Job2Pay_                                             if PayPeriodJob2==6
replace AnnualInc_Job2=5*Job2_WeeksPerYear_*Job2Pay_                        if PayPeriodJob2==11
		
* Sum these income sources for paid employees, treating missings as zeros. 
egen AnnualInc_PE_10=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ AnnualInc_Job2_), missing

egen AnnualInc_PEJ1_10=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ ), missing
	
**************************
* Self Employees
**************************	
	
	
* Hours Per Week - Self Employees - (Same as for Paid Employees from this wave on *
* Weeks Per Year - Self Employees - (Same as for Paid Employees from this wave on *
gen HoursPerWeekSE_10=.
replace HoursPerWeekSE_10=HoursPerWeek_10 if SelfEmp==1

gen WeeksPerYearSE_10=.
replace WeeksPerYearSE_10=WeeksPerYear_10 if SelfEmp==1


* Binary Indicating whether they receive a salary from this business: G52		
gen SelfEmp_RegSalary10=MJ187
	replace SelfEmp_RegSalary10=. if SelfEmp_RegSalary10>5 | SelfEmp_RegSalary10==0
	replace SelfEmp_RegSalary10=0 if SelfEmp_RegSalary10==5
	
* Salary Amount - Self Employees - G52A	
gen SelfEmp_Salary10=MJ188	
	replace SelfEmp_Salary10=. if SelfEmp_Salary10>=999999998
	replace SelfEmp_Salary10=. if SelfEmp_Salary10==0
	
* Salary Pay Period - Self Employees - G52B	
gen SelfEmp_PayPeriod10=MJ192
	replace SelfEmp_PayPeriod10=. if SelfEmp_PayPeriod10>11 | SelfEmp_PayPeriod10==0

/*
MJ192                         SELF-EMPLOYMENT SALARY AMOUNT PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBSELFEMPD.J192_

         (How much are you paid before taxes and other deductions?)
         
         Amount: [SELF-EMPLOYMENT SALARY AMOUNT]
         
         Per:

         .................................................................................
            98           1.  HOUR
           115           2.  WEEK
            13           3.  EVERY TWO WEEKS/BI-WEEKLY
           109           4.  MONTH
             2           5.  TWICE A MONTH
           143           6.  YEAR
            18          11.  Day
            17          97.  OTHER (SPECIFY); including per visit, class, mile, job
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         21519       Blank.  INAP (Inapplicable); Partial Interview



 */
	
	
* Construct Annual Salary for Self-Employees

gen AnnualSalSE_10=.
		replace AnnualSalSE=WeeksPerYearSE*HoursPerWeekSE*(SelfEmp_Salary)        if SelfEmp_PayPeriod==1
		replace AnnualSalSE=WeeksPerYearSE*SelfEmp_Salary                         if SelfEmp_PayPeriod==2
		replace AnnualSalSE=(WeeksPerYearSE/2)*SelfEmp_Salary                     if SelfEmp_PayPeriod==3
		replace AnnualSalSE=12*SelfEmp_Salary                                     if SelfEmp_PayPeriod==4
		replace AnnualSalSE=24*SelfEmp_Salary                                     if SelfEmp_PayPeriod==5		
		replace AnnualSalSE=SelfEmp_Salary                                        if SelfEmp_PayPeriod==6
		replace AnnualSalSE=5*WeeksPerYearSE*SelfEmp_Salary                       if SelfEmp_PayPeriod==11
	
	
* Binary Variable Indicating whether the self-employee gets profits from the business G53
gen SelfEmp_GetProfit10=MJ194
	replace SelfEmp_GetProfit10=. if SelfEmp_GetProfit10>5 | SelfEmp_GetProfit10==0

* Profit Amount - G53A
gen SelfEmp_Profit_10=MJ195
	replace SelfEmp_Profit_10=. if SelfEmp_Profit_10>=999999998

gen SelfEmp_ProfitPeriod10=MJ199 
	replace SelfEmp_ProfitPeriod10=. if SelfEmp_ProfitPeriod10>11 | SelfEmp_ProfitPeriod10==0
	
/*
MJ199                         AMT NET EARNINGS/PROFITS PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBSELFEMPD.J199_

         ([In addition to your regular salary, how/How] much do you receive from net
         earnings or profits?)
         
         Amount: [AMT NET EARNINGS/PROFITS]
         
         Per:

         .................................................................................
            16           1.  HOUR
            50           2.  WEEK
                         3.  EVERY TWO WEEKS/BI-WEEKLY
            75           4.  MONTH
                         5.  TWICE A MONTH
           877           6.  YEAR
             2          11.  Day
            13          97.  OTHER (SPECIFY)
                        98.  DK (Don't Know); NA (Not Ascertained)
             1          99.  RF (Refused)
         21000       Blank.  INAP (Inapplicable); Partial Interview


*/
						
		
gen AnnualProfSE_10=.
		replace AnnualProfSE_=WeeksPerYearSE_*HoursPerWeekSE*SelfEmp_Profit_  if SelfEmp_ProfitPeriod==1
		replace AnnualProfSE_=WeeksPerYearSE_*SelfEmp_Profit_                 if SelfEmp_ProfitPeriod==2
		replace AnnualProfSE_=(WeeksPerYearSE_/2)*SelfEmp_Profit_             if SelfEmp_ProfitPeriod==3
		replace AnnualProfSE_=12*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==4
		replace AnnualProfSE_=24*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==5		
		replace AnnualProfSE_=SelfEmp_Profit_                                 if SelfEmp_ProfitPeriod==6
		replace AnnualProfSE_=5*WeeksPerYearSE_*SelfEmp_Profit_               if SelfEmp_ProfitPeriod==11
	


egen AnnualInc_SE_10=rowtotal(AnnualSalSE_ AnnualProfSE_), missing
	

egen AnnualIncTot_10=rowtotal(AnnualInc_PE_ AnnualInc_SE_), missing

keep HHID PN *SUBHH *FINR Working *Retired* HomeMaker WorkForPay SelfEmp_10 AnnualInc_PE_ AnnualInc_PEJ1_ AnnualInc_SE_ AnnualIncTot_ *Same*Emp* *SameJob* *Job_Ind* *Job_Occ* WeeksPerYear* *HoursPerWeek*

gen YEAR=2010

save "$CleanData/HRSEmpInc10.dta", replace



/* Employment Answers from 2012 - New Format */
clear all
infile using "$HRSSurveys12/h12sta/H12J_R.dct" , using("$HRSSurveys12/h12da/H12J_R.da")

* Get indicators for whether the respondent is currently  Working / Retired / HomeMaker, 
* which are recorded as binary variables from the G1 survey items. 

gen Working_12=0
gen Retired_12=0
gen HomeMaker_12=0

forvalues QN=1(1)5{

replace Working_12=1   if NJ005M`QN'==1
replace Retired_12=1   if NJ005M`QN'==5
replace HomeMaker_12=1 if NJ005M`QN'==6

}

gen MonthRetired_12=NJ017
gen YearRetired_12=NJ018


* WorkForPay - item G2, asks whether the individual is doing any work for pay
* at the present time.  This variable is almost identical to Working above, but
* there are some respodnents who are coded as "1" for WorkForPay, but "0" for 
* Working.  These are mostly individuals who are on sick leave, retired, etc. 

gen WorkForPay_12=NJ020
	replace WorkForPay_12=0 if WorkForPay_12==5
	replace WorkForPay_12=. if WorkForPay_12>5

* Self Employed - item G3.  This item and future items ask about "current, main job"
* This item asks if individuals work for someone else or are self-employed / run own business	
	
gen SelfEmp_12=NJ021
	replace SelfEmp=0 if SelfEmp==1
	replace SelfEmp=1 if SelfEmp==2
	replace SelfEmp=. if SelfEmp>2
	
* HoursPerWeek - item G44.  How many hours a week do you usually work on this job? (98 / 99 are DK / NA)
* Notice that HoursPerWeek is set to 0 for individuals who are self-employed.  We set 0 to missing here:

gen HoursPerWeek_12=NJ172
	replace HoursPerWeek_12=. if HoursPerWeek_12>168
	
* WeeksPerYear - item G47.  How many weeks do you work per year, including paid vacations.  
* This is set to zero for self-employees.  We set 0 to missing.

gen WeeksPerYear_12=NJ179
		replace WeeksPerYear_12=. if WeeksPerYear_12>52
				  
gen HowPaidPE_12=NJ205
		replace HowPaidPE_12=. if HowPaidPE_12>=8
		
/*         
NJ205                         HOW PAID ON JOB
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J205_

         Are you salaried on this job, paid by the hour, or what?

         .................................................................................
          2021           1.  SALARIED
          3853           2.  HOURLY
           129           3.  PIECEWORK/COMMISSION
           256           7.  OTHER/COMBINATION
            10           8.  DK (Don't Know); NA (Not Ascertained)
            10           9.  RF (Refused)
         14275       Blank.  INAP (Inapplicable); Partial Interview

 */		

********************************************************************************
* Workers could receive income either from salary, hourly wages, commission, or 
* other compensation schemes, and here we create separate earnings variables for 
* each kind of earnings flow.		
********************************************************************************		
		
*********************
* Salaried Workers
*********************			
		
* Salary - item G56a.  How much is your SALARY before taxes and other deductions.
* This will be zero for those who are paid hourly, and those who are self-employed.
* We set 0 equal to missings 		
		
gen Salary_12=NJ206
		replace Salary_12=. if Salary_12>=999998
		replace Salary_12=. if Salary_12==0

gen PayPeriodSal_12=NJ210
		replace PayPeriodSal_12=. if PayPeriodSal_12>11
		
* PayPeriod - item G56B.  In the previous question, how often is the reported
* salary received: 		
/*
NJ210                         AMOUNT OF SALARY ON JOB PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J210_

         (How much is your salary, before taxes and other deductions?) 
         
         IWER: If Respondent is a teacher, record annual salary 
         
         IWER: PROBE if necessary: Is that per hour, week, month, or year?
         
         Amount: [AMOUNT OF SALARY ON JOB]
         
         Per:

         .................................................................................
            43           1.  HOUR
           142           2.  WEEK
            98           3.  EVERY TWO WEEKS/BI-WEEKLY
           165           4.  MONTH
            11           5.  TWICE A MONTH
          1347           6.  YEAR
            18          11.  Day
             1          97.  OTHER (SPECIFY)
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         18729       Blank.  INAP (Inapplicable); Partial Interview




					   */

* Calculate Annual Salary based on responses, with different calculations
* for each pay period:		
gen AnnualInc_Salary_12=.
replace AnnualInc_Salary=HoursPerWeek_*WeeksPerYear_*Salary     if PayPeriodSal==1
replace AnnualInc_Salary=WeeksPerYear_*Salary                   if PayPeriodSal==2
replace AnnualInc_Salary=(WeeksPerYear_/2)*Salary               if PayPeriodSal==3		
replace AnnualInc_Salary=12*Salary                              if PayPeriodSal==4
replace AnnualInc_Salary=24*Salary                              if PayPeriodSal==5
replace AnnualInc_Salary=Salary                                 if PayPeriodSal==6	
replace AnnualInc_Salary=5*WeeksPerYear_*Salary                 if PayPeriodSal==11
						   

*********************
* Hourly Workers
*********************						   
	* Hourly Wage Rate - item G56F.  We set zeros equal to missing.
gen HourlyPay_12=NJ216
		replace HourlyPay_12=. if HourlyPay_12>=10000
		replace HourlyPay_12=. if HourlyPay_12==0
				
gen AnnualInc_Hourly_12=HoursPerWeek_*WeeksPerYear_*HourlyPay_
				
				
************************
* PIECEWORK/COMMISSION 	
************************		
* Piecework Pay - Note that in the code book this is listed as "Overtime Pay"
* but this is only non-missing for individuals who have a value of 3 for NJ205
gen PieceworkPay_12=NJ225	
	replace PieceworkPay_12=. if PieceworkPay_12>=999998
	replace PieceworkPay_12=. if PieceworkPay_12==0
* Piecework Pay Time Period - Item G56N		
gen PayPeriodPW_12=NJ226		
	replace PayPeriodPW_12=. if PayPeriodPW_12>11
	replace PayPeriodPW_12=. if PayPeriodPW_12==0	
	
/*
NJ226                         AMOUNT PAID FOR OVERTIME PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J226_

         IWER: PROBE if necessary: Is that per week or month?
         
         Amount: [AMOUNT PAID FOR OVERTIME]
         
         Per:

         .................................................................................
                         1.  HOUR
            47           2.  WEEK
             2           3.  EVERY TWO WEEKS/BI-WEEKLY
            46           4.  MONTH
                         5.  TWICE A MONTH
             7           6.  YEAR
             1          11.  Day
             5          97.  OTHER (SPECIFY); including per visit, class, mile, job,
                             piece
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         20446       Blank.  INAP (Inapplicable); Partial Interview



*/
					   
gen AnnualInc_Piecework_12=.
replace AnnualInc_Piecework_=HoursPerWeek_*WeeksPerYear_*PieceworkPay_     if PayPeriodPW==1
replace AnnualInc_Piecework_=WeeksPerYear_*PieceworkPay_                   if PayPeriodPW==2
replace AnnualInc_Piecework_=(WeeksPerYear_/2)*PieceworkPay_               if PayPeriodPW==3
replace AnnualInc_Piecework_=12*PieceworkPay_                              if PayPeriodPW==4
replace AnnualInc_Piecework_=24*PieceworkPay_                              if PayPeriodPW==5
replace AnnualInc_Piecework_=PieceworkPay_                                 if PayPeriodPW==6		
replace AnnualInc_Piecework_=5*WeeksPerYear_*PieceworkPay_                 if PayPeriodPW==11

		
*****************************
* Other
*****************************
* Other Pay - Item G56R
gen OtherPay_12=NJ230
		replace OtherPay_12=. if OtherPay_12>9999998
		replace OtherPay_12=. if OtherPay_12==0
* Other Pay - Item G56S		
gen PayPeriodOther_12=NJ231
		replace PayPeriodOther_12=. if PayPeriodOther_12>11
		replace PayPeriodOther_12=. if PayPeriodOther_12==0	
	
	
/*     
NJ231                         AMOUNT PAID- OTHER- PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J231_

         IWER: PROBE if necessary: Was that per hour, week, month, or year?
         
         Amount: [AMOUNT PAID- OTHER]
         
         Per:

         .................................................................................
            23           1.  HOUR
            38           2.  WEEK
            14           3.  EVERY TWO WEEKS/BI-WEEKLY
            31           4.  MONTH
                         5.  TWICE A MONTH
            57           6.  YEAR
            47          11.  Day
            19          97.  OTHER (SPECIFY); including per visit, class, mile, job,
                             piece
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         20325       Blank.  INAP (Inapplicable); Partial Interview


	 */
	
gen AnnualInc_Other_12=.
	replace AnnualInc_Other_=HoursPerWeek_*WeeksPerYear_*(OtherPay_)     if PayPeriodOther==1
	replace AnnualInc_Other_=WeeksPerYear_*OtherPay_                     if PayPeriodOther==2
	replace AnnualInc_Other_=(WeeksPerYear_/2)*OtherPay_                 if PayPeriodOther==3	
	replace AnnualInc_Other_=12*OtherPay_                                if PayPeriodOther==4
	replace AnnualInc_Other_=24*OtherPay_                                if PayPeriodOther==5	
	replace AnnualInc_Other_=OtherPay_                                   if PayPeriodOther==6		
	replace AnnualInc_Other_=5*WeeksPerYear_*OtherPay_ 	                 if PayPeriodOther==11
	
	
*************************************************
* Indicator for Same Job Title as Previous Wave:	
*************************************************	



/* NJ058                         SAME JOB TITLE AS PREVIOUS WAVE
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         Ref: SecJ.PREVIOUSJOBANDPENSION.PWELSENOWELSE.J058_SameJobTitle

         [In [Prev IW Month, Year] our records indicate that your job title was [Prev
         Wave Job Title]. Is this still the case? / Is your job title still the same as
         it was in [Prev IW Month, Year]? ]
         
         IWER: If job title is slightly inaccurate but describes R's current job, answer
         'yes' here and note corrections as a comment

         .................................................................................
          4392           1.  YES
             8           3.  RETIRED & WORKING FOR SAME EMPLOYER/BUSINESS
           412           5.  NO
             4           7.  DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE
                         8.  DK (Don't Know); NA (Not Ascertained)
                         9.  RF (Refused)
         15738       Blank.  INAP (Inapplicable); Partial Interview*/
		 

* Item G19B
gen SameEmp_12=NJ045

* Job Characteristics

gen SameJob_12=NJ058
		 /*            
	      4392           1.  YES
             8           3.  RETIRED & WORKING FOR SAME EMPLOYER/BUSINESS
           412           5.  NO
             4           7.  DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE */ 
gen SameJobTBranch_12=.


gen Job_Ind_12=NJ166M
gen Job_Occ_12=NJ168M	 
	
	
*******************************
* Second Job 
*******************************
* Second Job Hours Per Week - G129
gen Job2_HoursPerWeek_12=NJ556
	replace Job2_HoursPerWeek_12=. if Job2_HoursPerWeek_12>96
* Second Job Weeks Per Year - G130
gen Job2_WeeksPerYear_12=NJ557
	replace Job2_WeeksPerYear_12=. if Job2_WeeksPerYear_12>52
* Pay Second Job - G131	
gen Job2Pay_12=NJ558
    replace Job2Pay_12=. if Job2Pay_12>=999998

* Pay Period Second Job - G131A	
gen PayPeriodJob2_12=NJ562
	replace PayPeriodJob2_12=. if PayPeriodJob2_12>11
	replace PayPeriodJob2_12=. if PayPeriodJob2_12==0
	
/*
NJ562                         EARNINGS ON SECOND JOB - PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.SECONDJOBANDPLANTORETIRE.J562_

         (About how much do you earn before taxes from (this other job/these other
         jobs)?)
         
         IWER: PROBE if necessary: Is that per hour, week, month, year, or what?
         
         Amount: [EARNINGS ON SECOND JOB]
         
         Per:

         .................................................................................
           148           1.  HOUR
            89           2.  WEEK
            25           3.  EVERY TWO WEEKS/BI-WEEKLY
           108           4.  MONTH
             1           5.  TWICE A MONTH
           408           6.  YEAR
             8          11.  Day
            15          97.  OTHER (SPECIFY); including per visit, class, mile, job,
                             piece
             1          98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         19751       Blank.  INAP (Inapplicable); Partial Interview



 */
					   
	
gen AnnualInc_Job2_12=.
replace AnnualInc_Job2=Job2_HoursPerWeek_*Job2_WeeksPerYear_*(Job2Pay_)     if PayPeriodJob2==1
replace AnnualInc_Job2=Job2_WeeksPerYear_*Job2Pay_                          if PayPeriodJob2==2
replace AnnualInc_Job2=(Job2_WeeksPerYear_/2)*Job2Pay_                      if PayPeriodJob2==3
replace AnnualInc_Job2=12*Job2Pay_                                          if PayPeriodJob2==4
replace AnnualInc_Job2=24*Job2Pay_                                          if PayPeriodJob2==5
replace AnnualInc_Job2=Job2Pay_                                             if PayPeriodJob2==6
replace AnnualInc_Job2=5*Job2_WeeksPerYear_*Job2Pay_                        if PayPeriodJob2==11
		
* Sum these income sources for paid employees, treating missings as zeros. 
egen AnnualInc_PE_12=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ AnnualInc_Job2_), missing

egen AnnualInc_PEJ1_12=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ ), missing
	
**************************
* Self Employees
**************************	
	
	
* Hours Per Week - Self Employees - (Same as for Paid Employees from this wave on *
* Weeks Per Year - Self Employees - (Same as for Paid Employees from this wave on *
gen HoursPerWeekSE_12=.
replace HoursPerWeekSE_12=HoursPerWeek_12 if SelfEmp==1

gen WeeksPerYearSE_12=.
replace WeeksPerYearSE_12=WeeksPerYear_12 if SelfEmp==1


* Binary Indicating whether they receive a salary from this business: G52		
gen SelfEmp_RegSalary12=NJ187
	replace SelfEmp_RegSalary12=. if SelfEmp_RegSalary12>5 | SelfEmp_RegSalary12==0
	replace SelfEmp_RegSalary12=0 if SelfEmp_RegSalary12==5
	
* Salary Amount - Self Employees - G52A	
gen SelfEmp_Salary12=NJ188	
	replace SelfEmp_Salary12=. if SelfEmp_Salary12>=9999998
	replace SelfEmp_Salary12=. if SelfEmp_Salary12==0
	
* Salary Pay Period - Self Employees - G52B	
gen SelfEmp_PayPeriod12=NJ192
	replace SelfEmp_PayPeriod12=. if SelfEmp_PayPeriod12>11 | SelfEmp_PayPeriod12==0

/*
NJ192                         SELF-EMPLOYMENT SALARY AMOUNT PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBSELFEMPD.J192_

         (How much are you paid before taxes and other deductions?)
         
         Amount:  [SELF-EMPLOYMENT SALARY AMOUNT]
         
         Per:

         .................................................................................
            81           1.  HOUR
           104           2.  WEEK
            13           3.  EVERY TWO WEEKS/BI-WEEKLY
            94           4.  MONTH
                         5.  TWICE A MONTH
           130           6.  YEAR
            20          11.  Day
            18          97.  OTHER (SPECIFY); including per visit, class, mile, job,
                             piece
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         20094       Blank.  INAP (Inapplicable); Partial Interview



 */
	
	
* Construct Annual Salary for Self-Employees

gen AnnualSalSE_12=.
		replace AnnualSalSE=WeeksPerYearSE*HoursPerWeekSE*(SelfEmp_Salary)        if SelfEmp_PayPeriod==1
		replace AnnualSalSE=WeeksPerYearSE*SelfEmp_Salary                         if SelfEmp_PayPeriod==2
		replace AnnualSalSE=(WeeksPerYearSE/2)*SelfEmp_Salary                     if SelfEmp_PayPeriod==3
		replace AnnualSalSE=12*SelfEmp_Salary                                     if SelfEmp_PayPeriod==4
		replace AnnualSalSE=24*SelfEmp_Salary                                     if SelfEmp_PayPeriod==5		
		replace AnnualSalSE=SelfEmp_Salary                                        if SelfEmp_PayPeriod==6
		replace AnnualSalSE=5*WeeksPerYearSE*SelfEmp_Salary                       if SelfEmp_PayPeriod==11
	
	
* Binary Variable Indicating whether the self-employee gets profits from the business G53
gen SelfEmp_GetProfit12=NJ194
	replace SelfEmp_GetProfit12=. if SelfEmp_GetProfit12>5 | SelfEmp_GetProfit12==0

* Profit Amount - G53A
gen SelfEmp_Profit_12=NJ195
	replace SelfEmp_Profit_12=. if SelfEmp_Profit_12>=9999998

gen SelfEmp_ProfitPeriod12=NJ199 
	replace SelfEmp_ProfitPeriod12=. if SelfEmp_ProfitPeriod12>11 | SelfEmp_ProfitPeriod12==0
	
/*
NJ199                         AMT NET EARNINGS/PROFITS PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBSELFEMPD.J199_

         ([In addition to your regular salary, how much do you receive from net earnings
         or profits?/What did you earn last year?/How much do you receive from net
         earnings or profits?]
         
         [IWER: If R has trouble giving dollar figure, ask:  What did you earn the last
         year you worked?)]
         
         Amount:  [AMT NET EARNINGS/PROFITS]
         
         Per:

         .................................................................................
            10           1.  HOUR
            44           2.  WEEK
             6           3.  EVERY TWO WEEKS/BI-WEEKLY
            63           4.  MONTH
             1           5.  TWICE A MONTH
           810           6.  YEAR
             2          11.  Day
             5          97.  OTHER (SPECIFY)
             2          98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         19611       Blank.  INAP (Inapplicable); Partial Interview


*/
						
		
gen AnnualProfSE_12=.
		replace AnnualProfSE_=WeeksPerYearSE_*HoursPerWeekSE*SelfEmp_Profit_  if SelfEmp_ProfitPeriod==1
		replace AnnualProfSE_=WeeksPerYearSE_*SelfEmp_Profit_                 if SelfEmp_ProfitPeriod==2
		replace AnnualProfSE_=(WeeksPerYearSE_/2)*SelfEmp_Profit_             if SelfEmp_ProfitPeriod==3
		replace AnnualProfSE_=12*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==4
		replace AnnualProfSE_=24*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==5		
		replace AnnualProfSE_=SelfEmp_Profit_                                 if SelfEmp_ProfitPeriod==6
		replace AnnualProfSE_=5*WeeksPerYearSE_*SelfEmp_Profit_               if SelfEmp_ProfitPeriod==11
	


egen AnnualInc_SE_12=rowtotal(AnnualSalSE_ AnnualProfSE_), missing
	

egen AnnualIncTot_12=rowtotal(AnnualInc_PE_ AnnualInc_SE_), missing

keep HHID PN *SUBHH *FINR Working *Retired* HomeMaker WorkForPay SelfEmp_12 AnnualInc_PE_ AnnualInc_PEJ1_ AnnualInc_SE_ AnnualIncTot_ *Same*Emp* *SameJob* *Job_Ind* *Job_Occ* WeeksPerYear* *HoursPerWeek*

gen YEAR=2012

save "$CleanData/HRSEmpInc12.dta", replace



/* Employment Answers from 2014 - New Format */
clear all
infile using "$HRSSurveys14/h14sta/H14J_R.dct" , using("$HRSSurveys14/h14da/H14J_R.da")

* Get indicators for whether the respondent is currently  Working / Retired / HomeMaker, 
* which are recorded as binary variables from the G1 survey items. 

gen Working_14=0
gen Retired_14=0
gen HomeMaker_14=0

forvalues QN=1(1)5{

replace Working_14=1   if OJ005M`QN'==1
replace Retired_14=1   if OJ005M`QN'==5
replace HomeMaker_14=1 if OJ005M`QN'==6

}

gen MonthRetired_14=OJ017
gen YearRetired_14=OJ018


* WorkForPay - item G2, asks whether the individual is doing any work for pay
* at the present time.  This variable is almost identical to Working above, but
* there are some respodnents who are coded as "1" for WorkForPay, but "0" for 
* Working.  These are mostly individuals who are on sick leave, retired, etc. 

gen WorkForPay_14=OJ020
	replace WorkForPay_14=0 if WorkForPay_14==5
	replace WorkForPay_14=. if WorkForPay_14>5

* Self Employed - item G3.  This item and future items ask about "current, main job"
* This item asks if individuals work for someone else or are self-employed / run own business	
	
gen SelfEmp_14=OJ021
	replace SelfEmp=0 if SelfEmp==1
	replace SelfEmp=1 if SelfEmp==2
	replace SelfEmp=. if SelfEmp>2
	
* HoursPerWeek - item G44.  How many hours a week do you usually work on this job? (98 / 99 are DK / NA)
* Notice that HoursPerWeek is set to 0 for individuals who are self-employed.  We set 0 to missing here:

gen HoursPerWeek_14=OJ172
	replace HoursPerWeek_14=. if HoursPerWeek_14>168
	
* WeeksPerYear - item G47.  How many weeks do you work per year, including paid vacations.  
* This is set to zero for self-employees.  We set 0 to missing.

gen WeeksPerYear_14=OJ179
		replace WeeksPerYear_14=. if WeeksPerYear_14>52
				  
gen HowPaidPE_14=OJ205
		replace HowPaidPE_14=. if HowPaidPE_14>=8
		
/*         
OJ205                         HOW PAID ON JOB
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J205_

         Are you salaried on this job, paid by the hour, or what?

         .................................................................................
          2021           1.  SALARIED
          3853           2.  HOURLY
           129           3.  PIECEWORK/COMMISSION
           256           7.  OTHER/COMBINATION
            10           8.  DK (Don't Know); NA (Not Ascertained)
            10           9.  RF (Refused)
         14275       Blank.  INAP (Inapplicable); Partial Interview

 */		

********************************************************************************
* Workers could receive income either from salary, hourly wages, commission, or 
* other compensation schemes, and here we create separate earnings variables for 
* each kind of earnings flow.		
********************************************************************************		
		
*********************
* Salaried Workers
*********************			
		
* Salary - item G56a.  How much is your SALARY before taxes and other deductions.
* This will be zero for those who are paid hourly, and those who are self-employed.
* We set 0 equal to missings 		
		
gen Salary_14=OJ206
		replace Salary_14=. if Salary_14>=999998
		replace Salary_14=. if Salary_14==0

gen PayPeriodSal_14=OJ210
		replace PayPeriodSal_14=. if PayPeriodSal_14>11
		
* PayPeriod - item G56B.  In the previous question, how often is the reported
* salary received: 		
/*
OJ210                         AMOUNT OF SALARY ON JOB PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J210_

         (How much is your salary, before taxes and other deductions?) 
         
         IWER: If Respondent is a teacher, record annual salary 
         
         IWER: PROBE if necessary: Is that per hour, week, month, or year?
         
         Amount: [AMOUNT OF SALARY ON JOB]
         
         Per:

         .................................................................................
            43           1.  HOUR
           142           2.  WEEK
            98           3.  EVERY TWO WEEKS/BI-WEEKLY
           165           4.  MONTH
            11           5.  TWICE A MONTH
          1347           6.  YEAR
            18          11.  Day
             1          97.  OTHER (SPECIFY)
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         18729       Blank.  INAP (Inapplicable); Partial Interview




					   */

* Calculate Annual Salary based on responses, with different calculations
* for each pay period:		
gen AnnualInc_Salary_14=.
replace AnnualInc_Salary=HoursPerWeek_*WeeksPerYear_*Salary     if PayPeriodSal==1
replace AnnualInc_Salary=WeeksPerYear_*Salary                   if PayPeriodSal==2
replace AnnualInc_Salary=(WeeksPerYear_/2)*Salary               if PayPeriodSal==3		
replace AnnualInc_Salary=12*Salary                              if PayPeriodSal==4
replace AnnualInc_Salary=24*Salary                              if PayPeriodSal==5
replace AnnualInc_Salary=Salary                                 if PayPeriodSal==6	
replace AnnualInc_Salary=5*WeeksPerYear_*Salary                 if PayPeriodSal==11
						   

*********************
* Hourly Workers
*********************						   
	* Hourly Wage Rate - item G56F.  We set zeros equal to missing.
gen HourlyPay_14=OJ216
		replace HourlyPay_14=. if HourlyPay_14>=10000
		replace HourlyPay_14=. if HourlyPay_14==0
				
gen AnnualInc_Hourly_14=HoursPerWeek_*WeeksPerYear_*HourlyPay_
				
				
************************
* PIECEWORK/COMMISSION 	
************************		
* Piecework Pay - Note that in the code book this is listed as "Overtime Pay"
* but this is only non-missing for individuals who have a value of 3 for OJ205
gen PieceworkPay_14=OJ225	
	replace PieceworkPay_14=. if PieceworkPay_14>=999998
	replace PieceworkPay_14=. if PieceworkPay_14==0
* Piecework Pay Time Period - Item G56N		
gen PayPeriodPW_14=OJ226		
	replace PayPeriodPW_14=. if PayPeriodPW_14>11
	replace PayPeriodPW_14=. if PayPeriodPW_14==0	
	
/*
OJ226                         AMOUNT PAID FOR OVERTIME PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J226_

         IWER: PROBE if necessary: Is that per week or month?
         
         Amount: [AMOUNT PAID FOR OVERTIME]
         
         Per:

         .................................................................................
                         1.  HOUR
            47           2.  WEEK
             2           3.  EVERY TWO WEEKS/BI-WEEKLY
            46           4.  MONTH
                         5.  TWICE A MONTH
             7           6.  YEAR
             1          11.  Day
             5          97.  OTHER (SPECIFY); including per visit, class, mile, job,
                             piece
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         20446       Blank.  INAP (Inapplicable); Partial Interview



*/
					   
gen AnnualInc_Piecework_14=.
replace AnnualInc_Piecework_=HoursPerWeek_*WeeksPerYear_*PieceworkPay_     if PayPeriodPW==1
replace AnnualInc_Piecework_=WeeksPerYear_*PieceworkPay_                   if PayPeriodPW==2
replace AnnualInc_Piecework_=(WeeksPerYear_/2)*PieceworkPay_               if PayPeriodPW==3
replace AnnualInc_Piecework_=12*PieceworkPay_                              if PayPeriodPW==4
replace AnnualInc_Piecework_=24*PieceworkPay_                              if PayPeriodPW==5
replace AnnualInc_Piecework_=PieceworkPay_                                 if PayPeriodPW==6		
replace AnnualInc_Piecework_=5*WeeksPerYear_*PieceworkPay_                 if PayPeriodPW==11

		
*****************************
* Other
*****************************
* Other Pay - Item G56R
gen OtherPay_14=OJ230
		replace OtherPay_14=. if OtherPay_14>9999998
		replace OtherPay_14=. if OtherPay_14==0
* Other Pay - Item G56S		
gen PayPeriodOther_14=OJ231
		replace PayPeriodOther_14=. if PayPeriodOther_14>11
		replace PayPeriodOther_14=. if PayPeriodOther_14==0	
	
	
/*     
OJ231                         AMOUNT PAID- OTHER- PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J231_

         IWER: PROBE if necessary: Was that per hour, week, month, or year?
         
         Amount: [AMOUNT PAID- OTHER]
         
         Per:

         .................................................................................
            23           1.  HOUR
            38           2.  WEEK
            14           3.  EVERY TWO WEEKS/BI-WEEKLY
            31           4.  MONTH
                         5.  TWICE A MONTH
            57           6.  YEAR
            47          11.  Day
            19          97.  OTHER (SPECIFY); including per visit, class, mile, job,
                             piece
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         20325       Blank.  INAP (Inapplicable); Partial Interview


	 */
	
gen AnnualInc_Other_14=.
	replace AnnualInc_Other_=HoursPerWeek_*WeeksPerYear_*(OtherPay_)     if PayPeriodOther==1
	replace AnnualInc_Other_=WeeksPerYear_*OtherPay_                     if PayPeriodOther==2
	replace AnnualInc_Other_=(WeeksPerYear_/2)*OtherPay_                 if PayPeriodOther==3	
	replace AnnualInc_Other_=12*OtherPay_                                if PayPeriodOther==4
	replace AnnualInc_Other_=24*OtherPay_                                if PayPeriodOther==5	
	replace AnnualInc_Other_=OtherPay_                                   if PayPeriodOther==6		
	replace AnnualInc_Other_=5*WeeksPerYear_*OtherPay_ 	                 if PayPeriodOther==11
	
	
*************************************************
* Indicator for Same Job Title as Previous Wave:	
*************************************************	



/* OJ058                         SAME JOB TITLE AS PREVIOUS WAVE
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         Ref: SecJ.PREVIOUSJOBANDPENSION.PWELSENOWELSE.J058_SameJobTitle

         [In [Prev IW Month, Year] our records indicate that your job title was [Prev
         Wave Job Title]. Is this still the case? / Is your job title still the same as
         it was in [Prev IW Month, Year]? ]
         
         IWER: If job title is slightly inaccurate but describes R's current job, answer
         'yes' here and note corrections as a comment

         .................................................................................
          4392           1.  YES
             8           3.  RETIRED & WORKING FOR SAME EMPLOYER/BUSINESS
           412           5.  NO
             4           7.  DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE
                         8.  DK (Don't Know); NA (Not Ascertained)
                         9.  RF (Refused)
         15738       Blank.  INAP (Inapplicable); Partial Interview*/
		 

	
gen SameSelfEmp_14=OJ958	

* Item G19B
gen SameEmp_14=OJ045
	
* Job Characteristics

gen SameJob_14=OJ058
		 /*            
	      4392           1.  YES
             8           3.  RETIRED & WORKING FOR SAME EMPLOYER/BUSINESS
           412           5.  NO
             4           7.  DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE */ 
gen SameJobTBranch_14=.

gen Job_Ind_14=OJ166M
gen Job_Occ_14=OJ168M	 
	
	
*******************************
* Second Job 
*******************************
* Second Job Hours Per Week - G129
gen Job2_HoursPerWeek_14=OJ556
	replace Job2_HoursPerWeek_14=. if Job2_HoursPerWeek_14>96
* Second Job Weeks Per Year - G130
gen Job2_WeeksPerYear_14=OJ557
	replace Job2_WeeksPerYear_14=. if Job2_WeeksPerYear_14>52
* Pay Second Job - G131	
gen Job2Pay_14=OJ558
    replace Job2Pay_14=. if Job2Pay_14>=999998

* Pay Period Second Job - G131A	
gen PayPeriodJob2_14=OJ562
	replace PayPeriodJob2_14=. if PayPeriodJob2_14>11
	replace PayPeriodJob2_14=. if PayPeriodJob2_14==0
	
/*
OJ562                         EARNINGS ON SECOND JOB - PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.SECONDJOBANDPLANTORETIRE.J562_

         (About how much do you earn before taxes from (this other job/these other
         jobs)?)
         
         IWER: PROBE if necessary: Is that per hour, week, month, year, or what?
         
         Amount: [EARNINGS ON SECOND JOB]
         
         Per:

         .................................................................................
           148           1.  HOUR
            89           2.  WEEK
            25           3.  EVERY TWO WEEKS/BI-WEEKLY
           108           4.  MONTH
             1           5.  TWICE A MONTH
           408           6.  YEAR
             8          11.  Day
            15          97.  OTHER (SPECIFY); including per visit, class, mile, job,
                             piece
             1          98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         19751       Blank.  INAP (Inapplicable); Partial Interview



 */
					   
	
gen AnnualInc_Job2_14=.
replace AnnualInc_Job2=Job2_HoursPerWeek_*Job2_WeeksPerYear_*(Job2Pay_)     if PayPeriodJob2==1
replace AnnualInc_Job2=Job2_WeeksPerYear_*Job2Pay_                          if PayPeriodJob2==2
replace AnnualInc_Job2=(Job2_WeeksPerYear_/2)*Job2Pay_                      if PayPeriodJob2==3
replace AnnualInc_Job2=12*Job2Pay_                                          if PayPeriodJob2==4
replace AnnualInc_Job2=24*Job2Pay_                                          if PayPeriodJob2==5
replace AnnualInc_Job2=Job2Pay_                                             if PayPeriodJob2==6
replace AnnualInc_Job2=5*Job2_WeeksPerYear_*Job2Pay_                        if PayPeriodJob2==11
		
* Sum these income sources for paid employees, treating missings as zeros. 
egen AnnualInc_PE_14=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ AnnualInc_Job2_), missing

egen AnnualInc_PEJ1_14=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ ), missing

	
**************************
* Self Employees
**************************	
	
	
* Hours Per Week - Self Employees - (Same as for Paid Employees from this wave on *
* Weeks Per Year - Self Employees - (Same as for Paid Employees from this wave on *
gen HoursPerWeekSE_14=.
replace HoursPerWeekSE_14=HoursPerWeek_14 if SelfEmp==1

gen WeeksPerYearSE_14=.
replace WeeksPerYearSE_14=WeeksPerYear_14 if SelfEmp==1


* Binary Indicating whether they receive a salary from this business: G52		
gen SelfEmp_RegSalary14=OJ187
	replace SelfEmp_RegSalary14=. if SelfEmp_RegSalary14>5 | SelfEmp_RegSalary14==0
	replace SelfEmp_RegSalary14=0 if SelfEmp_RegSalary14==5
	
* Salary Amount - Self Employees - G52A	
gen SelfEmp_Salary14=OJ188	
	replace SelfEmp_Salary14=. if SelfEmp_Salary14>=9999998
	replace SelfEmp_Salary14=. if SelfEmp_Salary14==0
	
* Salary Pay Period - Self Employees - G52B	
gen SelfEmp_PayPeriod14=OJ192
	replace SelfEmp_PayPeriod14=. if SelfEmp_PayPeriod14>11 | SelfEmp_PayPeriod14==0

/*
OJ192                         SELF-EMPLOYMENT SALARY AMOUNT PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBSELFEMPD.J192_

         (How much are you paid before taxes and other deductions?)
         
         Amount:  [SELF-EMPLOYMENT SALARY AMOUNT]
         
         Per:

         .................................................................................
            81           1.  HOUR
           104           2.  WEEK
            13           3.  EVERY TWO WEEKS/BI-WEEKLY
            94           4.  MONTH
                         5.  TWICE A MONTH
           130           6.  YEAR
            20          11.  Day
            18          97.  OTHER (SPECIFY); including per visit, class, mile, job,
                             piece
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         20094       Blank.  INAP (Inapplicable); Partial Interview



 */
	
	
* Construct Annual Salary for Self-Employees

gen AnnualSalSE_14=.
		replace AnnualSalSE=WeeksPerYearSE*HoursPerWeekSE*(SelfEmp_Salary)        if SelfEmp_PayPeriod==1
		replace AnnualSalSE=WeeksPerYearSE*SelfEmp_Salary                         if SelfEmp_PayPeriod==2
		replace AnnualSalSE=(WeeksPerYearSE/2)*SelfEmp_Salary                     if SelfEmp_PayPeriod==3
		replace AnnualSalSE=12*SelfEmp_Salary                                     if SelfEmp_PayPeriod==4
		replace AnnualSalSE=24*SelfEmp_Salary                                     if SelfEmp_PayPeriod==5		
		replace AnnualSalSE=SelfEmp_Salary                                        if SelfEmp_PayPeriod==6
		replace AnnualSalSE=5*WeeksPerYearSE*SelfEmp_Salary                       if SelfEmp_PayPeriod==11
	
	
* Binary Variable Indicating whether the self-employee gets profits from the business G53
gen SelfEmp_GetProfit14=OJ194
	replace SelfEmp_GetProfit14=. if SelfEmp_GetProfit14>5 | SelfEmp_GetProfit14==0

* Profit Amount - G53A
gen SelfEmp_Profit_14=OJ195
	replace SelfEmp_Profit_14=. if SelfEmp_Profit_14>=9999998

gen SelfEmp_ProfitPeriod14=OJ199 
	replace SelfEmp_ProfitPeriod14=. if SelfEmp_ProfitPeriod14>11 | SelfEmp_ProfitPeriod14==0
	
/*
OJ199                         AMT NET EARNINGS/PROFITS PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBSELFEMPD.J199_

         ([In addition to your regular salary, how much do you receive from net earnings
         or profits?/What did you earn last year?/How much do you receive from net
         earnings or profits?]
         
         [IWER: If R has trouble giving dollar figure, ask:  What did you earn the last
         year you worked?)]
         
         Amount:  [AMT NET EARNINGS/PROFITS]
         
         Per:

         .................................................................................
            10           1.  HOUR
            44           2.  WEEK
             6           3.  EVERY TWO WEEKS/BI-WEEKLY
            63           4.  MONTH
             1           5.  TWICE A MONTH
           810           6.  YEAR
             2          11.  Day
             5          97.  OTHER (SPECIFY)
             2          98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         19611       Blank.  INAP (Inapplicable); Partial Interview


*/
						
		
gen AnnualProfSE_14=.
		replace AnnualProfSE_=WeeksPerYearSE_*HoursPerWeekSE*SelfEmp_Profit_  if SelfEmp_ProfitPeriod==1
		replace AnnualProfSE_=WeeksPerYearSE_*SelfEmp_Profit_                 if SelfEmp_ProfitPeriod==2
		replace AnnualProfSE_=(WeeksPerYearSE_/2)*SelfEmp_Profit_             if SelfEmp_ProfitPeriod==3
		replace AnnualProfSE_=12*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==4
		replace AnnualProfSE_=24*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==5		
		replace AnnualProfSE_=SelfEmp_Profit_                                 if SelfEmp_ProfitPeriod==6
		replace AnnualProfSE_=5*WeeksPerYearSE_*SelfEmp_Profit_               if SelfEmp_ProfitPeriod==11
	


egen AnnualInc_SE_14=rowtotal(AnnualSalSE_ AnnualProfSE_), missing
	

egen AnnualIncTot_14=rowtotal(AnnualInc_PE_ AnnualInc_SE_), missing

keep HHID PN *SUBHH *FINR Working *Retired* HomeMaker WorkForPay SelfEmp_14 AnnualInc_PE_ AnnualInc_PEJ1_ AnnualInc_SE_ AnnualIncTot_ *Same*Emp* *SameJob* *Job_Ind* *Job_Occ* WeeksPerYear* *HoursPerWeek*

gen YEAR=2014

save "$CleanData/HRSEmpInc14.dta", replace




/* Employment Answers from 2016 - New Format */
clear all
infile using "$HRSSurveys16/h16sta/H16J_R.dct" , using("$HRSSurveys16/h16da/H16J_R.da")

* Get indicators for whether the respondent is currently  Working / Retired / HomeMaker, 
* which are recorded as binary variables from the G1 survey items. 

gen Working_16=0
gen Retired_16=0
gen HomeMaker_16=0

forvalues QN=1(1)5{

replace Working_16=1   if PJ005M`QN'==1
replace Retired_16=1   if PJ005M`QN'==5
replace HomeMaker_16=1 if PJ005M`QN'==6

}

gen MonthRetired_16=PJ017
gen YearRetired_16=PJ018


* WorkForPay - item G2, asks whether the individual is doing any work for pay
* at the present time.  This variable is almost identical to Working above, but
* there are some respodnents who are coded as "1" for WorkForPay, but "0" for 
* Working.  These are mostly individuals who are on sick leave, retired, etc. 

gen WorkForPay_16=PJ020
	replace WorkForPay_16=0 if WorkForPay_16==5
	replace WorkForPay_16=. if WorkForPay_16>5

* Self Employed - item G3.  This item and future items ask about "current, main job"
* This item asks if individuals work for someone else or are self-employed / run own business	
	
gen SelfEmp_16=PJ021
	replace SelfEmp=0 if SelfEmp==1
	replace SelfEmp=1 if SelfEmp==2
	replace SelfEmp=. if SelfEmp>2
	
* HoursPerWeek - item G44.  How many hours a week do you usually work on this job? (98 / 99 are DK / NA)
* Notice that HoursPerWeek is set to 0 for individuals who are self-employed.  We set 0 to missing here:

gen HoursPerWeek_16=PJ172
	replace HoursPerWeek_16=. if HoursPerWeek_16>168
	
* WeeksPerYear - item G47.  How many weeks do you work per year, including paid vacations.  
* This is set to zero for self-employees.  We set 0 to missing.

gen WeeksPerYear_16=PJ179
		replace WeeksPerYear_16=. if WeeksPerYear_16>52
				  
gen HowPaidPE_16=PJ205
		replace HowPaidPE_16=. if HowPaidPE_16>=8
		
/*         
PJ205                         HOW PAID ON JOB
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J205_

         Are you salaried on this job, paid by the hour, or what?

         .................................................................................
          2021           1.  SALARIED
          3853           2.  HOURLY
           129           3.  PIECEWORK/COMMISSION
           256           7.  OTHER/COMBINATION
            10           8.  DK (Don't Know); NA (Not Ascertained)
            10           9.  RF (Refused)
         14275       Blank.  INAP (Inapplicable); Partial Interview

 */		

********************************************************************************
* Workers could receive income either from salary, hourly wages, commission, or 
* other compensation schemes, and here we create separate earnings variables for 
* each kind of earnings flow.		
********************************************************************************		
		
*********************
* Salaried Workers
*********************			
		
* Salary - item G56a.  How much is your SALARY before taxes and other deductions.
* This will be zero for those who are paid hourly, and those who are self-employed.
* We set 0 equal to missings 		
		
gen Salary_16=PJ206
		replace Salary_16=. if Salary_16>=999998
		replace Salary_16=. if Salary_16==0

gen PayPeriodSal_16=PJ210
		replace PayPeriodSal_16=. if PayPeriodSal_16>11
		
* PayPeriod - item G56B.  In the previous question, how often is the reported
* salary received: 		
/*
PJ210                         AMOUNT OF SALARY ON JOB PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J210_

         (How much is your salary, before taxes and other deductions?) 
         
         IWER: If Respondent is a teacher, record annual salary 
         
         IWER: PROBE if necessary: Is that per hour, week, month, or year?
         
         Amount: [AMOUNT OF SALARY ON JOB]
         
         Per:

         .................................................................................
            43           1.  HOUR
           142           2.  WEEK
            98           3.  EVERY TWO WEEKS/BI-WEEKLY
           165           4.  MONTH
            11           5.  TWICE A MONTH
          1347           6.  YEAR
            18          11.  Day
             1          97.  OTHER (SPECIFY)
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         18729       Blank.  INAP (Inapplicable); Partial Interview




					   */

* Calculate Annual Salary based on responses, with different calculations
* for each pay period:		
gen AnnualInc_Salary_16=.
replace AnnualInc_Salary=HoursPerWeek_*WeeksPerYear_*Salary     if PayPeriodSal==1
replace AnnualInc_Salary=WeeksPerYear_*Salary                   if PayPeriodSal==2
replace AnnualInc_Salary=(WeeksPerYear_/2)*Salary               if PayPeriodSal==3		
replace AnnualInc_Salary=12*Salary                              if PayPeriodSal==4
replace AnnualInc_Salary=24*Salary                              if PayPeriodSal==5
replace AnnualInc_Salary=Salary                                 if PayPeriodSal==6	
replace AnnualInc_Salary=5*WeeksPerYear_*Salary                 if PayPeriodSal==11
						   

*********************
* Hourly Workers
*********************						   
	* Hourly Wage Rate - item G56F.  We set zeros equal to missing.
gen HourlyPay_16=PJ216
		replace HourlyPay_16=. if HourlyPay_16>=10000
		replace HourlyPay_16=. if HourlyPay_16==0
				
gen AnnualInc_Hourly_16=HoursPerWeek_*WeeksPerYear_*HourlyPay_
				
				
************************
* PIECEWORK/COMMISSION 	
************************		
* Piecework Pay - Note that in the code book this is listed as "Overtime Pay"
* but this is only non-missing for individuals who have a value of 3 for PJ205
gen PieceworkPay_16=PJ225	
	replace PieceworkPay_16=. if PieceworkPay_16>=999998
	replace PieceworkPay_16=. if PieceworkPay_16==0
* Piecework Pay Time Period - Item G56N		
gen PayPeriodPW_16=PJ226		
	replace PayPeriodPW_16=. if PayPeriodPW_16>11
	replace PayPeriodPW_16=. if PayPeriodPW_16==0	
	
/*
PJ226                         AMOUNT PAID FOR OVERTIME PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J226_

         IWER: PROBE if necessary: Is that per week or month?
         
         Amount: [AMOUNT PAID FOR OVERTIME]
         
         Per:

         .................................................................................
                         1.  HOUR
            47           2.  WEEK
             2           3.  EVERY TWO WEEKS/BI-WEEKLY
            46           4.  MONTH
                         5.  TWICE A MONTH
             7           6.  YEAR
             1          11.  Day
             5          97.  OTHER (SPECIFY); including per visit, class, mile, job,
                             piece
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         20446       Blank.  INAP (Inapplicable); Partial Interview



*/
					   
gen AnnualInc_Piecework_16=.
replace AnnualInc_Piecework_=HoursPerWeek_*WeeksPerYear_*PieceworkPay_     if PayPeriodPW==1
replace AnnualInc_Piecework_=WeeksPerYear_*PieceworkPay_                   if PayPeriodPW==2
replace AnnualInc_Piecework_=(WeeksPerYear_/2)*PieceworkPay_               if PayPeriodPW==3
replace AnnualInc_Piecework_=12*PieceworkPay_                              if PayPeriodPW==4
replace AnnualInc_Piecework_=24*PieceworkPay_                              if PayPeriodPW==5
replace AnnualInc_Piecework_=PieceworkPay_                                 if PayPeriodPW==6		
replace AnnualInc_Piecework_=5*WeeksPerYear_*PieceworkPay_                 if PayPeriodPW==11

		
*****************************
* Other
*****************************
* Other Pay - Item G56R
gen OtherPay_16=PJ230
		replace OtherPay_16=. if OtherPay_16>9999998
		replace OtherPay_16=. if OtherPay_16==0
* Other Pay - Item G56S		
gen PayPeriodOther_16=PJ231
		replace PayPeriodOther_16=. if PayPeriodOther_16>11
		replace PayPeriodOther_16=. if PayPeriodOther_16==0	
	
	
/*     
PJ231                         AMOUNT PAID- OTHER- PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBELSEEMPD.J231_

         IWER: PROBE if necessary: Was that per hour, week, month, or year?
         
         Amount: [AMOUNT PAID- OTHER]
         
         Per:

         .................................................................................
            23           1.  HOUR
            38           2.  WEEK
            14           3.  EVERY TWO WEEKS/BI-WEEKLY
            31           4.  MONTH
                         5.  TWICE A MONTH
            57           6.  YEAR
            47          11.  Day
            19          97.  OTHER (SPECIFY); including per visit, class, mile, job,
                             piece
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         20325       Blank.  INAP (Inapplicable); Partial Interview


	 */
	
gen AnnualInc_Other_16=.
	replace AnnualInc_Other_=HoursPerWeek_*WeeksPerYear_*(OtherPay_)     if PayPeriodOther==1
	replace AnnualInc_Other_=WeeksPerYear_*OtherPay_                     if PayPeriodOther==2
	replace AnnualInc_Other_=(WeeksPerYear_/2)*OtherPay_                 if PayPeriodOther==3	
	replace AnnualInc_Other_=12*OtherPay_                                if PayPeriodOther==4
	replace AnnualInc_Other_=24*OtherPay_                                if PayPeriodOther==5	
	replace AnnualInc_Other_=OtherPay_                                   if PayPeriodOther==6		
	replace AnnualInc_Other_=5*WeeksPerYear_*OtherPay_ 	                 if PayPeriodOther==11
	
	
*************************************************
* Indicator for Same Job Title as Previous Wave:	
*************************************************	



/* PJ058                         SAME JOB TITLE AS PREVIOUS WAVE
         Section: J     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         Ref: SecJ.PREVIOUSJOBANDPENSION.PWELSENOWELSE.J058_SameJobTitle

         [In [Prev IW Month, Year] our records indicate that your job title was [Prev
         Wave Job Title]. Is this still the case? / Is your job title still the same as
         it was in [Prev IW Month, Year]? ]
         
         IWER: If job title is slightly inaccurate but describes R's current job, answer
         'yes' here and note corrections as a comment

         .................................................................................
          4392           1.  YES
             8           3.  RETIRED & WORKING FOR SAME EMPLOYER/BUSINESS
           412           5.  NO
             4           7.  DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE
                         8.  DK (Don't Know); NA (Not Ascertained)
                         9.  RF (Refused)
         15738       Blank.  INAP (Inapplicable); Partial Interview*/
		 
gen SameSelfEmp_16=PJ958	

* Item G19B
gen SameEmp_16=PJ045
	
* Job Characteristics

gen SameJob_16=PJ058
		 /*            
	      4392           1.  YES
             8           3.  RETIRED & WORKING FOR SAME EMPLOYER/BUSINESS
           412           5.  NO
             4           7.  DENIES HAVING THIS JOB TITLE AT PREVIOUS WAVE */ 
gen SameJobTBranch_16=.

gen Job_Ind_16=PJ166M
gen Job_Occ_16=PJ168M	 
	
	
*******************************
* Second Job 
*******************************
* Second Job Hours Per Week - G129
gen Job2_HoursPerWeek_16=PJ556
	replace Job2_HoursPerWeek_16=. if Job2_HoursPerWeek_16>96
* Second Job Weeks Per Year - G130
gen Job2_WeeksPerYear_16=PJ557
	replace Job2_WeeksPerYear_16=. if Job2_WeeksPerYear_16>52
* Pay Second Job - G131	
gen Job2Pay_16=PJ558
    replace Job2Pay_16=. if Job2Pay_16>=999998

* Pay Period Second Job - G131A	
gen PayPeriodJob2_16=PJ562
	replace PayPeriodJob2_16=. if PayPeriodJob2_16>11
	replace PayPeriodJob2_16=. if PayPeriodJob2_16==0
	
/*
PJ562                         EARNINGS ON SECOND JOB - PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.SECONDJOBANDPLANTORETIRE.J562_

         (About how much do you earn before taxes from (this other job/these other
         jobs)?)
         
         IWER: PROBE if necessary: Is that per hour, week, month, year, or what?
         
         Amount: [EARNINGS ON SECOND JOB]
         
         Per:

         .................................................................................
           148           1.  HOUR
            89           2.  WEEK
            25           3.  EVERY TWO WEEKS/BI-WEEKLY
           108           4.  MONTH
             1           5.  TWICE A MONTH
           408           6.  YEAR
             8          11.  Day
            15          97.  OTHER (SPECIFY); including per visit, class, mile, job,
                             piece
             1          98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         19751       Blank.  INAP (Inapplicable); Partial Interview



 */
					   
	
gen AnnualInc_Job2_16=.
replace AnnualInc_Job2=Job2_HoursPerWeek_*Job2_WeeksPerYear_*(Job2Pay_)     if PayPeriodJob2==1
replace AnnualInc_Job2=Job2_WeeksPerYear_*Job2Pay_                          if PayPeriodJob2==2
replace AnnualInc_Job2=(Job2_WeeksPerYear_/2)*Job2Pay_                      if PayPeriodJob2==3
replace AnnualInc_Job2=12*Job2Pay_                                          if PayPeriodJob2==4
replace AnnualInc_Job2=24*Job2Pay_                                          if PayPeriodJob2==5
replace AnnualInc_Job2=Job2Pay_                                             if PayPeriodJob2==6
replace AnnualInc_Job2=5*Job2_WeeksPerYear_*Job2Pay_                        if PayPeriodJob2==11
		
* Sum these income sources for paid employees, treating missings as zeros. 
egen AnnualInc_PE_16=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ AnnualInc_Job2_), missing

egen AnnualInc_PEJ1_16=rowtotal(AnnualInc_Salary_ AnnualInc_Hourly_ AnnualInc_Piecework_ AnnualInc_Other_ ), missing

	
**************************
* Self Employees
**************************	
	
	
* Hours Per Week - Self Employees - (Same as for Paid Employees from this wave on *
* Weeks Per Year - Self Employees - (Same as for Paid Employees from this wave on *
gen HoursPerWeekSE_16=.
replace HoursPerWeekSE_16=HoursPerWeek_16 if SelfEmp==1

gen WeeksPerYearSE_16=.
replace WeeksPerYearSE_16=WeeksPerYear_16 if SelfEmp==1


* Binary Indicating whether they receive a salary from this business: G52		
gen SelfEmp_RegSalary16=PJ187
	replace SelfEmp_RegSalary16=. if SelfEmp_RegSalary16>5 | SelfEmp_RegSalary16==0
	replace SelfEmp_RegSalary16=0 if SelfEmp_RegSalary16==5
	
* Salary Amount - Self Employees - G52A	
gen SelfEmp_Salary16=PJ188	
	replace SelfEmp_Salary16=. if SelfEmp_Salary16>=9999998
	replace SelfEmp_Salary16=. if SelfEmp_Salary16==0
	
* Salary Pay Period - Self Employees - G52B	
gen SelfEmp_PayPeriod16=PJ192
	replace SelfEmp_PayPeriod16=. if SelfEmp_PayPeriod16>11 | SelfEmp_PayPeriod16==0

/*
PJ192                         SELF-EMPLOYMENT SALARY AMOUNT PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBSELFEMPD.J192_

         (How much are you paid before taxes and other deductions?)
         
         Amount:  [SELF-EMPLOYMENT SALARY AMOUNT]
         
         Per:

         .................................................................................
            81           1.  HOUR
           104           2.  WEEK
            13           3.  EVERY TWO WEEKS/BI-WEEKLY
            94           4.  MONTH
                         5.  TWICE A MONTH
           130           6.  YEAR
            20          11.  Day
            18          97.  OTHER (SPECIFY); including per visit, class, mile, job,
                             piece
                        98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         20094       Blank.  INAP (Inapplicable); Partial Interview



 */
	
	
* Construct Annual Salary for Self-Employees

gen AnnualSalSE_16=.
		replace AnnualSalSE=WeeksPerYearSE*HoursPerWeekSE*(SelfEmp_Salary)        if SelfEmp_PayPeriod==1
		replace AnnualSalSE=WeeksPerYearSE*SelfEmp_Salary                         if SelfEmp_PayPeriod==2
		replace AnnualSalSE=(WeeksPerYearSE/2)*SelfEmp_Salary                     if SelfEmp_PayPeriod==3
		replace AnnualSalSE=12*SelfEmp_Salary                                     if SelfEmp_PayPeriod==4
		replace AnnualSalSE=24*SelfEmp_Salary                                     if SelfEmp_PayPeriod==5		
		replace AnnualSalSE=SelfEmp_Salary                                        if SelfEmp_PayPeriod==6
		replace AnnualSalSE=5*WeeksPerYearSE*SelfEmp_Salary                       if SelfEmp_PayPeriod==11
	
	
* Binary Variable Indicating whether the self-employee gets profits from the business G53
gen SelfEmp_GetProfit16=PJ194
	replace SelfEmp_GetProfit16=. if SelfEmp_GetProfit16>5 | SelfEmp_GetProfit16==0

* Profit Amount - G53A
gen SelfEmp_Profit_16=PJ195
	replace SelfEmp_Profit_16=. if SelfEmp_Profit_16>=9999998

gen SelfEmp_ProfitPeriod16=PJ199 
	replace SelfEmp_ProfitPeriod16=. if SelfEmp_ProfitPeriod16>11 | SelfEmp_ProfitPeriod16==0
	
/*
PJ199                         AMT NET EARNINGS/PROFITS PER
         Section: J     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         Ref: SecJ.CURRENTJOB.CURRJOBSELFEMPD.J199_

         ([In addition to your regular salary, how much do you receive from net earnings
         or profits?/What did you earn last year?/How much do you receive from net
         earnings or profits?]
         
         [IWER: If R has trouble giving dollar figure, ask:  What did you earn the last
         year you worked?)]
         
         Amount:  [AMT NET EARNINGS/PROFITS]
         
         Per:

         .................................................................................
            10           1.  HOUR
            44           2.  WEEK
             6           3.  EVERY TWO WEEKS/BI-WEEKLY
            63           4.  MONTH
             1           5.  TWICE A MONTH
           810           6.  YEAR
             2          11.  Day
             5          97.  OTHER (SPECIFY)
             2          98.  DK (Don't Know); NA (Not Ascertained)
                        99.  RF (Refused)
         19611       Blank.  INAP (Inapplicable); Partial Interview


*/
						
		
gen AnnualProfSE_16=.
		replace AnnualProfSE_=WeeksPerYearSE_*HoursPerWeekSE*SelfEmp_Profit_  if SelfEmp_ProfitPeriod==1
		replace AnnualProfSE_=WeeksPerYearSE_*SelfEmp_Profit_                 if SelfEmp_ProfitPeriod==2
		replace AnnualProfSE_=(WeeksPerYearSE_/2)*SelfEmp_Profit_             if SelfEmp_ProfitPeriod==3
		replace AnnualProfSE_=12*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==4
		replace AnnualProfSE_=24*SelfEmp_Profit_                              if SelfEmp_ProfitPeriod==5		
		replace AnnualProfSE_=SelfEmp_Profit_                                 if SelfEmp_ProfitPeriod==6
		replace AnnualProfSE_=5*WeeksPerYearSE_*SelfEmp_Profit_               if SelfEmp_ProfitPeriod==11
	


egen AnnualInc_SE_16=rowtotal(AnnualSalSE_ AnnualProfSE_), missing
	

egen AnnualIncTot_16=rowtotal(AnnualInc_PE_ AnnualInc_SE_), missing

keep HHID PN *SUBHH *FINR Working *Retired* HomeMaker WorkForPay SelfEmp_16 AnnualInc_PE_ AnnualInc_PEJ1_ AnnualInc_SE_ AnnualIncTot_ *Same*Emp* *SameJob* *Job_Ind* *Job_Occ* WeeksPerYear* *HoursPerWeek*

gen YEAR=2016


save "$CleanData/HRSEmpInc16.dta", replace




clear all
use "$CleanData/HRSEmpInc92.dta"
append using "$CleanData/HRSEmpInc94.dta"
append using "$CleanData/HRSEmpInc96.dta"
append using "$CleanData/HRSEmpInc98.dta"
append using "$CleanData/HRSEmpInc00.dta"
append using "$CleanData/HRSEmpInc02.dta"
append using "$CleanData/HRSEmpInc04.dta"
append using "$CleanData/HRSEmpInc06.dta"
append using "$CleanData/HRSEmpInc08.dta"
append using "$CleanData/HRSEmpInc10.dta"
append using "$CleanData/HRSEmpInc12.dta"
append using "$CleanData/HRSEmpInc14.dta"
append using "$CleanData/HRSEmpInc16.dta"

gen Working=.
gen Retired=.
gen HomeMaker=.
gen WorkForPay=.
gen SelfEmp=.
gen AnnualInc_PE=.
gen AnnualInc_PEJ1=.
gen AnnualInc_SE=.
gen AnnualIncTot=.
gen Job_Ind=.
gen Job_Occ=.
gen HoursPerWeek=.
gen HoursPerWeekSE=.
gen WeeksPerYear=.
gen WeeksPerYearSE=.

foreach Var in Working Retired HomeMaker WorkForPay SelfEmp AnnualInc_PE AnnualInc_PEJ1 AnnualInc_SE AnnualIncTot Job_Ind Job_Occ HoursPerWeek HoursPerWeekSE WeeksPerYear WeeksPerYearSE {
	foreach YRInd in 92 94 96 98 00 02 04 06 08 10 12 14 16 {
		
		if (`YRInd'>90) {
			di `YRInd'
			replace  `Var'=`Var'_`YRInd' if YEAR==(1900+`YRInd')
			
		} 
		
		else {
			di `YRInd'
			replace  `Var'=`Var'_`YRInd' if YEAR==(2000+`YRInd')
		}
		
	}
}


replace Job_Ind=SE_Job_Ind_92 if YEAR==1992 & SE_Job_Ind_92~=. & Job_Ind==.
replace Job_Occ=SE_Job_Occ_92 if YEAR==1992 & SE_Job_Occ_92~=. & Job_Occ==.

replace Job_Ind=SE_Job_Ind_94 if YEAR==1994 & SE_Job_Ind_94~=. & Job_Ind==.
replace Job_Occ=SE_Job_Occ_94 if YEAR==1994 & SE_Job_Occ_94~=. & Job_Occ==.




* Get Time-Invariant versions of Job_Ind, Job_Occ, SE_Job_Ind (1992, 1994) SE_Job_Occ, SameJob SameEmp
foreach YRInd in 92 94 96 98 00 02 04 06 08 10 12 14 16 {

		if (`YRInd'>90) {
				local FullYear=(1900+`YRInd')
		} 
		
		else {
				local FullYear=(2000+`YRInd')
		}

		foreach var in Job_Ind Job_Occ {
				bys HHID PN: egen `var'`FullYear'=max(`var'_`YRInd')
		}		
		
		
		if (`FullYear'>1992) {
			
			foreach var in SameJob SameEmp {
					bys HHID PN: egen `var'`FullYear'=max(`var'_`YRInd')
			}
			
			if (`FullYear'>=2014) {
			
				bys HHID PN: egen SameSelfEmp`FullYear'=max(SameSelfEmp_`YRInd')
			
			}
			
		} 
		
}


foreach yr in 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016{

	gen SameJobCharsAsLast`yr'=.
		replace SameJobCharsAsLast`yr'=1 if SameEmp`yr'==1 & SameJob`yr'==1
		
}	


foreach yr in 2014 2016 {

	replace SameJobCharsAsLast`yr'=1 if SameSelfEmp`yr'==1
}



/*
* Test the Same Job Characteristics Code

gen Job_Ind_Test=Job_Ind
gen Job_Occ_Test=Job_Occ


foreach yr in 1994 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 {
	local lastyr=`yr'-2
	
	gen Temp=.
	replace Temp=Job_Ind_Test if YEAR==`lastyr'
	bys HHID PN: egen IndLastYear=max(Temp)
	drop Temp
	
	gen Temp=.
	replace Temp=Job_Occ_Test if YEAR==`lastyr'
	bys HHID PN: egen OccLastYear=max(Temp)
	drop Temp
		
	
	replace Job_Ind_Test=IndLastYear if YEAR==`yr' & SameJobCharsAsLast`yr'==1 & Job_Ind_Test==.
	replace Job_Occ_Test=OccLastYear if YEAR==`yr' & SameJobCharsAsLast`yr'==1 & Job_Occ_Test==.
	
	drop IndLastYear OccLastYear
}

*/


* Now, merge with the BLS CPI Index:
gen CPIYear=YEAR

merge m:1 CPIYear using "$CPIDir\CPI_U_1913_2016_2k10.dta", gen(YearMerge)
	* Drop observations that correspond to years that aren't in data:
	drop if YearMerge==2

	
gen RealAnnualIncPE=AnnualInc_PE/CPI
gen RealAnnualIncPEJ1=AnnualInc_PEJ1/CPI
gen RealAnnualIncSE=AnnualInc_SE/CPI	
gen RealAnnualIncTotal=AnnualIncTot/CPI	


keep HHID PN YEAR Working Retired HomeMaker WorkForPay SelfEmp AnnualInc_PE AnnualInc_PEJ1 AnnualInc_SE AnnualIncTot Real* Job_Ind Job_Occ SameJob* SameEmp* SameJobCharsAsLast* HoursPerWeek* WeeksPerYear*


save "$CleanData\EA_HRSEmpIncOccPanel.dta", replace
