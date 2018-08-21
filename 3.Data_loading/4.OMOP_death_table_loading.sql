--Loading the death table data of public_temp schema to formal OHDSI CDM database.
--The public schema is the formal OHDSI CDM database.
--All the data in temporary schema could be inputted into the OHDSI CDM table whether there have been some data in the database or not.

set search_path = public_temp;

--4.1 Inputting 0 for the null value of the required fields.
update public_temp.death
set death_date = '0001-01-01'
where death_date is null

--4.2 Loading temporary death table data into OHDSI CDM.
insert into public.death(person_id, death_date, death_type_concept_id)
(select person_id, death_date, death_type_concept_id
from public_temp.death)

