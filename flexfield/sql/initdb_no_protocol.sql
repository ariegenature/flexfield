begin;

  \set epsg_code 2154

  -- Tables

  create table if not exists no_protocol.catch_all (
    id uuid default uuid_generate_v4() primary key,
    study varchar(15) references common.study on delete cascade on update cascade,
    protocol varchar(15) references common.protocol on delete cascade on update cascade,
    data_source varchar(3) references ref.data_source on delete restrict on update cascade,
    ref_source text not null default '',
    data_type varchar(3) references ref.data_type on delete restrict on update cascade,
    presence varchar(3) references ref.presence on delete restrict on update cascade,
    taxon int not null references ref.taxon on delete restrict on update cascade,
    quoted_name text not null default '',
    count_range int4range not null default '[1, 1]',
    subject_type varchar(4) not null default 'IND' references ref.subject_type on delete restrict on update cascade,
    observation_period tstzrange not null,
    altitude_range int4range,
    deep_range int4range,
    observation_method smallint references ref.observation_method on delete restrict on update cascade,
    count_method varchar(3) references ref.count_method on delete restrict on update cascade,
    living_status smallint references ref.living_status on delete restrict on update cascade,
    domestication_status smallint references ref.domestication_status on delete restrict on update cascade,
    gender smallint references ref.gender on delete restrict on update cascade,
    age smallint references ref.age on delete restrict on update cascade,
    biogeographical_status smallint references ref.biogeographical_status on delete restrict on update cascade,
    biological_status smallint references ref.biological_status on delete restrict on update cascade,
    bird_breeding_code smallint references ref.bird_breeding_code on delete restrict on update cascade,
    evidence smallint references ref.evidence on delete restrict on update cascade,
    evidence_url text not null default '',
    comments text not null default '',
    geometry geometry(Point, 4326) not null,
    -- metadata
    dc_title varchar(250) not null constraint title_cannot_be_empty check (dc_title != ''),
    dc_date_created timestamp not null,
    dc_date_modified timestamp not null,
    dc_date_submitted date,
    dc_date_accepted date,
    dc_date_issued date,
    dc_creator text not null constraint creator_cannot_be_empty check (dc_creator != ''),
    validator text constraint validator_cannot_be_empty check (validator != ''),
    dc_publisher text not null default '',
    dc_language text not null references ref.language,
    dc_type text not null constraint type_cannot_be_empty check (dc_type != '')
  );

  comment on table no_protocol.catch_all is 'Observations qui ne rentrent dans aucun autre formulaire';

  create table if not exists no_protocol.catch_all_observer (
    observation uuid not null references no_protocol.catch_all on delete restrict on update cascade,
    name text not null constraint observer_name_cannot_be_empty check (name != ''),
    primary key (observation, name)
  );

  comment on table no_protocol.catch_all_observer is 'Relie une observation à ses observateurs';

  -- Views

  create or replace view no_protocol.catch_all_view as (
    with obs_observer(id, array_names, names) as (
      select obs.id, array_agg(observer.name), string_agg(observer.name, ', ')
        from no_protocol.catch_all as obs
        left join no_protocol.catch_all_observer as observer on observer.observation = obs.id
        group by obs.id
    )
    select obs.id,
        st.short_title as study,
        prot.short_title as protocol,
        obs.observation_period,
        lower(obs.observation_period) as observation_period_beginning,
        upper(obs.observation_period) as observation_period_ending,
        array_to_json(obs_observer.array_names) as observers,
        obs_observer.names as observer_names,
        obs.data_source,
        dsource.title as data_source_title,
        obs.ref_source,
        obs.data_type,
        dtype.title as data_type_title,
        obs.presence,
        pres.title as presence_title,
        obs.subject_type,
        stype.title as subject_type_title,
        obs.taxon,
        sciname.value as taxon_name,
        obs.quoted_name,
        obs.observation_method,
        obsmeth.title as observation_method_title,
        obs.count_range,
        lower(obs.count_range) as count_min,
        upper(obs.count_range) - 1 as count_max,
        obs.count_method,
        cntmeth.title as count_method_title,
        obs.living_status,
        livstatus.title as living_status_title,
        obs.domestication_status,
        domstatus.title as domestication_status_title,
        obs.gender,
        gender.title as gender_title,
        obs.age,
        age.title as age_title,
        obs.biogeographical_status,
        biogeostatus.title as biogeographical_status_title,
        obs.biological_status,
        biostatus.title as biological_status_title,
        obs.bird_breeding_code,
        brcode.title as bird_breeding_code_title,
        obs.altitude_range,
        lower(obs.altitude_range) as altitude_min,
        upper(obs.altitude_range) - 1 as altitude_max,
        obs.deep_range,
        lower(obs.deep_range) as deep_min,
        upper(obs.deep_range) - 1 as deep_max,
        obs.evidence,
        evidence.title as evidence_title,
        obs.evidence_url,
        obs.comments,
        st_asgeojson(obs.geometry) as geometry,
        st_astext(st_transform(obs.geometry, :epsg_code)) as wfs_geometry,
        obs.dc_title,
        obs.dc_date_created,
        obs.dc_date_modified,
        obs.dc_date_submitted,
        obs.dc_date_accepted,
        obs.dc_date_issued,
        obs.dc_creator,
        obs.validator,
        obs.dc_publisher,
        obs.dc_language,
        obs.dc_type
      from no_protocol.catch_all as obs
      left join obs_observer on obs_observer.id = obs.id
      left join common.study as st on st.code = obs.study
      left join common.protocol as prot on prot.code = obs.protocol
      left join ref.subject_type as stype on stype.code = obs.subject_type
      left join ref.data_source as dsource on dsource.code = obs.data_source
      left join ref.data_type as dtype on dtype.code = obs.data_type
      left join ref.presence as pres on pres.code = obs.presence
      left join ref.scientific_name as sciname on sciname.taxon = obs.taxon and sciname.is_preferred = true
      left join ref.observation_method as obsmeth on obsmeth.code = obs.observation_method
      left join ref.count_method as cntmeth on cntmeth.code = obs.count_method
      left join ref.living_status as livstatus on livstatus.code = obs.living_status
      left join ref.domestication_status as domstatus on domstatus.code = obs.domestication_status
      left join ref.gender as gender on gender.code = obs.gender
      left join ref.age as age on age.code = obs.age
      left join ref.biogeographical_status as biogeostatus on biogeostatus.code = obs.biogeographical_status
      left join ref.biological_status as biostatus on biostatus.code = obs.biogeographical_status
      left join ref.bird_breeding_code as brcode on brcode.code = obs.bird_breeding_code
      left join ref.evidence as evidence on evidence.code = obs.evidence
  );

  comment on view no_protocol.catch_all_view is 'View to be modified to edit main `catch all` table';

  create materialized view if not exists wfs.catch_all_obs as
  select obs.id as id,
      obs.study as etude,
      obs.protocol as protocole,
      obs.data_source_title as type_source,
      obs.ref_source as source,
      obs.data_type_title as publique,
      obs.observation_period_beginning as debut_obs,
      obs.observation_period_ending as fin_obs,
      obs.observer_names as observateurs,
      obs.taxon as id_taxref,
      obs.taxon_name as nom_sci,
      obs.quoted_name as nom_cite,
      obs.presence_title as presence,
      obs.observation_method_title as methode_obs,
      obs.count_min as eff_min,
      obs.count_max as eff_max,
      obs.count_method_title as methode_dnbr,
      obs.subject_type_title as objet_dnbr,
      obs.living_status_title as vivant,
      obs.domestication_status_title as naturalite,
      obs.gender_title as sexe,
      obs.age_title as stade,
      obs.biogeographical_status_title as statut_biogeo,
      obs.biological_status_title as statut_biologique,
      obs.bird_breeding_code_title as ind_nidification,
      obs.altitude_min as altitude_min,
      obs.altitude_max as altitude_max,
      obs.deep_min as prof_min,
      obs.deep_max as prof_max,
      obs.evidence_url as url_preuve,
      obs.comments as remarques,
      obs.dc_date_created as date_creation,
      obs.dc_date_modified as date_modification,
      obs.dc_date_submitted as date_soumission,
      obs.dc_date_accepted as date_validation,
      obs.dc_date_issued as date_publication,
      obs.dc_creator as numerisateur,
      obs.validator as validateur,
      obs.wfs_geometry as geometry
    from no_protocol.catch_all_view as obs
    order by debut_obs asc;

  comment on materialized view wfs.catch_all_obs is 'To be served via WFS';

  -- Triggers

  create or replace function tg_catch_all_add_missing_data ()
    returns trigger
    language plpgsql
  as $$
  declare
      altitude_max integer;
      count_max integer;
      deep_max integer;
      observation_period_ending timestamptz;
  begin
    NEW.geometry := st_setsrid(st_geomfromgeojson(NEW.geometry), 4326);
    -- Metadata
    if NEW.id is null then  -- Generate UUID
      NEW.id := uuid_generate_v4();
    end if;
    if NEW.dc_date_created is null then
      NEW.dc_date_created := now();
    end if;
    if NEW.dc_date_modified is null then
      NEW.dc_date_modified := now();
    end if;
    if NEW.dc_publisher is null then
      NEW.dc_publisher := '';
    end if;
    if NEW.dc_type is null then
      NEW.dc_type := 'event';
    end if;
    -- Other data
    if NEW.data_source is null then
      NEW.data_source := 'Te';
    end if;
    if NEW.data_type is null then
      NEW.data_type := 'Ac';
    end if;
    if NEW.observation_period is null then
      if NEW.observation_period_ending is null then
        observation_period_ending := NEW.observation_period_beginning;
      else
        observation_period_ending := NEW.observation_period_ending;
      end if;
      NEW.observation_period := format('[%s, %s]', NEW.observation_period_beginning, observation_period_ending)::tstzrange;
    end if;
    if NEW.count_range is null and NEW.count_min is not null then
      if NEW.count_max is null then
        count_max := NEW.count_min;
      else
        count_max := NEW.count_max;
      end if;
      NEW.count_range := format('[%s, %s]', NEW.count_min, count_max)::int4range;
    end if;
    if NEW.altitude_range is null and NEW.altitude_min is not null then
      if NEW.altitude_max is null then
        altitude_max := NEW.altitude_min;
      else
        altitude_max := NEW.altitude_max;
      end if;
      NEW.altitude_range := format('[%s, %s]', NEW.altitude_min, altitude_max)::int4range;
    end if;
    if NEW.deep_range is null and NEW.deep_min is not null then
      if NEW.deep_max is null then
        deep_max := NEW.deep_min;
      else
        deep_max := NEW.deep_max;
      end if;
      NEW.deep_range := format('[%s, %s]', NEW.deep_min, deep_max)::int4range;
    end if;
    if NEW.quoted_name is null then
      NEW.quoted_name := '';
    end if;
    -- Populate observers
    with obs(id) as (
      insert into no_protocol.catch_all
      select * from json_populate_record(null::no_protocol.catch_all, row_to_json(NEW))
      returning id
    )
    insert into no_protocol.catch_all_observer
    select obs.id, observer.name
    FROM obs, (select json_array_elements_text(NEW.observers) AS name) as observer;
    -- TODO: Populate subject : | obs_id | taxon_name |
    return null;
  end;
  $$;

  drop trigger if exists catch_all_add_missing_data on no_protocol.catch_all_view;
  drop trigger if exists catch_all_update_date_modified on no_protocol.catch_all;

  create trigger catch_all_add_missing_data
  instead of insert
  on no_protocol.catch_all_view
  for each row
    execute procedure tg_catch_all_add_missing_data();

  create trigger catch_all_update_date_modified
  before update
  on no_protocol.catch_all
  for each row
    execute procedure tg_update_date_modified();

  -- Studies, protocols and forms

  insert into common.form
  (code, title, short_title, version, description, component_name, json_description, allow_no_protocol, is_active, pictogram)
  values
  (
    'CATCHALLFORM',
    'Formulaire générique SINP « tout taxon » - v1',
    'Formulaire SINP « tout taxon »',
    '1.0.0',
    'Formulaire générique, compatible SINP, permettant la saisie de n''importe quel taxon',
    '',
    '{
      "slug": "catch-all-form",
      "model": {
        "study": null,
        "protocol": null,
        "ref_source": "",
        "observation_period_beginning": null,
        "observation_period_ending": null,
        "observers": [],
        "observation_method": null,
        "subject_type": "IND",
        "taxon": null,
        "quoted_name": "",
        "presence": "Pr",
        "count_min": 1,
        "count_max": null,
        "count_method": "Co",
        "living_status": 2,
        "domestication_status": 0,
        "gender": 1,
        "age": 1,
        "biogeographical_status": 0,
        "biological_status": 2,
        "bird_breeding_code": null,
        "evidence_url": "",
        "altitude_min": null,
        "altitude_max": null,
        "deep_min": null,
        "deep_max": null,
        "comments": "",
        "dc_language": "fra",
        "dc_creator": null,
        "dc_title": null
      },
      "tabs": [
        {
          "id": 0,
          "title": "Identification",
          "schema": {
            "fields": [
              {
                "id": "taxon",
                "api": "/backend/taxon",
                "icon": "flower",
                "size": "is-small",
                "type": "b-autocomplete",
                "model": "taxon",
                "required": true,
                "validator": "integer",
                "fieldLabel": "Espèce",
                "placeholder": "Commencer à saisir le nom du taxon...",
                "searchParam": "q",
                "selectField": "taxon_id",
                "displayField": "name",
                "resultProperty": "results"
              },
              {
                "id": "presence",
                "type": "b-radio-button",
                "size": "is-small",
                "model": "presence",
                "fieldLabel": "Présence/Absence",
                "values": [
                  {"id": "Pr", "text": "<span class=\"icon\"><i class=\"mdi mdi-check\"><\/i><\/span><span>Présent<\/span>"},
                  {"id": "No", "text": "<span class=\"icon\"><i class=\"mdi mdi-close\"><\/i><\/span><span>Non observé<\/span>"},
                  {"id": "NSP", "text": "<span class=\"icon\"><i class=\"mdi mdi-help\"><\/i><\/span><span>Ne sait pas<\/span>"}
                ],
                "required": true,
                "validator": "string"
              },
              {
                "id": "count-min",
                "icon": "code-greater-than-or-equal",
                "size": "is-small",
                "type": "b-input",
                "inputType": "number",
                "model": "count_min",
                "required": true,
                "fieldLabel": "Effectif minimal (ou exact)",
                "validator": "integer"
              },
              {
                "id": "count-max",
                "icon": "code-less-than-or-equal",
                "size": "is-small",
                "type": "b-input",
                "inputType": "number",
                "model": "count_max",
                "fieldLabel": "Effectif maximal",
                "fieldHelp": "Laisser vide si effectif minimal est exact",
                "fieldType": "is-primary",
                "validator": "integer"
              },
              {
                "id": "count-method",
                "type": "b-radio-button",
                "size": "is-small",
                "model": "count_method",
                "fieldLabel": "Méthode de dénombrement",
                "values": [
                  {"id": "Co", "text": "<span class=\"icon\"><i class=\"mdi mdi-counter\"><\/i><\/span><span>Compté<\/span>"},
                  {"id": "Ca", "text": "<span class=\"icon\"><i class=\"mdi mdi-sigma\"><\/i><\/span><span>Calculé<\/span>"},
                  {"id": "Es", "text": "<span class=\"icon\"><i class=\"mdi mdi-tilde\"><\/i><\/span><span>Estimé<\/span>"}
                ],
                "required": true,
                "validator": "string"
              },
              {
                "id": "subject-type",
                "type": "b-select",
                "size": "is-small",
                "icon": "binocular",
                "model": "subject_type",
                "fieldLabel": "Objet du dénombrement",
                "placeholder": "Sélectionner un objet",
                "values": [
                  {"id": "COL", "title": "Colonie"},
                  {"id": "CPL", "title": "Couple"},
                  {"id": "HAM", "title": "Hampe florale"},
                  {"id": "IND", "title": "Individu"},
                  {"id": "NID", "title": "Nid"},
                  {"id": "NSP", "title": "Ne Sait Pas"},
                  {"id": "PON", "title": "Ponte"},
                  {"id": "SURF", "title": "Surface"},
                  {"id": "TIGE", "title": "Tige"},
                  {"id": "TOUF", "title": "Touffe"}
                ],
                "required": true,
                "validator": "string"
              }
            ]
          }
        },
        {
          "id": 1,
          "title": "Détails",
          "schema": {
            "fields": [
              {
                "id": "living-status",
                "type": "b-radio-button",
                "size": "is-small",
                "model": "living_status",
                "fieldLabel": "Vivant/Mort",
                "values": [
                  {"id": 2, "text": "<span class=\"icon\"><i class=\"mdi mdi-heart-pulse\"><\/i><\/span><span>Observé vivant<\/span>"},
                  {"id": 3, "text": "<span class=\"icon\"><i class=\"mdi mdi-heart-off\"><\/i><\/span><span>Trouvé mort<\/span>"},
                  {"id": 0, "text": "<span class=\"icon\"><i class=\"mdi mdi-help\"><\/i><\/span><span>Ne sait pas<\/span>"}
                ],
                "validator": "integer"
              },
              {
                "id": "domestication-status",
                "type": "b-radio-button",
                "size": "is-small",
                "fieldLabel": "Naturalité",
                "model": "domestication_status",
                "values": [
                  {"id": 0, "text": "<span>Inconnu</span>"},
                  {"id": 1, "text": "<span>Sauvage</span>"},
                  {"id": 2, "text": "<span>Cultivé/élevé</span>"},
                  {"id": 3, "text": "<span>Planté</span>"},
                  {"id": 4, "text": "<span>Féral</span>"},
                  {"id": 5, "text": "<span>Subspontané</span>"}
                ],
                "validator": "integer"
              },
              {
                "id": "gender",
                "type": "b-radio-button",
                "size": "is-small",
                "model": "gender",
                "fieldLabel": "Sexe",
                "values": [
                  {"id": 1, "text": "<span class=\"icon\"><i class=\"mdi mdi-help\"><\/i><\/span><span>Indéterminé<\/span>"},
                  {"id": 2, "text": "<span class=\"icon\"><i class=\"mdi mdi-gender-female\"><\/i><\/span>Femelle<\/span>"},
                  {"id": 3, "text": "<span class=\"icon\"><i class=\"mdi mdi-gender-male\"><\/i><\/span>Mâle<\/span>"},
                  {"id": 4, "text": "<span class=\"icon\"><i class=\"mdi mdi-gender-male-female\"><\/i><\/span>Hermaphrodite<\/span>"},
                  {"id": 5, "text": "<span class=\"icon\"><i class=\"mdi mdi-plus\"><\/i><\/span>Mixte (plusieurs individus)<\/span>"}
                ],
                "validator": "integer"
              },
              {
                "id": "age",
                "type": "b-select",
                "size": "is-small",
                "icon": "chart-timeline",
                "model": "age",
                "fieldLabel": "Stade",
                "placeholder": "Sélectionner un stade",
                "values": [
                  {"id": 1, "title": "Indéterminé"},
                  {"id": 2, "title": "Adulte"},
                  {"id": 3, "title": "Juvénile"},
                  {"id": 4, "title": "Immature"},
                  {"id": 5, "title": "Sub-adulte"},
                  {"id": 6, "title": "Larve"},
                  {"id": 7, "title": "Chenille"},
                  {"id": 8, "title": "Têtard"},
                  {"id": 9, "title": "Œuf"},
                  {"id": 10, "title": "Mue"},
                  {"id": 11, "title": "Exuvie"},
                  {"id": 12, "title": "Chrysalide"},
                  {"id": 13, "title": "Nymphe"},
                  {"id": 14, "title": "Pupe"},
                  {"id": 15, "title": "Imago"},
                  {"id": 16, "title": "Sub-imago"},
                  {"id": 17, "title": "Alevin"},
                  {"id": 18, "title": "Germination"},
                  {"id": 19, "title": "Fané"},
                  {"id": 20, "title": "Graine"},
                  {"id": 21, "title": "Thalle, protothalle"},
                  {"id": 22, "title": "Tubercule"},
                  {"id": 23, "title": "Bulbe"},
                  {"id": 24, "title": "Rhizome"},
                  {"id": 25, "title": "Emergent"},
                  {"id": 26, "title": "Post-Larve"}
                ],
                "validator": "integer"
              },
              {
                "id": "biogeographical-status",
                "type": "b-select",
                "size": "is-small",
                "icon": "earth",
                "model": "biogeographical_status",
                "fieldLabel": "Statut biogégraphique",
                "placeholder": "Sélectionner un statut",
                "values": [
                  {"id": 0, "title": "Inconnu/cryptogène"},
                  {"id": 2, "title": "Présent (indigène ou indéterminé)"},
                  {"id": 3, "title": "Introduit"},
                  {"id": 4, "title": "Introduit envahissant"},
                  {"id": 5, "title": "Introduit non établi (dont domestique)"},
                  {"id": 6, "title": "Occasionnel"}
                ],
                "validator": "integer"
              },
              {
                "id": "biological-status",
                "icon": "fish",
                "size": "is-small",
                "type": "b-select",
                "model": "biological_status",
                "fieldLabel": "Statut biologique",
                "placeholder": "Sélectionner un état",
                "values": [
                  {"id": 2, "title": "Non Déterminé"},
                  {"id": 3, "title": "Reproduction"},
                  {"id": 4, "title": "Hibernation"},
                  {"id": 5, "title": "Estivation"},
                  {"id": 6, "title": "Halte migratoire"},
                  {"id": 7, "title": "Swarming"},
                  {"id": 8, "title": "Chasse / alimentation"},
                  {"id": 9, "title": "Pas de reproduction"},
                  {"id": 10, "title": "Passage en vol"},
                  {"id": 11, "title": "Erratique"},
                  {"id": 12, "title": "Sédentaire"}
                ],
                "validator": "integer"
              },
              {
                "id": "bird-breeding-code",
                "type": "b-select",
                "size": "is-small",
                "icon": "fish",
                "model": "bird_breeding_code",
                "fieldLabel": "Indice de nidification (oiseau)",
                "placeholder": "Sélectionner un indice",
                "values": [
                  {"id": 0, "title": "IN0 - Absence de réponse à la repasse"},
                  {"id": 1, "title": "IN1 - Oiseau retrouvé mort, écrasé"},
                  {"id": 2, "title": "IN2 - Oiseau vu en période de nidification (février à juillet) dans un milieu favorable"},
                  {"id": 3, "title": "IN3 - Mâle chanteur (et/ou cris nuptiaux et/ou tambourinage) présent en période de nidification dans un milieu favorable"},
                  {"id": 4, "title": "IN4 - Couple présent en période de reproduction dans un milieu favorable"},
                  {"id": 5, "title": "IN5 - Comportement territorial (chant, querelles avec des voisins, etc.) observé sur un même site à au moins une semaine d''intervalle. Observation simultanée de deux mâles chanteurs ou plus sur un même site"},
                  {"id": 6, "title": "IN6 - Parades, accouplement ou échange de nourriture entre adultes"},
                  {"id": 7, "title": "IN7 - Cri d''alarme ou tout autre comportement agité indiquant la proximité d''un nid ou de jeunes"},
                  {"id": 8, "title": "IN8 - Observation sur un oiseau en main : plaque incubatrice très vascularisée ou oeuf présent dans l''oviducte. "},
                  {"id": 9, "title": "IN9 - Transport de matériel ou construction d''un nid ; forage d''une cavité"},
                  {"id": 10, "title": "IN10 - Oiseau simulant une blessure ou détournant l''attention, tels les canards, gallinacés, oiseaux de rivage, etc."},
                  {"id": 11, "title": "IN11 - Nid vide ayant été utilisé ou contenant des coquilles d’œufs"},
                  {"id": 12, "title": "IN12 - Jeunes en duvet ou jeunes venant de quitter le nid et incapables de soutenir le vol sur de longues distances"},
                  {"id": 13, "title": "IN13 - Adulte gagnant, occupant ou quittant le site d''un nid ; comportement révélateur d''un nid occupé dont le contenu ne peut être vérifié (trop haut ou dans une cavité)"},
                  {"id": 14, "title": "IN14 - Adulte transportant de la nourriture pour les jeunes"},
                  {"id": 15, "title": "IN15 - Adulte couvant"},
                  {"id": 16, "title": "IN16 - Nid avec des œufs ou des jeunes (vus ou entendus)"},
                  {"id": 17, "title": "IN17 - Oiseau vu hors période de nidification, août à janvier"}
                ],
                "validator": "integer"
              },
              {
                "id": "altitude-min",
                "type": "b-input",
                "size": "is-small",
                "icon": "altimeter",
                "inputType": "number",
                "model": "altitude_min",
                "fieldLabel": "Altitude minimale",
                "validator": "integer"
              },
              {
                "id": "altitude-max",
                "type": "b-input",
                "size": "is-small",
                "icon": "altimeter",
                "inputType": "number",
                "model": "altitude_max",
                "fieldLabel": "Altitude maximale",
                "fieldHelp": "Laisser vide si altitude minimale est exacte",
                "validator": "integer"
              },
              {
                "id": "deep-min",
                "type": "b-input",
                "size": "is-small",
                "icon": "waves",
                "inputType": "number",
                "model": "deep_min",
                "fieldLabel": "Profondeur minimale",
                "validator": "integer"
              },
              {
                "id": "deep-max",
                "type": "b-input",
                "size": "is-small",
                "icon": "waves",
                "inputType": "number",
                "model": "deep_max",
                "fieldLabel": "Profondeur maximale",
                "fieldHelp": "Laisser vide si profondeur minimale est exacte",
                "validator": "integer"
              },
              {
                "id": "evidence-url",
                "type": "b-input",
                "inputType": "text",
                "size": "is-small",
                "icon": "file-image",
                "model": "evidence_url",
                "fieldLabel": "Nom de fichier de la photo",
                "placeholder": "180415-PL-desman-001.jpg",
                "fieldHelp": "Laisser vide s''il n''y a pas de photo",
                "validator": "string"
              }
            ]
          }
        },
        {
          "id": 2,
          "title": "Métadonnées",
          "schema": {
            "fields": [
              {
                "id": "date",
                "size": "is-small",
                "type": "b-datepicker",
                "model": "observation_period_beginning",
                "inline": true,
                "required": true,
                "validator": "date",
                "fieldLabel": "Date"
              },
              {
                "id": "observation-method",
                "type": "b-select",
                "size": "is-small",
                "icon": "glasses",
                "fieldLabel": "Type de contact",
                "placeholder": "Sélectionner une méthode",
                "model": "observation_method",
                "values": [
                  {"id": 0, "title": "Vu"},
                  {"id": 1, "title": "Entendu"},
                  {"id": 2, "title": "Coquilles d''œuf"},
                  {"id": 4, "title": "Empreintes"},
                  {"id": 5, "title": "Exuvie"},
                  {"id": 6, "title": "Fèces/Guano/Epreintes"},
                  {"id": 7, "title": "Mues"},
                  {"id": 8, "title": "Nid/Gîte"},
                  {"id": 9, "title": "Pelote de réjection"},
                  {"id": 10, "title": "Restes dans pelote de réjection"},
                  {"id": 11, "title": "Poils/plumes/phanères"},
                  {"id": 12, "title": "Restes de repas"},
                  {"id": 13, "title": "Spore"},
                  {"id": 14, "title": "Pollen"},
                  {"id": 17, "title": "Fleur"},
                  {"id": 18, "title": "Feuille"},
                  {"id": 20, "title": "Autre"},
                  {"id": 21, "title": "Inconnu"},
                  {"id": 23, "title": "Galerie/terrier"},
                  {"id": 25, "title": "Vu et entendu"}
                ],
                "validator": "integer"
              },
              {
                "id": "observers",
                "min": 1,
                "icon": "human-greeting",
                "size": "is-small",
                "type": "b-taginput",
                "model": "observers",
                "tagType": "is-primary",
                "required": true,
                "fieldHelp": "Séparer par des virgules",
                "fieldLabel": "Observateur(s)",
                "validators": ["array", "required"],
                "placeholder": "Ajouter un observateur"
              },
              {
                "id": "comments",
                "size": "is-small",
                "type": "b-input",
                "model": "comments",
                "inputType": "textarea",
                "fieldLabel": "Vous pouvez ajouter des remarques à cette observation"
              }
            ]
          }
        }
      ]
    }',
    true,
    true,
    'https://ariegenature.fr/wp-content/uploads/2018/04/globe-outline.png'
  )
  on conflict do nothing;

commit;
