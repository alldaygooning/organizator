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

create table if not exists users(
	id serial primary key,
	name varchar (50) not null unique,
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
