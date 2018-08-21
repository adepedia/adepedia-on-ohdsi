--Loading the person table data of public_temp schema to formal OHDSI CDM database.
--The public schema is the formal OHDSI CDM database.
--All the data in temporary schema could be inputted into the OHDSI CDM table whether there have been some data in the database or not.

--The location table loading must be conducted before this code!

set search_path = public_temp;

--2.1 Inputting 0 for the null value of the required fields.
update public_temp.person
set gender_concept_id = 0 
where gender_concept_id is null

update public_temp.person
set year_of_birth = 0 
where year_of_birth is null

update public_temp.person
set race_concept_id = 0 
where race_concept_id is null

update public_temp.person
set ethnicity_concept_id = 0 
where ethnicity_concept_id is null

--2.2 Computing the new id base on the existing data in the OHDSI CDM.
alter table public_temp.person
add column location_new_id int;

with cte1 as
(
select count(*) as qa from public_temp.location
),
cte2 as
(
select count(*) as qb from public.location
)
update public_temp.person
set location_new_id = location_id + (select cte2.qb - cte1.qa from cte1,cte2)

--2.3 Loading temporary person table data into OHDSI CDM.
insert into public.person(person_id, gender_concept_id, year_of_birth, race_concept_id,
ethnicity_concept_id, location_id, person_source_value, gender_source_value)
(select person_id, gender_concept_id, year_of_birth, race_concept_id, 
ethnicity_concept_id, location_new_id, person_source_value, gender_source_value
from public_temp.person)


