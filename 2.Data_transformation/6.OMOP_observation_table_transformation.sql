--Create temporary schema to store the transformed data.
--There is no required fields in temporary schema in order to facility the data transformation.
--The OMOP schema must be built first! (The public schema in codes is the OMOP CDM schema)

--The observation table in our project mainly stored the adverse events records and outcome information of the patient.

create schema public_temp;
set search_path = public_temp;

--6.Transforming observation table
--6.1. Create observation table
--50 characters are not enough for the field "observation_source_value", so we change the field type to varchar(variable unlimited length).

drop table if exists observation;
create table observation as 
(select * from public.observation limit 0);

drop sequence if exists observation_id_seq;
create sequence observation_id_seq
    start with 1
    increment by 1
    no minvalue
    no maxvalue
    cache 1;

alter table observation alter column observation_id set default nextval('observation_id_seq');
alter table observation alter observation_source_value type varchar;

--6.2. Input adverse event
truncate table observation;
insert into observation(person_id, observation_concept_id,
observation_type_concept_id, qualifier_concept_id,observation_source_value)
(select cast(caseid as int), outcome_concept_id, '44814721', '44788367', pt
from standard_faers.standard_reac);

--6.3. Input outcome_concept_id
alter table standard_faers.standard_outc add column outc_concept_id int;

update standard_faers.standard_outc
set outc_concept_id = 
	case when outc_code = 'DE' then 4306655
	when outc_code = 'LT' then 40483553
	when outc_code = 'HO' then 8715
	when outc_code = 'DS' then 37420519
	when outc_code = 'CA' then 4029540
	when outc_code = 'RI' then 4191370
	when outc_code = 'OT' then 9177
	else null
	end
where outc_code is not null;

insert into observation(person_id, observation_concept_id,
observation_type_concept_id, qualifier_concept_id,observation_source_value)
(select cast(caseid as int), outc_concept_id, '44814721', '44803440', outc_code
from standard_faers.standard_outc
where outc_code is not null);

--6.4. Input observation_date
update observation a
set observation_date = to_date(b.event_dt, 'YYYYMMDD')
from standard_faers.standard_demo b
where a.person_id = cast(b.caseid as int)
and b.event_dt is not null;


