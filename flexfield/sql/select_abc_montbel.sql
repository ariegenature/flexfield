-- name: abc_montbel
-- Get all observations
select row_to_json(t)::jsonb || '{"type": "Feature"}'::jsonb from (
  select *
  from abc_montbel.geojson_view
) as t;
