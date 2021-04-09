* Get 2000 to 1990 from 2000 Census

clear all

cd "$Census1980"

use IPUMS_USCensus_1980.dta

rename occ occ1980

keep occ1990 occ1980

bys occ1980: egen Temp=mode(occ1990), min

bys occ1980: gen Counter=_n

keep if Counter==1

keep occ1980 Temp

rename Temp occ1990

save "$CleanData\CensusOcc_1980to1990.dta", replace


clear all

cd "$Census2000"

use IPUMS_USCensus_2000.dta

rename occ occ2000

keep occ1990 occ2000

bys occ2000: egen Temp=mode(occ1990), min

bys occ2000: gen Counter=_n

keep if Counter==1

keep occ2000 Temp

rename Temp occ1990

save "$CleanData\CensusOcc_2000to1990.dta", replace


* Get 2010 to 1990 from the 2010 ACS:

clear all

cd "$ACS2010"

use ACS2010.dta

keep occ occ1990

rename occ occ2010

bys occ2010: egen Temp=mode(occ1990), min

bys occ2010: gen Counter=_n

keep if Counter==1

keep occ2010 Temp

rename Temp occ1990

save "$CleanData\CensusOcc_2010to1990.dta", replace

clear all
