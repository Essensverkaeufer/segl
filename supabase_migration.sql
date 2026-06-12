create extension if not exists pgcrypto;

create table if not exists public.segl_players (
  id uuid primary key default gen_random_uuid(),
  username text not null unique,
  password_hash text not null,
  password_salt text not null,
  pet_count bigint not null default 0 check (pet_count >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.segl_players enable row level security;

revoke all on table public.segl_players from anon, authenticated;

drop function if exists public.segl_register(text, text, text);
drop function if exists public.segl_login(text, text);
drop function if exists public.segl_pet(text, text);
drop function if exists public.segl_get_salt(text);
drop function if exists public.segl_leaderboard(integer);

create or replace function public.segl_get_salt(p_username text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_salt text;
begin
  select password_salt into v_salt
  from public.segl_players
  where username = lower(trim(p_username));

  return v_salt;
end;
$$;

create or replace function public.segl_register(
  p_username text,
  p_password_hash text,
  p_password_salt text
)
returns table(username text, pet_count bigint)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_username text := lower(trim(p_username));
begin
  if v_username is null or length(v_username) < 3 or length(v_username) > 20 then
    raise exception 'username must be 3-20 characters';
  end if;

  if v_username !~ '^[a-z0-9_]+$' then
    raise exception 'username can only use letters, numbers, and underscores';
  end if;

  if p_password_hash is null or length(p_password_hash) < 20 or p_password_salt is null or length(p_password_salt) < 8 then
    raise exception 'invalid password data';
  end if;

  insert into public.segl_players (username, password_hash, password_salt)
  values (v_username, p_password_hash, p_password_salt);

  return query
  select v_username, 0::bigint;
end;
$$;

create or replace function public.segl_login(
  p_username text,
  p_password_hash text
)
returns table(username text, pet_count bigint)
language plpgsql
security definer
set search_path = public
as $$
begin
  return query
  select sp.username, sp.pet_count
  from public.segl_players sp
  where sp.username = lower(trim(p_username))
    and sp.password_hash = p_password_hash;
end;
$$;

create or replace function public.segl_pet(
  p_username text,
  p_password_hash text
)
returns table(username text, pet_count bigint)
language plpgsql
security definer
set search_path = public
as $$
begin
  return query
  update public.segl_players sp
  set pet_count = sp.pet_count + 1,
      updated_at = now()
  where sp.username = lower(trim(p_username))
    and sp.password_hash = p_password_hash
  returning sp.username, sp.pet_count;
end;
$$;

create or replace function public.segl_leaderboard(p_limit integer default 10)
returns table(rank bigint, username text, pet_count bigint)
language sql
security definer
set search_path = public
as $$
  select row_number() over (order by pet_count desc, updated_at asc) as rank,
         username,
         pet_count
  from public.segl_players
  order by pet_count desc, updated_at asc
  limit greatest(1, least(coalesce(p_limit, 10), 50));
$$;

grant execute on function public.segl_get_salt(text) to anon, authenticated;
grant execute on function public.segl_register(text, text, text) to anon, authenticated;
grant execute on function public.segl_login(text, text) to anon, authenticated;
grant execute on function public.segl_pet(text, text) to anon, authenticated;
grant execute on function public.segl_leaderboard(integer) to anon, authenticated;
