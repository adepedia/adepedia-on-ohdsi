--Loading the fact_relationship table data of public_temp schema to formal OHDSI CDM database.
--The public schema is the formal OHDSI CDM database.
--All the data in temporary schema could be inputted into the OHDSI CDM table whether there have been some data in the database or not.

set search_path = public_temp;

--7.1 Loading temporary fact_relationship table data into OHDSI CDM.
insert into public.fact_relationship(domain_concept_id_1, fact_id_1, domain_concept_id_2,
fact_id_2, relationship_concept_id)
(select domain_concept_id_1, fact_id_1, domain_concept_id_2,
fact_id_2, relationship_concept_id
from public_temp.fact_relationship)