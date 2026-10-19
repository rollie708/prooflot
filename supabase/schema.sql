create extension if not exists pgcrypto;

create table if not exists public.assets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  category text not null,
  manufacturer text,
  model text,
  year integer check (year is null or year between 1900 and 2100),
  serial_number text,
  description text,
  location text,
  status text not null default 'pending' check (status in ('pending','verified','rejected')),
  public_slug text not null unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists assets_owner_created_idx on public.assets(owner_id, created_at desc);
alter table public.assets enable row level security;
create policy "Owners can manage their assets" on public.assets for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

create table if not exists public.evidence (
  id uuid primary key default gen_random_uuid(),
  asset_id uuid not null references public.assets(id) on delete cascade,
  owner_id uuid not null references auth.users(id) on delete cascade,
  file_path text not null unique,
  file_name text not null,
  mime_type text,
  size_bytes bigint not null,
  sha256 text not null,
  created_at timestamptz not null default now()
);
create index if not exists evidence_asset_idx on public.evidence(asset_id);
alter table public.evidence enable row level security;
create policy "Owners can manage evidence metadata" on public.evidence for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);

-- Explicit public projections avoid exposing owner IDs or private storage paths.
create or replace function public.get_shared_asset(asset_slug text)
returns table(id uuid, name text, category text, manufacturer text, model text, year integer, serial_number text, description text, location text, status text, public_slug text, created_at timestamptz)
language sql stable security definer set search_path = public
as $$ select a.id,a.name,a.category,a.manufacturer,a.model,a.year,a.serial_number,a.description,a.location,a.status,a.public_slug,a.created_at from public.assets a where a.public_slug=asset_slug $$;
create or replace function public.get_shared_evidence(p_asset_id uuid)
returns table(id uuid, file_name text, sha256 text, created_at timestamptz)
language sql stable security definer set search_path = public
as $$ select e.id,e.file_name,e.sha256,e.created_at from public.evidence e join public.assets a on a.id=e.asset_id where a.id=p_asset_id $$;

create table if not exists public.activity (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  asset_id uuid references public.assets(id) on delete set null,
  event_type text not null,
  description text not null,
  created_at timestamptz not null default now()
);
create index if not exists activity_owner_created_idx on public.activity(owner_id, created_at desc);
alter table public.activity enable row level security;
create policy "Owners can read activity" on public.activity for select using (auth.uid() = owner_id);
create policy "Owners can create activity" on public.activity for insert with check (auth.uid() = owner_id);

create table if not exists public.early_access (
  email text primary key check (length(email) <= 320),
  created_at timestamptz not null default now()
);
alter table public.early_access enable row level security;
create policy "Anyone can register early access email" on public.early_access for insert to anon, authenticated with check (true);
create policy "Anyone can repeat early access registration" on public.early_access for update to anon, authenticated using (true) with check (true);

insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('asset-evidence','asset-evidence',false,52428800,array['image/jpeg','image/png','image/webp','application/pdf','application/msword','application/vnd.openxmlformats-officedocument.wordprocessingml.document','application/vnd.ms-excel','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'])
on conflict (id) do nothing;
create policy "Owners upload evidence to their folder" on storage.objects for insert to authenticated with check (bucket_id='asset-evidence' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "Owners read evidence from their folder" on storage.objects for select to authenticated using (bucket_id='asset-evidence' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "Owners delete evidence from their folder" on storage.objects for delete to authenticated using (bucket_id='asset-evidence' and (storage.foldername(name))[1]=auth.uid()::text);
