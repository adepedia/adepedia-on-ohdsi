--Loading the drug_exposure table data of public_temp schema to formal OHDSI CDM database.
--The public schema is the formal OHDSI CDM database.
--All the data in temporary schema could be inputted into the OHDSI CDM table whether there have been some data in the database or not.

set search_path = public_temp;

--5.1 Inputting 0 for the null value of the required fields.
update public_temp.drug_exposure
set drug_concept_id = 0
where drug_concept_id is null

update public_temp.drug_exposure
set drug_exposure_start_date = '0001-01-01'
where drug_exposure_start_date is null

update public_temp.drug_exposure
set drug_exposure_end_date = '0001-01-01'
where drug_exposure_end_date is null

--5.2 Loading temporary drug_exposure table data into OHDSI CDM.
--50 characters are not enough for the field "lot_number" and "drug_source_value", so we change the field type to varchar(variable unlimited length).
alter table public.drug_exposure alter lot_number type varchar;
alter table public.drug_exposure alter drug_source_value type varchar;

with cte1 as
(
	select count(*) as qu from public.drug_exposure
)
insert into public.drug_exposure(drug_exposure_id, person_id, drug_concept_id, 
drug_exposure_start_date, drug_exposure_end_date, drug_type_concept_id, 
days_supply, route_concept_id, lot_number, 
drug_source_value, route_source_value, dose_unit_source_value)
(select drug_exposure_id + cte1.qu, person_id, drug_concept_id, 
drug_exposure_start_date, drug_exposure_end_date, drug_type_concept_id, 
days_supply, route_concept_id, lot_number, 
drug_source_value, route_source_value, dose_unit_source_value 
from public_temp.drug_exposure, cte1)

