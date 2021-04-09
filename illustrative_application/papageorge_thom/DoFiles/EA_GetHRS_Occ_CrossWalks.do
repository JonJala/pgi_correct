* Load 2000 IPUMS Census Data
clear all

cd "$Census2000"

use IPUMS_USCensus_2000.dta

* For the years 2006-2010, the HRS masks occupations by recoding them to a coarse
* set of 25 occupation codes based on the 2000 Census occupation codes. Here
* we create a crosswalk between the HRS's Masking of the 2000 Codes and 
* the 1990 census codes, since we will be merging the task data based on
* the 1990 census codes.  So the goal is for each of the 25 HRS Masked
* cateogries, we record the modal 1990 occupation code.

* To make this comparable, it will all be boiled down to the 1990-2004 
* HRS masking scheme, which involves only 17 categories.  So for each of the 
* 17 masking categories, we will report the modal 1990 occupation category. 

* Just keep the occ and occ1990 data - we are creating a cross-walk
* between the 2000 Census occupation codes and the 1990 occupation codes.
* occ contains the 2000 census occupation codes, while occ1990 represents
* the corresponding 1990 census occupation codes.

keep occ occ1990 perwt
 
* Drop uknown occupations (999) and unemployed (991) 
drop if occ1990>=991

* Generate categorical variable for occupations based on masking categories 
* used by HRS for 2006-2010 (based on 2000 Census):

gen Job_Occ_2000=.
replace Job_Occ_2000=1  if occ>0 & occ<=44
replace Job_Occ_2000=2  if occ>=50 & occ<=73
replace Job_Occ_2000=3  if occ>=80 & occ<=95
replace Job_Occ_2000=4  if occ>=100 & occ<=124
replace Job_Occ_2000=5  if occ>=130 & occ<=156
replace Job_Occ_2000=6  if occ>=160 & occ<=196
replace Job_Occ_2000=7  if occ>=200 & occ<=206
replace Job_Occ_2000=8  if occ>=210 & occ<=215
replace Job_Occ_2000=9  if occ>=220 & occ<=255
replace Job_Occ_2000=10 if occ>=260 & occ<=296
replace Job_Occ_2000=11 if occ>=300 & occ<=354
replace Job_Occ_2000=12 if occ>=360 & occ<=365
replace Job_Occ_2000=13 if occ>=370 & occ<=395
replace Job_Occ_2000=14 if occ>=400 & occ<=416
replace Job_Occ_2000=15 if occ>=420 & occ<=425
replace Job_Occ_2000=16 if occ>=430 & occ<=465
replace Job_Occ_2000=17 if occ>=470 & occ<=496
replace Job_Occ_2000=18 if occ>=500 & occ<=593
replace Job_Occ_2000=19 if occ>=600 & occ<=613
replace Job_Occ_2000=20 if occ>=620 & occ<=676
replace Job_Occ_2000=21 if occ>=680 & occ<=694
replace Job_Occ_2000=22 if occ>=700 & occ<=762
replace Job_Occ_2000=23 if occ>=770 & occ<=896
replace Job_Occ_2000=24 if occ>=900 & occ<=975
replace Job_Occ_2000=25 if occ>=980 & occ<=985

* Create a categorical variable for occupations based on masking categories
* used by HRS for 1990 - 2004 ... this will be the harmonized scheme used
* in the paper

gen OccCat=.

replace OccCat=1 if occ1990>=3 & occ1990<=37
replace OccCat=2 if occ1990>=43 & occ1990<=235
replace OccCat=3 if occ1990>=243 & occ1990<=285
replace OccCat=4 if occ1990>=303 & occ1990<=389
replace OccCat=5 if occ1990>=403 & occ1990<=407
replace OccCat=6 if occ1990>=413 & occ1990<=427
replace OccCat=7 if occ1990>=433 & occ1990<=444
replace OccCat=8 if occ1990>=445 & occ1990<=447
replace OccCat=9 if occ1990>=448 & occ1990<=469
replace OccCat=10 if occ1990>=473 & occ1990<=499
replace OccCat=11 if occ1990>=503 & occ1990<=549
replace OccCat=12 if occ1990>=553 & occ1990<=617
replace OccCat=13 if occ1990>=633 & occ1990<=699
replace OccCat=14 if occ1990>=703 & occ1990<=799
replace OccCat=15 if occ1990>=803 & occ1990<=859
replace OccCat=16 if occ1990>=863 & occ1990<=889
replace OccCat=17 if occ1990==905


bys Job_Occ_2000: egen OccCatMode2000=mode(OccCat)

bys Job_Occ_2000: gen Counter=_n

keep if Counter==1

keep Job_Occ_2000 OccCatMode2000

save "$CleanData\HRS_Occs_Census2000.dta", replace


clear all

use "$ACS2010\ACS2010.dta", replace

* Just keep the occ and occ1990 data - we are creating a cross-walk
* between the 2010 Census occupation codes and the 1990 occupation codes
keep occ occ1990
 
* Drop uknown occupations (999) and unemployed (991) 
drop if occ1990>=991


* Generate categorical variable for occupations based on masking categories 
* used by HRS for 2006-2010 (based on 2000 Census):

gen Job_Occ_2010=.
replace Job_Occ_2010=1  if occ>=10 & occ<=430
replace Job_Occ_2010=2  if occ>=500 & occ<=950
replace Job_Occ_2010=3  if occ>=1000 & occ<=1240
replace Job_Occ_2010=4  if occ>=1300 & occ<=1560
replace Job_Occ_2010=5  if occ>=1600 & occ<=1960
replace Job_Occ_2010=6  if occ>=2000 & occ<=2060
replace Job_Occ_2010=7  if occ>=2100 & occ<=2160
replace Job_Occ_2010=8  if occ>=2200 & occ<=2550
replace Job_Occ_2010=9  if occ>=2600 & occ<=2960
replace Job_Occ_2010=10 if occ>=3000 & occ<=3540
replace Job_Occ_2010=11 if occ>=3600 & occ<=3650
replace Job_Occ_2010=12 if occ>=3700 & occ<=3950
replace Job_Occ_2010=13 if occ>=4000 & occ<=4160
replace Job_Occ_2010=14 if occ>=4200 & occ<=4250
replace Job_Occ_2010=15 if occ>=4300 & occ<=4650
replace Job_Occ_2010=16 if occ>=4700 & occ<=4960
replace Job_Occ_2010=17 if occ>=5000 & occ<=5940
replace Job_Occ_2010=18 if occ>=6000 & occ<=6130
replace Job_Occ_2010=19 if occ>=6200 & occ<=6940
replace Job_Occ_2010=20 if occ>=7000 & occ<=7630
replace Job_Occ_2010=21 if occ>=7700 & occ<=8960
replace Job_Occ_2010=22 if occ>=9000 & occ<=9750
replace Job_Occ_2010=23 if occ>=9800 & occ<=9830


* Create a categorical variable for occupations based on masking categories
* used by HRS for 1990 - 2004 ... this will be the harmonized scheme used
* in the paper

gen OccCat=.

replace OccCat=1 if occ1990>=3 & occ1990<=37
replace OccCat=2 if occ1990>=43 & occ1990<=235
replace OccCat=3 if occ1990>=243 & occ1990<=285
replace OccCat=4 if occ1990>=303 & occ1990<=389
replace OccCat=5 if occ1990>=403 & occ1990<=407
replace OccCat=6 if occ1990>=413 & occ1990<=427
replace OccCat=7 if occ1990>=433 & occ1990<=444
replace OccCat=8 if occ1990>=445 & occ1990<=447
replace OccCat=9 if occ1990>=448 & occ1990<=469
replace OccCat=10 if occ1990>=473 & occ1990<=499
replace OccCat=11 if occ1990>=503 & occ1990<=549
replace OccCat=12 if occ1990>=553 & occ1990<=617
replace OccCat=13 if occ1990>=633 & occ1990<=699
replace OccCat=14 if occ1990>=703 & occ1990<=799
replace OccCat=15 if occ1990>=803 & occ1990<=859
replace OccCat=16 if occ1990>=863 & occ1990<=889
replace OccCat=17 if occ1990==905


bys Job_Occ_2010: egen OccCatMode2010=mode(OccCat)

bys Job_Occ_2010: gen Counter=_n

keep if Counter==1

keep Job_Occ_2010 OccCatMode2010

drop if Job_Occ_2010==.

save "$CleanData\HRS_Occs_Census2010.dta", replace

clear all
