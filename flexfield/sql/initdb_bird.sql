begin;

  -- Tables in ref schema

  create table if not exists ref.bird_breeding_code (
    code smallint primary key,
    title text not null constraint breeding_code_title_must_not_be_empty check (title != ''),
    category text not null constraint invalid_breeding_code_category check (category in ('Nidification possible', 'Nidification probable', 'Nidification certaine', 'Nidification inconnue'))
  );

commit;
