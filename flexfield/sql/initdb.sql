begin;

  create schema if not exists ref;
  create schema if not exists common;
  create schema if not exists no_protocol;
  create schema if not exists wfs;

  comment on schema ref is 'Reference data from relevant authorities';
  comment on schema common is 'Users, studies, protocols and other common data';
  comment on schema no_protocol is 'Actual field data when no particular protocol is involved';
  comment on schema wfs is 'GIS layers to be served using WFS';

  -- Types

  create type role as enum ('Reader', 'Contributor', 'Collaborator', 'Manager');

  -- Tables in ref schema

  create table if not exists ref.language (
    iso_639_3 char(3) primary key,
    iso_639_1 char(2) not null
  );

  create table if not exists ref.language_name (
    id serial primary key,
    value text not null,
    language char(3) not null references ref.language,
    target_language char(3) not null references ref.language,
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
    is_active boolean not null default true,
    pictogram text not null constraint protocol_pictogram_must_not_be_empty check (pictogram != '')
  );

  comment on column common.protocol.title is 'Full protocol title, including version or date(s)';
  comment on column common.protocol.short_title is 'Protocol title to display in small places (eg. form bullet list)';

  create table if not exists common.form (
    slug text primary key constraint form_slug_must_be_lowercase_alphanumeric check (slug ~* '[a-z][a-z0-9]+'),
    title text not null constraint form_title_must_not_be_empty check (title != ''),
    short_title text not null constraint form_short_title_must_not_be_empty check (short_title != ''),
    version text not null constraint form_version_must_not_be_empty check (version != ''),
    description text not null default '',
    component_name text not null default '',
    json_model jsonb not null default '{
        "study": null,
        "protocol": null,
        "dc_title": null,
        "dc_subject": null,
        "dc_language": null,
        "dc_type": null,
        "dc_creator": null,
        "dc_date": null,
        "dc_date_created": null,
        "dc_date_modified": null,
        "dc_date_submitted": null,
        "validator": null,
        "dc_date_accepted": null,
        "dc_publisher": null,
        "dc_date_issued": null
    }'::jsonb,
    json_description jsonb not null default '{"tabs": []}'::json,
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
    form text not null references common.form on delete restrict on update cascade,
    primary key (protocol, form)
  );

  create table if not exists common.user (
    username text primary key constraint username_must_be_lowercase_alphanumeric check (username ~* '[a-z][a-z0-9]+'),
    display_name text not null constraint display_name_must_not_be_empty check (display_name != ''),
    email text not null constraint not_valid_email check (email ~* '([a-zA-Z\d.+-]+@[a-zA-Z\d-]+(\.[a-zA-Z\d-]+)+)')
  );

  create table if not exists common.group (
    slug text primary key constraint group_slug_must_be_lowercase_alphanumeric check (slug ~* '[a-z][a-z0-9]+'),
    name text not null constraint group_name_must_not_be_empty check (name != ''),
    description text not null default ''
  );

  create table if not exists common.group_membership (
    group_slug text not null references common.group on delete cascade on update cascade,
    username text not null references common.user on delete cascade on update cascade,
    primary key (group_slug, username)
  );

  create table if not exists common.study_group_role (
    study varchar(15) not null references common.study on delete restrict on update cascade,
    group_slug text not null references common.group on delete restrict on update cascade,
    role role not null,
    primary key (study, group_slug)
  );

  create table if not exists common.form_allowed_geometries (
    form text not null references common.form on delete restrict on update cascade,
    geometry varchar(10) not null constraint not_a_known_geometry_type check (geometry in ('Point', 'LineString', 'Polygon')),
    primary key (form, geometry)
  );

  -- Procedures and functions for triggers

  create or replace function geomfromjsonb (json_geom jsonb)
    returns geometry
    language plpgsql
  as $$
  begin
    return st_setsrid(st_geomfromgeojson(json_geom::text), 4326);
  end;
  $$;

  create or replace function tg_add_missing_metadata ()
    returns trigger
    language plpgsql
  as $$
  begin
    if NEW.properties->>'dc_date_created' is null or NEW.properties->>'dc_date_created' = '' then
      NEW.properties := jsonb_set(NEW.properties, '{dc_date_created}', to_jsonb(now()));
    end if;
    if NEW.properties->>'dc_type' is null or NEW.properties->>'dc_type' = '' then
      NEW.properties := jsonb_set(NEW.properties, '{dc_type}', to_jsonb('event'::text));
    end if;
    return NEW;
  end;
  $$;

  create or replace function tg_done ()
    returns trigger
    language plpgsql
  as $$
  begin
    return null;
  end;
  $$;

  create or replace function tg_insert_row_in_table ()
    returns trigger
    language plpgsql
  as $$
  declare
    new_id uuid;
    new_data jsonb;
    target text;
  begin
    target := format('%s.%s', TG_ARGV[0], TG_ARGV[1]);
    new_id := uuid_generate_v4();
    new_data := NEW.properties;
    new_data := jsonb_set(new_data, '{geometry}', to_jsonb(geomfromjsonb(NEW.geometry)));
    new_data := jsonb_set(new_data, '{id}', to_jsonb(new_id));
    NEW.id := new_id;
    execute format('insert into %s select * from jsonb_populate_record(null::%s, ''%s'')', target, target, new_data);
    return NEW;  -- Return the feature with its new id so that other inserts can be performed (eg. in other tables)
  end;
  $$;

  create or replace function tg_update_date_modified ()
    returns trigger
    language plpgsql
  as $$
  begin
    NEW.dc_date_modified := now();
    return NEW;
  end;
  $$;

  create or replace function tg_update_row_in_table ()
    returns trigger
    language plpgsql
  as $$
  declare
    id uuid;
    key text;
    new_geometry geometry;
    new_properties jsonb;
    new_value text;
    old_geometry geometry;
    old_properties jsonb;
    old_value text;
    target_schema text;
    target_table text;
  begin
    target_schema := TG_ARGV[0];
    target_table := TG_ARGV[1];
    id := NEW.id;
    new_properties := NEW.properties;
    old_properties := OLD.properties;
    for key, new_value in select * from jsonb_each_text(new_properties) loop
      if (key not in (select column_name from information_schema.columns where table_schema = target_schema and table_name = target_table)) or (key = 'dc_date_modified') then
        continue;
      end if;
      old_value := old_properties->>key;
      if (old_value = new_value) or (old_value is null and new_value is null) then
        continue;
      end if;
      execute format('update %s.%s set %s = ''%s'' where id = ''%s''', target_schema, target_table, key, new_value, id);
    end loop;
    new_geometry := geomfromjsonb(NEW.geometry);
    old_geometry := geomfromjsonb(OLD.geometry);
    if not st_equals(old_geometry, new_geometry) then
        execute format('update %s.%s set geometry = ''%s'' where id = ''%s''', target_schema, target_table, new_geometry, id);
      end if;
    return NEW;
  end;
  $$;

commit;
