This folder contains all required scripts and datasets to replicate Table 3 of Becker
et al.

`./papageorge_thom/`

A slightly edited replication package from Papageorge and Thom
(paper and original replication materials [here](https://academic.oup.com/jeea/article-abstract/18/3/1351/5677507)). All data needed for the replication are publicly
available, but one will need to make an account with HRS to access their data.
More detailed instructions on replication are at `./papageorge_thom/GenesEduc_ReadMe.do`
-- read this document carefully. The replication package will produce a table,
`EA_CrossSection.dta`, that will be needed to reproduce Table 3.

`./replication/`

This contains the scripts to reproduce the estimates in Table 3. The first script
processes the data for input to `pgic.py`. The second script calls `pgic.py`.
For more instructions, read `./replication/README.md`.
