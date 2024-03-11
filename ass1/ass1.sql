-- COMP3311 22T3 Assignment 1
--
-- Fill in the gaps ("...") below with your code
-- You can add any auxiliary views/function that you like
-- The code in this file *MUST* load into an empty database in one pass
-- It will be tested as follows:
-- createdb test; psql test -f ass1.dump; psql test -f ass1.sql
-- Make sure it can load without error under these conditions


-- Q1: new breweries in Sydney in 2020

create or replace view Q1(brewery,suburb)
as
select b.name, l.town
from Breweries b join Locations l on (b.located_in = l.id)
where b.founded=2020 and l.metro='Sydney'
;

-- Q2: beers whose name is same as their style

create or replace view Q2(beer,brewery)
as
select b.name, r.name from Beers b
	join Brewed_by y on (b.id = y.beer)
	join Breweries r on (r.id = y.brewery)
	join Styles s on (b.style = s.id)
where b.name = s.name
;

-- Q3: original Californian craft brewery

create or replace view minFounded
as
select min(b2.founded) 
from Breweries b2 join Locations l2 on (b2.located_in = l2.id)
where l2.region = 'California';


create or replace view Q3(brewery,founded)
as
select b1.name, b1.founded 
from Breweries b1 join Locations l1 on (b1.located_in = l1.id)
where l1.region = 'California' 
and b1.founded = (select * from minFounded)
;

-- Q4: all IPA variations, and how many times each occurs

create or replace view Q4(style,count)
as
select s.name, count(s.name) 
from Styles s join Beers b on (b.style = s.id)
where s.name like '%IPA%'
group by s.name 
;

-- Q5: all Californian breweries, showing precise location

create or replace view Q5helper1(brewery, location)
as
select b.name, l.town 
from Breweries b join Locations l on (b.located_in = l.id)
where l.region = 'California' 
and l.town is not null;

create or replace view Q5helper2(brewery, location)
as 
select b.name, l.metro
from Breweries b join Locations l on (b.located_in = l.id)
where l.region = 'California' 
and l.town is null;


create or replace view Q5(brewery,location)
as
select brewery, location from Q5helper1
union
select brewery, location from Q5helper2
;

-- Q6: strongest barrel-aged beer

create or replace view BarrelAged
as
select * 
from Beers
where notes like '%barrel%aged%'
or notes like '%aged%barrel%';

create or replace view StrongestBABeer(abv)
as
select max(ABV) 
from BarrelAged;

create or replace view Q6(beer,brewery,abv)
as
select b.name, r.name, b.abv 
from Beers b 
	join Brewed_by y on (b.id = y.beer)
	join Breweries r on (r.id = y.brewery)
where b.abv = (select * from StrongestBABeer)
;

-- Q7: most popular hop

create or replace view ContainsIng(beer, ingredient)
as
select b.name, i.name 
from Beers b
	join Contains c on (b.id = c.beer)
	join Ingredients i on (i.id = c.ingredient)
where i.itype = 'hop'
;

create or replace view AggBeerIng(ingredient, ingredientCount)
as 
select ingredient, count(ingredient)
from ContainsIng 
group by ingredient;

create or replace view Q7(hop)
as
select i1.ingredient
from AggBeerIng i1
where i1.ingredientCount = (select max(i2.ingredientCount) 
			    from AggBeerIng i2)
;

-- Q8: breweries that don't make IPA or Lager or Stout (any variation thereof)

create or replace view CommonStyles
as 
select * from Styles where name like '%IPA%'
union
select * from Styles where name like '%Lager%'
union
select * from Styles where name like '%Stout%';

create or replace view CommonBeer(id,beer,styleName)
as
select b.id, b.name, s.name 
from Beers b join CommonStyles s on (b.style = s.id);

create or replace view CommonBeerBrew(brewery)
as
select distinct r.name 
from Breweries r 
	join Brewed_by y on (r.id = y.brewery)
	join CommonBeer b on (b.id = y.beer)
;

create or replace view Q8(brewery)
as
select r1.name from Breweries r1
except
select r2.brewery from CommonBeerBrew r2;
;

-- Q9: most commonly used grain in Hazy IPAs

create or replace view Q9Helper1(ingredient, countBeer)
as
select i.name, count(b.name)
from Beers b 
	join Styles s on (b.style = s.id)
	join Contains c on (b.id = c.beer)
	join Ingredients i on (c.ingredient = i.id)
where s.name = 'Hazy IPA' and i.itype = 'grain'
group by i.name
;

create or replace view Q9(grain)
as
select q.ingredient from Q9Helper1 q 
where q.countBeer = (select max(countBeer) from Q9Helper1)
;

-- Q10: ingredients not used in any beer

-- first get the set of all ingredients that are used in beers
create or replace view Q10Helper(ingredient)
as
select distinct i.name 
from Beers b 
	join Contains c on (b.id = c.beer)
	join Ingredients i on (i.id = c.ingredient)
;

-- take the set of all beers and remove the set from above to get set of ingredients used in no beers
create or replace view Q10(unused)
as
select name from Ingredients 
except 
select ingredient from Q10Helper
;

-- Q11: min/max abv for a given country

drop type if exists ABVrange cascade;
create type ABVrange as (minABV float, maxABV float);

create or replace view Q11Helper(beer, ABV, brewery, country)
as
select b.name, b.ABV, r.name, l.country
from Breweries r 
	join Locations l on (r.located_in = l.id)
	join Brewed_by y on (r.id = y.brewery)
	join Beers b on (b.id = y.beer)
;

create or replace function
	Q11(_country text) returns ABVrange
as $$
declare
	_minABV float;
	_maxABV float;
begin 


	select coalesce(min(q.ABV), 0.0) into _minABV::numeric(4,1)
	from Q11Helper q 
	where q.country = _country;
	
	select coalesce(max(q.ABV), 0.0) into _maxABV::numeric(4,1)
	from Q11Helper q 
	where q.country = _country;
	
	return (_minABV, _maxABV);
end;
$$
language plpgsql;

-- Q12: details of beers

drop type if exists BeerData cascade;
create type BeerData as (beer text, brewer text, info text);

create or replace view Q12Helper(bid, beer, brewery, ingType, ingName)
as
select b.id, b.name, r.name, i.itype, i.name
from Beers b 
	join Brewed_by y on (b.id = y.beer)
	join Breweries r on (r.id = y.brewery)
	left outer join Contains c on (b.id = c.beer)
	left outer join Ingredients i on (i.id = c.ingredient)
;

create or replace view Q12AggIng(bid, beer, brewery, ingType, ingName)
as
select bid, beer, brewery, ingType, string_agg(ingName, ',' order by ingName) IngName
from Q12Helper
group by bid, beer, brewery, ingType
order by bid, brewery
;

create or replace view Q12AggBrew(beer, brewery, ingType, ingName)
as
select beer, string_agg(brewery, ' + ' order by brewery) Brewery, ingType, ingName
from Q12AggIng
group by bid, beer, ingType, ingName
;

create or replace function
	Q12HelpFunction(partial_name text) returns setof BeerData
as $$
declare
	rec record;
	res Beerdata;
	correctType text;
	info_res text;

begin

	for rec in 
		select * 
		from Q12AggBrew b
		where lower(b.beer) like '%'||lower(partial_name)||'%'
	loop 
		if (rec.ingType = 'hop') then
			correctType := 'Hops';
		elsif (rec.ingType = 'grain') then
			correctType := 'Grain';
		elsif (rec.ingType = 'adjunct') then
			correctType := 'Extras';
		else
			info_res := rec.ingType;
			return next (rec.beer, rec.brewery, info_res);
		end if;

		info_res := correctType || ': ' || rec.ingName;

		return next (rec.beer, rec.brewery, info_res);

	end loop;
	return;
end;
$$
language plpgsql;

create or replace function
	Q12(partial_name text) returns setof BeerData
as $$
begin
	return query
	select beer, brewer, string_agg(info, E'\n')
	from Q12HelpFunction(partial_name)
	group by beer, brewer;
end;
$$
language plpgsql;







qry3 = '''
select rc.name, m.run_on, r.id, r.prize, r.length
from RaceCourses rc
join Meetings m on rc.id = m.run_at
join Races r on r.part_of = m.id
where rc.name = %s
and m.run_on = %s
'''

qry4 = '''
select h.name, j.name, r.finished
from Horses h 
join Runners ru on ru.horse = h.id
join Jockeys j on ru.jockey = j.id
where r.id = %s
'''