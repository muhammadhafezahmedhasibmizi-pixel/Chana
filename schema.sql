-- Mistri Khujun production schema for Supabase/PostgreSQL
create extension if not exists pgcrypto;
create type public.user_role as enum ('customer','technician','admin');
create type public.technician_status as enum ('pending','verified','rejected','suspended');

create table if not exists public.profiles(id uuid primary key references auth.users(id) on delete cascade,full_name text not null,phone text,avatar_url text,role public.user_role not null default 'customer',created_at timestamptz not null default now(),updated_at timestamptz not null default now());
create table if not exists public.categories(id uuid primary key default gen_random_uuid(),name text not null,slug text unique not null,icon text,color text,active boolean not null default true,created_at timestamptz not null default now());
create table if not exists public.divisions(id uuid primary key default gen_random_uuid(),name text unique not null,slug text unique not null);
create table if not exists public.districts(id uuid primary key default gen_random_uuid(),division_id uuid not null references public.divisions(id) on delete cascade,name text not null,slug text not null,unique(division_id,slug));
create table if not exists public.upazilas(id uuid primary key default gen_random_uuid(),district_id uuid not null references public.districts(id) on delete cascade,name text not null,slug text not null,unique(district_id,slug));
create table if not exists public.areas(id uuid primary key default gen_random_uuid(),upazila_id uuid not null references public.upazilas(id) on delete cascade,name text not null,slug text not null,unique(upazila_id,slug));
create table if not exists public.technicians(id uuid primary key default gen_random_uuid(),user_id uuid unique not null references auth.users(id) on delete cascade,full_name text not null,phone text not null,email text,avatar_url text,category_id uuid references public.categories(id),division_id uuid references public.divisions(id),district_id uuid references public.districts(id),upazila_id uuid references public.upazilas(id),area_id uuid references public.areas(id),experience integer not null default 0 check(experience>=0),description text,available_time text,whatsapp text,verification_info text,status public.technician_status not null default 'pending',verified boolean not null default false,rating numeric(2,1) not null default 0,review_count integer not null default 0,created_at timestamptz not null default now(),updated_at timestamptz not null default now());
create table if not exists public.technician_work_images(id uuid primary key default gen_random_uuid(),technician_id uuid not null references public.technicians(id) on delete cascade,storage_path text not null,caption text,created_at timestamptz not null default now());
create table if not exists public.reviews(id uuid primary key default gen_random_uuid(),technician_id uuid not null references public.technicians(id) on delete cascade,user_id uuid not null references auth.users(id) on delete cascade,rating integer not null check(rating between 1 and 5),review_text text,created_at timestamptz not null default now(),unique(technician_id,user_id));
create table if not exists public.favorites(id uuid primary key default gen_random_uuid(),technician_id uuid not null references public.technicians(id) on delete cascade,user_id uuid not null references auth.users(id) on delete cascade,created_at timestamptz not null default now(),unique(technician_id,user_id));
create table if not exists public.contact_requests(id uuid primary key default gen_random_uuid(),name text not null,phone text not null,email text,message text not null,status text not null default 'new',created_at timestamptz not null default now());
create table if not exists public.hero_banners(id uuid primary key default gen_random_uuid(),title text,subtitle text,image_url text not null,category_id uuid references public.categories(id),active boolean not null default true,sort_order integer not null default 0,created_at timestamptz not null default now());
create table if not exists public.admin_users(user_id uuid primary key references auth.users(id) on delete cascade,created_at timestamptz not null default now());

create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.admin_users where user_id=auth.uid()); $$;
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$ begin insert into public.profiles(id,full_name,phone,role) values(new.id,coalesce(new.raw_user_meta_data->>'full_name','User'),new.raw_user_meta_data->>'phone',coalesce((new.raw_user_meta_data->>'role')::public.user_role,'customer')) on conflict(id) do nothing; return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users; create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

create or replace function public.refresh_technician_rating() returns trigger language plpgsql security definer set search_path=public as $$ begin update public.technicians t set rating=coalesce((select round(avg(rating)::numeric,1) from public.reviews where technician_id=coalesce(new.technician_id,old.technician_id)),0),review_count=(select count(*) from public.reviews where technician_id=coalesce(new.technician_id,old.technician_id)) where t.id=coalesce(new.technician_id,old.technician_id); return coalesce(new,old); end; $$;
drop trigger if exists reviews_rating_refresh on public.reviews; create trigger reviews_rating_refresh after insert or update or delete on public.reviews for each row execute procedure public.refresh_technician_rating();

insert into public.categories(name,slug,icon) values
('ইলেকট্রিশিয়ান','electrician','⚡'),('প্লাম্বার','plumber','🔧'),('AC মিস্ত্রি','ac-technician','❄️'),('রাজমিস্ত্রি','mason','🧱'),('রং মিস্ত্রি','painter','🎨'),('কাঠমিস্ত্রি','carpenter','🪚'),('ওয়েল্ডিং মিস্ত্রি','welder','🔥'),('গাড়ি মেকানিক','car-mechanic','🚗'),('বাইক মেকানিক','bike-mechanic','🏍️'),('টাইলস মিস্ত্রি','tile','▦'),('অ্যালুমিনিয়াম/গ্লাস মিস্ত্রি','aluminium-glass','▣'),('ফার্নিচার মিস্ত্রি','furniture','🪑'),('নির্মাণ শ্রমিক/হেলপার','helper','👷'),('ক্লিনিং কর্মী','cleaning','🧹'),('বাগানের কর্মী','garden','🌿'),('অন্যান্য','other','✦') on conflict(slug) do nothing;
insert into public.divisions(name,slug) values ('ঢাকা','dhaka'),('চট্টগ্রাম','chattogram'),('রাজশাহী','rajshahi'),('খুলনা','khulna'),('বরিশাল','barishal'),('সিলেট','sylhet'),('রংপুর','rangpur'),('ময়মনসিংহ','mymensingh') on conflict(slug) do nothing;

alter table public.profiles enable row level security; alter table public.categories enable row level security; alter table public.divisions enable row level security; alter table public.districts enable row level security; alter table public.upazilas enable row level security; alter table public.areas enable row level security; alter table public.technicians enable row level security; alter table public.technician_work_images enable row level security; alter table public.reviews enable row level security; alter table public.favorites enable row level security; alter table public.contact_requests enable row level security; alter table public.hero_banners enable row level security; alter table public.admin_users enable row level security;

do $$ declare t text; begin foreach t in array array['categories','divisions','districts','upazilas','areas'] loop execute format('drop policy if exists public_read_%s on public.%s',t,t); execute format('create policy public_read_%s on public.%s for select using (true)',t,t); end loop; end $$;
create policy "public read verified technicians" on public.technicians for select using (status='verified' or user_id=auth.uid() or public.is_admin());
create policy "technician insert own" on public.technicians for insert with check(user_id=auth.uid());
create policy "technician update own" on public.technicians for update using(user_id=auth.uid() or public.is_admin()) with check(user_id=auth.uid() or public.is_admin());
create policy "admin delete technicians" on public.technicians for delete using(public.is_admin());
create policy "public read verified images" on public.technician_work_images for select using(exists(select 1 from technicians t where t.id=technician_id and t.status='verified') or public.is_admin());
create policy "owner manage images" on public.technician_work_images for all using(exists(select 1 from technicians t where t.id=technician_id and t.user_id=auth.uid()) or public.is_admin()) with check(exists(select 1 from technicians t where t.id=technician_id and t.user_id=auth.uid()) or public.is_admin());
create policy "public read reviews" on public.reviews for select using(true);
create policy "auth create review" on public.reviews for insert with check(auth.uid()=user_id and exists(select 1 from technicians t where t.id=technician_id and t.status='verified'));
create policy "own review update" on public.reviews for update using(auth.uid()=user_id or public.is_admin()) with check(auth.uid()=user_id or public.is_admin());
create policy "own review delete" on public.reviews for delete using(auth.uid()=user_id or public.is_admin());
create policy "own favorites" on public.favorites for all using(auth.uid()=user_id) with check(auth.uid()=user_id);
create policy "anyone contact insert" on public.contact_requests for insert with check(true);
create policy "admin contact read" on public.contact_requests for select using(public.is_admin());
create policy "admin contact update" on public.contact_requests for update using(public.is_admin());
create policy "public active banners" on public.hero_banners for select using(active=true or public.is_admin());
create policy "admin banner manage" on public.hero_banners for all using(public.is_admin()) with check(public.is_admin());
create policy "own profile" on public.profiles for select using(auth.uid()=id or public.is_admin());
create policy "own profile update" on public.profiles for update using(auth.uid()=id or public.is_admin()) with check(auth.uid()=id or public.is_admin());
create policy "admin manage admin_users" on public.admin_users for all using(public.is_admin()) with check(public.is_admin());

insert into storage.buckets(id,name,public) values('avatars','avatars',true),('work-images','work-images',true) on conflict(id) do nothing;
