begin;

  \set epsg_code 2154

  -- Schemas

  create schema if not exists orchidaceae;

  comment on schema orchidaceae is 'Données concernant l''atlas des orchidées d''Ariège';

  -- Tables

  create table if not exists orchidaceae.orchid_group (
    id varchar(63) primary key,
    name text not null constraint orchid_group_name_cannot_be_empty check (name != '')
  );

  comment on table orchidaceae.orchid_group is 'Groupe d''orchidées';

  create table if not exists orchidaceae.taxon_group (
    taxon integer not null references ref.taxon on delete restrict on update cascade,
    orchid_group varchar(63) not null references orchidaceae.orchid_group on delete restrict on update cascade
  );

  comment on table orchidaceae.taxon_group is 'Relie une espèce d''orchidées à un groupe';

  create table if not exists orchidaceae.observation (
    id uuid default uuid_generate_v4() primary key,
    study varchar(15) references common.study on delete cascade on update cascade,
    protocol varchar(15) references common.protocol on delete cascade on update cascade,
    observation_date date not null,
    orchid_group varchar(63) not null references orchidaceae.orchid_group on delete restrict on update cascade,
    taxon int references ref.taxon on delete restrict on update cascade,
    quoted_name text not null default '',
    count_range int4range not null default '[1, 5]',
    has_abnormalities boolean not null default false,
    with_hypochromy boolean not null default false,
    evidence_url text not null default '',
    comments text not null default '',
    geometry geometry(Point, 4326) not null,
    -- metadata
    dc_title varchar(250) not null constraint title_cannot_be_empty check (dc_title != ''),
    dc_date_created timestamp not null,
    dc_date_modified timestamp not null,
    dc_date_submitted date,
    dc_date_accepted date,
    dc_date_issued date,
    dc_creator text not null constraint creator_cannot_be_empty check (dc_creator != ''),
    validator text constraint validator_cannot_be_empty check (validator != ''),
    dc_publisher text not null default '',
    dc_language text not null references ref.language,
    dc_type text not null constraint type_cannot_be_empty check (dc_type != '')
  );

  comment on table orchidaceae.observation is 'Observations d''orchidées';

  create table if not exists orchidaceae.observer (
    observation uuid not null references orchidaceae.observation on delete restrict on update cascade,
    name text not null constraint observer_name_cannot_be_empty check (name != ''),
    primary key (observation, name)
  );

  comment on table orchidaceae.observer is 'Relie une observation à ses observateurs';

  -- Views

  create or replace view orchidaceae.observation_view as (
    with obs_observer(id, array_names, names) as (
      select obs.id, array_agg(observer.name), string_agg(observer.name, ', ')
        from orchidaceae.observation as obs
        left join orchidaceae.observer as observer on observer.observation = obs.id
        group by obs.id
    )
    select obs.id,
        st.short_title as study,
        prot.short_title as protocol,
        obs.observation_date,
        array_to_json(obs_observer.array_names) as observers,
        obs_observer.names as observer_names,
        obs.orchid_group,
        grp.name as orchid_group_name,
        obs.taxon,
        sciname.value as taxon_name,
        obs.quoted_name,
        obs.count_range,
        lower(obs.count_range) as count_min,
        upper(obs.count_range) - 1 as count_max,
        obs.has_abnormalities,
        obs.with_hypochromy,
        obs.evidence_url,
        obs.comments,
        st_asgeojson(obs.geometry) as geometry,
        st_astext(st_transform(obs.geometry, :epsg_code)) as wfs_geometry,
        obs.dc_title,
        obs.dc_date_created,
        obs.dc_date_modified,
        obs.dc_date_submitted,
        obs.dc_date_accepted,
        obs.dc_date_issued,
        obs.dc_creator,
        obs.validator,
        obs.dc_publisher,
        obs.dc_language,
        obs.dc_type
      from orchidaceae.observation as obs
      left join obs_observer on obs_observer.id = obs.id
      left join common.study as st on st.code = obs.study
      left join common.protocol as prot on prot.code = obs.protocol
      left join orchidaceae.orchid_group as grp on grp.id = obs.orchid_group
      left join ref.scientific_name as sciname on sciname.taxon = obs.taxon and sciname.is_preferred = true
  );

  comment on view orchidaceae.observation_view is 'View to be modified to edit main table';

  create materialized view if not exists wfs.orchidaceae as
  select obs.id as id,
      obs.study as etude,
      obs.protocol as protocole,
      obs.observation_date as date_obs,
      obs.observer_names as observateurs,
      obs.orchid_group_name as groupe,
      obs.taxon as id_taxref,
      obs.taxon_name as nom_sci,
      obs.quoted_name as nom_cite,
      obs.count_min as eff_min,
      obs.count_max as eff_max,
      obs.has_abnormalities as lusus,
      obs.with_hypochromy as hypochromie,
      obs.evidence_url as url_preuve,
      obs.comments as remarques,
      obs.dc_date_created as date_creation,
      obs.dc_date_modified as date_modification,
      obs.dc_date_submitted as date_soumission,
      obs.dc_date_accepted as date_validation,
      obs.dc_date_issued as date_publication,
      obs.dc_creator as numerisateur,
      obs.validator as validateur,
      obs.wfs_geometry as geometry
    from orchidaceae.observation_view as obs
    order by date_obs asc;

  comment on materialized view wfs.orchidaceae is 'To be served via WFS';

  -- Triggers

  create or replace function tg_orchidaceae_add_missing_data ()
    returns trigger
    language plpgsql
  as $$
  declare
  begin
    NEW.geometry := st_setsrid(st_geomfromgeojson(NEW.geometry), 4326);
    -- Metadata
    if NEW.id is null then  -- Generate UUID
      NEW.id := uuid_generate_v4();
    end if;
    if NEW.dc_date_created is null then
      NEW.dc_date_created := now();
    end if;
    if NEW.dc_date_modified is null then
      NEW.dc_date_modified := now();
    end if;
    if NEW.dc_publisher is null then
      NEW.dc_publisher := '';
    end if;
    if NEW.dc_type is null then
      NEW.dc_type := 'event';
    end if;
    -- Other data
    if NEW.quoted_name is null then
      NEW.quoted_name := '';
    end if;
    -- Populate observers
    with obs(id) as (
      insert into orchidaceae.observation
      select * from json_populate_record(null::orchidaceae.observation, row_to_json(NEW))
      returning id
    )
    insert into orchidaceae.observer
    select obs.id, observer.name
    FROM obs, (select json_array_elements_text(NEW.observers) AS name) as observer;
    -- TODO: Populate subject : | obs_id | taxon_name |
    return null;
  end;
  $$;

  drop trigger if exists orchidaceae_add_missing_data on orchidaceae.observation_view;
  drop trigger if exists orchidaceae_update_date_modified on orchidaceae.observation;

  create trigger orchidaceae_add_missing_data
  instead of insert
  on orchidaceae.observation_view
  for each row
    execute procedure tg_orchidaceae_add_missing_data();

  create trigger orchidaceae_update_date_modified
  before update
  on orchidaceae.observation
  for each row
    execute procedure tg_update_date_modified();

commit;
