begin;

  -- Data

  insert into orchidaceae.orchid_group
  (id, name)
  values
  ('anacamptis', 'Anacamptis'),
  ('cephalanthera', 'Cephalanthera'),
  ('Dactylorhiza', 'Dactylorhiza'),
  ('epipactis', 'Epipactis'),
  ('gymnadenia', 'Gymnadenia'),
  ('ophrys', 'Ophrys'),
  ('orchis', 'Orchis'),
  ('platanthera', 'Platanthera'),
  ('serapias', 'Serapias'),
  ('other', 'Autre');

  -- Studies, protocols and forms

  insert into common.study
  (code, title, short_title, description, dates, pictogram, is_public, allow_no_protocol, is_active)
  values
  (
    'ORCHID18',
    'Atlas des orchidacées d''Ariège - 2018-2019',
    'Atlas orchidacées',
    'Inventaire des orchidacées sauvages en Ariège',
    '[2018-01-01, 2019-12-31]',
    'https://ariegenature.fr/wp-content/uploads/2018/05/orchid.png',
    true,
    false,
    true
  )
  on conflict do nothing;

  insert into common.protocol
  (code, title, short_title, version, description, is_public, is_active, pictogram)
  values
  (
    'ORCHIDPROT',
    'Procédure de terrain pour l''inventaire des orchidacées',
    'Procédure terrain', '1.0.0', 'Procédure à respecter lors des inventaires d''orchidacées sur le terrain',
    true,
    true,
    'https://ariegenature.fr/wp-content/uploads/2018/05/orchid.png'
  )
  on conflict do nothing;

  insert into common.form
  (code, title, short_title, version, description, component_name, json_description, allow_no_protocol, is_active, pictogram)
  values
  (
    'ORCHIDFORM',
    'Formulaire pour l''inventaire des orchidacées - v1',
    'Formulaire orchidacées',
    '1.0.0',
    'Formulaire permettant la saisie d''informations spécifiques pour les orchidacées',
    '',
    '{
      "slug": "orchid-form",
      "model": {
        "study": null,
        "protocol": null,
        "observation_date": null,
        "observers": [],
        "orchid_group": null,
        "taxon": null,
        "quoted_name": "",
        "count_range": "[1, 6)",
        "has_abnormalities": false,
        "with_hypochromy": false,
        "evidence_url": "",
        "comments": "",
        "dc_language": "fra",
        "dc_creator": null,
        "dc_title": null
      },
      "tabs": [
        {
          "id": 0,
          "title": "Groupe",
          "schema": {
            "fields": [
              {
                "id": "orchid-group",
                "model": "orchid_group",
                "type": "b-radio",
                "size": "is-small",
                "fieldLabel": "Groupe",
                "values": [
                  {"id": "anacamptis", "text": "Anacamptis"},
                  {"id": "cephalanthera", "text": "Cephalanthera"},
                  {"id": "Dactylorhiza", "text": "Dactylorhiza"},
                  {"id": "epipactis", "text": "Epipactis"},
                  {"id": "gymnadenia", "text": "Gymnadenia"},
                  {"id": "ophrys", "text": "Ophrys"},
                  {"id": "orchis", "text": "Orchis"},
                  {"id": "platanthera", "text": "Platanthera"},
                  {"id": "serapias", "text": "Serapias"},
                  {"id": "other", "text": "Autre"}
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
                "id": "taxon",
                "model": "taxon",
                "type": "b-autocomplete",
                "size": "is-small",
                "icon": "flower",
                "fieldLabel": "Espèce",
                "placeholder": "Commencer à saisir le nom du taxon...",
                "fieldHelp": "Laisser vide si l''espèce précise est inconnue",
                "api": "/backend/taxon",
                "searchParam": "q",
                "selectField": "taxon_id",
                "displayField": "name",
                "resultProperty": "results",
                "validator": "integer"
              },
              {
                "id": "count-range",
                "model": "count_range",
                "type": "b-radio-button",
                "size": "is-small",
                "fieldLabel": "Effectif",
                "values": [
                  {"id": "[1, 6)", "text": "<span>1&nbsp;&mdash;&nbsp;5<\/span>"},
                  {"id": "[6, 11)", "text": "<span>6&nbsp;&mdash;&nbsp;10<\/span>"},
                  {"id": "[11, 51)", "text": "<span>11&nbsp;&mdash;&nbsp;50<\/span>"},
                  {"id": "[51, 101)", "text": "<span>51&nbsp;&mdash;&nbsp;100<\/span>"},
                  {"id": "[101,)", "text": "<span>&gt;&nbsp;100<\/span>"}
                ],
                "required": true,
                "validator": "string"
              },
              {
                "id": "has-abnormalities",
                "model": "has_abnormalities",
                "type": "b-switch",
                "size": "is-small",
                "fieldLabel": "Lusus",
                "textOn": "Présence d''anomalies",
                "textOff": "Pas d''anomalies"
              },
              {
                "id": "with-hypochromy",
                "model": "with_hypochromy",
                "type": "b-switch",
                "size": "is-small",
                "fieldLabel": "Hypochromie",
                "textOn": "Hypochrome",
                "textOff": "Non hypochrome"
              },
              {
                "id": "evidence-url",
                "model": "evidence_url",
                "type": "b-input",
                "inputType": "text",
                "size": "is-small",
                "icon": "file-image",
                "fieldLabel": "Nom de fichier de la photo",
                "placeholder": "180415-PL-ophrys_abeille-001.jpg",
                "fieldHelp": "Fournir obligatoirement une photo si Lusus ou hybride",
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
                "model": "observation_date",
                "type": "b-datepicker",
                "size": "is-small",
                "inline": true,
                "fieldLabel": "Date",
                "required": true,
                "validator": "date"
              },
              {
                "id": "observers",
                "model": "observers",
                "type": "b-taginput",
                "tagType": "is-primary",
                "size": "is-small",
                "icon": "human-greeting",
                "fieldLabel": "Observateur(s)",
                "placeholder": "Ajouter un observateur",
                "fieldHelp": "Séparer par des virgules",
                "required": true,
                "min": 1,
                "validators": ["array", "required"]
              },
              {
                "id": "comments",
                "model": "comments",
                "type": "b-input",
                "inputType": "textarea",
                "size": "is-small",
                "fieldLabel": "Vous pouvez ajouter des remarques à cette observation"
              }
            ]
          }
        }
      ]
    }',
    false,
    true,
    'https://ariegenature.fr/wp-content/uploads/2018/05/orchid.png'
  )
  on conflict do nothing;

  insert into common.study_protocol
  (study, protocol)
  values
  ('ORCHID18', 'ORCHIDPROT')
  on conflict do nothing;

  insert into common.protocol_form
  (protocol, form)
  values
  ('ORCHIDPROT', 'ORCHIDFORM')
  on conflict do nothing;

commit;
