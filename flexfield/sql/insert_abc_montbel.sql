-- name: insert_observation<!
-- Insert new observation into database
insert into abc_montbel.observation
(observation_date, taxon, observation_method, has_picture, is_confident, comments, geometry)
values
(:observation_date, :taxon, :observation_method, :has_picture, :is_confident, :comments, st_setsrid(st_geomfromgeojson(:geometry), 4326))

-- name: insert_observer!
-- Insert observers into database
insert into abc_montbel.observer
(observation, name)
values
(:obs_id, :name)
