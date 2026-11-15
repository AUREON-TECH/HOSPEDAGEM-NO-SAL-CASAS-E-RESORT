begin;
-- Synthetic identities have no passwords or sessions and are rolled back with the entire test.
insert into auth.users(id,email,email_confirmed_at) values
('00000000-0000-4000-a000-000000000101','hns-qa-admin@example.invalid',now()),
('00000000-0000-4000-a000-000000000102','hns-qa-client@example.invalid',now());
insert into hns_private.admins values('00000000-0000-4000-a000-000000000101');
set local role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-4000-a000-000000000101',true);
do $$begin if not public.hns_is_admin() then raise exception 'Admin authorization failed';end if;end$$;
insert into public.hns_properties(id,title,nightly,capacity) values('00000000-0000-4000-a000-000000000201','__HNS_QA__',25000,4);
insert into public.hns_bookings(id,property_id,check_in,check_out,guests,guest_name,phone,status,total) values('00000000-0000-4000-a000-000000000301','00000000-0000-4000-a000-000000000201',current_date+10,current_date+12,2,'QA admin','00000000000','confirmed',50000);
do $$begin
 if (select count(*) from public.hns_nights where property_id='00000000-0000-4000-a000-000000000201')<>2 then raise exception 'Exclusive checkout nights failed';end if;
 begin
 insert into public.hns_bookings(property_id,check_in,check_out,guests,guest_name,phone,status,total) values('00000000-0000-4000-a000-000000000201',current_date+11,current_date+13,2,'Overlap','00000000000','confirmed',50000);
 raise exception 'Overlap incorrectly accepted';
 exception when unique_violation then null;when raise_exception then if sqlerrm<>'Período indisponível' then raise;end if;end;
end $$;
insert into public.hns_entries(kind,amount,description,reservation_id) values('income',10000,'QA payment','00000000-0000-4000-a000-000000000301');
select set_config('request.jwt.claim.sub','00000000-0000-4000-a000-000000000102',true);
do $$declare c integer;begin
 if public.hns_is_admin() then raise exception 'Client promoted to admin';end if;
 if exists(select 1 from public.hns_entries) then raise exception 'Finance exposed';end if;
 if exists(select 1 from public.hns_bookings where id='00000000-0000-4000-a000-000000000301') then raise exception 'Other client booking exposed';end if;
 update public.hns_properties set nightly=1 where id='00000000-0000-4000-a000-000000000201';get diagnostics c=row_count;if c<>0 then raise exception 'Client edited nightly';end if;
end $$;
insert into public.hns_bookings(id,property_id,check_in,check_out,guests,guest_name,phone,status,total) values('00000000-0000-4000-a000-000000000302','00000000-0000-4000-a000-000000000201',current_date+20,current_date+22,2,'QA client','00000000000','confirmed',1);
do $$begin
 if not exists(select 1 from public.hns_bookings where id='00000000-0000-4000-a000-000000000302' and status='pending' and total=50000) then raise exception 'Server pricing or pending status failed';end if;
 begin insert into public.hns_bookings(property_id,check_in,check_out,guests,guest_name,phone) values('00000000-0000-4000-a000-000000000201',current_date+30,current_date+32,8,'Over capacity','00000000000');raise exception 'Capacity bypass';exception when raise_exception then if sqlerrm<>'Quantidade acima da capacidade' then raise;end if;end;
end $$;
select set_config('request.jwt.claim.sub','00000000-0000-4000-a000-000000000101',true);
update public.hns_bookings set status='cancelled' where id='00000000-0000-4000-a000-000000000301';
do $$begin
 if exists(select 1 from public.hns_nights where property_id='00000000-0000-4000-a000-000000000201') then raise exception 'Cancellation did not release dates';end if;
 if not exists(select 1 from public.hns_entries where reservation_id='00000000-0000-4000-a000-000000000301') then raise exception 'Cancellation erased finance';end if;
end $$;
insert into public.hns_blocks(property_id,check_in,check_out) values('00000000-0000-4000-a000-000000000201',current_date+10,current_date+12);
do $$begin if (select count(*) from public.hns_nights where property_id='00000000-0000-4000-a000-000000000201')<>2 then raise exception 'Block failed';end if;end$$;
delete from public.hns_blocks where property_id='00000000-0000-4000-a000-000000000201';
do $$begin if exists(select 1 from public.hns_nights where property_id='00000000-0000-4000-a000-000000000201') then raise exception 'Unblock failed';end if;end$$;
reset role;
rollback;
select 'PASS: admin/client isolation, server pricing, capacity, date locks, cancellation, preserved finance and blocking' as result;
