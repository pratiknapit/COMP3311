-- Prac 04 Views

-- Q1 

create or replace view Q1 as
select count(*) as nacc from Accesses where accTime between '2005-03-02 00:00:00'and '2005-03-02 23:59:59';

-- Q2

create or replace view Q2 as
select count(*) as nsearches from Accesses where page like '%messageboard%' and params like '%state=search%';

-- Q3 - on which (distinct) machines in the Tuba Lab where WebCMS sessions run that were not terminated correctly (i.e. were uncompleted);
create or replace view Q3 as
select h.hostname from Hosts h join Sessions s on (h.id = s.host) where s.complete='F' and h.hostname like '%tuba%' order by h.hostname;
