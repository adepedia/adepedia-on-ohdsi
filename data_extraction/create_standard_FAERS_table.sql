--These codes are focus on to setup a standardized FAERS database, which is based on
--data de-duplication and drug name/adverse events/indications normalization results of AEOLUS[1]. 
--All sql codes are coding with PostgreSQL.
--Need to conduct the AEOLUS process first!
--Only for the FAERS data after Sep. 2012.
--GitHub of AEOLUS: https://github.com/ltscomputingllc/faersdbstats
--[1] Banda, J.M., et al., A curated and standardized adverse drug event resource to accelerate drug safety research. Sci Data, 2016. 3: p. 160026.



create schema standard_faers;
set search_path = standard_faers;

--1. Create FAERS Demographic table
--1.1. Input de-duplicated FAERS Demographic table data
drop table if exists standard_demo;
create table standard_demo as 
select a.* from faers.demo a,faers.unique_all_case b where a.primaryid = b.primaryid;

delete from standard_demo 
where primaryid in (select primaryid from standard_demo group by primaryid having count(primaryid) > 1) 
and ctid not in (select max(ctid) from standard_demo group by primaryid having count(primaryid)>1);

--1.2. Update Demographic table to input missing event date, age, sex and reporter country value
update standard_demo a
set event_dt = b.event_dt, 
    age = b.age, 
    sex = b.sex, 
    reporter_country = b.reporter_country
from faers.unique_all_casedemo b
where a.primaryid = b.primaryid;

--2. Create FAERS Drug table
--2.1. Input de-duplicated FAERS Drug table data
drop table if exists standard_drug;
create table standard_drug as 
select a.* from faers.drug a ,faers.unique_all_case b where a.primaryid = b.primaryid

drop index if exists standard_drug_index;
create index standard_drug_index on standard_drug(primaryid,drug_seq);

delete from standard_drug a
where (a.primaryid, a.drug_seq) in (select primaryid,drug_seq from standard_drug group by primaryid,drug_seq having count(*) > 1) 
and ctid not in (select max(ctid) from standard_drug group by primaryid,drug_seq having count(*)>1);

--2.2. Input drug standard concept id (RxNorm) into standard drug table
alter table standard_drug 
add column standard_concept_id integer;

update standard_drug a
set standard_concept_id = b.standard_concept_id
from faers.standard_combined_drug_mapping b
where a.primaryid = b.primaryid and a.drug_seq = b.drug_seq;

--3. Create FAERS Reaction table
--3.1. Input adverse event name and related SNOMED CT or MedDRA standard concept id.
drop table if exists standard_reac;
create table standard_reac as 
select a.primaryid, a.pt, a.outcome_concept_id, snomed_outcome_concept_id from faers.standard_case_outcome a;

--3.2. Add caseid and drug reaction act data
alter table standard_reac 
add column caseid char varying,
add column drug_rec_act char varying,
add column filename char varying;

update standard_reac a
set caseid = b.caseid, 
    drug_rec_act = b.drug_rec_act, 
    filename = b.filename
from faers.reac b
where a.primaryid = b.primaryid;

--4. Create FAERS Outcome table
--4.1. Input de-duplicated FAERS Outcome table data
drop table if exists standard_outc;
create table standard_outc as 
select a.primaryid, a.outc_code, a.snomed_concept_id
from faers.standard_case_outcome_category a;

--4.2 Add caseid
alter table standard_outc 
add column caseid char varying;

update standard_outc a
set caseid = b.caseid
from faers.unique_all_case b
where a.primaryid = b.primaryid;

--5. Create FAERS Report table
--5.1. Input de-duplicated FAERS Report table data
drop table if exists standard_rpsr;
create table standard_rpsr as 
select a.* from faers.rpsr a,faers.unique_all_case b where a.primaryid = b.primaryid;

--6. Create standard FAERS Therapy table
--6.1. Input de-duplicated FAERS Therapy table data
drop table if exists standard_ther;
create table standard_ther as 
select a.* from faers.ther a,faers.unique_all_case b where a.primaryid = b.primaryid;

--7. Create FAERS Indication table
--7.1. Input de-duplicated and standardized (SNOMED CT or MedDRA) FAERS Indication table data
drop table if exists standard_indi;
create table standard_indi as 
select a.primaryid, a.indi_drug_seq, a.indi_pt, a.indication_concept_id, snomed_indication_concept_id
from faers.standard_case_indication a;

--7.2. Add caseid
alter table standard_indi 
add column caseid char varying,
add column filename char varying;

update standard_indi a
set caseid = b.caseid, 
    filename = b.filename
from faers.indi b
where a.primaryid = b.primaryid;

