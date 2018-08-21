--Loading the measurement table data of public_temp schema to formal OHDSI CDM database.
--The public schema is the formal OHDSI CDM database.
--All the data in temporary schema could be inputted into the OHDSI CDM table whether there have been some data in the database or not.

set search_path = public_temp;

--8.1 Inputting 0 for the null value of the required fields.
update public_temp.measurement
set measurement_date = '0001-01-01'
where measurement_date is null

--8.2 Loading temporary measurement table data into OHDSI CDM.
with cte1 as
(
	select count(*) as qu from public.measurement
)
insert into public.measurement(measurement_id, person_id, measurement_concept_id,
measurement_date, measurement_type_concept_id, value_as_number,
unit_concept_id, measurement_source_value, unit_source_value, value_source_value)
(select measurement_id + cte1.qu, person_id, measurement_concept_id,
measurement_date, measurement_type_concept_id, value_as_number,
unit_concept_id, measurement_source_value, unit_source_value, value_source_value
from public_temp.measurement, cte1)

