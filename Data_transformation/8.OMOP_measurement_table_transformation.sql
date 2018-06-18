--Create temporary schema to store the transformed data.
--There is no required fields in temporary schema in order to facility the data transformation.
--The OMOP schema must be built first! (The public schema in codes is the OMOP CDM schema)

--The measurement table in our project mainly stored the body weight information of the patient.

create schema public_temp;
set search_path = public_temp;

--8.Transforming measurement table
drop table if exists measurement;
create table measurement as 
(select * from public.measurement limit 0);

alter table standard_faers.standard_demo add column wt_temp varchar;
alter table standard_faers.standard_demo add column wt_unit_temp varchar;

drop sequence if exists measurement_id_seq;
create sequence measurement_id_seq
    start with 1
    increment by 1
    no minvalue
    no maxvalue
    cache 1;
    
alter table measurement alter column measurement_id set default nextval('measurement_id_seq');

--Formatting weight value and unit
update standard_faers.standard_demo
set wt_temp = 
	case when wt ~ '^\.' then ('0' || wt)
	when wt ~ '^\-' then null
	when wt ~ '^0[0-9]' then substring(wt from 2)
	when wt ~ '^\s' then substring(wt from 2)
	when wt ~ '[a-z,A-Z]' then null
	when wt ~ '^[0-9]+\.$' then (wt || 0)
	when wt ~ '\-' then null
	when wt ~ '\~' then null
	when wt ~ '\`' then null
	when wt ~ '\/' then null
	when wt ~ '\s' then substring(wt from '^[0-9]+\.*[0-9]+')
	else wt
	end
where wt is not null;
	
	
update standard_faers.standard_demo
set wt_unit_temp = 
	case when wt_cod = 'LBS' then 8739
	when wt_cod = 'KG' then 9529
	when wt_cod = 'GMS' then 8504
	else null
	end
where wt_cod is not null;

--Input all fields
insert into measurement(person_id, measurement_concept_id, measurement_date,
measurement_type_concept_id, value_as_number, unit_concept_id, unit_source_value, value_source_value)
(select cast(caseid as int), '3025315', to_date(event_dt, 'YYYYMMDD'), 
'44818704', cast(wt_temp as numeric), cast(wt_unit_temp as int), wt_cod, wt
from standard_faers.standard_demo
where wt is not null);


