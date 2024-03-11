-- return a given drinker's favourite beers

create or replace function
   favBeers(_drinker text) returns setof Beers
as $$
declare
	res record;
begin
	for res in
		select b.*
		from   Beers b join Likes L on L.beer = b.name
		where  L.drinker = _drinker
	loop
		return next res;
	end loop;
end;
$$ language plpgsql;
