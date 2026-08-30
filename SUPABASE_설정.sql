-- 이탈리아·슬로베니아 여행앱: 실시간 동기화 설정
-- Supabase Dashboard → SQL Editor → New query → 전체 붙여넣기 → Run

create extension if not exists pgcrypto;

create table if not exists public.trips (
  id uuid primary key default gen_random_uuid(),
  name text not null default '이탈리아·슬로베니아 여행',
  invite_code text not null unique,
  owner_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.trip_members (
  trip_id uuid not null references public.trips(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','member')),
  joined_at timestamptz not null default now(),
  primary key (trip_id,user_id)
);

create table if not exists public.trip_state (
  trip_id uuid primary key references public.trips(id) on delete cascade,
  state_json jsonb not null default '{}'::jsonb,
  updated_by uuid references auth.users(id) on delete set null,
  updated_client text,
  updated_at timestamptz not null default now()
);

alter table public.trips enable row level security;
alter table public.trip_members enable row level security;
alter table public.trip_state enable row level security;

-- 정책 안에서 membership 확인 시 RLS 재귀를 피하는 함수
create or replace function public.is_trip_member(p_trip_id uuid)
returns boolean
language sql
stable
security definer
set search_path=public
as $$
  select exists(
    select 1 from public.trip_members
    where trip_id=p_trip_id and user_id=auth.uid()
  );
$$;
revoke all on function public.is_trip_member(uuid) from public;
grant execute on function public.is_trip_member(uuid) to authenticated;

drop policy if exists "members can view trips" on public.trips;
drop policy if exists "authenticated can create trips" on public.trips;
drop policy if exists "members can view memberships" on public.trip_members;
drop policy if exists "users can add themselves as owner" on public.trip_members;
drop policy if exists "members can view trip state" on public.trip_state;
drop policy if exists "members can insert trip state" on public.trip_state;
drop policy if exists "members can update trip state" on public.trip_state;

create policy "members can view trips"
on public.trips for select to authenticated
using (owner_id=auth.uid() or public.is_trip_member(id));

create policy "authenticated can create trips"
on public.trips for insert to authenticated
with check (owner_id=auth.uid());

create policy "members can view memberships"
on public.trip_members for select to authenticated
using (user_id=auth.uid() or public.is_trip_member(trip_id));

create policy "users can add themselves as owner"
on public.trip_members for insert to authenticated
with check (
  user_id=auth.uid() and role='owner'
  and exists(select 1 from public.trips t where t.id=trip_id and t.owner_id=auth.uid())
);

create policy "members can view trip state"
on public.trip_state for select to authenticated
using (public.is_trip_member(trip_id));

create policy "members can insert trip state"
on public.trip_state for insert to authenticated
with check (public.is_trip_member(trip_id));

create policy "members can update trip state"
on public.trip_state for update to authenticated
using (public.is_trip_member(trip_id))
with check (public.is_trip_member(trip_id));

-- 초대코드를 아는 로그인 사용자만 멤버로 추가
create or replace function public.join_trip_by_code(p_invite_code text)
returns uuid
language plpgsql
security definer
set search_path=public
as $$
declare v_trip_id uuid;
begin
  if auth.uid() is null then raise exception 'Login required'; end if;
  select id into v_trip_id from public.trips
  where upper(invite_code)=upper(trim(p_invite_code)) limit 1;
  if v_trip_id is null then return null; end if;
  insert into public.trip_members(trip_id,user_id,role)
  values(v_trip_id,auth.uid(),'member')
  on conflict(trip_id,user_id) do nothing;
  return v_trip_id;
end;
$$;
revoke all on function public.join_trip_by_code(text) from public;
grant execute on function public.join_trip_by_code(text) to authenticated;

alter table public.trip_state replica identity full;

do $$
begin
  alter publication supabase_realtime add table public.trip_state;
exception when duplicate_object then null;
end $$;
