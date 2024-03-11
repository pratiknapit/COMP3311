-- COMP3311 20T3 Final Exam
-- Q5: find genres that groups worked in

-- ... helper views and/or functions go here ...

drop function if exists q5();
drop type if exists GroupGenres;

create type GroupGenres as ("group" text, genres text);

create or replace function
    q5() returns setof GroupGenres
as $$
declare
    r1 record;
    r2 record;
    genres text;
    res GroupGenres;
begin
    for r1 in select id, name from Groups 
    loop
        res."group" := r1.name;
        genres := '';
        for r2 in select distinct genre from Albums where made_by = r1.id
        loop
            genres = genres||r2.genre||',';
        end loop;
        res.genres := genres;
        return next res;
    end loop;
end;
$$ language plpgsql
;

