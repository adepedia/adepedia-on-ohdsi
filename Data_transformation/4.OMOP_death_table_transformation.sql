--Create temporary schema to store the transformed data.
--There is no required fields in temporary schema in order to facility the data transformation.
--The OMOP schema must be built first! (The public schema in codes is the OMOP CDM schema)

--The death table in our project mainly stored the death information of the patient.

create schema public_temp;
set search_path = public_temp;

--4. Transforming death table
--4.1. Input person_id and death_type_concept_id
drop table if exists death;
create table death as 
(select * from public.death limit 0);

truncate table death;
insert into death(person_id, death_type_concept_id) 
(select cast(caseid as int), '38003566' from standard_faers.standard_outc where outc_code = 'DE');

--4.2. Impute death_date (The last end date of the therapy for a death patient will be seen as the death date)
with cte1 as
(
	select cast(caseid as int) as rnid,to_date(end_dt,'YYYYMMDD') as dt, row_number()over(partition by caseid order by end_dt desc) as rn
	from standard_faers.standard_ther a where a.end_dt is not null
)
update death a 
set death_date = cte1.dt
from cte1
where cte1.rnid = a.person_id and cte1.rn = 1;

