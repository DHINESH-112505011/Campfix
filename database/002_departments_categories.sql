-- ============================================================
-- 002_departments_categories.sql
-- CampFix: departments and complaint categories
-- ============================================================

create table if not exists departments (
    id uuid primary key default uuid_generate_v4(),
    name text not null unique,
    code text not null unique,
    description text,
    head_profile_id uuid references profiles(id) on delete set null,
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

drop trigger if exists trg_departments_updated_at on departments;
create trigger trg_departments_updated_at
    before update on departments
    for each row
    execute function set_updated_at();

-- Now that departments exists, add the deferred FK from profiles
alter table profiles
    add constraint fk_profiles_department
    foreign key (department_id) references departments(id) on delete set null;

create table if not exists categories (
    id uuid primary key default uuid_generate_v4(),
    name text not null unique,
    description text,
    icon text,                         -- icon identifier string, matched to Flutter IconData mapping
    department_id uuid references departments(id) on delete set null,
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index if not exists idx_categories_department_id on categories(department_id);

drop trigger if exists trg_categories_updated_at on categories;
create trigger trg_categories_updated_at
    before update on categories
    for each row
    execute function set_updated_at();

-- Seed data (per §79)
insert into departments (name, code, description) values
    ('Electrical', 'ELEC', 'Handles all electrical maintenance issues'),
    ('Plumbing', 'PLUMB', 'Handles water, taps, and plumbing issues'),
    ('Housekeeping', 'HSKP', 'Handles cleaning and sanitation'),
    ('IT', 'IT', 'Handles IT equipment and network issues'),
    ('Civil', 'CIVIL', 'Handles building and civil/structural issues'),
    ('Hostel Maintenance', 'HOSTEL', 'Handles hostel-specific maintenance'),
    ('General Maintenance', 'GEN', 'Handles general/miscellaneous maintenance')
on conflict (code) do nothing;

insert into categories (name, description, icon, department_id) values
    ('Electrical', 'Fans, lights, wiring, sparking issues', 'electrical_services', (select id from departments where code = 'ELEC')),
    ('Plumbing', 'Taps, pipes, water leakage', 'plumbing', (select id from departments where code = 'PLUMB')),
    ('Cleaning', 'Sanitation and cleanliness issues', 'cleaning_services', (select id from departments where code = 'HSKP')),
    ('Furniture', 'Broken chairs, tables, desks', 'chair', (select id from departments where code = 'GEN')),
    ('IT', 'Computers, projectors, IT equipment', 'computer', (select id from departments where code = 'IT')),
    ('Restroom', 'Restroom-specific issues', 'wc', (select id from departments where code = 'HSKP')),
    ('Hostel', 'Hostel room and facility issues', 'apartment', (select id from departments where code = 'HOSTEL')),
    ('Civil', 'Building, walls, structural issues', 'foundation', (select id from departments where code = 'CIVIL')),
    ('AC', 'Air conditioning issues', 'ac_unit', (select id from departments where code = 'GEN')),
    ('Internet', 'Wi-Fi and network connectivity', 'wifi', (select id from departments where code = 'IT')),
    ('Other', 'Anything not covered above', 'more_horiz', (select id from departments where code = 'GEN'))
on conflict (name) do nothing;