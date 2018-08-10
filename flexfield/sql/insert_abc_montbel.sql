-- name: abc_montbel!
-- Insert new observation into database
insert into abc_montbel.geojson_view
select * from jsonb_populate_record(null::abc_montbel.geojson_view, :feature::jsonb)
