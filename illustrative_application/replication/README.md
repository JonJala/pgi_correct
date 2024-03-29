The scripts in this folder are used to prepare and estimate the regression models in
Table 3 of Becker et al.


`1.make_reg_data.do`

Short stata script to clean regression data, generate interactions and dummies, drop
linearly dependent columns, etc. Just need to point the script to the cross section
from Papageorge and Thom, `EA_CrossSection.dta`. The script will insert pgic input data
for each regression:

    - reg1: regression of EA on EA PGI.
    - reg2: regression of EA on EA PGI, controlling for parental EA.
    - reg3: first GxE regression, outcome is at least high school.
    - reg4: second GxE regression, outcome is at least college.


`2.replicate_estimates.sh`

Short bash script to call `pgic.py` which will generate original and corrected
coefficient estimates (Table 3 of Becker et al.) Just need to activate your pgic
virtualenv to ensure package compatibility. Virtualenv activation instructions at
`../../README.md`. Even if not replicating our results, we encourage users to familiarize
themselves with this script as an example of how to properly call the pgic tool.
