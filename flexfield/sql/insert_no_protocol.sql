-- name: catch_all_form!
-- Insert new observation into database
insert into no_protocol.catch_all_view
select * from jsonb_populate_record(null::no_protocol.catch_all_view, :feature::jsonb)
