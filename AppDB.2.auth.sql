--# auth 
create user app_owner nosuperuser nocreatedb login password 'app_owner';
create schema app_owner authorization app_owner;
create user app_user nosuperuser nocreatedb login password 'app_user';
grant usage on schema app_owner to app_user;
alter default privileges in schema app_owner grant select,insert,update,delete on tables to app_user;
alter role app_user set search_path to "$user",app_owner,public;
