-- name: abc_montbel
-- Get all observations
select row_to_json(t) from (
  select obs.id,
      obs.study,
      obs.study_title,
      obs.protocol,
      obs.protocol_title,
      obs.observation_date,
      obs.observer_names,
      obs.taxon_name as taxon,
      obs.observation_method_name as observation_method,
      obs.count_min,
      obs.count_max,
      obs.count_method_name as count_method,
      obs.comments,
      obs.grid_cell,
      obs.dc_date_created,
      obs.dc_date_modified,
      obs.dc_date_submitted,
      obs.dc_date_accepted,
      obs.dc_date_issued,
      obs.dc_creator,
      obs.validator,
      obs.geometry
    from abc_montbel.observation_updatable_view as obs
    order by dc_date_modified desc
) as t;
