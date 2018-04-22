-- name: get_user_capabilities
-- Get all user capabilities (allowed studies, protocols and forms)
with available_study as (
  (
    select st.code, st.title, st.short_title, st.description, st.pictogram
      from common.study as st
      where st.is_public is true and st.is_active = true
  )
  union
  (
    select st.code, st.title, st.short_title, st.description, st.pictogram
      from common.study as st
      left join lateral (
        select uas.username
        from common.user_authorized_studies as uas
        where uas.study = st.code
      ) as username on true
      where st.is_active is true and username = :username
  )
)
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
    form.yaml_description as form_yaml_description,
    nopform.code as nop_form_code,
    nopform.title as nop_form_title,
    nopform.short_title as nop_form_short_title,
    nopform.description as nop_form_description,
    nopform.pictogram as nop_form_pictogram,
    nopform.component_name as nop_form_component_name,
    nopform.yaml_description as nop_form_yaml_description
  from available_study as st
  left join common.study_protocol as sp on sp.study = st.code
  left join common.protocol as prot on prot.code = sp.protocol
  left join common.protocol_form as pf on pf.protocol = prot.code
  left join common.form as form on form.code = pf.form
  left join common.study_form_no_protocol as sf on sf.study = st.code
  left join common.form as nopform on nopform.code = sf.form
  order by study_code asc, protocol_code asc;
