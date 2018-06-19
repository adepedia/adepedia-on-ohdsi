--Create temporary schema to store the transformed data.
--There is no required fields in temporary schema in order to facility the data transformation.
--The OMOP schema must be built first! (The public schema in codes is the OMOP CDM schema)

--The drug_exposure table in our project mainly stored the drug use information of the patient.

create schema public_temp;
set search_path = public_temp;

--5. Transforming drug_exposure table
--5.1. Create drug_exposure table
--We use "primaryid" + "drug_seq" in FAERS to represent drug_exposure_source_id, but the string length exceed the range of int, so we change the type of drug_exposure_source_id into bigint，
--50 characters are not enough for the field "lot_number" and "drug_source_value", so we change the field type to varchar(variable unlimited length).

drop table if exists drug_exposure;
create table drug_exposure as 
(select * from public.drug_exposure limit 0);

drop sequence if exists drug_exposure_id_seq;
create sequence drug_exposure_id_seq
    start with 1
    increment by 1
    no minvalue
    no maxvalue
    cache 1;

alter table drug_exposure alter column drug_exposure_id set default nextval('drug_exposure_id_seq');
alter table drug_exposure add column drug_exposure_source_id bigint;
alter table drug_exposure alter lot_number type varchar;
alter table drug_exposure alter drug_source_value type varchar;

--5.2. Normalize route_concept_id
alter table standard_faers.standard_drug add column route_temp int;

update standard_faers.standard_drug a 
set route_temp = 
	case when a.route = 'Auricular (otic)' then 4023156
	when a.route = 'INTRA-AURAL' then 4023156
	when a.route = 'BUCCAL' then 4181897
	when a.route = 'Buccal' then 4181897
	when a.route = 'CUTANEOUS' then 4263689
	when a.route = 'Cutaneous' then 4263689
	when a.route = 'Dental' then 4163765
	when a.route = 'DENTAL' then 4163765
	when a.route = 'ENDOCERVICAL' then 4186831
	when a.route = 'Endocervical' then 4186831
	when a.route = 'Endotracheal' then 4186832
	when a.route = 'ENDOTRACHEAL' then 4186832
	when a.route = 'Epidural' then 4225555
	when a.route = 'EPIDURAL' then 4225555
	when a.route = 'EXTRA-AMNIOTIC' then 4186833
	when a.route = 'GASTROSTOMY TUBE' then 4186834
	when a.route = 'HEMODIALYSIS' then 4228125
	when a.route = 'Hemodialysis' then 4228125
	when a.route = 'INHALATION' then 4011083
	when a.route = 'Respiratory (inhalation)' then 4011083
	when a.route = 'Intra-amniotic' then 4163767
	when a.route = 'INTRA-AMNIOTIC' then 4163767
	when a.route = 'INTRA-ARTERIAL' then 4240824
	when a.route = 'Intra-arterial' then 4240824
	when a.route = 'INTRA-ARTICULAR' then 4006860
	when a.route = 'Intra-articular' then 4006860
	when a.route = 'INTRA-BURSAL' then 4163768
	when a.route = 'Intra-uterine' then 4269621
	when a.route = 'INTRAUTERINE' then 4269621
	when a.route = 'INTRACARDIAC' then 4156705
	when a.route = 'Intracardiac' then 4156705
	when a.route = 'INTRACAVERNOSA' then 4157757
	when a.route = 'Intracavernous' then 4157757
	when a.route = 'Intracervical' then 4186835
	when a.route = 'INTRA-CERVICAL' then 4186835
	when a.route = 'Intracoronary' then 4186836
	when a.route = 'INTRACORONARY' then 4186836
	when a.route = 'Intradermal' then 4156706
	when a.route = 'INTRADERMAL' then 4156706
	when a.route = 'INTRADISCAL' then 4163769
	when a.route = 'Intradiscal (intraspinal)' then 4163769
	when a.route = 'Intralesional' then 4157758
	when a.route = 'Intralymphatic' then 4157759
	when a.route = 'INTRALYMPHATIC' then 4157759
	when a.route = 'INTRAMUSCULAR' then 4302612
	when a.route = 'Intramuscular' then 4302612
	when a.route = 'INTRAOCULAR' then 4157760
	when a.route = 'Intraocular' then 4157760
	when a.route = 'Intraperitoneal' then 4243022
	when a.route = 'INTRAPERITONEAL' then 4243022
	when a.route = 'INTRAPLEURAL' then 4156707
	when a.route = 'Intrapleural' then 4156707
	when a.route = 'INTRATHECAL' then 4217202
	when a.route = 'Intrathecal' then 4217202
	when a.route = 'INTRAVENOUS' then 4112421
	when a.route = 'INTRAVENOUS DRIP' then 4112421
	when a.route = 'Intravenous drip' then 4112421
	when a.route = 'Intravenous bolus' then 4112421
	when a.route = 'INTRAVENOUS BOLUS' then 4112421
	when a.route = 'Intravenous (not otherwise specified)' then 4112421
	when a.route = 'INTRAVENTRICULAR' then 4222259
	when a.route = 'INTRAVESICAL' then 4186838
	when a.route = 'Intravesical' then 4186838
	when a.route = 'Iontophoresis' then 4302956
	when a.route = 'IONTOPHORESIS' then 4302956
	when a.route = 'NASAL' then 4128792
	when a.route = 'Nasal' then 4128792
	when a.route = 'ORAL' then 4128794
	when a.route = 'Oral' then 4128794
	when a.route = 'PARENTERAL' then 40491411
	when a.route = 'Parenteral' then 40491411
	when a.route = 'PERIARTICULAR' then 4156708
	when a.route = 'Periarticular' then 4156708
	when a.route = 'PERINEURAL' then 4157761
	when a.route = 'Perineural' then 4157761
	when a.route = 'RECTAL' then 4115462
	when a.route = 'Rectal' then 4115462
	when a.route = 'SUBCONJUNCTIVAL' then 4163770
	when a.route = 'Sunconjunctival' then 4163770
	when a.route = 'Subcutaneous' then 4139962
	when a.route = 'SUBCUTANEOUS' then 4139962
	when a.route = 'SUBLINGUAL' then 4292110
	when a.route = 'Sublingual' then 4292110
	when a.route = 'Topical' then 4231622
	when a.route = 'TOPICAL' then 4231622
	when a.route = 'Transdermal' then 4262099
	when a.route = 'TRANSDERMAL' then 4262099
	when a.route = 'URETHRAL' then 4233974
	when a.route = 'Urethral' then 4233974
	when a.route = 'VAGINAL' then 4057765
	when a.route = 'Vaginal' then 4057765
	else null
	end
where a.route is not null;

--5.3. Input value to drug_exposure table
truncate table drug_exposure;
insert into drug_exposure
(drug_exposure_source_id, person_id, drug_concept_id, lot_number, drug_source_value, route_source_value, dose_unit_source_value,
drug_type_concept_id, route_concept_id)
(select cast((primaryid || drug_seq) as bigint), 
 cast(caseid as int), 
 standard_concept_id,
 lot_num,
 drugname,
 route,
 dose_unit,
 '44787730',
 route_temp
from standard_faers.standard_drug);

--5.4. Input drug_exposure_start_date and drug_exposure_end_date
--The execution time of these codes are about 10 mins
alter table standard_faers.standard_ther
add column drug_exposure_id bigint;

update standard_faers.standard_ther
set drug_exposure_id = cast((primaryid || dsg_drug_seq) as bigint);

drop index if exists standard_faers.standard_ther_index;
create index standard_ther_index on standard_faers.standard_ther(drug_exposure_id);

with cte1 as
(
	select drug_exposure_id, to_date(start_dt,'YYYYMMDD') as stdt, to_date(end_dt,'YYYYMMDD') as enddt, 
	row_number()over(partition by drug_exposure_id order by start_dt) as rn
	from standard_faers.standard_ther a where a.start_dt is not null or a.end_dt is not null
)
update drug_exposure a 
set drug_exposure_start_date = cte1.stdt,
    drug_exposure_end_date = cte1.enddt
from cte1
where cte1.drug_exposure_id = a.drug_exposure_source_id and cte1.rn = 1;

--5.5. Impute the days_supply value
--Calculate the days of supply of the medication if both drug_exposure_start_date and drug_exposure_end_date values are not null
update drug_exposure 
set days_supply = (drug_exposure_end_date - drug_exposure_start_date + 1)
where drug_exposure_start_date is not null and drug_exposure_end_date is not null

--Input the days of supply of the medication value from FAERS therapy table if either drug_exposure_start_date or drug_exposure_end_date is null
--Formatting dur and dur_cod value
alter table standard_faers.standard_ther
add column dur_cod_temp varchar;

alter table standard_faers.standard_ther
add column dur_temp varchar;

alter table standard_faers.standard_ther
add column days_supply int;

update standard_faers.standard_ther
set dur_cod_temp = trim(dur_cod)
where dur_cod is not null;

update standard_faers.standard_ther
set dur_cod_temp = 
	case when dur_cod_temp ~ '^Y$' then 'YR'
	when dur_cod_temp ~ '^YEAR' then 'YR'
	when dur_cod_temp ~ '^YR' then 'YR'
	when dur_cod_temp ~ '^MO' then 'MON'
	when dur_cod_temp ~ '^WEEK' then 'WK'
	when dur_cod_temp ~ '^WK' then 'WK'	
	when dur_cod_temp ~ '^DA' then 'DAY'
	when dur_cod_temp ~ '^D$' then 'DAY'
	when dur_cod_temp ~ '^HR' then 'HR'
	when dur_cod_temp ~ '^HOUR' then 'HR'
	when dur_cod_temp ~ '^MIN' then 'MIN'
	when dur_cod_temp ~ '^SEC' then 'SEC'
	else dur_cod_temp
	end
where dur_cod_temp is not null;

update standard_faers.standard_ther
set dur_temp = dur
where dur is not null

update standard_faers.standard_ther
set dur_temp = 
	case when dur_temp ~ '\>' then regexp_replace(dur_temp, '\>', '')
	when dur_temp ~'\<' then regexp_replace(dur_temp, '\<', '')
	else dur_temp
	end
where dur_temp is not null and (dur_temp ~ '\>' or dur_temp ~ '\<');

update standard_faers.standard_ther
set dur_temp = regexp_replace(dur_temp, '\t', '')
where dur_temp ~ '\t';

update standard_faers.standard_ther 
set dur_temp = 
	case when dur_temp ~ '^[0-9]\-[0-9]$' then to_char((to_number(dur_temp,'9') + to_number(dur_temp,'  9')) / 2, '999D99')
	when dur_temp ~ '^[0-9]\-[0-9][0-9]$' then to_char((to_number(dur_temp,'9') + to_number(dur_temp,'  99')) / 2, '999D99')
	when dur_temp ~ '^[0-9][0-9]\-[0-9][0-9]$' then to_char((to_number(dur_temp,'99') + to_number(dur_temp,'   99')) / 2, '999D99')
	when dur_temp ~ '^[0-9]\.[0-9]\-[0-9]$' then to_char((to_number(dur_temp,'9D9') + to_number(dur_temp,'    9')) / 2, '999D99')
	when dur_temp ~ '^[0-9]\-[0-9]\.[0-9]$' then to_char((to_number(dur_temp,'9') + to_number(dur_temp,'  9D9')) / 2, '999D99')
	else dur_temp
	end
where dur_temp ~ '\-';

update standard_faers.standard_ther
set dur_temp = trim(dur_temp)
where dur_temp is not null;

update standard_faers.standard_ther
set days_supply = 
	case when dur_cod_temp = 'YR' then cast(dur_temp as numeric) * 365
	when dur_cod_temp = 'MON' then cast(dur_temp as numeric) * 30
	when dur_cod_temp = 'WK' then cast(dur_temp as numeric) * 7
	when dur_cod_temp = 'HR' then cast(dur_temp as numeric) / 24
	when dur_cod_temp = 'MIN' then cast(dur_temp as numeric) / 1440
	when dur_cod_temp = 'SEC' then cast(dur_temp as numeric) / 86400
	else null
	end
where dur_temp is not null and (dur_temp ~ '^[0-9]+$' or dur_temp ~ '^[0-9]+\.[0-9]+$');

update drug_exposure a
set days_supply = b.days_supply
from standard_faers.standard_ther b
where a.drug_exposure_source_id = b.drug_exposure_id
and (a.drug_exposure_start_date is null or a.drug_exposure_end_date is null)
and b.days_supply is not null;

--Alter the minimun days of supply of the medication to 1 day.
update drug_exposure
set days_supply = 1
where days_supply = 0;


