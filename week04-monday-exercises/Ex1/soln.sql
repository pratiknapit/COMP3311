
-- Q10. Bars where either Gernot or John drink.

create or replace view bar_and_drinker as
select bar, drinker
from   Frequents
;

create or replace view Q10 as
select bar from Bar_and_drinker where drinker = 'John'
union
select bar from Bar_and_drinker where drinker = 'Gernot'
;

create or replace view altQ10 as
select bar
from   Bar_and_drinker
where  drinker = 'Gernot' or drinker = 'John'
;

-- Q11. Bars where both Gernot and John drink.

create or replace view Q11 as
select bar from Bar_and_drinker where drinker = 'John'
intersect
select bar from Bar_and_drinker where drinker = 'Gernot'
;

-- always returns zero tuples
create or replace view badQ11 as
select bar
from   Bar_and_drinker
where  drinker = 'Gernot' and drinker = 'John'
;

-- Q12. Bars where John drinks but Gernot doesn't

create or replace view Q12 as
select bar from Bar_and_drinker where drinker = 'John'
except
select bar from Bar_and_drinker where drinker = 'Gernot'
;

-- Q13. Which bar sells 'New' cheapest?

create or replace Beer_bar_prices as
select *
from   Sells
;

create or replace view Q13 as
select bar
from   Beer_bar_prices
where  beer = 'New' and
         price = (select min(price)
                  from   Beer_bar_prices
                  where  beer = 'New')
;

-- Q14. Find bars that serve New at the same price
--      as the Coogee Bay Hotel charges for VB.

create or replace view CBH_VB_price as
select price
from   Sells
where  bar = 'Coogee Bay Hotel'
         and beer = 'Victoria Bitter';
;

create or replace view Q14 as
select bar
from   Sells
where  beer = 'New'
         and price = (select price from CBH_VB_price)
;

-- Q15. Find the average price of common beers
--      ("common" = served in more than two hotels).

create or replace view Q15 as
select beer, avg(price)::numeric(5,2)) as "AvgPrice"
from   Sells
group  by beer
having count(bar) > 2
;
