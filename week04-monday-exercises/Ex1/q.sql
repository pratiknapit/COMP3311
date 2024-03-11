
-- Q10 Bars where either Gernot or John drink

create or replace view Q10(bar)
as
select bar
from   Frequents
where  drinker = 'John' or drinker = 'Gernot'
;

-- or

create view JohnBars as
select bar from Frequents where  drinker = 'John';

create view GernotBars as
select bar from Frequents where  drinker = 'Gernot';

create or replace view altQ10(bar)
as
(select bar from JohnBars)
union
(select bar from GernotBars)
;

-- Q11 Bars where both Gernot and John drink

create or replace view badQ11(bar)
as
select bar
from   Frequents
where  drinker = 'John' and drinker = 'Gernot'
;

create or replace view altQ11(bar)
as
(select bar from JohnBars)
intersect
(select bar from GernotBars)
;


-- Q12 Bars where John drinks but Gernot doesn't

create or replace Q12(bar)
as
(select bar from JohnBars)
except
(select bar from GernotBars)
;

