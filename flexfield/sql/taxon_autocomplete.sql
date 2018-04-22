-- name: get_matching_taxons
-- Get taxons matching given query term
with matching_taxon as (
  (
    select distinct 1 as class,
        format('%%s [%%s]', cname.value, sciname.value) as name,
        cname.taxon as taxon
      from ref.common_name as cname
      left join ref.scientific_name as sciname on sciname.taxon = cname.taxon and sciname.is_preferred = true
      where cname.value ilike :query_startswith limit 8
  )
  union
  (
    select distinct 2 as class,
        format('%%s [%%s]', biname.binomial, sciname.value) as name,
        sciname.taxon as taxon
      from ref.scientific_name as biname
      left join ref.scientific_name as sciname on biname.taxon = sciname.taxon and sciname.is_preferred = true
      where biname.binomial ilike :query_startswith limit 8
  )
  union
  (
    select distinct 3 as class,
        format('%%s [%%s]', cname.value, sciname.value) as name,
        cname.taxon as taxon
      from ref.common_name as cname
      left join ref.scientific_name as sciname on sciname.taxon = cname.taxon and sciname.is_preferred = true
      where cname.value ilike :query_in limit 8
  )
  union
  (
    select distinct 4 as class,
        format('%%s [%%s]', biname.binomial, sciname.value) as name,
        sciname.taxon as taxon
      from ref.scientific_name as biname
      left join ref.scientific_name as sciname on biname.taxon = sciname.taxon and sciname.is_preferred = true
      where biname.binomial ilike :query_in limit 8
  )
)
select name, taxon
  from matching_taxon
  order by class asc, name asc
  limit 16
