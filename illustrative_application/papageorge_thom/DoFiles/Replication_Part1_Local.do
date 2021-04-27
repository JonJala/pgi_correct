
clear all

global EADoFiles       "C:\Users\thomk\Dropbox (KThom)\HRSGenes\PAPER_SES\REPLICATION"
global CleanData       "C:\Users\thomk\Dropbox (KThom)\HRSGenes\PAPER_SES\REPLICATION\RepClean"
global TableDir        "C:\Users\thomk\Dropbox (KThom)\HRSGenes\PAPER_SES\REPLICATION\RepOutput"
global FigureDir        "C:\Users\thomk\Dropbox (KThom)\HRSGenes\PAPER_SES\REPLICATION\RepOutput"
global Tracker16        "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\2016_Cross_Wave_Tracker"
global EA3ScoreDir     "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\SSGAC_Lee_et_al"
global HRSPGS3Dir      "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\PGENSCORE3"
global CrossWaveCogDir "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\2014_CrossWaveCognition"
global CrossWaveLocDir "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\2014_CrossWave_Region"
global LifeHistory     "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\LifeHistory"
global OccCrossWalks   "C:\Users\KT44\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\EXTERNAL\DOT\CENSUS_CROSSWALKS"
global CPSDecades      "E:\CPS\Decades"
global ExternalDir     "C:\Users\thomk\Dropbox (KThom)\HRSGenes\PAPER_SES\REPLICATION\RepExternal"

global HRSSurveys92 "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\1992_HRS_Survey"
global HRSSurveys94 "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\1994_HRS_Survey"
global HRSSurveys96 "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\1996_HRS_Survey"
global HRSSurveys98 "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\1998_HRS_Survey"
global HRSSurveys00 "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\2000_HRS_Survey"
global HRSSurveys02 "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\2002_HRS_Survey"
global HRSSurveys04 "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\2004_HRS_Survey"
global HRSSurveys06 "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\2006_HRS_Survey"
global HRSSurveys08 "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\2008_HRS_Survey"
global HRSSurveys10 "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\2010_HRS_Survey"
global HRSSurveys12 "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\2012_HRS_Survey"
global HRSSurveys14 "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\2014_HRS_Survey"
global HRSSurveys16 "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\2016_HRS_Survey"

global HRSInternet06 "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\2006_Internet_Survey"
global HRSInternet07 "C:\Users\thomk\Dropbox (KThom)\HRSGenes\ESTIMATION\DATA\RAW\2007_Internet_Survey"


global AHEADSurveys93 "C:\Users\thomk\Dropbox (KThom)\HRSGenes/ESTIMATION/DATA/RAW/1993_AHEAD_Survey"
global AHEADSurveys95 "C:\Users\thomk\Dropbox (KThom)\HRSGenes/ESTIMATION/DATA/RAW/1995_AHEAD_Survey"

global HRSExit10      "C:\Users\thomk\Dropbox (KThom)\HRSGenes/ESTIMATION/DATA/RAW/2010_Exit_Survey"
global HRSExit08      "C:\Users\thomk\Dropbox (KThom)\HRSGenes/ESTIMATION/DATA/RAW/2008_Exit_Survey"
global HRSExit06      "C:\Users\thomk\Dropbox (KThom)\HRSGenes/ESTIMATION/DATA/RAW/2006_Exit_Survey"
global HRSExit04      "C:\Users\thomk\Dropbox (KThom)\HRSGenes/ESTIMATION/DATA/RAW/2004_Exit_Survey"
global HRSExit02      "C:\Users\thomk\Dropbox (KThom)\HRSGenes/ESTIMATION/DATA/RAW/2002_Exit_Survey"
global HRSExit00      "C:\Users\thomk\Dropbox (KThom)\HRSGenes/ESTIMATION/DATA/RAW/2000_Exit_Survey"
global HRSExit98      "C:\Users\thomk\Dropbox (KThom)\HRSGenes/ESTIMATION/DATA/RAW/1998_Exit_Survey"
global HRSExit96      "C:\Users\thomk\Dropbox (KThom)\HRSGenes/ESTIMATION/DATA/RAW/1996_Exit_Survey"
global AHEADExit95    "C:\Users\thomk\Dropbox (KThom)\HRSGenes/ESTIMATION/DATA/RAW/1995_AHEAD_EXIT"

global Census1950      "E:\IPUMS_USCensus_1950"
global Census1960      "E:\IPUMS_USCensus_1960"
global Census1970      "E:\IPUMS_USCensus_1970"
global Census1980      "E:\IPUMS_USCensus_1980"
global Census2000      "E:\IPUMS_USCensus_2000"
global ACS2010         "E:\ACS\ACS_2010"

global CPIDir          "C:\Users\thomk\Dropbox (KThom)\CPI"


clear all

* The HRS masks occupation variables based on 17 categories for 1990 Census 
* codes (used until 2004), 25 catgories for the 200 Census codes (used 2006-2010), 
* and 23 categories for the 2010 Census codes (used after 2010).  This code
* generates a series of crosswalks between HRS masked categories from these
* three different schemes, so one could have comparable masked categories based on
* the 1990 categories for all waves.  
do "$EADoFiles\EA_GetHRS_Occ_CrossWalks.do"

clear all

* The next do file creates a cross-walk between the 1980, 2000, and 2010
* Census / ACS occupation codes and the 1990 Census occupation codes. 
* Note that these are not crosswalks based on the HRS masking categories, these
* simply calculate the modal 1990 occupation code for each occupation category
* in 1980, 2000, and 2010.
do "$EADoFiles\EA_GetCensusOccCW2010_2000_1990.do"

clear all

* Clean Census Data for Father's Income by Occupation:
* This produces two outputs:
*   "$CleanData\FOccIncData.dta" - gives average real income in 1950, 1960, 1970 for the 17 masked HRS occupation categories.
*   "$CleanData\FOcc1990AvgInc.dta" - gives average real income in 1950, 1960, 1970 for all 1990 Census occupation codes.
do "$EADoFiles\EA_GetFOccInc.do"

clear all

* Cognition
do "$EADoFiles\EA_GetCleanCogImpute.do"

clear all

* Get Indicator for Ever Redoing Grade from Leave-Behind Module:
do "$EADoFiles\EA_GetLeaveBehind.do"

clear all

* Get Demographics (including Parental Education and Childhood SES):
do "$EADoFiles\EA_GetDemo.do"

clear all

* Get Income and Occupation Panel (Including variable to indicate whether respondent has the
* same job as last wave:
do "$EADoFiles\EA_GetHRSEmpIncOcc.do"

clear all

* Get Cross-Sectional Variables, including Educational Attainment and the Polygenic Scores:
do "$EADoFiles\EA_GetCrossSample.do"

clear all

* Get Top Code Stats:
do "$EADoFiles\EA_GetCPSTopCodeStatsComplete.do"

clear all


* Do Files to be transferred to the MiCDA Server:
*
* 1) Results 

* Data Files to be transferred to the MiCDA Server:
*
* 1) EA_CrossSection.dta - Basic Cross-Sectional Data set with education and 
*                          publicly available genetic data
*
* 2) EA_HRSEmpIncOccPanel.dta - Panel of HRS labor outcomes, including 
*                               industry and occupation categories, and 
*                               indicators for job changes
*
* 3) EA_TopCodeStatsComplete.dta - Average incomes above top-coded limits
*
* 4) Replication Files from Autor Levy and Murnane:
*    occ80.dta (from ALM replication files)
*    occ90.dta (from ALM replication files)
*    DOT91_8090_MALES.dta (from ALM replication files)  The original
*    file in Autor's replication materials is dot91-8090-gen.dta, but I
*    simply restricted that data set to female=0 (just task intensities
*    for men in those occupations, since our sample for this section is all 
*    male).  
*
* 5) Replication Files from Autor and Dorn:
*     
*     occ1980_occ1990dd.dta  (David Dorn Replication)
*     occ2000_occ1990dd.dta  (David Dorn Replication)
*     occ1990dd_data2012.dta (David Dorn Replication)
*
* 6) Father's Income Stats: FOcc1990AvgInc (based on 1990 occupation codes)
*
* 7) Census Occupation Crosswalks (generated above)
*
*		CensusOcc_1980to1990.dta (generated above)
*		CensusOcc_2000to1990.dta (generated above)
*		CensusOcc_2010to1990.dta (generated above)
*
* 8) BLS CPI Files: 
	 * CPI_U_1913_2016_2k10.dta
	 