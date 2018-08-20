--Loading the condition_occurrence table data of public_temp schema to formal OHDSI CDM database.
--The public schema is the formal OHDSI CDM database.
--All the data in temporary schema could be inputted into the OHDSI CDM table whether there have been some data in the database or not.

set search_path = public_temp;

--3.1 Inputting 0 for the null value of the required fields.
update public_temp.condition_occurrence
set condition_start_date = '0001-01-01'
where condition_start_date is null

--3.2 Loading temporary condition_occurrence table data into OHDSI CDM.
with cte1 as
(
	select count(*) as qu from public.condition_occurrence
)
insert into public.condition_occurrence(condition_occurrence_id, person_id, condition_concept_id, 
condition_start_date, condition_type_concept_id, condition_source_value, condition_occurrence_source_id)
(select condition_occurrence_id + cte1.qu, person_id, condition_concept_id, 
condition_start_date, condition_type_concept_id, condition_source_value, condition_occurrence_source_id 
from public_temp.condition_occurrence, cte1)


