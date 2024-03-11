-- COMP3311 20T3 Final Exam
-- Q2: group(s) with no albums

-- ... helper views (if any) go here ...

create or replace view q2("group")
as
select g.name
from Groups g left join Albums a on g.id = a.made_by
group by g.name
having count(a.id) = 0
;

