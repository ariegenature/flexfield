-- name: orchid_form!
-- Insert new observation into database
insert into orchidaceae.observation_view
select * from jsonb_populate_record(null::orchidaceae.observation_view, :feature::jsonb)
