-- COMP3311 20T3 Final Exam
-- Q3:  performer(s) who play many instruments

-- ... helper views (if any) go here ...

create or replace view PlayedOn(performer, song, instrument)
as
select performer, song,
    case when instrument like '%guitar%' then 'guitar'
         else instrument
    end
from PlaysOn
where instrument <> 'vocals'
;

create or replace view totalInstr(ninstr)
as
select count(distinct instrument)
from PlayedOn
;

create or replace view nInstrPlayed(pid, name, ninstr)
as
select p.id, p.name, count(distinct pl.instrument)
from Performers p join PlayedOn pl on p.id = pl.performer
group by p.id, p.name
;

create or replace view q3(performer,ninstruments)
as
select p.name, p.ninstr
from nInstrPlayed p
where p.ninstr > ((select ninstr from totalInstr)/2)
;

