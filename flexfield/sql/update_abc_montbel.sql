-- name: abc_montbel!
-- Update observation into database
update abc_montbel.geojson_view
set properties = :properties::jsonb,
  geometry = :geometry::jsonb
where id = :id
