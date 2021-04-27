
/* Demographics - 1992  */

clear all

infile using "$HRSSurveys92/h92sta/HEALTH.dct" , using("$HRSSurveys92/h92da/HEALTH.da")

* Region of Birth:
gen RegionBorn_1992=V205

* Mother's Education:
gen MotherEduc_1992=V212
	replace MotherEduc=. if MotherEduc>=98
	
/*         212     A4.     What is the highest grade of school your mother
                        completed? [IF DK, PROBE:  What would be your best
                        guess?]
                ____________________________________________________________

                        Code grade (00-17)

                        98.     DK
                        99.     NA */	
	
* Father's Education:	
gen FatherEduc_1992=V213
	replace FatherEduc=. if FatherEduc>=98

/*         213     A5.     And what is the highest grade of school your father
                        completed? [IF DK, PROBE:  What would be your best
                        guess?]
                ____________________________________________________________

                        Code grade (00-17)

                        98.     DK
                        99.     NA  */	
	
* Religion.  The variable V214 contains detailed codes on religious 
* denomination.  We will collapse these down to a set of 9 categories:		
gen ReligionDenom_1992=V214

	gen ReligCat_1992=.
		replace ReligCat_1992=1  if ReligionDenom>=1   & ReligionDenom<=10
		replace ReligCat_1992=2  if ReligionDenom>=11  & ReligionDenom<=20
		replace ReligCat_1992=3  if ReligionDenom>=21  & ReligionDenom<=40
		replace ReligCat_1992=4  if ReligionDenom>=41  & ReligionDenom<=50
		replace ReligCat_1992=5  if ReligionDenom>=51  & ReligionDenom<=60
		replace ReligCat_1992=6  if ReligionDenom>=61  & ReligionDenom<=70
		replace ReligCat_1992=7  if ReligionDenom==71  
		replace ReligCat_1992=8  if ReligionDenom>=81  & ReligionDenom<=90
		replace ReligCat_1992=9  if ReligionDenom>=91  & ReligionDenom<=97

/* See 	Codes in Codebook, 1-10, Reformation Protestant       (Cat 1)
                           11-20, Pietistic Protestant        (Cat 2)
						   21-40, Fundamentalist Protestant   (Cat 3)
						   41-50, General Protestant          (Cat 4)
						   51-60, Catholic / Orthodox         (Cat 5)
						   61-70, Nontraditional Christian    (Cat 6)
						   71     Jewish                      (Cat 7)
						   81-90, Non Judeo-Christian         (Cat 8)
						   91-97, No Religion                 (Cat 9)
						   98,    DK / NA
						   99,    Refused */
						   
			
keep HHID PN *1992

gen YEAR=1992

save "$CleanData/HRSDemo1992.dta", replace


/* Demographic Variables from 1993 */

clear all
infile using "$AHEADSurveys93/BR21.dct" , using("$AHEADSurveys93/BR21.da")

gen MotherEduc8_1993=V130

/* V130      [RESP]    A4. MOTHER IN SCHOOL 8/+ YEARS
          A4.  Did your mother attend 8 years or more of school?
 -----------------------------------------------------------------------------
               3801      YES................................  1
               3418      NO.................................  5
               1000      DK................................. .D
                  3      RF................................. .R */

gen FatherEduc8_1993=V131

/* V131      [RESP]    A5. FATHER IN SCHOOL 8/+ YEARS
          A5.  Did your father attend 8 years or more of school?
 -----------------------------------------------------------------------------
               3521      YES................................  1
               3676      NO.................................  5
               1025      DK................................. .D
                  0      RF................................. .R */


gen ReligionDenom93_1993=V134

/*
V134      [RESP]    A6. R'S RELIGION
          A6.  What is your religious preference; Is it Protestant,
               Catholic,  Jewish, some other religion, or do you have no
               preference?
 -----------------------------------------------------------------------------
               5221      PROTESTANT.........................  1
               2170      CATHOLIC...........................  2 GO TO A6b
                333      JEWISH.............................  3 GO TO A6b
                361      NO PREFERENCE......................  4 GO TO A6b
                129      OTHER RELIGION.....................  7
                  6      DK................................. .D GO TO A6b
                  2      RF................................. .R GO TO A6b */				  

keep HHID PN Mother Father Religion

gen YEAR=1993

save "$CleanData/HRSDemo1993.dta", replace


/* Demographic Variables from 1994 */

clear all
infile using "$HRSSurveys94/h94sta/W2A.dct" , using("$HRSSurveys94/h94da/W2A.da")

* Region of Birth:
gen RegionBorn_1994=W216

* Religious Denomination:
gen ReligionDenom_1994=W226

	gen ReligCat_1994=.
		replace ReligCat_1994=1  if ReligionDenom>=1   & ReligionDenom<=10
		replace ReligCat_1994=2  if ReligionDenom>=11  & ReligionDenom<=20
		replace ReligCat_1994=3  if ReligionDenom>=21  & ReligionDenom<=40
		replace ReligCat_1994=4  if ReligionDenom>=41  & ReligionDenom<=50
		replace ReligCat_1994=5  if ReligionDenom>=51  & ReligionDenom<=60
		replace ReligCat_1994=6  if ReligionDenom>=61  & ReligionDenom<=70
		replace ReligCat_1994=7  if ReligionDenom==71  
		replace ReligCat_1994=8  if ReligionDenom>=81  & ReligionDenom<=90
		replace ReligCat_1994=9  if ReligionDenom>=91  & ReligionDenom<=97

/* See 	Codes in Codebook, 1-10, Reformation Protestant
                           11-20, Pietistic Protestant
						   21-40, Fundamentalist Protestant
						   41-50, General Protestant
						   51-60, Catholic / Orthodox 
						   61-70, Nontraditional Christian 
						   71     Jewish
						   81-90, Non Judeo-Christian
						   91-97, No Religion
						   98,    DK / NA
						   99,    Refused */


keep HHID PN *1994

gen YEAR=1994

save "$CleanData/HRSDemo1994.dta", replace



/* Demographic Variables from 1995 */

clear all
infile using "$AHEADSurveys95/a95sta/A95A_R.dct" , using("$AHEADSurveys95/a95da/A95A_R.da")

gen MotherEduc8_1995=D654

/* D654      A4.MA EDUC                                
          Section: A            Level: Respondent      CAI Reference: Q654
          Type: Numeric         Width: 1               Decimals: 0

          A4. Did your mother attend 8 years or more of school?
          ................................................................................
             37         1. YES
             22         5. NO
                        7. Other
             17         8. DK (don't know); NA (not ascertained)
                        9. RF (refused)
           6951     Blank. INAP (Inapplicable); [Q370:W1 INTERV] IS (1) */

gen FatherEduc8_1995=D655

/* D655      A5.PA EDUC                                
          Section: A            Level: Respondent      CAI Reference: Q655
          Type: Numeric         Width: 1               Decimals: 0

          A5. Did your father attend 8 years or more of school?
          ................................................................................
             27         1. YES
             28         5. NO
                        7. Other
             21         8. DK (don't know); NA (not ascertained)
                        9. RF (refused)
           6951     Blank. INAP (Inapplicable); [Q370:W1 INTERV] IS (1) */


gen Religion95_1995=D732	

/* D732      A36.R RELIGIOUS PREF                      
          Section: A            Level: Respondent      CAI Reference: Q732
          Type: Numeric         Width: 1               Decimals: 0

          A36. What is your religious preference; Is it Protestant, Catholic, Jewish,
          some other religion, or do you have no preference?
          ................................................................................
             44         1. PROTESTANT
             24         2. CATHOLIC
              2         3. JEWISH
              4         4. NO PREFERENCE
              2         7. Other
                        8. DK (don't know); NA (not ascertained)
                        9. RF (refused)
           6951     Blank. INAP (Inapplicable); [Q370:W1 INTERV] IS (NE 0 AND NE 5) */	   

gen ReligionDenom95_1995=D733			  
		  

keep HHID PN *_1995

gen YEAR=1995

save "$CleanData/HRSDemo1995.dta", replace




/* Demographic Variables from 1996  */

clear all
infile using "$HRSSurveys96/h96sta/H96A_R.dct" , using("$HRSSurveys96/h96da/H96A_R.da")


gen RegionBorn_1996=E640M

/* 
E640M     A2A. REGION - US BORN                     
          Section: A            Level: Respondent      CAI Reference: Q19062
          Type: Numeric         Width: 2               Decimals: 0  */

gen RegionSch_1996 =E715M

/* E715M     A27. REGION WHERE LIVE WHEN IN SCH-MASKE  
          Section: A            Level: Respondent      CAI Reference: Q19066
          Type: Numeric         Width: 2               Decimals: 0

          A27. In what state or country did you live most of the time you were (in
          grade school/in high school/about age 10)? */
		  

gen MotherEduc8_1996=E654

/* E654      A4.MOTHER EDUC                            
          Section: A            Level: Respondent      CAI Reference: Q654
          Type: Numeric         Width: 1               Decimals: 0

          A4. Did your mother attend 8 years or more of school?  */

gen FatherEduc8_1996=E655

/* E655      A5.FATHER EDUC                            
          Section: A            Level: Respondent      CAI Reference: Q655
          Type: Numeric         Width: 1               Decimals: 0

          A5. Did your father attend 8 years or more of school? */


gen RuralChildhood_1996=E718

/* E718      A28.LIVE IN CITY/TOWN/RURAL               
          Section: A            Level: Respondent      CAI Reference: Q718
          Type: Numeric         Width: 1               Decimals: 0

          A28. Were you living in a rural area most of the time when you were (in
          grade school/in high school/about age 10)? */

		  
		  
gen Religion_1996=E732
	/*
	E732      A36.R RELIGIOUS PREF                      
          Section: A            Level: Respondent      CAI Reference: Q732
          Type: Numeric         Width: 1               Decimals: 0

          A36. What is your religious preference; Is it Protestant, Catholic, Jewish,
          some other religion, or do you have no preference?
          ................................................................................
            103         1. PROTESTANT
             66         2. CATHOLIC
              7         3. JEWISH
             13         4. NO PREFERENCE
              7         7. OTHER
                        8. DK (don't know); NA (not ascertained)
                        9. RF (refused)
	*/

gen ReligionDenom_1996=E733
	/* Codes are consistent with past questions */

keep HHID PN *1996

gen YEAR=1996

save "$CleanData/HRSDemo1996.dta", replace



/* Demographic Variables from 1998 - New Format */
clear all
infile using "$HRSSurveys98/h98sta/H98A_R.dct" , using("$HRSSurveys98/h98da/H98A_R.da")

*******************************
* Region Born / Went to School
*******************************
gen RegionBorn_1998    =F972M
gen RegionSch_1998     =F1035M
gen RuralChildhood_1998=F1038

/*F972M     A2A.REGION - US BORN                      
          Section: A            Level: Respondent      CAI Reference: Q10972
          Type: Numeric         Width: 2               Decimals: 0

          A2a. In what state were you born?

          User note:  Some categories have been collapsed to protect respondent
          confidentiality.
          ................................................................................
            241         1. Northeast Region: New England Division (ME, NH, VT, MA, RI, CT)
            692         2. Northeast Region: Middle Atlantic Division (NY, NJ, PA)
            808         3. Midwest Region: East North Central Division (OH, IN, IL, MI,
                           WI)
            482         4. Midwest Region: West North Central Division (MN, IA, MO, ND,
                           SD, NE, KS)
            715         5. South Region: South Atlantic Division (DE, MD, DC, VA, West VA,
                           NC, SC, GA, FL)
            336         6. South Region: East South Central Division (KY, TN, AL, MS)
            462         7. South Region: West South Central Division (AR, LA, OK, TX)
            141         8. West Region: Mountain Division (MT, ID, WY, CO, NM, AZ, UT, NV)
            292         9. West Region: Pacific Division (WA, OR, CA, AK, HI)
                       10. U.S., NA state
              3        11. Foreign Country: Not in a Census Division (includes U.S.
                           territories)
                       96. Same State (see questionnaire)
              1        98. DK (don't know); NA (not ascertained)
              1        99. RF (refused) 
			  
F1035M    A27.WHERE LIVE WHEN IN SCH - REGION       
          Section: A            Level: Respondent      CAI Reference: Q11035
          Type: Numeric         Width: 2               Decimals: 0

          A27. In what state or country did you live most of the time you were (in
          grade school/in high school/about age 10)?

          User note:  Some categories have been collapsed to protect respondent
          confidentiality.
          ................................................................................
            223         1. Northeast Region: New England Division (ME, NH, VT, MA, RI, CT)
            647         2. Northeast Region: Middle Atlantic Division (NY, NJ, PA)
            780         3. Midwest Region: East North Central Division (OH, IN, IL, MI,
                           WI)
            435         4. Midwest Region: West North Central Division (MN, IA, MO, ND,
                           SD, NE, KS)
            672         5. South Region: South Atlantic Division (DE, MD, DC, VA, West VA,
                           NC, SC, GA, FL)
            278         6. South Region: East South Central Division (KY, TN, AL, MS)
            386         7. South Region: West South Central Division (AR, LA, OK, TX)
            128         8. West Region: Mountain Division (MT, ID, WY, CO, NM, AZ, UT, NV)
            390         9. West Region: Pacific Division (WA, OR, CA, AK, HI)
                       10. U.S., NA state
            332        11. Foreign Country: Not in a Census Division (includes U.S.
                           territories)
              4        96. Same State (see questionnaire)
              2        98. DK (don't know); NA (not ascertained)
              2        99. RF (refused)
          17105     Blank. INAP (Inapplicable): [Q456:CS CONTINUE] IS (5); [Q497:CS2b] IS
                           (A) OR [Q542:CS15C2] IS (A) OR [Q518:CS11a] IS (A); [Q517:CS11]
                           IS (1) AND [Q721:CS26] IS (NE 1); [Q744:CS36c] IS (5);
                           [Q463:PRELOAD REINTERVIEW HH] IS (5) AND [Q732:CS33A] IS (95);
                           [Q732:CS33A] IS (95); [Q1029:A26a] IS (1) AND [Q682:PREVIOUS
                           WAVE INTERV] IS (1); [Q1029:A26a] IS (1) AND [Q682:PREVIOUS
                           WAVE INTERV] IS (NE 1); [Q741:CS36] IS (1 OR 3); [Q682:PREVIOUS
                           WAVE INTERV] IS (1); [Q1031:A26c] IS (96) OR [Q1029:A26a] IS
                           (1)
	
F1038     A28.LIVE IN CITY/TOWN/RURAL               
          Section: A            Level: Respondent      CAI Reference: Q1038
          Type: Numeric         Width: 1               Decimals: 0

          A28. Were you living in a rural area most of the time when you were (in
          grade school/in high school/about age 10)?

          User note:  Question wording depended upon amount of schooling.
          ................................................................................
           2388         1. YES
           2697         5. NO
              7         8. DK (don't know); NA (not ascertained)
              1         9. RF (refused)
          16291     Blank. INAP (Inapplicable): [Q456:CS CONTINUE] IS (5); [Q497:CS2b] IS
                           (A) OR [Q542:CS15C2] IS (A) OR [Q518:CS11a] IS (A); [Q517:CS11]
                           IS (1) AND [Q721:CS26] IS (NE 1); [Q744:CS36c] IS (5);
                           [Q1029:A26a] IS (1) AND [Q682:PREVIOUS WAVE INTERV] IS (1);
                           [Q741:CS36] IS (1 OR 3); [Q682:PREVIOUS WAVE INTERV] IS (1)	
			  
			  */

			  
			  
***************************************************************
* Family SES / Family Background Variables: (See Codes Below) 
***************************************************************
gen HealthChild_1998    =F992
gen FamilySES_1998      =F993
gen FamDiff_Move_1998   =F994
gen FamDiff_Help_1998   =F995
gen FamDiff_FUnemp_1998 =F996
gen FatherUsOcc_1998    =F997HM
* Note there are two Father Occupation Variables - F997HM and F997AM.  The 
* F997AM variable uses a coding scheme with fewer categories and is for the 
* AHEAD respondents.  However, all individuals with a non-missing entry for
* F997AM have a non-missing value for F997HM, so we will use that variable, since
* it is more detailed.  
gen FatherEduc_1998=F1000
gen MotherEduc_1998=F1001

/*
F992      A4A. RATE HEALTH AS CHILD                 
          Section: A            Level: Respondent      CAI Reference: Q992
          Type: Numeric         Width: 1               Decimals: 0

          A4a. Consider your health while you were growing up, from birth to age 16.
          Would you say that your health during that time was excellent, very good,
          good, fair, or poor?
          ................................................................................
          10354         1. EXCELLENT
           5520         2. VERY GOOD
           4072         3. GOOD
           1035         4. FAIR
            344         5. POOR
             58         8. DK (don't know); NA (not ascertained)
              1         9. RF (refused)
                    Blank. INAP (Inapplicable): [Q456:CS CONTINUE] IS (5); [Q497:CS2b] IS
                           (A) OR [Q542:CS15C2] IS (A) OR [Q518:CS11a] IS (A)




F993      A4B. RATE FAMILY SES                      
          Section: A            Level: Respondent      CAI Reference: Q993
          Type: Numeric         Width: 1               Decimals: 0

          A4b. Now think about your family when you were growing up, from birth to age
          16.  Would you say your family during that time was pretty well off
          financially, about average, or poor?
          ................................................................................
           1336         1. PRETTY WELL OFF FINANCIALLY
          12863         3. ABOUT AVERAGE
           6891         5. POOR
            219         6. IT VARIED (VOL)
             67         8. DK (don't know); NA (not ascertained)
              8         9. RF (refused)
                    Blank. INAP (Inapplicable): [Q456:CS CONTINUE] IS (5); [Q497:CS2b] IS
                           (A) OR [Q542:CS15C2] IS (A) OR [Q518:CS11a] IS (A)




F994      A4C. FAMILY MOVE                          
          Section: A            Level: Respondent      CAI Reference: Q994
          Type: Numeric         Width: 1               Decimals: 0

          A4c. While you were growing up, before age 16, did financial difficulties
          ever cause you or your family to move to a different place?
          ................................................................................
           3777         1. YES
          17416         5. NO
            188         8. DK (don't know); NA (not ascertained)
              3         9. RF (refused)
                    Blank. INAP (Inapplicable): [Q456:CS CONTINUE] IS (5); [Q497:CS2b] IS
                           (A) OR [Q542:CS15C2] IS (A) OR [Q518:CS11a] IS (A)




F995      A4D. FAMILY HELPED                        
          Section: A            Level: Respondent      CAI Reference: Q995
          Type: Numeric         Width: 1               Decimals: 0

          A4d. Before age 16, was there a time when you or your family received help
          from relatives because of financial difficulties?
          ................................................................................
           2466         1. YES
          18554         5. NO
            359         8. DK (don't know); NA (not ascertained)
              5         9. RF (refused)
                    Blank. INAP (Inapplicable): [Q456:CS CONTINUE] IS (5); [Q497:CS2b] IS
                           (A) OR [Q542:CS15C2] IS (A) OR [Q518:CS11a] IS (A)




F996      A4E. FATHER LOSE JOB                      
          Section: A            Level: Respondent      CAI Reference: Q996
          Type: Numeric         Width: 1               Decimals: 0

          A4e. Before age 16, was there a time of several months or more when your
          father had no job?

              IWER:  IF R MENTIONS NEVER LIVING WITH FATHER WHEN
              GROWING UP, CHOOSE CODE 7

              IF R MENTIONS THAT FATHER NEVER WORKED OR WAS
              ALWAYS DISABLED, CHOOSE CODE 6
          ................................................................................
           4163         1. YES
          14813         5. NO
            129         6. FATHER NEVER WORKED/ALWAYS DISABLED (VOL)
           1948         7. NEVER LIVED WITH FATHER/FATHER WAS NOT ALIVE (VOL)
            328         8. DK (don't know); NA (not ascertained)
              3         9. RF (refused)
                    Blank. INAP (Inapplicable): [Q456:CS CONTINUE] IS (5); [Q497:CS2b] IS
                           (A) OR [Q542:CS15C2] IS (A) OR [Q518:CS11a] IS (A)




F997HM    A4F.FATHER USUAL OCCUPATION - HRS MASKED  
          Section: A            Level: Respondent      CAI Reference: Q10997
          Type: Numeric         Width: 2               Decimals: 0

          A4f. What was your father's occupation when you were age 16?

              IWER, PROBE:  What kind of work did he do?  What activities
              did he do at work?

          Note:  This masked codeframe was the one used in the previous HRS public
          data releases, 1992, 1994 and 1996. This codeframe provided for all samples.
          ................................................................................
           1401         1. Managerial specialty operation (003-037)
           1094         2. Professional specialty operation and technical support (043-
                           235)
           1508         3. Sales (243-285)
            474         4. Clerical, administrative support (303-389)
              8         5. Service: private household, cleaning and building services
                           (403-407)
            268         6. Service: protection (413-427)
            132         7. Service: food preparation (433-444)
             15         8. Health services (445-447)
            373         9. Personal services (448-469)
           4890        10. Farming, forestry, fishing (473-499)
            754        11. Mechanics and repair (503-549)
           1931        12. Construction trade and extractors (553-617)
           1174        13. Precision production (633-699)
           1499        14. Operators: machine (703-799)
           1165        15. Operators: transport, etc. (803-859)
           1223        16. Operators: handlers, etc. (863-889)
            179        17. Member of Armed Forces (900)
            855        98. DK (don't know); NA (not ascertained)
           2441     Blank. INAP (Inapplicable): [Q456:CS CONTINUE] IS (5); [Q497:CS2b] IS
                           (A) OR [Q542:CS15C2] IS (A) OR [Q518:CS11a] IS (A);
                           [Q682:PREVIOUS WAVE INTERV] IS (NE 1) AND [Q996:A4e] IS (7);
                           [Q682:PREVIOUS WAVE INTERV] IS (NE 1) AND [Q996:A4e] IS (6);
                           [Q682:PREVIOUS WAVE INTERV] IS (1) AND [Q996:A4e] IS (6 OR 7)




F997AM    A4F.FATHER USUAL OCCUPATION - AHD MASKED  
          Section: A            Level: Respondent      CAI Reference: Q30997
          Type: Numeric         Width: 2               Decimals: 0

          A4f. What was your father's occupation when you were age 16?

              IWER, PROBE:  What kind of work did he do?  What activities
              did he do at work?

          Note:  This masked codeframe was the one used in the previous AHEAD public
          data releases, 1993 and 1995. This codeframe provided for just the AHEAD
          sample.
          ................................................................................
            285         1. Professional, technical workers (023-024, 026-027, 034-036,038-
                           235)
            315         2. Managers, officials and proprietors (003-019, 025, 028-033,037)
            120         3. Clerical and kindred workers (303-389)
            433         4. Sales workers (243-285)
           1075         5. Craftsmen, foremen and kindred workers (413-414, 416-425, 503-
                           699, 803, 843, 863)
            606         6. Operatives and kindred workers (703-799, 804-834, 844-859)
            442         7. Laborers and farm foremen (477-484, 486-489, 495-499, 864-889)
            159         8. Service workers (403-407, 415, 426-469)
           1609         9. Farmers and farm managers (473-476)
            275        98. DK (don't know); NA (not ascertained)
          16065     Blank. INAP (Inapplicable): [Q456:CS CONTINUE] IS (5); [Q497:CS2b] IS
                           (A) OR [Q542:CS15C2] IS (A) OR [Q518:CS11a] IS (A);
                           [Q682:PREVIOUS WAVE INTERV] IS (NE 1) AND [Q996:A4e] IS (7);
                           [Q682:PREVIOUS WAVE INTERV] IS (NE 1) AND [Q996:A4e] IS (6);
                           [Q682:PREVIOUS WAVE INTERV] IS (1) AND [Q996:A4e] IS (6 OR 7)




F1000     A5.PA EDUC                                
          Section: A            Level: Respondent      CAI Reference: Q1000
          Type: Numeric         Width: 2               Decimals: 0

          A5. What is the highest grade of school your father completed?

                  0     FOR NO FORMAL EDUCATION
                  1-11  GRADES
                  12    HIGH SCHOOL
                  13-15 SOME COLLEGE
                  16    COLLEGE GRAD
                  17    POST COLLEGE (17+ YEARS)
                  97    OTHER
          ................................................................................
            197         0. FOR NO FORMAL EDUCATION
           2047      1-11. GRADES
            953        12. HIGH SCHOOL
            288     13-15. SOME COLLEGE
            198        16. COLLEGE GRAD
            145        17. POST COLLEGE (17+ YEARS)
             19        97. OTHER
            766        98. DK (don't know); NA (not ascertained)
              2        99. RF (refused)
          16769     Blank. INAP (Inapplicable): [Q456:CS CONTINUE] IS (5); [Q497:CS2b] IS
                           (A) OR [Q542:CS15C2] IS (A) OR [Q518:CS11a] IS (A);
                           [Q682:PREVIOUS WAVE INTERV] IS (1); [Q682:PREVIOUS WAVE INTERV]
                           IS (NE 1) AND [Q996:A4e] IS (7)




F1001     A6.MA EDUC                                
          Section: A            Level: Respondent      CAI Reference: Q1001
          Type: Numeric         Width: 2               Decimals: 0

          A6. And what is the highest grade of school your mother completed?

                  0     FOR NO FORMAL EDUCATION
                  1-11  GRADES
                  12    HIGH SCHOOL
                  13-15 SOME COLLEGE
                  16    COLLEGE GRAD
                  17    POST COLLEGE (17+ YEARS)
                  97    OTHER
          ................................................................................
            186         0. FOR NO FORMAL EDUCATION
           2004      1-11. GRADES
           1449        12. HIGH SCHOOL
            377     13-15. SOME COLLEGE
            219        16. COLLEGE GRAD
             63        17. POST COLLEGE (17+ YEARS)
             28        97. OTHER
            765        98. DK (don't know); NA (not ascertained)
              2        99. RF (refused)
          16291     Blank. INAP (Inapplicable): [Q456:CS CONTINUE] IS (5); [Q497:CS2b] IS
                           (A) OR [Q542:CS15C2] IS (A) OR [Q518:CS11a] IS (A);
                           [Q682:PREVIOUS WAVE INTERV] IS (1)
*/
						   
**********************************************
* Religion Variables 
**********************************************
gen Religion_1998=F1052
gen ReligionDenom_1998=F1053M


keep HHID PN *1998

gen YEAR=1998

save "$CleanData/HRSDemo1998.dta", replace


/* Demographic Variables from 2000 - New Format */
clear all
infile using "$HRSSurveys00/h00sta/H00A_R.dct" , using("$HRSSurveys00/h00da/H00A_R.da")


*******************************
* Region Born / Went to School
*******************************
gen RegionBorn_2000    =G1061M
gen RegionSch_2000     =G1122M
gen RuralChildhood_2000=G1125

********************************************
* Family SES / Family Background Variables: 
********************************************
gen HealthChild_2000    =G1079
gen FamilySES_2000      =G1080
gen FamDiff_Move_2000   =G1081
gen FamDiff_Help_2000   =G1082
gen FamDiff_FUnemp_2000 =G1083
gen FatherUsOcc_2000    =G1084M

gen FatherEduc_2000=G1087
gen MotherEduc_2000=G1088

**********************************************
* Religion Variables 
**********************************************

gen Religion_2000=G1139
gen ReligionDenom_2000=G1140M
gen ReligionImport_2000=G1142


keep HHID PN *00

gen YEAR=2000

save "$CleanData/HRSDemo2000.dta", replace


/* Demographic Variables from 2002 - New Format */
clear all
infile using "$HRSSurveys02/h02sta/H02B_R.dct" , using("$HRSSurveys02/h02da/H02B_R.da")


**************************************************
* Region Born / Went to School (See codes below)
**************************************************
gen RegionBorn_2002    =HB003M
gen RegionSch_2002     =HB047M
gen RuralChildhood_2002=HB049

/*
HB003M   STATE BORN - MASKED
         Section: B     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         CAI Reference: BB_Born.B003_                                Ref 2000: G1061M

        In what state were you born?

        STATE:

        User Note: Code categories have been collapsed to protect participant
        confidentiality.
        ..................................................................................
            9           1. Northeast Region: New England Division (ME, NH, VT, MA, RI, CT)
           25           2. Northeast Region: Middle Atlantic Division (NY, NJ, PA)
           32           3. Midwest Region: East North Central Division (OH, IN, IL, MI,
                           WI)
           17           4. Midwest Region: West North Central Division (MN, IA, MO, ND,
                           SD, NE, KS)
           35           5. South Region: South Atlantic Division (DE, MD, DC, VA, WV, NC,
                           SC, GA, FL)
           15           6. South Region: East South Central Division (KY, TN, AL, MS)
           36           7. South Region: West South Central Division (AR, LA, OK, TX)
            5           8. West Region: Mountain Division (MT, ID, WY, CO, NM, AZ, UT, NV)
           22           9. West Region: Pacific Division (WA, OR, CA, AK, HI)
                       10. U.S., NA state
                       11. Foreign Country: Not in a Census Division (includes
                           U.S.territories)
                       96. Same State (see questionnaire)
                       97. OTHER COUNTRY
            1          98. DK (don't know); NA (not ascertained)
                       99. RF (refused)
        17970       Blank. INAP (Inapplicable)
		
HB047M   ST/COUNTRY LIVED DURING SCHOOL - MASKED
         Section: B     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         CAI Reference: BB_LivedArea.B047_                           Ref 2000: G1122M

        In what state or country did you live most of the time you were  in grade
        school/in high school/about age 10)?

        STATE:
        or COUNTRY:

        User Note: Code categories have been collapsed to protect participant
        confidentiality.
        ..................................................................................
           11           1. Northeast Region: New England Division (ME, NH, VT, MA, RI, CT)
           19           2. Northeast Region: Middle Atlantic Division (NY, NJ, PA)
           23           3. Midwest Region: East North Central Division (OH, IN, IL, MI,
                           WI)
           18           4. Midwest Region: West North Central Division (MN, IA, MO, ND,
                           SD, NE, KS)
           35           5. South Region: South Atlantic Division (DE, MD, DC, VA, WV, NC,
                           SC, GA, FL)
            8           6. South Region: East South Central Division (KY, TN, AL, MS)
           27           7. South Region: West South Central Division (AR, LA, OK, TX)
            6           8. West Region: Mountain Division (MT, ID, WY, CO, NM, AZ, UT, NV)
           27           9. West Region: Pacific Division (WA, OR, CA, AK, HI)
           18          11. Foreign Country: Not in a Census Division (includes U.S.
                           territories)
                       97. OTHER COUNTRY (SPECIFY)
            1          98. DK (Don't Know); NA (Not Ascertained)
                       99. RF (Refused)
        17974       Blank. INAP (Inapplicable)	
		
HB049    LIVED RURAL AREA DURING SCHOOL
         Section: B     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: BB_LivedArea.B049_                           Ref 2000: G1125

        Were you living in a rural area most of the time when you were  in grade
        school/in high school/about age 10)?
        ..................................................................................
          117           1. YES
          112           5. NO
            2           8. DK (Don't Know)
                        9. RF (Refused)
        17936       Blank. INAP (Inapplicable)		
		
		*/

********************************************
* Family SES / Family Background Variables: 
********************************************
gen HealthChild_2002    =HB019
gen FamilySES_2002      =HB020
gen FamDiff_Move_2002   =HB021
gen FamDiff_Help_2002   =HB022
gen FamDiff_FUnemp_2002 =HB023
gen FatherUsOcc_2002    =HB024M
*  Parental Education Variables  
gen FatherEduc_2002=HB026
gen MotherEduc_2002=HB027

/*
HB019    RATE HEALTH AS CHILD
         Section: B     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: BB_Health.B019_                              Ref 2000: G1079

        Consider your health while you were growing up, from birth to age 16. Would
        you say that your health during that time was excellent, very good, good,
        fair, or poor?
        ..................................................................................
          231           1. EXCELLENT
          103           2. VERY GOOD
           96           3. GOOD
           25           4. FAIR
            4           5. POOR
            2           8. DK (Don't Know)
                        9. RF (Refused)
        17706       Blank. INAP (Inapplicable)




        Ask:
         IF ((piReIwR <> REIWR) OR (piPWIWYEAR < (piInitA114_PrevWaveYear - 2)))

HB020    RATE FAMILY FINANCIAL SITUATION - SES
         Section: B     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: BB_Health.B020_                              Ref 2000: G1080

        Now think about your family when you were growing up, from birth to age 16.
        Would you say your family during that time was pretty well off financially,
        about average, or poor?
        ..................................................................................
           23           1. PRETTY WELL OFF FINANCIALLY
          267           3. ABOUT AVERAGE
          155           5. POOR
            6           6. IT VARIED (VOL)
            8           8. DK (Don't Know)
            2           9. RF (Refused)
        17706       Blank. INAP (Inapplicable)




        Ask:
         IF ((piReIwR <> REIWR) OR (piPWIWYEAR < (piInitA114_PrevWaveYear - 2)))

HB021    MOVE DUE TO FINANCIAL DIFFICULTY
         Section: B     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: BB_Health.B021_                              Ref 2000: G1081

        While you were growing up, before age 16, did financial difficulties ever
        cause you or your family to move to a different place?
        ..................................................................................
           84           1. YES
          369           5. NO
            6           8. DK (Don't Know)
            2           9. RF (Refused)
        17706       Blank. INAP (Inapplicable)




        Ask:
         IF ((piReIwR <> REIWR) OR (piPWIWYEAR < (piInitA114_PrevWaveYear - 2)))

HB022    FAMILY GET FINANCIAL HELP  IN CHILDHOOD
         Section: B     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: BB_Health.B022_                              Ref 2000: G1082

        Before age 16, was there a time when you or your family received help from
        relatives because of financial difficulties?
        ..................................................................................
           63           1. YES
          377           5. NO
           19           8. DK (Don't Know)
            2           9. RF (Refused)
        17706       Blank. INAP (Inapplicable)




        Ask:
         IF ((piReIwR <> REIWR) OR (piPWIWYEAR < (piInitA114_PrevWaveYear - 2)))

HB023    FATHER UNEMPLOYED DURING CHILDHOOD
         Section: B     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: BB_Health.B023_                              Ref 2000: G1083

        Before age 16, was there a time of several months or more when your father had
        no job?

        IWER: IF R MENTIONS NEVER LIVING WITH FATHER WHEN GROWING UP, CHOOSE CODE 7

        IF R MENTIONS THAT FATHER NEVER WORKED OR WAS ALWAYS DISABLED, CHOOSE CODE 6
        ..................................................................................
           76           1. YES
          319           5. NO
            4           6. FATHER NEVER WORKED/ALWAYS DISABLED (VOL)
           35           7. NEVER LIVED WITH FATHER/FATHER WAS NOT ALIVE (VOL)
           24           8. DK (Don't Know)
            3           9. RF (Refused)
        17706       Blank. INAP (Inapplicable)




        Ask:
         IF ((piReIwR <> REIWR) OR (piPWIWYEAR < (piInitA114_PrevWaveYear - 2)))
         AND ((B023_ <> FANVRWORKALWYSDISABLVOL) AND (B023_ <> NVRLVDWFAFANOTALIVEVOL))

HB024M   FATHER USUAL OCCUPATION - MASKED
         Section: B     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         CAI Reference: BB_Health.B024_                              Ref 2000: G1084M

        What was your father's occupation when you were age 16?

        IWER: PROBE: What kind of work did he do? What activities did he do at work?

        User Note: Code categories have been collapsed to protect participant
        confidentiality.

        User Note:  Respondents who indicated that their father was deceased during
        the time period were coded as 'Blank. INAP (Inapplicable).
        ..................................................................................
           21           1. Managerial specialty operation (003-037)
           18           2. Professional specialty operation and technical support (043-
                           235)
           17           3. Sales (243-285)
           12           4. Clerical, administrative support (303-389)
                        5. Service: private household, cleaning and building services
                           (403-407)
            3           6. Service: protection (413-427)
            8           7. Service: food preparation (433-444)
            1           8. Health services (445-447)
            9           9. Personal services (448-469)
           82          10. Farming, forestry, fishing (473-499)
           23          11. Mechanics and repair (503-549)
           41          12. Construction trade and extractors (553-617)
           20          13. Precision production (633-699)
           39          14. Operators: machine (703-799)
           36          15. Operators: transport, etc
           31          16. Operators: handlers, etc
            6          17. Member of Armed Forces (900)
            3          98. DK (don't know); NA (not ascertained)
           44          99. RF (Refused)
        17753       Blank. INAP (Inapplicable)

HB026    FATHER EDUCATION- HIGHEST GRADE
         Section: B     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         CAI Reference: BB_OtherBackground.B026_                     Ref 2000: G1087

        What is the highest grade of school your father completed?

        0 FOR NO FORMAL EDUCATION
        1-11 GRADES
        12 HIGH SCHOOL
        13-15 SOME COLLEGE
        16 COLLEGE GRAD
        17 POST COLLEGE (17+ YEARS)
        97 OTHER
        ..................................................................................

         -----------------------------------------------------------------
              N      Min         Max          Mean            SD    Miss
            299        0          20          8.78          4.38   17741
         -----------------------------------------------------------------
            2          97. OTHER
          118          98. DK (Don't Know)
            7          99. RF (Refused)




        Ask:
         IF (NOT ((piReIwR = REIWR) AND (PWIWYEAR >= (piInitA114_PrevWaveYear - 2))))

HB027    MOTHER EDUCATION- HIGHEST GRADE
         Section: B     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         CAI Reference: BB_OtherBackground.B027_                     Ref 2000: G1088

        And what is the highest grade of school your mother completed?

        0 FOR NO FORMAL EDUCATION
        1-11 GRADES
        12 HIGH SCHOOL
        13-15 SOME COLLEGE
        16 COLLEGE GRAD
        17 POST COLLEGE (17+ YEARS)
        97 OTHER
        ..................................................................................

         -----------------------------------------------------------------
              N      Min         Max          Mean            SD    Miss
            330        0          17          8.85          4.15   17706
         -----------------------------------------------------------------
            2          97. OTHER
          122          98. DK (Don't Know)
            7          99. RF (Refused)		
		
*/

**********************************************
* Religion Variables 
**********************************************

gen Religion_2002=HB050
gen ReligionDenom_2002=HB052M

/*
HB050    R RELIGIOUS PREFERENCE
         Section: B     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         CAI Reference: BB_LivedArea.B050_                           Ref 2000: G1139

        What is your religious preference: Is it Protestant, Catholic, Jewish, some
        other religion, or do you have no preference?
        ..................................................................................
          140           1. PROTESTANT
           51           2. CATHOLIC
            5           3. JEWISH
           27           4. NO PREFERENCE
            4           7. OTHER (SPECIFY)
            1           8. DK (Don't Know); NA (Not Ascertained)
            3           9. RF (Refused)
        17936       Blank. INAP (Inapplicable)




        Ask:
         IF (piReIwR <> REIWR)
         AND (B050_ = PROTESTANT)

HB052M   DENOMINATION - MASKED
         Section: B     Level: Respondent      Type: Numeric    Width: 2   Decimals: 0
         CAI Reference: BB_LivedArea.B052_                           Ref 2000: G1140M

        What denomination is that?

        User Note: Code categories have been collapsed to protect participant
        confidentiality.
        ..................................................................................
           31           1. PROTESTANT: REFORMATION ERA (Congregational; Episcopalian,
                           Anglican, Church of England; Evangelical and Reformed;
                           Lutheran; Presbyterian; Reformed, Dutch Reformed or Christian
                           Reformed; United Church of Christ)
           68          11. PROTESTANT: PIETISTIC (African Methodist Episcopal; AME Zion;
                           Baptist--NA type; Disciples of Christ; Methodist; United
                           Brethren or Evangelical Brethren; Mennonite, Amish; Church of
                           the Brethren; 'Christian'
           23          21. PROTESTANT: FUNDAMENTALIST (Church of Christ; Church of God,
                           'Holiness', Church of Living; God, Church of God in Prophecy;
                           Church of God in Christ; Fundamentalist Baptist: include
                           Primitive Baptist, Free Will Baptist, Missionary Baptist,
                           Gospel Baptist; Nazarene or Free Methodist; Pentecostal or
                           Assembly of God; Plymouth Brethren; Salvation Army;
                           Sanctified; Seventh Day Adventist; Southern Baptist; United
                           Missionary or Protestant Missionary; Christian and Missionary
                           Alliance; Missouri Synod Lutheran; Other Fundamentalist;
                           'Apostolic'--NFS; 'Charismatic' --NFS; Bible Church, Word of
                           Faith, Foursquare
            5          41. PROTESTANT: GENERAL (Protestant, no denomination given; Non-
                           denominational Protestant church; Community church--no
                           denominational basis; 'Born again Christian'--NFS;
                           'Evangelical'--NFS; Other Protestant--not listed above;
                           Berean,AZUA, United Church of Canada
                       51. CATHOLIC; EASTERN ORTHODOX (ROMAN CATHOLIC; 'Catholic'--NFS;
                           Greek Rite Catholic; Orthodox; Eastern Orthodox;
                           Greek/Russian; Orthodox; other Orthodox
            8          61. NON-TRADITIONAL CHRISTIAN (Christian Scientist; Jehovah's
                           Witnesses Latter Day Saints, Mormons Quakers; Spiritualists;
                           Unitarian or Universalist; Unity; Other non-traditional
                           Christian
                       71. JEWISH
            2          81. NON-JUDEO-CHRISTIAN (Nation of Islam; Islam; Muslim; Moslem;
                           Mohammedan; World Community of Islam in the West; Buddhist;
                           Hindu; Bahai; Other non-Judeo-Christian religion)
                       91. NO RELIGION; NONE; NO PREFERENCE; Atheist; agnostic; OTHER
                           (include Mason, New Age, RC and Jewish, RC in summer/Lutheran
                           in winter, Mile-High Church of Rel. Science, Science of Mind,
                           Yeshuan)
            1          98. DK (Don't Know)
                       99. RF (Refused)
        18029       Blank. INAP (Inapplicable) */


keep HHID PN *2002

gen YEAR=2002

save "$CleanData/HRSDemo2002.dta", replace




/* Demographic Variables from 2004 - New Format */
clear all
infile using "$HRSSurveys04/h04sta/H04B_R.dct" , using("$HRSSurveys04/h04da/H04B_R.da")


*************************************************************
* Region Born / Went to School (Coding same as 2002 format)
*************************************************************
gen RegionBorn_2004    =JB003M
gen RegionSch_2004     =JB047M
gen RuralChildhood_2004=JB049

**************************************************************************
* Family SES / Family Background Variables: (Coding same as 2002 format)
**************************************************************************
gen HealthChild_2004    =JB019
gen FamilySES_2004      =JB020
gen FamDiff_Move_2004   =JB021
gen FamDiff_Help_2004   =JB022
gen FamDiff_FUnemp_2004 =JB023
gen FatherUsOcc_2004    =JB024M
*  Parental Education Variables  
gen FatherEduc_2004=JB026
gen MotherEduc_2004=JB027

****************************************************
* Religion Variables (Coding same as 2002 format)
****************************************************
gen Religion_2004=JB050
gen ReligionDenom_2004=JB052M


keep HHID PN *2004

gen YEAR=2004

save "$CleanData/HRSDemo2004.dta", replace



/* Demographic Variables from 2006 - New Format */
clear all
infile using "$HRSSurveys06/h06sta/H06B_R.dct" , using("$HRSSurveys06/h06da/H06B_R.da")


*******************************
* Region Born / Went to School
*******************************
gen RegionBorn_2006    =KB003M
gen RegionSch_2006     =KB047M
gen RuralChildhood_2006=KB049

********************************************
* Family SES / Family Background Variables: 
********************************************
gen HealthChild_2006    =KB019
gen FamilySES_2006      =KB020
gen FamDiff_Move_2006   =KB021
gen FamDiff_Help_2006   =KB022
gen FamDiff_FUnemp_2006 =KB023
gen FatherUsOcc_2006    =KB024M
*  Parental Education Variables  
gen FatherEduc_2006=KB026
gen MotherEduc_2006=KB027

**********************************************
* Religion Variables 
**********************************************

gen Religion_2006=KB050
gen ReligionDenom_2006=KB052M

keep HHID PN *2006

gen YEAR=2006

save "$CleanData/HRSDemo2006.dta", replace



/* Demographic Variables from 2008 - New Format */
clear all
infile using "$HRSSurveys08/h08sta/H08B_R.dct" , using("$HRSSurveys08/h08da/H08B_R.da")


*******************************
* Region Born / Went to School
*******************************
gen RegionBorn_2008    =LB003M
gen RegionSch_2008     =LB047M
gen RuralChildhood_2008=LB049

********************************************
* Family SES / Family Background Variables: 
********************************************
gen HealthChild_2008    =LB019
gen FamilySES_2008      =LB020
gen FamDiff_Move_2008   =LB021
gen FamDiff_Help_2008   =LB022
gen FamDiff_FUnemp_2008 =LB023
gen FatherUsOcc_2008    =LB024M
*  Parental Education Variables  
gen FatherEduc_2008=LB026
gen MotherEduc_2008=LB027

**********************************************
* Religion Variables 
**********************************************

gen Religion_2008=LB050
gen ReligionDenom_2008=LB052M


/* Now, look at more detailed Childhood health variables 
   Note LB121 is a question indicating more nuance for item
   LB120 */

gen CH_MissSchool_2008=LB099
gen CH_Measles_2008   =LB100
gen CH_Mumps_2008     =LB101
gen CH_CPox_2008      =LB102
gen CH_Sight_2008     =LB103
gen CH_ParSmoke_2008  =LB104
gen CH_Asthma_2008    =LB105
gen CH_Diabetes_2008  =LB106
gen CH_Resp_2008      =LB107
gen CH_Speech_2008    =LB108
gen CH_Allergy_2008   =LB109
gen CH_Heart_2008     =LB110
gen CH_Ear_2008       =LB111
gen CH_Epilepsy_2008  =LB112
gen CH_Migraines_2008 =LB113
gen CH_Stomach_2008   =LB114
gen CH_BloodP_2008    =LB115
gen CH_Depression_2008=LB116
gen CH_Drugs_2008     =LB117
gen CH_Psych_2008     =LB118
gen CH_Concuss_2008   =LB119
gen CH_Disable_2008   =LB120
gen CH_Smoke_2008     =LB122
gen CH_Learn_2008     =LB123
gen CH_Other_2008     =LB124


keep HHID PN *2008

gen YEAR=2008

save "$CleanData/HRSDemo2008.dta", replace


/* Demographic Variables from 2010 - New Format */
clear all
infile using "$HRSSurveys10/h10sta/H10B_R.dct" , using("$HRSSurveys10/h10da/H10B_R.da")


*******************************
* Region Born / Went to School
*******************************
gen RegionBorn_2010    =MB003M
gen RegionSch_2010     =MB047M
gen RuralChildhood_2010=MB049

********************************************
* Family SES / Family Background Variables: 
********************************************
gen HealthChild_2010    =MB019
gen FamilySES_2010      =MB020
gen FamDiff_Move_2010   =MB021
gen FamDiff_Help_2010   =MB022
gen FamDiff_FUnemp_2010 =MB023
gen FatherUsOcc_2010    =MB024M
*  Parental Education Variables  
gen FatherEduc_2010=MB026
gen MotherEduc_2010=MB027

**********************************************
* Religion Variables 
**********************************************

gen Religion_2010=MB050
gen ReligionDenom_2010=MB052M



/* Now, look at more detailed Childhood health variables */

gen CH_MissSchool_2010=MB099
gen CH_Measles_2010   =MB100
gen CH_Mumps_2010     =MB101
gen CH_CPox_2010      =MB102
gen CH_Sight_2010     =MB103
gen CH_ParSmoke_2010  =MB104
gen CH_Asthma_2010    =MB105
gen CH_Diabetes_2010  =MB106
gen CH_Resp_2010      =MB107
gen CH_Speech_2010    =MB108
gen CH_Allergy_2010   =MB109
gen CH_Heart_2010     =MB110
gen CH_Ear_2010       =MB111
gen CH_Epilepsy_2010  =MB112
gen CH_Migraines_2010 =MB113
gen CH_Stomach_2010   =MB114
gen CH_BloodP_2010    =MB115
gen CH_Depression_2010=MB116
gen CH_Drugs_2010     =MB117
gen CH_Psych_2010     =MB118
gen CH_Concuss_2010   =MB119
gen CH_Disable_2010   =MB120
gen CH_Smoke_2010     =MB122
gen CH_Learn_2010     =MB123
gen CH_Other_2010     =MB124


keep HHID PN *2010

gen YEAR=2010

save "$CleanData/HRSDemo2010.dta", replace


/* Demographic Variables from 2012 - New Format */
clear all
infile using "$HRSSurveys12/h12sta/H12B_R.dct" , using("$HRSSurveys12/h12da/H12B_R.da")


*******************************
* Region Born / Went to School
*******************************
gen RegionBorn_2012    =NB003M
gen RegionSch_2012     =NB047M
gen RuralChildhood_2012=NB049

********************************************
* Family SES / Family Background Variables: 
********************************************
gen HealthChild_2012    =NB019
gen FamilySES_2012      =NB020
gen FamDiff_Move_2012   =NB021
gen FamDiff_Help_2012   =NB022
gen FamDiff_FUnemp_2012 =NB023
gen FatherUsOcc_2012    =NB024M
*  Parental Education Variables  
gen FatherEduc_2012=NB026
gen MotherEduc_2012=NB027

**********************************************
* Religion Variables 
**********************************************
gen Religion_2012=NB050
gen ReligionDenom_2012=NB052M


/* Now, look at more detailed Childhood health variables */

gen CH_MissSchool_2012=NB099
gen CH_Measles_2012   =NB100
gen CH_Mumps_2012     =NB101
gen CH_CPox_2012      =NB102
gen CH_Sight_2012     =NB103
gen CH_ParSmoke_2012  =NB104
gen CH_Asthma_2012    =NB105
gen CH_Diabetes_2012  =NB106
gen CH_Resp_2012      =NB107
gen CH_Speech_2012    =NB108
gen CH_Allergy_2012   =NB109
gen CH_Heart_2012     =NB110
gen CH_Ear_2012       =NB111
gen CH_Epilepsy_2012  =NB112
gen CH_Migraines_2012 =NB113
gen CH_Stomach_2012   =NB114
gen CH_BloodP_2012    =NB115
gen CH_Depression_2012=NB116
gen CH_Drugs_2012     =NB117
gen CH_Psych_2012     =NB118
gen CH_Concuss_2012   =NB119
gen CH_Disable_2012   =NB120
gen CH_Smoke_2012     =NB122
gen CH_Learn_2012     =NB123
gen CH_Other_2012     =NB124


keep HHID PN *_2012

gen YEAR=2012

save "$CleanData/HRSDemo2012.dta", replace




/* Demographic Variables from 2014 - New Format */
clear all
infile using "$HRSSurveys14/h14sta/H14B_R.dct" , using("$HRSSurveys14/h14da/H14B_R.da")

*******************************
* Region Born / Went to School
*******************************
gen RegionBorn_2014    =OB003M
gen RegionSch_2014     =OB047M
gen RuralChildhood_2014=OB049

********************************************
* Family SES / Family Background Variables: 
********************************************
gen HealthChild_2014    =OB019
gen FamilySES_2014      =OB020
gen FamDiff_Move_2014   =OB021
gen FamDiff_Help_2014   =OB022
gen FamDiff_FUnemp_2014 =OB023
gen FatherUsOcc_2014    =OB024M
*  Parental Education Variables  
gen FatherEduc_2014=OB026
gen MotherEduc_2014=OB027

**********************************************
* Religion Variables 
**********************************************
gen Religion_2014=OB050
gen ReligionDenom_2014=OB052M


/* Now, look at more detailed Childhood health variables */

gen CH_MissSchool_2014=OB099
gen CH_Measles_2014   =OB100
gen CH_Mumps_2014     =OB101
gen CH_CPox_2014      =OB102
gen CH_Sight_2014     =OB103
gen CH_ParSmoke_2014  =OB104
gen CH_Asthma_2014    =OB105
gen CH_Diabetes_2014  =OB106
gen CH_Resp_2014      =OB107
gen CH_Speech_2014    =OB108
gen CH_Allergy_2014   =OB109
gen CH_Heart_2014     =OB110
gen CH_Ear_2014       =OB111
gen CH_Epilepsy_2014  =OB112
gen CH_Migraines_2014 =OB113
gen CH_Stomach_2014   =OB114
gen CH_BloodP_2014    =OB115
gen CH_Depression_2014=OB116
gen CH_Drugs_2014     =OB117
gen CH_Psych_2014     =OB118
gen CH_Concuss_2014   =OB119
gen CH_Disable_2014   =OB120
gen CH_Smoke_2014     =OB122
gen CH_Learn_2014     =OB123
gen CH_Other_2014     =OB124


keep HHID PN *2014

gen YEAR=2014

save "$CleanData/HRSDemo2014.dta", replace





/* Demographic Variables from 2016 - New Format */
clear all
infile using "$HRSSurveys16/h16sta/H16B_R.dct" , using("$HRSSurveys16/h16da/H16B_R.da")


*******************************
* Region Born / Went to School
*******************************
gen RegionBorn_2016    =PB003M
gen RegionSch_2016     =PB047M
gen RuralChildhood_2016=PB049

********************************************
* Family SES / Family Background Variables: 
********************************************
gen HealthChild_2016    =PB019
gen FamilySES_2016      =PB020
gen FamDiff_Move_2016   =PB021
gen FamDiff_Help_2016   =PB022
gen FamDiff_FUnemp_2016 =PB023
gen FatherUsOcc_2016    =PB024M
*  Parental Education Variables  
gen FatherEduc_2016=PB026
gen MotherEduc_2016=PB027

**********************************************
* Religion Variables 
**********************************************

gen Religion_2016=PB050
gen ReligionDenom_2016=PB052M


/* Now, look at more detailed Childhood health variables */

gen CH_MissSchool_2016=PB099
gen CH_Measles_2016   =PB100
gen CH_Mumps_2016     =PB101
gen CH_CPox_2016      =PB102
gen CH_Sight_2016     =PB103
gen CH_ParSmoke_2016  =PB104
gen CH_Asthma_2016    =PB105
gen CH_Diabetes_2016  =PB106
gen CH_Resp_2016      =PB107
gen CH_Speech_2016    =PB108
gen CH_Allergy_2016   =PB109
gen CH_Heart_2016     =PB110
gen CH_Ear_2016       =PB111
gen CH_Epilepsy_2016  =PB112
gen CH_Migraines_2016 =PB113
gen CH_Stomach_2016   =PB114
gen CH_BloodP_2016    =PB115
gen CH_Depression_2016=PB116
gen CH_Drugs_2016     =PB117
gen CH_Psych_2016     =PB118
gen CH_Concuss_2016   =PB119
gen CH_Disable_2016   =PB120
gen CH_Smoke_2016     =PB122
gen CH_Learn_2016     =PB123
gen CH_Other_2016     =PB124


keep HHID PN *2016

gen YEAR=2016

save "$CleanData/HRSDemo2016.dta", replace


/*  Load the Cross-Wave Region File and get indicators for Region of residence 
     in each wave and an indicator for urban / suburban / ex-urban residence */
clear all

infile using "$CrossWaveLocDir\stata\HRSXREGION14.dct", using("$CrossWaveLocDir\data\HRSXREGION14.da")

* REGIONB - Region / Division in which indiviudals were born
* REGLIV10 - Region / Division in which individuals lived when in school (grade school / high school / about age 10)
* REGION*  - Region / Division in which individuals lived in year ***
* BEALE(BYR)_(HRSYR)  - Classification of location of residence as urban / suburban / ex-urban in HRSYR based on 
*                        BEALE scale from reference year BYR

keep HHID PN REGLIV10 REGION*

save "$CleanData/HRSCrossWaveRegion.dta", replace

***********************************************************************************
* Clean variables from the Internet Surveys with Childhood Health Info (2006, 2007)
* Start with 2006 Internet Survey
************************************************************************************
clear all
infile using "$HRSInternet06\net06_r.dct", using("$HRSInternet06\net06_r.da")

gen HealthChild_2006int=I2_CHDHLTH 

/*
I2_CHDDIS1          CHILDHOOD DISEASES 1 - 1 HQ004
         Section: I     Level: RESPONDENT      Type: Numeric    Width: 1   Decimals: 0

         Before you were 17 years old did you suffer from any of the following childhood
         diseases? (Please check all that apply.)

         .................................................................................
          1151           1.  MEASLES
            69           2.  MUMPS
            87           3.  CHICKEN POX
                         8.  DK (Don't Know) */
* Initialize MEASLES / MUMPS / C. POX items to 5 (indicates no).
gen Temp1=5
gen Temp2=5
gen Temp3=5
* Loop over the three survey items for this group and set Temp var to 1 if
* individaul indicates having this condition:
forvalues ItemInd=1(1)3{
	forvalues DInd=1(1)3{
		replace Temp`DInd'=1 if I2_CHDDIS`ItemInd'==`DInd'
	}
}
* Rename variables
rename Temp1 CH_Measles_2006int
rename Temp2 CH_Mumps_2006int
rename Temp3 CH_CPox_2006int

* Parental Smoking:
* Coding in the internet survey:
        /* Did your parents/guardians smoke during your childhood?

         .................................................................................
           995           1.  YES, ONE OR MORE
           351           2.  NO, NONE OF THEM
             1           8.  DK (Don't Know)
             5           9.  Question Skipped */

* Coding in the reset of the waves (which we will adopt):
/*
          5661           1.  YES, ONE OF THEM
          2112           2.  YES, BOTH
          4451           5.  NO, NONE OF THEM
            49           8.  DK (Don't Know); NA (Not Ascertained)
             1           9.  RF (Refused) */

gen CH_ParSmoke_2006int=I2_PARSMOKE

	replace CH_ParSmoke=5 if CH_ParSmoke==2
	replace CH_ParSmoke=3 if CH_ParSmoke==1

/* 
I2_CHDDISA1         CHILDHOOD DISEASES 2 - 1 HQ006
         Section: I     Level: RESPONDENT      Type: Numeric    Width: 2   Decimals: 0

         Before you were 17 years old did you suffer from any of the following childhood
         diseases? (Please check all that apply.)

         .................................................................................
            60           1.  ASTHMA
             2           2.  DIABETES
           148           3.  RESPIRATORY DISORDER SUCH AS BRONCHITIS, WHEEZING, HAY
                             FEVER, SHORTNESS OF BREATH, OR SINUS INFECTION
            19           4.  SPEECH IMPAIRMENT
            78           5.  ALLERGIC CONDITION(S)
            23           6.  HEART TROUBLE
            88           7.  CHRONIC EAR PROBLEMS OR INFECTIONS
                        98.  DK (Don't Know)
           934          99.  Question Skipped or No Disease Reported */	

* Initialize Asthma, Diabetes, Respiratory, Speech, Allergy, Heart, Ear Items:
* Set the initial values to 5 indicating "NO"
forvalues IND=1(1)7 {
	gen Temp`IND'=5
}	
* Loop over the three survey items for this group and set Temp var to 1 if
* individaul indicates having this condition:
forvalues ItemInd=1(1)5{
	forvalues DInd=1(1)7{
		replace Temp`DInd'=1 if I2_CHDDISA`ItemInd'==`DInd'
	}
}	

rename Temp1 CH_Asthma_2006int
rename Temp2 CH_Diabetes_2006int
rename Temp3 CH_Resp_2006int
rename Temp4 CH_Speech_2006int
rename Temp5 CH_Allergy_2006int
rename Temp6 CH_Heart_2006int
rename Temp7 CH_Ear_2006int

/*
I2_CHDDISB1         CHILDHOOD DISEASES 3 - 1 HQ006B
         Section: I     Level: RESPONDENT      Type: Numeric    Width: 2   Decimals: 0

         Before you were 17 years old did you suffer from any of the following childhood
         diseases? (Please check all that apply.)

         .................................................................................
             8           8.  EPILEPSY/SEIZURES
            82           9.  SEVERE HEADACHES OR MIGRAINES
            55          10.  STOMACH PROBLEM
             6          11.  HIGH BLOOD PRESSURE
            25          12.  DIFFICULTY SEEING EVEN WITH EYE GLASSES
            17          13.  DEPRESSION
             1          14.  DRUG OR ALCOHOL PROBLEMS
                        98.  DK (Don't Know)
          1158          99.  Question Skipped or No Disease Reported */
		  
* Initialize Epilepsy, Migraine, Stomach, Blood P, Sigh, Depression, Drug/Alch Questions
* Set the initial values to 5 indicating "NO"
forvalues IND=8(1)14 {
	gen Temp`IND'=5
}	
* Loop over the three survey items for this group and set Temp var to 1 if
* individaul indicates having this condition:
forvalues ItemInd=1(1)7{
	forvalues DInd=8(1)14{
		replace Temp`DInd'=1 if i2_chddisb`ItemInd'==`DInd'
	}
}	



rename Temp8  CH_Epilepsy_2006int
rename Temp9  CH_Migraines_2006int
rename Temp10 CH_Stomach_2006int
rename Temp11 CH_BloodP_2006int
rename Temp12 CH_Sight_2006int
rename Temp13 CH_Depression_2006int
rename Temp14 CH_Drugs_2006int

keep HHID PN *2006int

save "$CleanData/HRSDemo2006int.dta", replace


****************************************************
* 2007 Internet Survey (has childhood health info):
****************************************************

clear all
infile using "$HRSInternet07\net07_r.dct", using("$HRSInternet07\net07_r.da")

gen HealthChild_2007int=I3_CHDHLTH 

/*
I3_CHDDIS1          CHILDHOOD DISEASES 1 - 1 - HQ004
         Section: I     Level: RESPONDENT      Type: Numeric    Width: 1   Decimals: 0
         Ref: Mod_3.HQ004[1]

         Before you were 17 years old did you suffer from any of the following childhood
         diseases? (Please check all that apply.)

         .................................................................................
          2287           1.  MEASLES
           102           2.  MUMPS
           162           3.  CHICKEN POX
                         8.  DK (Don't Know)
           114       Blank.  INAP (Inapplicable) or Data Missing*/
* Initialize MEASLES / MUMPS / C. POX items to 5 (indicates no).
gen Temp1=5
gen Temp2=5
gen Temp3=5
* Loop over the three survey items for this group and set Temp var to 1 if
* individaul indicates having this condition:
forvalues ItemInd=1(1)3{
	forvalues DInd=1(1)3{
		replace Temp`DInd'=1 if I3_CHDDIS`ItemInd'==`DInd'
	}
}
* Rename variables
rename Temp1 CH_Measles_2007int
rename Temp2 CH_Mumps_2007int
rename Temp3 CH_CPox_2007int

* Parental Smoking:
* Coding in the internet survey:
/* I3_PARSMOKE         PARENTS SMOKE DURING CHILDHOOD - HQ010
         Section: I     Level: RESPONDENT      Type: Numeric    Width: 1   Decimals: 0
         Ref: Mod_3.HQ010

         Did your parents/guardians smoke during your childhood?

         .................................................................................
          1909           1.  YES, ONE OR MORE
           756           2.  NO, NONE OF THEM
                         8.  DK (Don't Know) */

* Coding in the reset of the waves (which we will adopt):
/*
          5661           1.  YES, ONE OF THEM
          2112           2.  YES, BOTH
          4451           5.  NO, NONE OF THEM
            49           8.  DK (Don't Know); NA (Not Ascertained)
             1           9.  RF (Refused) */

gen CH_ParSmoke_2007int=I3_PARSMOKE

	replace CH_ParSmoke=5 if CH_ParSmoke==2
	replace CH_ParSmoke=3 if CH_ParSmoke==1

/* 
I3_CHDDISA1         CHILDHOOD DISEASES 2 - 1 HQ006
         Section: I     Level: RESPONDENT      Type: Numeric    Width: 1   Decimals: 0
         Ref: Mod_3.HQ006[1]

         Before you were 17 years old did you suffer from any of the following childhood
         diseases? (Please check all that apply.)

         .................................................................................
            96           1.  ASTHMA
             3           2.  DIABETES
           292           3.  RESPIRATORY DISORDER SUCH AS BRONCHITIS, WHEEZING, HAY
                             FEVER, SHORTNESS OF BREATH, OR SINUS INFECTION
            45           4.  SPEECH IMPAIRMENT
           153           5.  ALLERGIC CONDITION(S)
            26           6.  HEART TROUBLE
           177           7.  CHRONIC EAR PROBLEMS OR INFECTIONS
                         8.  DK (Don't Know)
          1873       Blank.  INAP (Inapplicable) or Data Missing
*/	

* Initialize Asthma, Diabetes, Respiratory, Speech, Allergy, Heart, Ear Items:
* Set the initial values to 5 indicating "NO"
forvalues IND=1(1)7 {
	gen Temp`IND'=5
}	
* Loop over the three survey items for this group and set Temp var to 1 if
* individaul indicates having this condition:
forvalues ItemInd=1(1)6{
	forvalues DInd=1(1)7{
		replace Temp`DInd'=1 if I3_CHDDISA`ItemInd'==`DInd'
	}
}	

rename Temp1 CH_Asthma_2007int
rename Temp2 CH_Diabetes_2007int
rename Temp3 CH_Resp_2007int
rename Temp4 CH_Speech_2007int
rename Temp5 CH_Allergy_2007int
rename Temp6 CH_Heart_2007int
rename Temp7 CH_Ear_2007int

/*
I3_CHDDISB1         CHILDHOOD DISEASES 3 - 1 - HQ006B
         Section: I     Level: RESPONDENT      Type: Numeric    Width: 2   Decimals: 0
         Ref: Mod_3.HQ006b[1]

         Before you were 17 years old did you suffer from any of the following childhood
         diseases? (Please check all that apply.)

         .................................................................................
            12           8.  EPILEPSY/SEIZURES
           157           9.  SEVERE HEADACHES OR MIGRAINES
           106          10.  STOMACH PROBLEM
             7          11.  HIGH BLOOD PRESSURE
            51          12.  DIFFICULTY SEEING EVEN WITH EYE GLASSES
            34          13.  DEPRESSION
            12          14.  DRUG OR ALCOHOL PROBLEMS
                        98.  DK (Don't Know)
          2286       Blank.  INAP (Inapplicable) or Data Missing */
		  
* Initialize Epilepsy, Migraine, Stomach, Blood P, Sigh, Depression, Drug/Alch Questions
* Set the initial values to 5 indicating "NO"
forvalues IND=8(1)14 {
	gen Temp`IND'=5
}	
* Loop over the three survey items for this group and set Temp var to 1 if
* individaul indicates having this condition:
forvalues ItemInd=1(1)5{
	forvalues DInd=8(1)14{
		replace Temp`DInd'=1 if I3_chddisb`ItemInd'==`DInd'
	}
}	

rename Temp8  CH_Epilepsy_2007int
rename Temp9  CH_Migraines_2007int
rename Temp10 CH_Stomach_2007int
rename Temp11 CH_BloodP_2007int
rename Temp12 CH_Sight_2007int
rename Temp13 CH_Depression_2007int
rename Temp14 CH_Drugs_2007int

keep HHID PN *2007int

save "$CleanData/HRSDemo2007int.dta", replace



* Clean variables from the 2015 and 2017 Life History Mail Surveys:
clear all

infile using "$LifeHistory\LHMS15_R.dct", using("$LifeHistory\LHMS15_R.da")
	
gen BooksAt10_15=LH17_15
gen PreSchool_15=LH19_15
gen NumInHouse_15=LH7_15
gen NumBedrooms_15=LH8_15

keep HHID PN BooksAt10 PreSchool NumInHouse NumBedrooms

save "$CleanData/EA_LifeHistory15Vars.dta", replace
	

clear all

infile using "$LifeHistory\LHMS17SPR_R.dct", using("$LifeHistory\LHMS17SPR_R.da")	
		
gen BooksAt10_17=LH11_17
gen PreSchool_17=LH23_17
gen NumInHouse_17=LH7_17
gen NumBedrooms_17=LH8_17

keep HHID PN BooksAt10 PreSchool NumInHouse NumBedrooms

* Note  there are no overlapping observations between the 2015 and 2017 Life 
* History Surveys, so here we append  "$CleanData/EA_LifeHistory15Vars.dta" to
* get a combined LifeHistory file:

append using "$CleanData/EA_LifeHistory15Vars.dta"

	
gen PreSchool=PreSchool_15
replace PreSchool=PreSchool_17 if PreSchool==. & PreSchool_17~=.	
replace PreSchool=0 if PreSchool==5	
	
gen BooksAt10=BooksAt10_15
replace BooksAt10=BooksAt10_17 if BooksAt10==. & BooksAt10_17~=.
	
gen HighBooks=(BooksAt10>=3)
replace HighBooks=. if BooksAt10==.

gen NumInHouse=NumInHouse_15
replace NumInHouse=NumInHouse_17 if NumInHouse==. & NumInHouse_17~=.
replace NumInHouse=. if NumInHouse==99
gen HighNumInHouse=(NumInHouse>5)
replace HighNumInHouse=. if NumInHouse==.

save "$CleanData/EA_LifeHistoryCombined.dta", replace



/**************************************
***************************************
  Here we merge the Demographic Files
***************************************
***************************************/
clear all
use "$CleanData/HRSDemo1992.dta"

foreach yr in 1993 1994 1995 1996 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 {
	merge 1:1 HHID PN using "$CleanData/HRSDemo`yr'.dta", gen (Merge`yr')
}

* Merge with the Cross-Wave Region File:
merge 1:1 HHID PN using "$CleanData/HRSCrossWaveRegion.dta", gen(MergeCrossWaveLoc)

* Merge with the Life History Items:
merge 1:1 HHID PN using "$CleanData/EA_LifeHistoryCombined.dta", gen(LHMerge)

* Merge with Internet Survey Items:
merge 1:1 HHID PN using "$CleanData/HRSDemo2006int.dta", gen (MergeInt2006)
merge 1:1 HHID PN using "$CleanData/HRSDemo2007int.dta", gen (MergeInt2007)

* ReligionDenom_2016 has all values set to 95 "Data Not Available".  Here we
* replace those values to . so that the code below does not treat 95 as an
* informative value:
replace ReligionDenom_2016=.

* Initialize Variables:
gen RegionBorn=.
gen RegionSch=.
gen FatherEduc=.
gen MotherEduc=.
gen FamilySES=.
gen FamDiff_Move=.
gen FamDiff_Help=.
gen FamDiff_FUnemp=. 
gen HealthChild=.
gen RuralChildhood=.
gen Religion=.
gen ReligionDenom=.
gen FatherUsOcc=.

gen CH_MissSchool=.
gen CH_Measles=.
gen CH_Mumps=.
gen CH_CPox=.
gen CH_Sight=.
gen CH_ParSmoke=.
gen CH_Asthma=.
gen CH_Diabetes=.
gen CH_Resp=.
gen CH_Speech=.
gen CH_Allergy=.
gen CH_Heart=.
gen CH_Ear=.
gen CH_Epilepsy=.
gen CH_Migraines=.
gen CH_Stomach=.
gen CH_BloodP=.
gen CH_Depression=.
gen CH_Drugs=.
gen CH_Psych=.
gen CH_Concuss=.
gen CH_Disable=.
gen CH_Smoke=.
gen CH_Learn=.
gen CH_Other=.

*********************************************************
* Parental Education, Religion, and Location Variables  *
*********************************************************

gen ReligionDenomPre96=ReligionDenom_1992
replace ReligionDenomPre96=ReligionDenom_1994 if ReligionDenomPre96==. & ReligionDenom_1994~=.


replace FatherEduc=FatherEduc_1992
replace MotherEduc=MotherEduc_1992
replace RegionBorn=RegionBorn_1992
replace RegionSch=RegionSch_1996
replace RuralChildhood=RuralChildhood_1996
replace Religion=Religion_1996

* 1994 Updates - RegionBorn
replace RegionBorn=RegionBorn_1994 if RegionBorn==. & RegionBorn_1994~=.

* 1996 Updates - RegionBorn
replace RegionBorn=RegionBorn_1996 if RegionBorn==. & RegionBorn_1996~=.
 

foreach YR in 1998 2000 2002 2004 2006 2008 2010 2012 2014 2016 {
   foreach VAR in FatherEduc MotherEduc  RegionBorn RegionSch HealthChild FatherUsOcc RuralChildhood ///
                  FamilySES FamDiff_Move FamDiff_Help FamDiff_FUnemp Religion ReligionDenom {
		replace `VAR'=`VAR'_`YR' if `VAR'==. & `VAR'_`YR'~=.
   }
}



foreach YR in  2008 2010 2012 2014 2016 {
   foreach VAR in            CH_MissSchool CH_Measles CH_Mumps CH_CPox CH_Sight CH_ParSmoke CH_Asthma ///
                              CH_Diabetes CH_Resp CH_Speech  CH_Allergy CH_Heart CH_Ear CH_Epilepsy CH_Migraines ///
							  CH_Stomach CH_BloodP  CH_Depression  CH_Drugs  CH_Psych CH_Concuss CH_Disable  CH_Smoke ///
							  CH_Learn  CH_Other {
		replace `VAR'=`VAR'_`YR' if `VAR'==. & `VAR'_`YR'~=.
   }
}

foreach YR in  2006int 2007int {
   foreach VAR in            CH_Measles CH_Mumps CH_CPox CH_ParSmoke CH_Asthma CH_Sight  ///
                              CH_Diabetes CH_Resp CH_Speech  CH_Allergy CH_Heart CH_Ear CH_Epilepsy CH_Migraines ///
							  CH_Stomach CH_BloodP  CH_Depression  CH_Drugs  {
		replace `VAR'=`VAR'_`YR' if `VAR'==. & `VAR'_`YR'~=.
   }
}


replace FatherEduc=. if FatherEduc>17
gen FatherEducWithM=FatherEduc
gen FEMiss =(FatherEduc==.)
	replace FatherEducWithM=9999 if FEMiss==1

replace MotherEduc=. if MotherEduc>17	
gen MotherEducWithM=MotherEduc
gen MEMiss=(MotherEduc==.)
	replace MotherEducWithM=9999 if MEMiss==1
	
gen HasParentEdu  =(MEMiss==0 & FEMiss==0)	


gen     FatherEduc8=FatherEduc8_1993
replace FatherEduc8=FatherEduc8_1995 if FatherEduc8==. & FatherEduc8_1995~=.
replace FatherEduc8=FatherEduc8_1996 if FatherEduc8==. & FatherEduc8_1996~=.
replace FatherEduc8=. if FatherEduc8==8
replace FatherEduc8=0 if FatherEduc8==5

	replace FatherEduc8=1 if FatherEduc>=8 & FatherEduc~=. & FatherEduc8==.
	replace FatherEduc8=0 if FatherEduc<8  & FatherEduc~=. & FatherEduc8==.


gen     MotherEduc8=MotherEduc8_1993
replace MotherEduc8=MotherEduc8_1995 if MotherEduc8==. & MotherEduc8_1995~=.
replace MotherEduc8=MotherEduc8_1996 if MotherEduc8==. & MotherEduc8_1996~=.
replace MotherEduc8=. if MotherEduc8==8
replace MotherEduc8=0 if MotherEduc8==5

	replace MotherEduc8=1 if MotherEduc>=8 & MotherEduc~=. & MotherEduc8==.
	replace MotherEduc8=0 if MotherEduc<8  & MotherEduc~=. & MotherEduc8==.		


	
	* The Religion Variable has the following categories:
	/*                   1.  PROTESTANT
                         2.  CATHOLIC
                         3.  JEWISH
                         4.  NO PREFERENCE
                         7.  OTHER (SPECIFY)
                         8.  DK (Don't Know); NA (Not Ascertained)
                         9.  RF (Refused) */
						 					 
						 
	* If the Religion Categorical Variable is missing, fill it in with values from 1992 / 1994 question
	replace Religion=1 if Religion==. & ReligionDenomPre96>=1  & ReligionDenomPre96<50
	replace Religion=1 if Religion==. & ReligionDenomPre96>=61 & ReligionDenomPre96<70 
	replace Religion=2 if Religion==. & ReligionDenomPre96>=51 & ReligionDenomPre96<60 
	replace Religion=3 if Religion==. & ReligionDenomPre96==71
	replace Religion=4 if Religion==. & ReligionDenomPre96>=90 & ReligionDenomPre96<98
	replace Religion=7 if Religion==. & ReligionDenomPre96>=81 & ReligionDenomPre96<90
	replace Religion=8 if Religion==. & ReligionDenomPre96==98
	replace Religion=9 if Religion==. & ReligionDenomPre96==99
	
	* If the Religion Categorical Variable is still missing, fill it in with values from the 1993 question
	replace Religion=ReligionDenom93_1993 if Religion==. & ReligionDenom93_1993~=.
	
	* If the Religion Categorical Variable is still missing, fill it in with values from the 1995 question
	replace Religion=1 if Religion==. & ReligionDenom95_1995>=1  & ReligionDenom95_1995<50
	replace Religion=1 if Religion==. & ReligionDenom95_1995>=61 & ReligionDenom95_1995<70 
	replace Religion=2 if Religion==. & ReligionDenom95_1995>=51 & ReligionDenom95_1995<60 
	replace Religion=3 if Religion==. & ReligionDenom95_1995==71
	replace Religion=4 if Religion==. & ReligionDenom95_1995>=90 & ReligionDenom95_1995<98
	replace Religion=7 if Religion==. & ReligionDenom95_1995>=81 & ReligionDenom95_1995<90
	replace Religion=8 if Religion==. & ReligionDenom95_1995==98
	replace Religion=9 if Religion==. & ReligionDenom95_1995==99	
	
	
	* Generate Dummies for different Religions:
	gen RC_Catholic=(Religion==2)
	gen RC_Jewish  =(Religion==3)
	gen RC_None    =(Religion==4)
	gen RC_Other   =(Religion==7)
	gen RC_Missing =(Religion==8 | Religion==9 | Religion==. )	
	

foreach YRInd in 2006 2008 2010 {

gen Job_Occ_2000=FatherUsOcc_`YRInd'

merge m:1 Job_Occ_2000 using "$CleanData\HRS_Occs_Census2000.dta", gen(OccMerge)

replace FatherUsOcc_`YRInd'=OccCatMode2000 if FatherUsOcc_`YRInd'<99
drop Job_Occ_2000 OccCatMode2000 OccMerge
}

foreach YRInd in 2012 2014 {

gen Job_Occ_2010=FatherUsOcc_`YRInd'

merge m:1 Job_Occ_2010 using "$CleanData\HRS_Occs_Census2010.dta", gen(OccMerge)

replace FatherUsOcc_`YRInd'=OccCatMode2010 if FatherUsOcc_`YRInd'<99
drop Job_Occ_2010 OccCatMode2010 OccMerge
}






/* Now, clean Father Occupation Variables.  Probably the best
thing to do here is to use income .... so we are going to merge in Income */	
	

gen FOcc=FatherUsOcc

sort FOcc

merge m:1 FOcc using "$CleanData/FOccIncData.dta", gen(FIncMerge)

gen FOccInc50=FInc_YR1950_Occ
gen FOccInc60=FInc_YR1960_Occ
gen FOccInc70=FInc_YR1970_Occ


gen FOccIncMasked=FOccInc60	

replace FOccIncMasked=FOccIncMasked/10000.0
gen logFOccIncMasked=log(FOccIncMasked)


gen FOccIncMaskedWithM=FOccIncMasked
gen FIncMaskedMiss =(FOccIncMasked==.)
replace FOccIncMaskedWithM=9999 if FIncMaskedMiss==1



	
/* Step 9: Clean some variables from the Demographic Data (HRSDemoCombined)	
* Clean Family SES Variables:  FatherEduc, MotherEduc, FamilySES, FamDiff_ */	
	
	/* Some descriptions:  
	FamilySES is coded as:  (ignore the frequency counts, I'm copying and pasting from one codebook):
	       1336         1. PRETTY WELL OFF FINANCIALLY
          12863         3. ABOUT AVERAGE
           6891         5. POOR
            219         6. IT VARIED (VOL)
             67         8. DK (don't know); NA (not ascertained)
              8         9. RF (refused)
			  
	
	FamDiff_Move (family ever move for financial difficulty), FamDiff_Help (family ever ask another fam for help) coded as :
	
           3777         1. YES
          17416         5. NO
            188         8. DK (don't know); NA (not ascertained)
              3         9. RF (refused)
	
	
	FamDiff_FUnemp (was father ever unemployed) coded as:
	       4163         1. YES
          14813         5. NO
            129         6. FATHER NEVER WORKED/ALWAYS DISABLED (VOL)
           1948         7. NEVER LIVED WITH FATHER/FATHER WAS NOT ALIVE (VOL)
            328         8. DK (don't know); NA (not ascertained)
              3         9. RF (refused)
			  
   			  
	Health as a Child:
	
          10354         1. EXCELLENT
           5520         2. VERY GOOD
           4072         3. GOOD
           1035         4. FAIR
            344         5. POOR
             58         8. DK (don't know); NA (not ascertained)
              1         9. RF (refused)	
			  
	Variables fo the form CH_* ... for example CH_Measles:
	
LB100               MEASLES BEFORE AGE 16
         Section: B     Level: Respondent      Type: Numeric    Width: 1   Decimals: 0
         Ref: SecB.Health.B100_

         Before you were 16 years old,
         did you have any of the following childhood diseases:
         
         Measles?

         .................................................................................
          9735           1.  YES
          2044           5.  NO
           494           8.  DK (Don't Know); NA (Not Ascertained)
             1           9.  RF (Refused)
          4943       Blank.  INAP (Inapplicable); Partial Interview	
	

	*/		  
	

	foreach var of varlist FamilySES FamDiff_Move FamDiff_Help FamDiff_FUnemp HealthChild ///
	                       CH_MissSchool CH_Measles CH_Mumps CH_CPox CH_Sight CH_ParSmoke CH_Asthma ///
                              CH_Diabetes CH_Resp CH_Speech  CH_Allergy CH_Heart CH_Ear CH_Epilepsy CH_Migraines ///
							  CH_Stomach CH_BloodP  CH_Depression  CH_Drugs  CH_Psych CH_Concuss CH_Disable  CH_Smoke ///
							  CH_Learn  CH_Other{
		replace `var'=8 if `var'==.
		tab `var', gen(`var'Cat)
	}
	
	
	
	

	
	***********************************************************
	* Merge in the Cross-Wave Location File and use "RegionB"
	***********************************************************
		* This line of code cleans the old version which had substantial 
		* missingness: 
		replace RegionBorn=9999 if RegionBorn==.	
	
	
drop if HHID==""	
		
	
*  Step 8: Merge with the Data from the Left Behind Survey, drop those only in the using set 	
merge m:1 HHID PN      using "$CleanData/HRS_RedoGrade.dta", gen(RedoGradeMerge)

drop if RedoGradeMerge==2		
		
	
	

* Measure 1: FamilySES:  1 (well-off) 3 (average) 5 (poor)
gen FamSES_InSample=(FamilySES==1 | FamilySES==3 | FamilySES==5)
gen FamSES_High=(FamilySES==1 | FamilySES==3)
gen FamSES_Low =FamilySES==5
	replace FamSES_High=. if (FamSES_InSample==0)
	replace FamSES_Low=.  if (FamSES_InSample==0)
	
	
* Measure 2a: Had to move for Hardship	
gen Move_InSample=(FamDiff_Move==1 | FamDiff_Move==5)
gen Move_High  =FamDiff_Move==5
gen Move_Low   =FamDiff_Move==1
	replace Move_High=. if (Move_InSample==0)
	replace Move_Low=.  if (Move_InSample==0)


* Measure 2b: Had to Ask Another Family for Help	
gen Help_InSample=(FamDiff_Help==1 | FamDiff_Help==5)
gen Help_High  =FamDiff_Help==5
gen Help_Low   =FamDiff_Help==1
	replace Help_High=. if (Help_InSample==0)
	replace Help_Low=.  if (Help_InSample==0)


* Measure 3: Had to either ask for help or Move	
gen MOrH_InSample=(Move_InSample==1 & Help_InSample==1)
gen MOrH_High=(Move_High==1 & Help_High==1)
gen MOrH_Low =(Move_Low==1 | Help_Low==1)

	replace MOrH_High=. if MOrH_InSample==0
	replace MOrH_Low=.  if MOrH_InSample==0
	

* Measure 4: Father Unemployd / not around	

gen FUnemp_InSample=(FamDiff_FUnemp==1 | FamDiff_FUnemp==5 | FamDiff_FUnemp==7)
gen FUnemp_High=FamDiff_FUnemp==5
gen FUnemp_Low =(FamDiff_FUnemp==1 | FamDiff_FUnemp==7)


	replace FUnemp_High=. if (FUnemp_InSample==0)
	replace FUnemp_Low =. if (FUnemp_InSample==0)


gen FUnempAlt_High=FUnemp_High
gen FUnempAlt_Low =FUnemp_Low
		replace FUnempAlt_High=. if FamDiff_FUnemp==7
		replace FUnempAlt_Low =. if FamDiff_FUnemp==7
		
	
* Measures: Mother's Education / Father's Education:	
gen MotherEduc_High=.
		replace MotherEduc_High=1 if MotherEduc>=12 & MotherEduc~=.
		replace MotherEduc_High=0 if MotherEduc<12  & MotherEduc~=.
		
	
gen FatherEduc_High=.
		replace FatherEduc_High=1 if FatherEduc>=12 & FatherEduc~=.
		replace FatherEduc_High=0 if FatherEduc<12  & FatherEduc~=.
		
	

keep HHID PN MotherEduc* FatherEduc* FEMiss MEMiss HasParentEdu Religion REGIONB REGLIV10 FamilySES  ///
     HealthChild MotherEduc8 FatherEduc8 FamDiff_Move FamDiff_Help FamDiff_FUnemp FatherUsOcc ///
	 RuralChildhood  CH_MissSchool CH_Measles CH_Mumps CH_CPox CH_Sight CH_ParSmoke CH_Asthma  ///
	 CH_Diabetes CH_Resp CH_Speech  CH_Allergy CH_Heart CH_Ear CH_Epilepsy CH_Migraines ///
	 CH_Stomach CH_BloodP  CH_Depression  CH_Drugs  CH_Psych CH_Concuss CH_Disable  CH_Smoke ///
	 CH_Learn  CH_Other FOccIncMasked FOccIncMaskedWithM FIncMaskedMiss *Cat* RC_* *_High *_Low ///
	 ChildRedoGrade BooksAt10 PreSchool NumInHouse ReligionDenomPre96 *int
	 
	 
	 
save "$CleanData/EA_DemographicVars.dta", replace













