--Loading the observation table data of public_temp schema to formal OHDSI CDM database.
--The public schema is the formal OHDSI CDM database.
--All the data in temporary schema could be inputted into the OHDSI CDM table whether there have been some data in the database or not.

set search_path = public_temp;

--6.1 Inputting 0 for the null value of the required fields.
update public_temp.observation
set observation_date = '0001-01-01'
where observation_date is null

--6.2 Loading temporary observation table data into OHDSI CDM.
--50 characters are not enough for the field "observation_source_value", so we change the field type to varchar(variable unlimited length).
alter table public.observation alter observation_source_value type varchar;

with cte1 as
(
	select count(*) as qu from public.observation
)
insert into public.observation(observation_id, person_id, observation_concept_id,
observation_date, observation_type_concept_id, qualifier_concept_id, observation_source_value)
(select observation_id + cte1.qu, person_id, observation_concept_id,
observation_date, observation_type_concept_id, qualifier_concept_id, observation_source_value
from public_temp.observation, cte1)

