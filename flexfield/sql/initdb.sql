begin;

  create schema if not exists ref;
  create schema if not exists common;
  create schema if not exists no_protocol;
  create schema if not exists wfs;

  comment on schema ref is 'Reference data from relevant authorities';
  comment on schema common is 'Users, studies, protocols and other common data';
  comment on schema no_protocol is 'Actual field data when no particular protocol is involved';
  comment on schema wfs is 'GIS layers to be served using WFS';

  -- Tables in ref schema

  create table if not exists ref.language (
    iso_639_3 char(3) primary key,
    iso_639_1 char(2) not null
  );

  create table if not exists ref.language_name (
    id serial primary key,
    value text not null,
    language char(3) not null references ref.language_code,
    target_language char(3) not null references ref.language_code,
    is_original bool not null
  );

  -- Tables in common schema

  create table if not exists common.study (
    code varchar(15) primary key constraint study_code_must_be_uppercase_alphanumeric check (code ~* '[A-Z][A-Z0-9]+'),
    title text not null constraint study_title_must_not_be_empty check (title != ''),
    short_title text not null constraint study_short_title_must_not_be_empty check (short_title != ''),
    dates daterange not null,
    description text not null default '',
    pictogram text not null constraint study_pictogram_must_not_be_empty check (pictogram != ''),
    is_public boolean not null default true,
    allow_no_protocol boolean not null default false,
    is_active boolean not null default true,
    perimeter geometry(MultiPolygon, 4326)
  );

  comment on column common.study.title is 'Full study title, including version or date(s)';
  comment on column common.study.short_title is 'Study title to display in small places (eg. form bullet list)';

  create table if not exists common.protocol (
    code varchar(15) primary key constraint protocol_code_must_be_uppercase_alphanumeric check (code ~* '[A-Z][A-Z0-9]+'),
    title text not null constraint protocol_title_must_not_be_empty check (title != ''),
    short_title text not null constraint protocol_short_title_must_not_be_empty check (short_title != ''),
    version text not null constraint protocol_version_must_not_be_empty check (version != ''),
    description text not null default '',
    is_public boolean not null default true,
    is_active boolean not null default true,
    pictogram text not null constraint protocol_pictogram_must_not_be_empty check (pictogram != '')
  );

  comment on column common.protocol.title is 'Full protocol title, including version or date(s)';
  comment on column common.protocol.short_title is 'Protocol title to display in small places (eg. form bullet list)';

  create table if not exists common.form (
    code varchar(15) primary key constraint form_code_must_be_uppercase_alphanumeric check (code ~* '[A-Z][A-Z0-9]+'),
    title text not null constraint form_title_must_not_be_empty check (title != ''),
    short_title text not null constraint form_short_title_must_not_be_empty check (short_title != ''),
    version text not null constraint form_version_must_not_be_empty check (version != ''),
    description text not null default '',
    component_name text not null default '',
    json_description jsonb default '{"tabs": []}'::json,
    allow_no_protocol boolean not null default false,
    is_active boolean not null default true,
    pictogram text not null constraint form_pictogram_must_not_be_empty check (pictogram != '')
    constraint one_of_component_name_or_json_description_must_be_given check (component_name != '' or json_description is not null)
  );

  comment on column common.form.title is 'Full form title, including version or date(s)';
  comment on column common.form.short_title is 'Form title to display in small places (eg. form bullet list)';

  create table if not exists common.study_protocol (
    study varchar(15) not null references common.study on delete restrict on update cascade,
    protocol varchar(15) not null references common.protocol on delete restrict on update cascade,
    primary key (study, protocol)
  );

  create table if not exists common.protocol_form (
    protocol varchar(15) not null references common.protocol on delete restrict on update cascade,
    form varchar(15) not null references common.form on delete restrict on update cascade,
    primary key (protocol, form)
  );

  create table if not exists common.user_authorized_studies (
    username text not null constraint username_must_not_be_empty check (username != ''),
    study varchar(15) not null references common.study on delete restrict on update cascade,
    primary key (username, study)
  );

  create table if not exists common.user_authorized_protocols (
    username text not null constraint username_must_not_be_empty check (username != ''),
    protocol varchar(15) not null references common.protocol on delete restrict on update cascade,
    primary key (username, protocol)
  );

  create table if not exists common.form_allowed_geometries (
    form varchar(15) not null references common.form on delete restrict on update cascade,
    geometry varchar(10) not null constraint not_a_known_geometry_type check (geometry in ('Point', 'LineString', 'Polygon')),
    primary key (form, geometry)
  );

commit;