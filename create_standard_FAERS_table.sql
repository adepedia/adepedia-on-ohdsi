--These codes are focus on to setup a standardized FAERS database, which is based on
--data de-duplication and drug name/adverse events/indications normalization results of AEOLUS[1]. 
--All sql codes are coding with PostgreSQL.
--Need to conduct the AEOLUS process first!
--GitHub of AEOLUS: https://github.com/ltscomputingllc/faersdbstats
--[1]Banda, J.M., et al., A curated and standardized adverse drug event resource to accelerate drug safety research. Sci Data, 2016. 3: p. 160026.


create schema standard_faers;
set search_path = standard_faers;

--1. Create standard FAERS demographic table
--1.1. Input FAERS demographic table data with de-duplication
drop table if exists standard_demo;
create table standard_demo as 
select a.* from faers.demo a,faers.unique_all_case b where a.primaryid = b.primaryid;

delete from standard_demo 
where primaryid in (select primaryid from standard_demo group by primaryid having count(primaryid) > 1) 
and ctid not in (select max(ctid) from standard_demo group by primaryid having count(primaryid)>1);

--1.2. Update demographic table to input missing event date, age, sex or reporter country value
update standard_demo a
set event_dt = b.event_dt, 
    age = b.age, 
    sex = b.sex, 
    reporter_country = b.reporter_country
from faers.unique_all_casedemo b
where a.primaryid = b.primaryid;

--2. Create standard FAERS drug table
--2.1. Input FAERS drug table data with de-duplication
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

--3. Create standard_reac table
--3.1. input the FAERS reac table data which adverse event name had been mapped with SNOMED CT or MedDRA standard terms.
drop table if exists standard_reac;
create table standard_reac as 
select a.primaryid, a.pt, a.outcome_concept_id, snomed_outcome_concept_id from faers.standard_case_outcome a;

--3.2 add caseid and drug_rec_act data
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

--4. create standard_outc table
--4.1导入已经去重和标准化后的outc表数据
drop table if exists standard_outc;
create table standard_outc as 
select a.primaryid, a.outc_code, a.snomed_concept_id
from faers.standard_case_outcome_category a;

--4.2补充caseid
alter table standard_outc 
add column caseid char varying;

update standard_outc a
set caseid = b.caseid
from faers.unique_all_case b
where a.primaryid = b.primaryid;

--5.建立standard_rpsr表
--5.1导入表rpsr数据，并去除重复
drop table if exists standard_rpsr;
create table standard_rpsr as 
select a.* from faers.rpsr a,faers.unique_all_case b where a.primaryid = b.primaryid;

--6.建立standard_ther表
--6.1导入ther表数据，并去除重复
drop table if exists standard_ther;
create table standard_ther as 
select a.* from faers.ther a,faers.unique_all_case b where a.primaryid = b.primaryid;

--7.建立standard_indi表
--7.1导入已经去重和标准化后的indi表数据
drop table if exists standard_indi;
create table standard_indi as 
select a.primaryid, a.indi_drug_seq, a.indi_pt, a.indication_concept_id, snomed_indication_concept_id
from faers.standard_case_indication a;

--7.2 add caseid
alter table standard_indi 
add column caseid char varying,
add column filename char varying;

update standard_indi a
set caseid = b.caseid, 
    filename = b.filename
from faers.indi b
where a.primaryid = b.primaryid;

