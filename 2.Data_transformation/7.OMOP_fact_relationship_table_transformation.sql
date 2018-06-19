--Create temporary schema to store the transformed data.
--There is no required fields in temporary schema in order to facility the data transformation.
--The OMOP schema must be built first! (The public schema in codes is the OMOP CDM schema)

--The fact_relationship table in our project mainly stored the drug-adverse events and drug-indication relationship.
--In order to input relationship data, the drug_exposure, observation and condition_occurrence table transformation must be conducted before this code.


create schema public_temp;
set search_path = public_temp;

--7.Transforming fact_relationship table
drop table if exists fact_relationship;
create table fact_relationship as 
(select * from public.fact_relationship limit 0);

--7.1. Input drug-adverse effects relationship
drop index if exists observation_person_id_index;
create index observation_person_id_index on observation(person_id);

drop index if exists drug_exposure_person_id_index;
create index drug_exposure_person_id_index on drug_exposure(person_id);

truncate table fact_relationship;
insert into fact_relationship(fact_id_1, fact_id_2,
domain_concept_id_1,domain_concept_id_2, relationship_concept_id)
(select a.drug_exposure_id, b.observation_id, 13, 27, 45754811 from drug_exposure a, observation b
where a.person_id = b.person_id 
and b.qualifier_concept_id = 44788367);

insert into fact_relationship(fact_id_1, fact_id_2,
domain_concept_id_1,domain_concept_id_2, relationship_concept_id)
(select b.observation_id, a.drug_exposure_id, 27, 13, 45754810 from drug_exposure a, observation b
where a.person_id = b.person_id 
and b.qualifier_concept_id = 44788367);

--7.2. Input drug-indication relationship
insert into fact_relationship(fact_id_1, fact_id_2,
domain_concept_id_1,domain_concept_id_2, relationship_concept_id)
(select a.drug_exposure_id, b.condition_occurrence_id, 13, 19, 44818734 from drug_exposure a, condition_occurrence b
where a.drug_exposure_source_id = b.condition_occurrence_source_id);

insert into fact_relationship(fact_id_1, fact_id_2,
domain_concept_id_1,domain_concept_id_2, relationship_concept_id)
(select b.condition_occurrence_id, a.drug_exposure_id, 19, 13, 44818832 from drug_exposure a, condition_occurrence b
where a.drug_exposure_source_id = b.condition_occurrence_source_id);


