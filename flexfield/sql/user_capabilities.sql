-- name: get_user_capabilities
-- Get all user capabilities (allowed studies, protocols and forms)
with available_study as (
  (
    select st.code, st.title, st.short_title, st.description, st.pictogram,
        st.allow_no_protocol
      from common.study as st
      where st.is_public is true and st.is_active = true
  )
  union
  (
    select st.code, st.title, st.short_title, st.description, st.pictogram,
        st.allow_no_protocol
      from common.study as st
      left join lateral (
        select uas.username
        from common.user_authorized_studies as uas
        where uas.study = st.code
      ) as username on true
      where st.is_active is true and username = :username
  )
),
available_protocol as (
  (
    select prot.code, prot.title, prot.short_title, prot.description, prot.pictogram
      from common.protocol as prot
      where prot.is_public is true and prot.is_active = true
  )
  union
  (
    select prot.code, prot.title, prot.short_title, prot.description, prot.pictogram
      from common.protocol as prot
      left join lateral (
        select uap.username
        from common.user_authorized_protocols as uap
        where uap.protocol = prot.code
      ) as username on true
      where prot.is_active is true and username = :username
  )
),
available_form as (
  select form.code, form.title, form.short_title, form.description, form.pictogram,
      form.may_have_no_protocol, form.component_name, form.json_description
    from common.form as form
    where form.is_active = true
),
no_protocol_study as (
  select st.code, st.title, st.short_title, st.description, st.pictogram
    from available_study as st
    where st.allow_no_protocol = true
),
no_protocol_form as (
  select form.code, form.title, form.short_title, form.description, form.pictogram,
      form.component_name, form.json_description
    from available_form as form
    where form.may_have_no_protocol = true
)
(
  select null as study_code,
      null as study_title,
      null as study_short_title,
      null as study_description,
      null as study_pictogram,
      null as protocol_code,
      null as protocol_title,
      null as protocol_short_title,
      null as protocol_description,
      null as protocol_pictogram,
      form.code as form_code,
      form.title as form_title,
      form.short_title as form_short_title,
      form.description as form_description,
      form.pictogram as form_pictogram,
      form.component_name as form_component_name,
      form.json_description as form_json_description
    from no_protocol_form as form
)
union
(
  select st.code as study_code,
      st.title as study_title,
      st.short_title as study_short_title,
      st.description as study_description,
      st.pictogram as study_pictogram,
      null as protocol_code,
      null as protocol_title,
      null as protocol_short_title,
      null as protocol_description,
      null as protocol_pictogram,
      form.code as form_code,
      form.title as form_title,
      form.short_title as form_short_title,
      form.description as form_description,
      form.pictogram as form_pictogram,
      form.component_name as form_component_name,
      form.json_description as form_json_description
    from no_protocol_study as st
    cross join no_protocol_form as form
)
union
(
  select st.code as study_code,
      st.title as study_title,
      st.short_title as study_short_title,
      st.description as study_description,
      st.pictogram as study_pictogram,
      prot.code as protocol_code,
      prot.title as protocol_title,
      prot.short_title as protocol_short_title,
      prot.description as protocol_description,
      prot.pictogram as protocol_pictogram,
      form.code as form_code,
      form.title as form_title,
      form.short_title as form_short_title,
      form.description as form_description,
      form.pictogram as form_pictogram,
      form.component_name as form_component_name,
      form.json_description as form_json_description
    from available_study as st
    inner join common.study_protocol as sp on sp.study = st.code
    left join available_protocol as prot on prot.code = sp.protocol
    inner join common.protocol_form as pf on pf.protocol = prot.code
    left join available_form as form on form.code = pf.form
) order by study_code asc, protocol_code asc, form_code asc;
