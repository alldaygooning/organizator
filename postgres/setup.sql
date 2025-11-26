create table if not exists coordinates (
	id serial primary key,
	x integer not null check(x <= 442),
	y integer not null
);

create table if not exists address(
	id serial primary key,
	street varchar not null,
	zip varchar not null
);

create type organization_type as enum (
    'COMMERCIAL',
    'PUBLIC',
    'GOVERNMENT',
    'PRIVATE_LIMITED_COMPANY',
    'OPEN_JOINT_STOCK_COMPANY'
);

create table if not exists organization(
	id bigserial primary key,
	name varchar not null check (name <> ''),
	coordinates_id integer not null references coordinates(id),
	creation_date timestamp not null default current_timestamp,
	address_id integer references address(id),
	annual_turnover integer not null check (annual_turnover > 0),
	employees_count integer check (employees_count > 0),
	rating integer check (rating > 0),
	full_name varchar not null,
	type organization_type,
	postal_address_id integer not null references address(id)
); 

create type user_role as enum ('ADMIN', 'USER');

create table if not exists users(
	id serial primary key,
	name varchar (50) not null unique,
	role user_role not null default 'USER',
	hash varchar not null,
	salt varchar (10) not null
);

create table if not exists users_organizations(
	user_id integer not null references users(id),
    organization_id bigint not null references organization(id),
    primary key (user_id, organization_id)
);

alter table users_organizations 
drop constraint users_organizations_organization_id_fkey;

alter table users_organizations 
add constraint users_organizations_organization_id_fkey 
foreign key (organization_id) references organization(id) on delete cascade;





create or replace function deleteByType(owner_id integer, org_type organization_type)
returns table(deleted_id bigint) as $$
begin
    return query
    delete from organization 
    where id in (
        select uo.organization_id 
        from users_organizations uo 
        where uo.user_id = owner_id
    )
    and type = org_type
    returning id;
end;
$$ language plpgsql;




create or replace function getTotalRating()
returns integer as $$
declare
    total_rating integer;
begin
    select sum(rating) into total_rating
    from organization
    where rating is not null;
    
    return total_rating;
end;
$$ language plpgsql;




create or replace function getTopOrganizationIdsByTurnover()
returns table(org_id bigint) 
as $$
begin
    return query
    select id
    from organization
    order by annual_turnover desc
    limit 5;
end;
$$ language plpgsql;




create or replace function getAverageEmployeeCount()
returns decimal as $$
declare
    avg_employees decimal;
begin
    select avg(employees_count) into avg_employees
    from (
        select employees_count
        from organization
        where employees_count is not null
        order by annual_turnover desc
        limit 10
    ) as top_organizations;
    
    return avg_employees;
end;
$$ language plpgsql;




create or replace function groupByAddress()
returns table(
    address_id integer,
    organization_count bigint
) as $$
begin
    return query
    select 
        a.id as address_id,
        count(o.id) as organization_count
    from address a
    left join organization o on o.address_id = a.id
    group by a.id
    order by organization_count desc;
end;
$$ language plpgsql;


