--Create temporary schema to store the transformed data.
--There is no required fields in temporary schema in order to facility the data transformation.
--The OMOP schema must be built first! (The public schema in codes is the OMOP CDM schema)

--The person table in our project mainly stored the demographic information of the patient.
--In order to input location data, the location table transformation must be conducted before this code.

create schema public_temp;
set search_path = public_temp;

--2. Transforming person table
--2.1. Input person_id and gender_source_value
drop table if exists person;
create table person as 
(select * from public.person limit 0);

truncate table person;
with cte1 as
(
	select cast(caseid as int) as caseidint, sex
	from standard_faers.standard_demo 
)
insert into person(person_id, gender_source_value) (select * from cte1); 

--2.2. Input person_source_value
update person
set person_source_value = person_id;

--2.3. Mapping gender_source_value with gender_concept_id
update person a 
set gender_concept_id = 
	case when a.gender_source_value = 'F' then 8532
	when a.gender_source_value = 'M' then 8507
	when a.gender_source_value = 'UNK' then 8551
	when a.gender_source_value = 'NS' then 8521
	end;
	
--2.4. Input location_id
with cte1 as
(
	select cast(a.caseid as int), a.occr_country, b.location_id  lid
	from standard_faers.standard_demo a, location b 
	where a.occr_country = b.location_source_value
)
update person set location_id = cte1.lid from cte1 
where person.person_id = cte1.caseid;

--2.5. Imputing year_of_birth
--Formatting age value
alter table standard_faers.standard_demo
add column age_temp varchar;

update standard_faers.standard_demo
set age_temp = 
	case when age ~ '^\.' then ('0' || age)
	when age ~ '^\-' then null
	when age ~ '^0[0-9]' then substring(age from 2)
	when age ~ '^\s' then substring(age from 2)
	when age ~ '[a-z,A-Z]' then null
	else age
	end;

---Formatting event_dt
alter table standard_faers.standard_demo
add column event_dt_temp varchar;

update standard_faers.standard_demo
set event_dt_temp = 
	case when event_dt ~ '^[0,1,3-9]0' then ('2' || substring(event_dt from 2))
	when event_dt ~ '^02' then ('20' || substring(event_dt from 3))
	when event_dt ~ '^21' then ('20' || substring(event_dt from 3))
	when event_dt ~ '^[0][3-9]20' then (substring(event_dt from 3) || substring(event_dt from 1 for 2))
	when event_dt ~ '^202' then ('201' || substring(event_dt from 4))
	when event_dt ~ '^1[0-8]' then null
	else event_dt
	end;

--year_of_birth imputation
alter table standard_faers.standard_demo
add column year_temp date;

update standard_faers.standard_demo a 
set year_temp = 
	case when a.age_cod = 'DEC' then to_date(event_dt_temp,'YYYYMMDD')  + ('-' || to_number(age_temp,'999999D') ||' decade')::interval
	when a.age_cod = 'YR' then to_date(event_dt_temp,'YYYYMMDD')  + ('-' || to_number(age_temp,'999999D') ||' year')::interval
	when a.age_cod = 'MON' then to_date(event_dt_temp,'YYYYMMDD')  + ('-' || to_number(age_temp,'999999D') ||' month')::interval
	when a.age_cod = 'WK' then to_date(event_dt_temp,'YYYYMMDD')  + ('-' || to_number(age_temp,'999999D') ||' week')::interval
	when a.age_cod = 'DY' then to_date(event_dt_temp,'YYYYMMDD')  + ('-' || to_number(age_temp,'999999D') ||' day')::interval
	when a.age_cod = 'HR' then to_date(event_dt_temp,'YYYYMMDD')  + ('-' || to_number(age_temp,'999999D') ||' hour')::interval
	else null
	end
where a.age_temp is not null and a.age_cod is not null and a.event_dt_temp is not null;

--Input year_of_birth
update person a
set year_of_birth = extract(year from b.year_temp)
from standard_faers.standard_demo b
where a.person_id = cast(b.caseid as int);


