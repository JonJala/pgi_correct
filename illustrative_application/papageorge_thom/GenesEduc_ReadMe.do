/*

Replication Instructions for 
Papageorge and Thom, "Genes, Education, and Labor Market Outcomes". 

Please read this file to set up directories, and then continue on to read
the comments in GenesWealth_Replication.do.

All of the replication files here are for Stata.  There are many .do files
associated with this project, but once all of the directories and raw data
files are properly set up, one should only need to run Replication_Part1_Local.do

Note that in Replication_Part1_Local.do you will need to fill in the exact
path on your machine(s) to each of the lobal directory names.
 
The Health and Retirement Study does not authorize the distribution of its primary
data files (or cleaned versions of them) apart from websites that they maintain
or sanction.  The files that should be contained in local directories below
are publicly available and can be downloaded from the HRS after registration
here:  https://hrs.isr.umich.edu/data-products

Before continuing on to the Replication_Part1_Local.do file, make sure that
the following directories are set up locally.  At the  start of the
Replication_Part1_Local.do file, you will need to fill in the specific
path you will assign for each global variable specified below.



Local Directories (29 Local Directories or Sets of Directories):  

1. Directory containing all do files: global EADoFiles

2. Directory containing cleaned and intermediate data files: global CleanData

3. Directory containing Tables (local - not Enclave): global TableDir

4. Directory containing the HRS Cross-Wave Tracker File (2016): global Tracker16
	Must contain:
	HRS_Tacker16.dta  (From HRS Website)

5. Directory containing the SSGAC's Polygenic Score for Educational Attainment 
	based on the Lee et al (2018) GWAS: global EA3ScoreDir
	Must contain:
	Lee_et_al_(2018)_PGS_HRS.txt (From HRS Website)

6. Directory containing HRS Polygenic Score File (Version 3): global HRSPGS3Dir
	Must contain:
	GENSCORE3E_R.dta  (From HRS Website)


7. Directory containing the Cross-Wave Cognition File: global CrossWaveCogDir 
	Must contain:
	COGIMP9214A_R.dct, COGIMP9214A_R.da          (From HRS Website)
	
8. Directory containing the Cross-Wave Region file: global CrossWaveLocDir 
	Must contain:
	HRSXREGION14.dct , HRSXREGION14.da          (From HRS Website)	

9. Directory containing the 2015 and 2017 Life History Files: global LifeHistory
    Must contain:
	LHMS15_R.dct, LHMS15_R.da, LHMS17SPR_R.dct, LHMS17SPR_R.da  (From HRS Website)	
	
10.  Directories containing Census and ACS data used to create occupation
     cross-walks, and to calculate income from US Censuses:
	 
	 global ACS2010 
	 Must contain: ACS2010.dta.  This is the version of the 2010 ACS data
	 available through IPUMS USA: https://usa.ipums.org/usa/
	 
	 global Census2000
     Must contain: IPUMS_USCensus_2000.dta.  This is the version of the 
	 2000 Census data available throgh IPUMS USA: https://usa.ipums.org/usa/

	 global Census1990
     Must contain: IPUMS_USCensus_1990.dta.  This is the version of the 
	 1990 Census data available throgh IPUMS USA: https://usa.ipums.org/usa/
	 
	 global Census1980
     Must contain: IPUMS_USCensus_1980.dta.  This is the version of the 
	 1980 Census data available throgh IPUMS USA: https://usa.ipums.org/usa/	 

	 global Census1970
     Must contain: IPUMS_USCensus_1970.dta.  This is the version of the 
	 1970 Census data available throgh IPUMS USA: https://usa.ipums.org/usa/

	 global Census1960
     Must contain: IPUMS_USCensus_1960.dta.  This is the version of the 
	 1960 Census data available throgh IPUMS USA: https://usa.ipums.org/usa/
	 
	 global Census1950
     Must contain: IPUMS_USCensus_1950.dta.  This is the version of the 
	 1950 Census data available throgh IPUMS USA: https://usa.ipums.org/usa/	 
	 
	 
11. 1992 HRS Survey Files:  global HRSSurveys92
	Must contain:
	HEALTH.dct, HEALTH.da
	EMPLOYER.dct, EMPLOYER.da
	KIDS.dct  , KIDS.da
	HHList.dct, HHList.da       (From HRS Website)

12. 1994 HRS Survey Files:  global HRSSurveys94
	Must contain:
	W2CS.dct, W2CS.da
	W2A.dct, W2A.da
	W2C.dct, W2C.da
	W2FA.dct, W2FA.da
	W2FB.dct, W2FB.da           (From HRS Website)

13. 1996 HRS Survey Files:  global HRSSurveys96
	Must contain:
	H96CS_R.dct, H96CS_R.da
	H96A_R.dct,  H96A_R.da
	H96B_R.dct,  H96B_R.da
	H96G_R.dct,  H96G_R.da
	H96H_R.dct, H96H_R.da
	H96PR_R.dct, H96PR_R.da     (From HRS Website)

14. 1998 HRS Survey Files:  global HRSSurveys98
	Must contain:
	H98A_R.dct, H98A_R.da
	H98G_R.dct, H98G_R.da
	H98H_R.dct, H98H_R.da
	H98J_R.dct, H98J_R.da
	H98PR_R.dct, H98PR_R.da     (From HRS Website)

15. 2000 HRS Survey Files:  global HRSSurveys00
	Must contain:
	H00A_R.dct, H00A_R.da
	H00G_R.dct, H00G_R.da
	H00H_R.dct, H00H_R.da
	H00PR_R.dct, H00PR_R.da     (From HRS Website)

16. 2002 HRS Survey Files:  global HRSSurveys02
	Must contain:
	H02A_R.dct, H02A_R.da
	H02B_R.dct, H02B_R.da
	H02J_R.dct, H02J_R.da
	H02P_R.dct, H02P_R.da
	H02PR_R.dct, H02PR_R.da     (From HRS Website)

17. 2004 HRS Survey Files:  global HRSSurveys04
	Must contain:
	H04A_R.dct, H04A_R.da
	H04B_R.dct, H04B_R.da
	H04J_R.dct, H04J_R.da
	H04P_R.dct, H04P_R.da
	H04PR_R.dct, H04PR_R.da      (From HRS Website)

18. 2006 HRS Survey Files:  global HRSSurveys06
	Must contain:
	H06A_R.dct, H06A_R.da
	H06B_R.dct, H06B_R.da
	H06J_R.dct, H06J_R.da
	H06P_R.dct, H06P_R.da
	H06PR_R.dct, H06PR_R.da      (From HRS Website)

19. 2008 HRS Survey Files:  global HRSSurveys08
	Must contain:
	H08A_R.dct, H08A_R.da
	H08B_R.dct, H08B_R.da
	H08J_R.dct, H08J_R.da
	H08P_R.dct, H08P_R.da
	H08PR_R.dct, H08PR_R.da      (From HRS Website)

20. 2010 HRS Survey Files:  global HRSSurveys10
	Must contain:
	H10A_R.dct, H10A_R.da
	H10B_R.dct, H10B_R.da
	H10J_R.dct, H10J_R.da
	H10P_R.dct, H10P_R.da
	H10PR_R.dct, H10PR_R.da      (From HRS Website)

21. 2012 HRS Survey Files:  global HRSSurveys12
	Must contain:
	H12A_R.dct, H12A_R.da
	H12B_R.dct, H12B_R.da
	H12J_R.dct, H12J_R.da
	H12P_R.dct, H12P_R.da
	H12PR_R.dct, H12PR_R.da     (From HRS Website)

22. 2014 HRS Survey Files:  global HRSSurveys14
	Must contain:
	H14A_R.dct, H14A_R.da
	H14B_R.dct, H14B_R.da
	H14J_R.dct, H14J_R.da
	H14P_R.dct, H14P_R.da
	H14PR_R.dct, H14PR_R.da     (From HRS Website)	

23. 2016 HRS Survey Files:  global HRSSurveys16
	Must contain:
	H16A_R.dct, H16A_R.da
	H16B_R.dct, H16B_R.da
	H16J_R.dct, H16J_R.da
	H16P_R.dct, H16P_R.da
	H16PR_R.dct, H16PR_R.da     (From HRS Website)		
	

24. Directory containing the SSA Taxable Maxima for each year: global ExternalDir  
	Must contain:
	SSATopCodeLevels.dta (included in replication package - data entered from 
	 table available at https://www.ssa.gov/OACT/COLA/cbb.html)
 
25. Directory containing CPS data (March waves, available from IPUMS packaged by decades):
	global CPSDecades
	Must contain:
	CPS_1960s.dta
	CPS_1970s.dta
	CPS_1980s.dta
	CPS_1990s.dta
	CPS_2000s.dta
	CPS_2010s.dta  (Available from IPUMS CPS: https://cps.ipums.org/cps/index.shtml)

26. Directory containing CPI used to convert to real 2010 dollars (From BLS):
	global: CPIDir
	Must contain:
	CPI_U_1913_2016_2k10.dta (included in replication package)

27. Directories containing the 2006 and 2007 HRS Internet Surveys
    global: HRSInternet06
	Must contain: net06_r.dct, net06_r.da
	
	global: HRSInternet07
	Must contain: net07_r.dct, net07_r.da
	
28. Directory for the 1993 AHEAD survey:
    global: AHEADSurveys93
	Must contain: BR21.dct, BR21.da

29. Directory for the 1995 AHEAD survey:
    global: AHEADSurveys95
	Must contain: A95A_R.dct, A95A_R.da
  
Once these directories are set up, proceed to run Replication_Part1_Local  
*/ 


