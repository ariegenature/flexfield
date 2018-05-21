-- name: orchid_form
-- Get all observations
select row_to_json(t) from (
    select id,
        study as "Étude",
        protocol as "Procédure",
        observation_date,
        observers,
        observer_names,
        orchid_group_name as "Groupe",
        taxon,
        taxon_name as subject,
        quoted_name as "Nom cité",
        count_range,
        count_min as "Effectif min",
        count_max as "Effectif max",
        has_abnormalities as "Lusus",
        with_hypochromy as "Hypochrome",
        evidence_url as "URL preuve",
        comments as "Commentaires",
        geometry,
        wfs_geometry,
        dc_title,
        dc_date_created,
        dc_date_modified,
        dc_date_submitted,
        dc_date_accepted,
        dc_date_issued,
        dc_creator,
        validator,
        dc_publisher,
        dc_language,
        dc_type
      from orchidaceae.observation_view
      order by dc_date_modified desc
  ) as t;
  
