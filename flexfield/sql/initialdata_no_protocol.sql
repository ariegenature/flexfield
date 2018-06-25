begin;

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
