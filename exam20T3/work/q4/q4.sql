-- COMP3311 20T3 Final Exam
-- Q4: list of long and short songs by each group

-- ... helper views and/or functions (if any) go here ...

drop function if exists q4();
drop type if exists SongCounts;
create type SongCounts as ( "group" text, nshort integer, nlong integer );

create or replace function
	q4() returns setof SongCounts
as $$
declare
	ns integer;
	nl integer;
	r1 record;
	r2 record;
	res SongCounts;
begin
	for r1 in select id, name from groups order by name
	loop
		res."group" := r1.name
		ns := 0; nl := 0
		for r2 in
			select s.id, s.length
			from Groups g join Albums a on g.id = a.made_by
				 join Songs s on a.id = s.on_album
			where g.id = r1.id 
		loop
			if r2.length < 180
			then 
				ns := ns + 1;
			elsif r2.length > 360
			then 
				nl := nl + 1;
			end if;
		end loop;
		res.nshort := ns; res.nlong := nl;
		return next res;
	end loop;
end;
$$ language plpgsql
;
