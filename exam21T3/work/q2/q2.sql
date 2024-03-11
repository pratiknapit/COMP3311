-- COMP3311 21T3 Exam Q2
-- Number of unsold properties of each type in each suburb
-- Ordered by type, then suburb

create or replace view q2(suburb, ptype, nprops)
as
select s.name, p.ptype, count(s.name)
from Suburbs s
join Streets t on t.suburb = s.id
join Properties p on p.street = t.id
where p.sold_date is null
group by s.name, p.ptype
order by p.ptype, s.name
;
