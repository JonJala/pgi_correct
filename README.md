# pgi_correct
`pgi_correct` is a Python-based command line tool that corrects for attenuation bias in OLS coefficients due to a noisily-measured polgyenic index (PGI). For more details please see Becker et al. (2021). 

### Getting started
You can clone the repository with 
```
$ git clone https://github.com/JonJala/pgi_correct.git
$ cd pgi_correct
```
The easiest way to ensure your libraries will be compatible with the dependencies in the software is to instantiate a virtual environment with [`virtualenv`](https://virtualenv.pypa.io/en/latest/). Once `virtualenv` is installed on your machine, you can type the following:
```
$ virtualenv -p $(which python3) pgic_env
$ source pgic_env/bin/activate 
$ pip install -r /path/to/pgi_correct/requirements.txt
```
To test proper installation, ensure that typing 
```
$ python3 ./pgic.py -h
```
gives a description of the software and accepted command line flags. If an error is thrown then the installation was unsuccessful. 

### Updating `pgi_correct`
You should keep your local instance of this software up to date with updates that are made on the github repository. To do that, type 
```
$ git pull
```
in the `pgi_correct` directory. If your local instance is outdated, `git` will retrieve all changes and update the code. Otherwise, you will be told that your local instance is already up to date. 

### Support
We are happy to answer any questions you may have about using the software. Before [opening an issue](https://github.com/JonJala/pgi_correct/issues), please be sure to read the wiki, description of the method in the paper linked above, and the description of the input flags and their proper usage. If your problem persists, **please do the following:**

  1. Rerun the specification that is causing the error, being sure to specify `--logging-level "debug"`. 
  2. Attach your log file in the issue. 
  
You may also contact us via email, although we encourage github issues so others can benefit from your question as well!    

### Citation
If you are using the PGI correction method or software, please cite Becker et al. (2021). 

### License
This project is licensed with the MIT public license.

### Authors 
Grant Goldman, Jonathan B. Jala, Patrick Turley

### Acknowledgements
We thank C. Shulman for helpful comments. This research was carried out under the auspices of the Social Science Genetic Association Consortium (SSGAC). This research was conducted using the UK Biobank Resource under application number 11425. The study was supported by funding from the Ragnar Söderberg Foundation (E42/15, D.C.), the Swedish Research Council (421-2013-1061, M.J.; 2019-00244, S.O.), an ERC Consolidator Grant (647648 EdGe, P.K.), the Pershing Square Fund of the Foundations of Human Behavior (D.L.), Open Philanthropy (010623-00001, D.J.B.), Riksbankens Jubileumsfond P18-0782:1 (S.O.), Netherlands Organisation for Scientific Research VENI grant 016.Veni.198.058 (A.O.), and the NIA/NIH through grants R24-AG065184 (D.J.B.) to the University of California Los Angeles; K99-AG062787-01 (P.T.) to Massachusetts General Hospital; 1R01-MH101244-02 (P.T.; PI: Benjamin M. Neale) and 5U01-MH109539-02 (P.T.; PI: B.M.N.) to the Broad Institute at Harvard and MIT; the Government of Canada through Genome Canada and the Ontario Genomics Institute (OGI-152) (J.P.B.); the Social Sciences and Humanities Research Council of Canada (J.P.B.), the National Health and Medical Research Council through grant GNT113400 (P.M.V); and the Australian Research Council. We thank the following consortia for sharing GWAS summary statistics: Reproductive Genetics (ReproGen) Consortium for age at first menses; Genetics of Personality Consortium (GPC) for neuroticism, extraversion, and openness; Psychiatric Genomics Consortium (PGC) for ADHD and depressive symptoms; Tobacco and Alcohol Genetics (TAG) Consortium for cigarettes per day and ever smoker; International Genomics of Alzheimer's Project (IGAP) for Alzheimer’s disease, GWAS & Sequencing Consortium of Alcohol and Nicotine use (GSCAN) for cigarettes per day, ever smoker and drinks per week; Genetic Investigation of Anthropometric Traits (GIANT) Consortium for height and BMI; and Cognitive Genomics (COGENT) Consortium for cognitive performance. We thank the research participants and employees of 23andMe for making this work possible. A full list of acknowledgements is provided in the Supplementary Note.
