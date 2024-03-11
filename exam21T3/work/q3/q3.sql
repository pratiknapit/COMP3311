-- COMP3311 21T3 Exam Q3
-- Unsold house(s) with the lowest listed price
-- Ordered by property ID

create or replace view PropAddr(id, uno, sno, street, stype, suburb, pcode)
as
select p.id, p.unit_no, p.street_no, st.name, st.stype, su.name, su.postcode
from Properties p 
join Streets st on p.street = st.id
join Suburbs su on st.suburb = su.id
;

create or replace view q3(id,price,street,suburb)
as
select p.id, p.list_price, a.sno||' '||a.street||' '||a.stype, a.suburb
from PropAddr a
join Properties p on p.id = a.id
where p.ptype = 'House' and p.sold_date is null
and
p.list_price = (select min(list_price) from Properties 
                        where ptype = 'House' and sold_price is null)


;
