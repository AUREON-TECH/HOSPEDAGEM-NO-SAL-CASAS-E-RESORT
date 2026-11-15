create schema if not exists hns_private;
revoke all on schema hns_private from public;
grant usage on schema hns_private to authenticated;
create table hns_private.admins(user_id uuid primary key references auth.users(id));
create function hns_private.is_admin() returns boolean language sql stable security definer set search_path='' as $$select auth.uid() is not null and exists(select 1 from hns_private.admins where user_id=auth.uid())$$;
revoke all on function hns_private.is_admin() from public;
grant execute on function hns_private.is_admin() to authenticated;
create function public.hns_is_admin() returns boolean language sql stable security invoker set search_path='' as $$select hns_private.is_admin()$$;
revoke all on function public.hns_is_admin() from public;
grant execute on function public.hns_is_admin() to authenticated;
create table public.hns_properties(
 id uuid primary key default gen_random_uuid(), title text not null check(length(title) between 3 and 100),
 location text not null default 'Salinópolis, PA' check(length(location)<=160), description text not null default '' check(length(description)<=5000),
 capacity integer not null default 5 check(capacity between 1 and 50), nightly integer not null default 0 check(nightly between 0 and 100000000),
 amenities text[] not null default '{}', photos text[] not null default '{}', active boolean not null default true,
 created_at timestamptz not null default now());
create table public.hns_bookings(
 id uuid primary key default gen_random_uuid(), user_id uuid not null default auth.uid() references auth.users(id),
 property_id uuid not null references public.hns_properties(id), check_in date not null,check_out date not null,
 guests integer not null check(guests between 1 and 50), guest_name text not null check(length(guest_name) between 2 and 120),
 phone text not null check(length(phone) between 8 and 30), notes text not null default '' check(length(notes)<=2000),
 status text not null default 'pending' check(status in ('pending','confirmed','completed','cancelled','declined')),
 total integer not null default 0 check(total between 0 and 100000000), created_at timestamptz not null default now(),
 check(check_out>check_in and check_out-check_in<=90));
create index hns_bookings_user on public.hns_bookings(user_id);
create index hns_bookings_property on public.hns_bookings(property_id);
create table public.hns_blocks(id uuid primary key default gen_random_uuid(),property_id uuid not null references public.hns_properties(id),check_in date not null,check_out date not null,reason text not null default 'Uso do proprietário' check(length(reason)<=300),check(check_out>check_in and check_out-check_in<=365));
create table public.hns_nights(property_id uuid not null references public.hns_properties(id),night date not null,booking_id uuid references public.hns_bookings(id) on delete cascade,block_id uuid references public.hns_blocks(id) on delete cascade,primary key(property_id,night));
create index hns_nights_booking on public.hns_nights(booking_id);
create index hns_nights_block on public.hns_nights(block_id);
create table public.hns_entries(
 id uuid primary key default gen_random_uuid(),kind text not null check(kind in ('income','expense')),
 amount integer not null check(amount>0 and amount<=100000000),description text not null check(length(description) between 2 and 200),
 category text not null default 'Outros' check(length(category)<=80),entry_date date not null default current_date,
 reservation_id uuid references public.hns_bookings(id),created_at timestamptz not null default now());
create index hns_entries_reservation on public.hns_entries(reservation_id);
create function hns_private.booking_check() returns trigger language plpgsql security definer set search_path='' as $$
declare p public.hns_properties; begin
 select * into p from public.hns_properties where id=new.property_id for update;
 if p.id is null or (not p.active and not hns_private.is_admin()) then raise exception 'Hospedagem indisponível';end if;
 if new.guests>p.capacity then raise exception 'Quantidade acima da capacidade';end if;
 if TG_OP='INSERT' then
  if new.check_in < (now() at time zone 'America/Sao_Paulo')::date then raise exception 'Escolha uma entrada a partir de hoje';end if;
  if not hns_private.is_admin() then new.status:='pending';new.user_id:=auth.uid();new.total:=p.nightly*(new.check_out-new.check_in);end if;
 end if;
 if TG_OP='UPDATE' and (new.user_id<>old.user_id or new.property_id<>old.property_id or new.check_in<>old.check_in or new.check_out<>old.check_out) then raise exception 'Para alterar datas ou imóvel, cancele e crie outra reserva';end if;
 if TG_OP='UPDATE' and old.status in ('cancelled','declined','completed') and new.status<>old.status then raise exception 'Reserva encerrada. Crie uma nova solicitação';end if;
 if new.status='confirmed' and new.total<=0 then raise exception 'Informe o valor combinado antes de confirmar';end if;
 if TG_OP='INSERT' and exists(select 1 from public.hns_nights where property_id=new.property_id and night>=new.check_in and night<new.check_out) then raise exception 'Período indisponível';end if;
 return new;end $$;
create trigger hns_booking_check before insert or update on public.hns_bookings for each row execute function hns_private.booking_check();
create function hns_private.sync_nights() returns trigger language plpgsql security definer set search_path='' as $$begin
 if TG_TABLE_NAME='hns_bookings' then
 delete from public.hns_nights where booking_id=new.id;
 if new.status in ('confirmed','completed') then insert into public.hns_nights(property_id,night,booking_id) select new.property_id,d::date,new.id from generate_series(new.check_in::timestamp,(new.check_out-1)::timestamp,'1 day') d;end if;
 else
 insert into public.hns_nights(property_id,night,block_id) select new.property_id,d::date,new.id from generate_series(new.check_in::timestamp,(new.check_out-1)::timestamp,'1 day') d;
 end if;return new;end $$;
create trigger hns_booking_nights after insert or update on public.hns_bookings for each row execute function hns_private.sync_nights();
create trigger hns_block_nights after insert on public.hns_blocks for each row execute function hns_private.sync_nights();
revoke all on function hns_private.booking_check(),hns_private.sync_nights() from public;
alter table public.hns_properties enable row level security;
alter table public.hns_bookings enable row level security;
alter table public.hns_blocks enable row level security;
alter table public.hns_nights enable row level security;
alter table public.hns_entries enable row level security;
create policy hns_catalog on public.hns_properties for select to anon,authenticated using(active);
create policy hns_manage_properties on public.hns_properties for all to authenticated using(hns_private.is_admin()) with check(hns_private.is_admin());
create policy hns_own_bookings on public.hns_bookings for select to authenticated using(user_id=(select auth.uid()) or hns_private.is_admin());
create policy hns_request_booking on public.hns_bookings for insert to authenticated with check(user_id=(select auth.uid()));
create policy hns_manage_bookings on public.hns_bookings for update to authenticated using(hns_private.is_admin()) with check(hns_private.is_admin());
create policy hns_blocks_admin on public.hns_blocks for all to authenticated using(hns_private.is_admin()) with check(hns_private.is_admin());
create policy hns_availability on public.hns_nights for select to anon,authenticated using(true);
create policy hns_finance on public.hns_entries for all to authenticated using(hns_private.is_admin()) with check(hns_private.is_admin());
revoke all on public.hns_properties,public.hns_bookings,public.hns_blocks,public.hns_nights,public.hns_entries from anon,authenticated;
grant select on public.hns_properties to anon,authenticated;
grant insert,update on public.hns_properties to authenticated;
grant select,insert,update on public.hns_bookings to authenticated;
grant select,insert,delete on public.hns_blocks to authenticated;
grant select(property_id,night) on public.hns_nights to anon,authenticated;
grant select,insert on public.hns_entries to authenticated;
insert into public.hns_properties(title,description,capacity,amenities,photos) values('Beach Resort • Apartamento de 1 quarto','Dias de descanso em Salinas, com lazer e conforto para a família. Acomodação anunciada para até 4 adultos e 1 criança de até 4 anos. Consulte condições e disponibilidade com a gestão.',5,array['Piscinas','Lazer em família','1 quarto','Até 4 adultos + 1 criança'],array['./resort.jpg']);
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types) values('hns-photos','hns-photos',true,8388608,array['image/jpeg','image/png','image/webp']);
create policy hns_photo_read on storage.objects for select to anon,authenticated using(bucket_id='hns-photos');
create policy hns_photo_write on storage.objects for insert to authenticated with check(bucket_id='hns-photos' and hns_private.is_admin());
create policy hns_photo_delete on storage.objects for delete to authenticated using(bucket_id='hns-photos' and hns_private.is_admin());
