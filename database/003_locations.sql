-- ============================================================
-- 003_locations.sql
-- CampFix: structured campus location hierarchy
-- ============================================================

create table if not exists locations (
    id uuid primary key default uuid_generate_v4(),
    campus text not null default 'Main Campus',
    building text not null,
    block text,
    floor text,
    room text,
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index if not exists idx_locations_building on locations(building);

drop trigger if exists trg_locations_updated_at on locations;
create trigger trg_locations_updated_at
    before update on locations
    for each row
    execute function set_updated_at();

-- Seed a few realistic locations (Admin can manage these later per §64)
insert into locations (campus, building, block, floor, room) values
    ('Main Campus', 'Main Block', 'A', '2nd Floor', 'Room 204'),
    ('Main Campus', 'Main Block', 'A', '1st Floor', 'Room 105'),
    ('Main Campus', 'Seminar Hall', null, 'Ground Floor', 'Hall 1'),
    ('Main Campus', 'Hostel Block B', null, 'Ground Floor', null),
    ('Main Campus', 'Library', null, '1st Floor', 'Reading Room'),
    ('Main Campus', 'Computer Lab', 'C', '3rd Floor', 'Lab 301')
on conflict do nothing;