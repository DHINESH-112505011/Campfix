-- ============================================================
-- 001_initial_schema.sql
-- CampFix: profiles table (extends Supabase auth.users)
-- ============================================================

create extension if not exists "uuid-ossp";

create table if not exists profiles (
    id uuid primary key default uuid_generate_v4(),
    auth_user_id uuid not null unique references auth.users(id) on delete cascade,
    full_name text not null,
    email text not null,
    phone text,
    role text not null default 'STUDENT'
        check (role in ('STUDENT', 'STAFF', 'ADMIN', 'SUPER_ADMIN')),
    student_or_staff_id text,
    department_id uuid,               -- FK added in 002 after departments table exists
    staff_specialization text,        -- e.g. Electrician, Plumber (relevant only for STAFF role)
    avatar_url text,
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index if not exists idx_profiles_auth_user_id on profiles(auth_user_id);
create index if not exists idx_profiles_role on profiles(role);
create index if not exists idx_profiles_department_id on profiles(department_id);

-- Auto-update updated_at on every row change
create or replace function set_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

drop trigger if exists trg_profiles_updated_at on profiles;
create trigger trg_profiles_updated_at
    before update on profiles
    for each row
    execute function set_updated_at();

-- Automatically create a profile row whenever a new auth user signs up.
-- Role always defaults to STUDENT here regardless of what metadata claims,
-- closing the loop on "never allow self-registration as ADMIN" (§7).
create or replace function handle_new_user()
returns trigger as $$
begin
    insert into public.profiles (auth_user_id, full_name, email, phone, student_or_staff_id, role)
    values (
        new.id,
        coalesce(new.raw_user_meta_data->>'full_name', 'New User'),
        new.email,
        new.raw_user_meta_data->>'phone',
        new.raw_user_meta_data->>'student_or_staff_id',
        'STUDENT'
    );
    return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert on auth.users
    for each row
    execute function handle_new_user();