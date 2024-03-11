-- COMP3311 20T3 Final Exam
-- Q1: longest album(s)

-- ... helper views (if any) go here ...

create or replace view album_lengths("group", title, year, length)
as
select g.name, a.title, a.year, sum(s.length) from Albums a
    join Songs s on s.on_album = a.id
    join Groups g on g.id = a.made_by
group by g.name, a.title, a.year
;

create or replace view q1("group",album,year)
as
select "group", title, year from album_lengths a
where a.length = (select max(b.length) from album_lengths b)
;

