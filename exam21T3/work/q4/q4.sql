-- COMP3311 21T3 Exam Q4
-- Return address for a property, given its ID
-- Format: [UnitNum/]StreetNum StreetName StreetType, Suburb Postode
-- If property ID is not in the database, return 'No such property'

create or replace function address(propID integer) returns text
as
$$
declare
	addr text := '';
	uno integer;
	sno integer;
	street text;
	stype StreetType;
	suburb text;
	pcode integer;
	number text;
begin
	select p.unit_no, p.street_no, st.name, st.stype, su.name, su.postcode
	into uno, sno, street, stype, suburb, pcode
	from Properties p
		join Streets st on p.street = st.id
		join Suburbs su on st.suburb = su.id
	where p.id = propID;

	if not found then
		return 'No such property';
	end if;

	if uno is null then
		number := sno::text;
	else
		number := uno::text||'/'||sno::text;
	end if;
	return number||' '||street||' '||stype||', '||suburb||' '||pcode::text;		
end;
$$ language plpgsql;
