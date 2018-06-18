--Create temporary schema to store the transformed data.
--There is no required fields in temporary schema in order to facility the data transformation.
--The OMOP schema must be built first! (The public schema in codes is the OMOP CDM schema)

--The location table in our project mainly stored the adverse event report country information.

create schema public_temp;
set search_path = public_temp;

--1. Transforming OMOP location table
drop table if exists location;
create table location as 
(select * from public.location limit 0);

truncate table location;
with cte1 as
(
	select distinct(occr_country) country
	from standard_faers.standard_demo 
	where occr_country is not null order by occr_country
),
cte2 as
(
	select row_number()OVER(order by country) as rn, country
	from cte1 
)
insert into location(location_id, location_source_value) (select * from cte2); 

