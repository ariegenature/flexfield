-- name: get_observations
-- Get all observations
with obs_observer as (
  select obs.id as id, string_agg(observer.name, ', ') as names
    from abc_montbel.observation as obs
    left join abc_montbel.observer as observer on observer.observation = obs.id
    group by obs.id
)
select obs.id as id,
    obs.observation_date as observation_date,
    obs_observer.names as observers,
    obs.taxon as taxon,
    obs.observation_method as observation_method,
    obs.has_picture as has_picture,
    obs.is_confident as is_confident,
    obs.comments as comments,
    st_asgeojson(obs.geometry) as geometry
  from abc_montbel.observation as obs
  left join obs_observer on obs_observer.id = obs.id
  order by id desc;
