-- Girne Ev Arama — Supabase table + policies.
-- Run this once in your Supabase project's SQL Editor (SQL Editor -> New query -> paste -> Run).

create extension if not exists pgcrypto;

create table if not exists ilanlar (
  id uuid primary key default gen_random_uuid(),
  baglanti text,
  baslik text,
  foto_url text,
  kira text,
  para_birimi text,
  oda text,
  banyo text,
  kira_suresi text,
  telefon text,
  mahalle text,
  ziyaret_tarihi timestamptz,
  lat double precision,
  lng double precision,
  durum text not null default 'İletişime geçilecek',
  favori boolean not null default false,
  notlar text,
  eklenme timestamptz not null default now(),
  guncelleme timestamptz not null default now()
);

-- If you already ran an earlier version of this file and the table exists
-- without these columns, run this once to add them:
-- alter table ilanlar add column if not exists mahalle text;
-- alter table ilanlar add column if not exists ziyaret_tarihi timestamptz;
-- alter table ilanlar add column if not exists lat double precision;
-- alter table ilanlar add column if not exists lng double precision;

alter table ilanlar enable row level security;

-- No per-user login: this app is a single shared link (the publishable API
-- key is public in the page source by design for a client-only app), so
-- access control is "whoever has the link/key", not "whoever is logged in
-- as whom". Requests made with the publishable key run as Postgres's
-- built-in "anon" role, so these policies grant that role full read/write
-- on this one table. See README.md for the trade-off this implies.
create policy "public read" on ilanlar
  for select using (true);

create policy "public insert" on ilanlar
  for insert with check (true);

create policy "public update" on ilanlar
  for update using (true);

create policy "public delete" on ilanlar
  for delete using (true);
