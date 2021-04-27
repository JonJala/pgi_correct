correction="../pgs_correct/pgic.py"
h2=.253
R2=.110

echo "MAKE SURE YOU HAVE ACTIVATED THE CORRECTED VIRTUALENV. RESULTS WILL NOT REPLICATE OTHERWISE!!!!!"
# ********************************************
# source /path/to/pgi_correct_venv/activate
# ********************************************
sleep 5

# regression 1
python3 ${correction} --reg-data-file "./reg1/reg1.txt"  \
                      --outcome "Educ"  \
                      --pgi-var "EA3Score"  \
                      --out "./reg1/reg1" \
                      --covariates "ev*" "iMale*" "interact*" "iBIRTHYR*"  \
                      --h2 ${h2} \
                      --R2 ${R2} \
                      --output-vars "EA3Score" \
                      --weights "EAWeight"

# regression 2
python3 ${correction} --reg-data-file "./reg2/reg2.txt" \
                     --outcome "Educ" \
                     --pgi-var "EA3Score" \
                     --out "./reg2/reg2" \
                     --covariates "FatherEduc" "MotherEduc" "FEMiss" "MEMiss" "ev*" "iMale*" "iBIRTHYR*" "interact*" \
                     --h2 ${h2} \
                     --R2 ${R2} \
                     --weights "EAWeight" \
                     --output-vars "EA3Score" "FatherEduc" "MotherEduc"

# regression 3
 python3 ${correction} --reg-data-file "./reg3/reg3.txt" \
                       --outcome "AtLstHS" \
                       --pgi-var "EA3Score" \
                       --pgi-interact-vars "HighSES" \
                       --covariates "ev*" "FatherEducWithM" "FEMiss" "MotherEducWithM" "MEMiss" "iBIRTHYR*" "HighSES" \
                       --weights "EAWeight" \
                       --out "./reg3/reg3" \
                       --h2 ${h2} \
                       --R2 ${R2} \
                       --output-vars "EA3Score" "HighSES" "HighSES_int"

# regression 4
 python3 ${correction} --reg-data-file "./reg4/reg4.txt" \
                       --outcome "AtLstColl" \
                       --pgi-var "EA3Score" \
                       --pgi-interact-vars "HighSES" \
                       --covariates "ev*" "FatherEducWithM" "FEMiss" "MotherEducWithM" "MEMiss" "iBIRTHYR*" "HighSES" \
                       --weights "EAWeight" \
                       --out "./reg4/reg4" \
                       --h2 ${h2} \
                       --R2 ${R2} \
                       --output-vars "EA3Score" "HighSES" "HighSES_int"