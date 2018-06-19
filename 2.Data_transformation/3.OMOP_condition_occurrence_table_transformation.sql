--Create temporary schema to store the transformed data.
--There is no required fields in temporary schema in order to facility the data transformation.
--The OMOP schema must be built first! (The public schema in codes is the OMOP CDM schema)

--The condition_occurrence table in our project mainly stored the indication information of the patient.

create schema public_temp;
set search_path = public_temp;

--3.Transforming condition_occurrence table
--3.1. Input condition_occurrence_id, person_id, condition_concept_id, condition_source_value
--We use "primaryid" + "indi_drug_seq" in FAERS to represent condition_occurrence_source_id, but the string length exceed the range of int, so we change the type of condition_occurrence_source_id into bigint，
--Also, 50 characters are not enough for the field "condition_source_value", so we increase the length to 100.
drop table if exists condition_occurrence;
create table condition_occurrence as 
(select * from public.condition_occurrence limit 0);

drop sequence if exists condition_occurrence_id_seq;
create sequence condition_occurrence_id_seq
    start with 1
    increment by 1
    no minvalue
    no maxvalue
    cache 1;

alter table condition_occurrence alter column condition_occurrence_id set default nextval('condition_occurrence_id_seq');
alter table condition_occurrence add column condition_occurrence_source_id bigint;
alter table condition_occurrence alter condition_source_value type varchar(100);

truncate table condition_occurrence;
insert into condition_occurrence(condition_occurrence_source_id, person_id, condition_concept_id, condition_source_value)
(select cast((primaryid || indi_drug_seq) as bigint), cast(caseid as int), snomed_indication_concept_id, indi_pt 
from standard_faers.standard_indi where snomed_indication_concept_id is not null);

insert into condition_occurrence(condition_occurrence_source_id, person_id, condition_concept_id, condition_source_value)
(select cast((primaryid || indi_drug_seq) as bigint), cast(caseid as int), indication_concept_id, indi_pt 
from standard_faers.standard_indi where snomed_indication_concept_id is null);

--3.2. Input condition_type_concept_id(45905770, Patient Self-Reported Condition)
update condition_occurrence
set condition_type_concept_id = '45905770';

--3.3. Impute condition_start_time (Choose the earliest condition time as the condition_start_time)
drop index if exists condition_source_occurrence_index;
create index condition_source_occurrence_index on condition_occurrence(condition_occurrence_source_id);

with cte1 as
(
	select cast((primaryid || dsg_drug_seq) as bigint) as rnid,to_date(start_dt,'YYYYMMDD') as dt, row_number()over(partition by (primaryid || dsg_drug_seq) order by start_dt) as rn
	from standard_faers.standard_ther
)
update condition_occurrence a 
set condition_start_date = cte1.dt
from cte1
where a.condition_occurrence_source_id = cte1.rnid and cte1.rn = 1;


