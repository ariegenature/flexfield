begin;

  \set epsg_code 2154

  -- Schemas

  create schema if not exists abc_montbel;

  comment on schema abc_montbel is 'Données concernant l''atlas de la biodiversité communale autour du lac de Montbel';

  -- Tables

  create table abc_montbel.grid (
    id smallint primary key,
    geometry geometry(Polygon, 4326) not null
  );

  comment on table abc_montbel.grid is 'Maillage du périmètre de l''étude';

  create table abc_montbel.observation (
    id uuid default uuid_generate_v4() primary key,
    study varchar(15) references common.study on delete cascade on update cascade,
    protocol varchar(15) references common.protocol on delete cascade on update cascade,
    observation_date date not null,
    taxon int not null references ref.taxon on delete cascade on update cascade,
    quoted_name text not null default '',
    observation_method int references ref.observation_method on delete cascade on update cascade,
    count_range int4range not null default '[1, 1]',
    count_method varchar(3) not null references ref.count_method on delete cascade on update cascade,
    picture_id text not null default '',
    is_confident boolean,
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

  comment on table abc_montbel.observation is 'Observations réalisées lors des inventaires';

  create table abc_montbel.observer (
    observation uuid not null references abc_montbel.observation on delete cascade on update cascade,
    name text not null constraint observer_name_cannot_be_empty check (name != ''),
    primary key (observation, name)
  );

  comment on table abc_montbel.observer is 'Relie une observation à ses observateurs';

  -- Views

  create or replace view abc_montbel.observation_updatable_view as (
    with obs_observer(id, array_names, names) as (
      select obs.id, array_agg(observer.name), string_agg(observer.name, ', ')
        from abc_montbel.observation as obs
        left join abc_montbel.observer as observer on observer.observation = obs.id
        group by obs.id
    )
    select obs.id,
        obs.study,
        st.short_title as study_title,
        obs.protocol,
        prot.short_title as protocol_title,
        obs.observation_date,
        array_to_json(obs_observer.array_names) as observers,  -- this is why we need an updatable view
        obs_observer.names as observer_names,  -- this is also why we need an updatable view
        obs.taxon,
        sciname.value as taxon_name,
        obs.quoted_name,
        obs.observation_method,
        obsmeth.title as observation_method_name,
        obs.count_range,
        lower(obs.count_range) as count_min, -- this is also why we need an updatable view
        upper(obs.count_range) - 1 as count_max, -- this is also why we need an updatable view
        obs.count_method,
        cntmeth.title as count_method_name,
        case obs.picture_id
          when '' then false
          else true
        end as has_picture,
        obs.picture_id,
        obs.is_confident,
        obs.comments,
        st_asgeojson(obs.geometry) as geometry,
        st_astext(st_transform(obs.geometry, :epsg_code)) as wfs_geometry,
        grid.id as grid_cell,
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
      from abc_montbel.observation as obs
      left join obs_observer on obs_observer.id = obs.id
      left join common.study as st on st.code = obs.study
      left join common.protocol as prot on prot.code = obs.protocol
      left join ref.scientific_name as sciname on sciname.taxon = obs.taxon and sciname.is_preferred = true
      left join ref.observation_method as obsmeth on obsmeth.code = obs.observation_method
      left join ref.count_method as cntmeth on cntmeth.code = obs.count_method
      left join abc_montbel.grid as grid on st_contains(grid.geometry, obs.geometry)
  );

  comment on view abc_montbel.observation_updatable_view is 'View to be modified to edit main `observation` table';

  create materialized view if not exists wfs.abc_montbel_obs as
  select obs.id as id,
      obs.study as etude,
      obs.protocol as protocole,
      obs.observation_date as date,
      obs.observer_names as observateurs,
      obs.taxon as id_taxref,
      obs.taxon_name as nom_sci,
      obs.quoted_name as nom_cite,
      obs.observation_method as code_meth_obs,
      obs.observation_method_name as meth_obs,
      obs.count_min as eff_min,
      obs.count_max as eff_max,
      obs.count_method as code_meth_dnbr,
      obs.count_method_name as meth_dnbr,
      obs.has_picture as photo_existante,
      obs.picture_id as id_photo,
      obs.is_confident as est_certain,
      obs.comments as remarques,
      obs.grid_cell as no_maille,
      obs.dc_date_created as date_creation,
      obs.dc_date_modified as date_modification,
      obs.dc_date_submitted as date_soumission,
      obs.dc_date_accepted as date_validation,
      obs.dc_date_issued as date_publication,
      obs.dc_creator as numerisateur,
      obs.validator as validateur,
      obs.wfs_geometry as geometry
    from abc_montbel.observation_updatable_view as obs
    order by observation_date asc;

  create materialized view if not exists wfs.abc_montbel_grid as
  select id,
      st_astext(st_transform(geometry, :epsg_code)) as geometry
  from abc_montbel.grid
  order by id asc;

  comment on materialized view wfs.abc_montbel_obs is 'To be served via WFS';

  -- Triggers

  create or replace function abc_montbel.tg_add_missing_data ()
    returns trigger
    language plpgsql
  as $$
  declare
  begin
    if NEW.count_range is null then
      NEW.count_range := format('[%s, %s]', NEW.count_min, NEW.count_max)::int4range;
    end if;
    if NEW.quoted_name is null then
      NEW.quoted_name := '';
    end if;
    -- Populate observers
    with obs(id) as (
      insert into abc_montbel.observation
      select * from json_populate_record(null::abc_montbel.observation, row_to_json(NEW))
      returning id
    )
    insert into abc_montbel.observer
    select obs.id, observer.name
    FROM obs, (select json_array_elements_text(NEW.observers) AS name) as observer;
    -- TODO: Populate subject : | obs_id | taxon_name |
    return null;
  end;
  $$;

  drop trigger if exists add_missing_abc_montbel_data on abc_montbel.observation_updatable_view;
  drop trigger if exists update_date_modified on abc_montbel.observation;

  create trigger set_geometry_srid
  instead of insert
  on abc_montbel.observation_updatable_view
  for each row
    execute procedure tg_set_geometry_srid();

  create trigger add_missing_metadata
  instead of insert
  on abc_montbel.observation_updatable_view
  for each row
    execute procedure tg_add_missing_metadata();

  create trigger add_missing_abc_montbel_data
  instead of insert
  on abc_montbel.observation_updatable_view
  for each row
    execute procedure abc_montbel.tg_add_missing_data();

  create trigger update_date_modified
  before update
  on abc_montbel.observation
  for each row
    execute procedure tg_update_date_modified();

commit;
