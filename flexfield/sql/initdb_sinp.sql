begin;

  -- Tables in ref schema

  create table if not exists ref.taxonomic_rank (
    taxref_code varchar(4) primary key constraint rank_code_must_not_be_empty check (taxref_code != ''),
    in_simplified_taxonomy bool not null default false
  );

  create table if not exists ref.taxonomic_rank_name (
    id serial primary key,
    value text not null constraint rank_name_must_not_be_empty check (value != ''),
    language char(3) not null references ref.language_code on delete cascade on update cascade,
    taxonomic_rank varchar(4) not null references ref.taxonomic_rank on delete cascade on update cascade
  );

  create table if not exists ref.taxref_habitat (
    taxref_id int primary key constraint taxref_id_must_be_positive check (taxref_id > 0),
    name text not null constraint habitat_name_must_not_be_empty check (name != ''),
    language char(3) not null references ref.language_code on delete cascade on update cascade,
    comments text not null default ''
  );

  create table if not exists ref.species_database_range (
    taxref_code char(3) primary key constraint database_range_code_must_not_be_empty check (taxref_code != '')
  );

  create table if not exists ref.species_database_range_name (
    id serial primary key,
    value text not null constraint database_range_name_must_not_be_empty check (value != ''),
    language char(3) not null references ref.language_code on delete cascade on update cascade,
    species_database_range char(3) not null references ref.species_database_range on delete cascade on update cascade
  );

  create table if not exists ref.species_database (
    name varchar(64) primary key constraint database_code_must_not_be_empty check (name != ''),
    range char(3) references ref.species_database_range on delete restrict on update cascade,
    title text not null constraint database_title_must_not_be_empty check (title != ''),
    url text not null default ''
  );

  create table if not exists ref.taxon (
    taxref_id int primary key constraint taxref_id_must_be_positive check (taxref_id > 0),
    parent_taxon int references ref.taxon on delete cascade on update cascade deferrable,
    taxonomic_rank varchar(4) references ref.taxonomic_rank on delete restrict on update cascade,
    taxref_habitat int references ref.taxref_habitat on delete restrict on update cascade
  );

  create table if not exists ref.scientific_name (
    taxref_id int primary key constraint taxref_id_must_be_positive check (taxref_id > 0),
    value text not null constraint scientific_name_value_must_not_be_empty check (value != ''),
    html_value text not null default '',
    binomial text not null constraint binomial_name_must_not_be_empty check (binomial != ''),
    authority text not null,
    taxon int not null references ref.taxon on delete cascade on update cascade,
    is_preferred bool not null default false
  );

  create table if not exists ref.scientific_name_source (
    scientific_name int not null references ref.scientific_name on delete cascade on update cascade,
    database varchar(64) not null references ref.species_database on delete cascade on update cascade,
    scientific_name_database_url text not null default '',
    scientific_name_database_id text
  );

  create table if not exists ref.common_name (
    id serial primary key,
    value text not null constraint common_name_must_not_be_empty check (value != ''),
    language char(3) not null references ref.language_code on delete cascade on update cascade,
    taxon int not null references ref.taxon on delete cascade on update cascade,
    comments text not null default ''
  );

  create table if not exists ref.data_type (
    code varchar(3) primary key,
    title text not null constraint data_type_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.presence_type (
    code varchar(3) primary key,
    title text not null constraint presence_type_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.subject_type (
    code varchar(4) primary key,
    title text not null constraint subject_type_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.living_status (
    code smallint primary key,
    title text not null constraint living_status_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.domestication_status (
    code smallint primary key,
    title text not null constraint domestication_status_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.gender (
    code smallint primary key,
    title text not null constraint gender_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.age (
    code smallint primary key,
    title text not null constraint age_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.biogeographical_status (
    code smallint primary key,
    title text not null constraint biogeographical_status_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.habitat_reference (
    code varchar(30) primary key,
    title text not null constraint habitat_reference_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.biological_status (
    code smallint primary key,
    title text not null constraint biological_status_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.observation_method (
    code smallint primary key,
    title text not null constraint observation_method_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.evidence (
    code smallint primary key,
    title text not null constraint evidence_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.blur_level (
    code smallint primary key,
    title text not null constraint blur_level_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.presence (
    code varchar(3) primary key,
    title text not null constraint presence_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.data_source (
    code varchar(3) primary key,
    title text not null constraint data_source_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.count_method (
    code varchar(3) primary key,
    title text not null constraint count_method_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.georeferencing_type (
    code smallint primary key,
    title text not null constraint georeferencing_type_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.merging_type (
    code varchar(6) primary key,
    title text not null constraint merging_type_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

  create table if not exists ref.waterbody_ref_version (
    code smallint primary key,
    title text not null constraint waterbody_ref_version_title_must_not_be_empty check (title != ''),
    description text not null default ''
  );

commit;
