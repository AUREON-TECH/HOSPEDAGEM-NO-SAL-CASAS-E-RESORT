alter table public.hns_properties alter column capacity drop not null;
alter table public.hns_properties alter column capacity drop default;
update public.hns_properties set title='Beach' where title='Beach Resort • Apartamento de 1 quarto';
insert into public.hns_properties(title,description,capacity) values('Park','',null),('Exclusive','',null),('Premium','',null),('Aqualand','',null);
create table hns_private.admin_emails(email text primary key);
-- The email allowlist is configured privately, outside this source tree.
create or replace function hns_private.is_admin() returns boolean language sql stable security definer set search_path='' as $$select auth.uid() is not null and (exists(select 1 from hns_private.admins where user_id=auth.uid()) or exists(select 1 from auth.users u join hns_private.admin_emails a on a.email=lower(u.email) where u.id=auth.uid() and u.email_confirmed_at is not null))$$;
