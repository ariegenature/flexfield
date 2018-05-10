begin;

  -- Tables in ref schema

  create table if not exists ref.cadastre_city (
    id char(5) primary key,
    name text not null,
    created date not null,
    updated date not null,
    geometry geometry(multipolygon, 2154) not null
  );

  create table if not exists ref.cadastre_section (
    city char(5) references ref.cadastre_city on delete cascade on update cascade,
    city_prefix char(3) not null,
    code varchar(2) not null,
    created date not null,
    updated date not null,
    geometry geometry(multipolygon, 2154) not null,
    primary key (city, city_prefix, code)
  );

  create table if not exists ref.cadastre_plot (
    city char(5),
    city_prefix char(3),
    section_code varchar(2),
    number integer constraint "plot number must be positive" check (number > 0),
    cadastre_area integer constraint "plot area must be non-negative" check (cadastre_area >= 0),
    created date not null,
    updated date not null,
    geometry geometry(polygon, 2154) not null,
    primary key (city, city_prefix, section_code, number),
    foreign key (city, city_prefix, section_code) references ref.cadastre_section on delete cascade on update cascade
  );

  create or replace view public.parcelles as (
    select
    (city || city_prefix || lpad(section_code, 2, '0') || number) as id,
    city as code_insee_commune,
    city_prefix as prefixe,
    section_code as section,
    number as num_parcelle,
    cadastre_area as contenance,
    geometry
    from ref.cadastre_plot
  );

commit;
