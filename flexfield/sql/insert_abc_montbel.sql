-- name: insert_observation!
-- Insert new observation into database
insert into abc_montbel.observation_updatable_view
select * from jsonb_populate_record(null::abc_montbel.observation_updatable_view, :feature::jsonb)
