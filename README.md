# adepedia-on-ohdsi
The development of ETL scripts to load FDA adverse event reporting system (FAERS) datasets into the OHDSI (OMOP) CDM.

* In current version, this ETL tool could convert the [FAERS](https://fis.fda.gov/extensions/FPD-QDE-FAERS/FPD-QDE-FAERS.html) data after Sep. 2012 into [OHDSI CDM](https://ohdsi.org/) (v5.0).
  
* For the FAERS data de-duplication and drug name standardization, you need to implement the AEOLUS process first.
  
  GitHub of AEOLUS: https://github.com/ltscomputingllc/faersdbstats  
  Publication of AEOLUS: Banda, J.M., et al., A curated and standardized adverse drug event resource to accelerate drug safety research. Sci Data, 2016. 3: p. 160026. [PubMed](https://www.ncbi.nlm.nih.gov/pubmed/27193236)
  
* After AEOLUS implemention, you can conduct our ETL tool as following order: 1.FAERS_standardization; 2.Data_transformation; 3.Data_loading.

* For more details such as mapping rules and information loss about this tool, you can find them in this paper:

  Yu Y, Ruddy KJ, Hong N, Tsuji S, Shah N, Jiang G. ADEpedia-on-OHDSI: A Next Generation Pharmacovigilance Signal Detection Platform Using the OHDSI Common Data Model. J Biomed Inform. 2019 Feb 7:103119. doi: 10.1016/j.jbi.2019.103119. [PubMed](https://www.ncbi.nlm.nih.gov/pubmed/30738946)
  
  

# Publications

* Yu Y, Ruddy KJ, Hong N, Tsuji S, Liu H, Shah N, Jiang G. ADEpedia-on-OHDSI: An Open Source ETL Tool for Converting FAERS into the OHDSI CDM for Improved Signal Detection. OHDSI Symposium 2018. [Abstract](https://docs.google.com/document/d/1zz0SjlfiO_np9A7S0ss4ySG_gXY1S6aOwKTrH5XZx3w/edit)| [Poster](https://drive.google.com/drive/folders/1DBPJuD1pnXc6LPYqB4fpy7ohI30Uo4bR) 

* Yu Y, Ruddy KJ, Hong N, Tsuji S,Shah N, Jiang G. Developing A Standards-based Signal Detection and Validation Framework of Immune-related Adverse Events Using the OHDSI Common Data Model. AMIA Annual Symposium 2018. [Podium Abstract](https://symposium2018.zerista.com/event/member/508534)

* Yu Y, Ruddy KJ, Hong N, Tsuji S, Shah N, Jiang G. ADEpedia-on-OHDSI: A Next Generation Pharmacovigilance Signal Detection Platform Using the OHDSI Common Data Model. J Biomed Inform. 2019 Feb 7:103119. doi: 10.1016/j.jbi.2019.103119. [PubMed](https://www.ncbi.nlm.nih.gov/pubmed/30738946)

* Yu Y, Ruddy KJ, Tsuji S, Hong N, Liu H, Shah N, Jiang G. Coverage Evaluation of CTCAE for Capturing the Immune-related Adverse Events Leveraging Text Mining Technologies. AMIA Informatics Summit 2019. [AMIA Paper](https://informaticssummit2019.zerista.com/event/member/542966)
