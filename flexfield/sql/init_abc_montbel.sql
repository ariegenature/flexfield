begin;

  \set epsg_code 2154

  create schema if not exists abc_montbel;

  create table abc_montbel.observation (
    id serial primary key,
    observation_date date not null,
    taxon int not null references ref.taxon on delete cascade on update cascade,
    observation_method int references ref.observation_method on delete cascade on update cascade,
    has_picture boolean not null,
    is_confident boolean,
    comments text not null default '',
    geometry geometry(Point, 4326) not null
  );

  create table abc_montbel.observer (
    observation int not null references abc_montbel.observation on delete cascade on update cascade,
    name text not null constraint observer_name_cannot_be_empty check (name != ''),
    primary key (observation, name)
  );

  create or replace view wfs.abc_montbel as
  with obs_observer as (
    select obs.id as id, string_agg(observer.name, ', ') as names
      from abc_montbel.observation as obs
      left join abc_montbel.observer as observer on observer.observation = obs.id
      group by obs.id
  )
  select obs.id as id,
      obs.observation_date as date_obs,
      obs_observer.names as observateurs,
      obs.taxon as id_taxref,
      sciname.value as nom_sci,
      meth.name as methode_obs,
      obs.has_picture as photo_existante,
      obs.is_confident as est_certain,
      obs.comments as remarques,
      st_astext(st_transform(obs.geometry, :epsg_code)) as geometry
    from abc_montbel.observation as obs
    left join obs_observer on obs_observer.id = obs.id
    left join ref.taxon as taxon on taxon.taxref_id = obs.taxon
    left join ref.scientific_name as sciname on sciname.taxon = taxon.taxref_id and sciname.is_preferred = true
    left join ref.observation_method as meth on meth.code = obs.observation_method
    order by date_obs asc;

commit;

