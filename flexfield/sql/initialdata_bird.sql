begin;

  -- Initial data

  insert into ref.bird_breeding_code (code, title, category) values
  (0, 'Absence de réponse à la repasse', 'Nidification inconnue'),
  (1, 'Oiseau retrouvé mort, écrasé', 'Nidification possible'),
  (2, 'Oiseau vu en période de nidification (février à juillet) dans un milieu favorable', 'Nidification possible'),
  (3, 'Mâle chanteur (et/ou cris nuptiaux et/ou tambourinage) présent en période de nidification dans un milieu favorable', 'Nidification possible'),
  (4, 'Couple présent en période de reproduction dans un milieu favorable', 'Nidification probable'),
  (5, 'Comportement territorial (chant, querelles avec des voisins, etc.) observé sur un même site à au moins une semaine d''intervalle. Observation simultanée de deux mâles chanteurs ou plus sur un même site', 'Nidification probable'),
  (6, 'Parades, accouplement ou échange de nourriture entre adultes', 'Nidification probable'),
  (7, 'Cri d''alarme ou tout autre comportement agité indiquant la proximité d''un nid ou de jeunes', 'Nidification probable'),
  (8, 'Observation sur un oiseau en main : plaque incubatrice très vascularisée ou oeuf présent dans l''oviducte. ', 'Nidification probable'),
  (9, 'Transport de matériel ou construction d''un nid ; forage d''une cavité', 'Nidification probable'),
  (10, 'Oiseau simulant une blessure ou détournant l''attention, tels les canards, gallinacés, oiseaux de rivage, etc.', 'Nidification certaine'),
  (11, 'Nid vide ayant été utilisé ou contenant des coquilles d’œufs', 'Nidification certaine'),
  (12, 'Jeunes en duvet ou jeunes venant de quitter le nid et incapables de soutenir le vol sur de longues distances', 'Nidification certaine'),
  (13, 'Adulte gagnant, occupant ou quittant le site d''un nid ; comportement révélateur d''un nid occupé dont le contenu ne peut être vérifié (trop haut ou dans une cavité)', 'Nidification certaine'),
  (14, 'Adulte transportant de la nourriture pour les jeunes', 'Nidification certaine'),
  (15, 'Adulte couvant', 'Nidification certaine'),
  (16, 'Nid avec des œufs ou des jeunes (vus ou entendus)', 'Nidification certaine'),
  (17, 'Oiseau vu hors période de nidification, août à janvier', 'Nidification inconnue');

commit;
