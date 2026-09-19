-- ============================================================
-- 004_complaints.sql
-- CampFix: core complaints table
-- ============================================================

create table if not exists complaints (
    id uuid primary key default uuid_generate_v4(),
    complaint_number text not null unique,

    student_id uuid not null references profiles(id) on delete cascade,
    category_id uuid references categories(id) on delete set null,
    department_id uuid references departments(id) on delete set null,

    title text not null,
    description text not null,

    priority text not null default 'MEDIUM'
        check (priority in ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),

    ai_category text,
    ai_priority text,
    ai_confidence numeric(4,3),        -- e.g. 0.943

    status text not null default 'SUBMITTED'
        check (status in (
            'SUBMITTED', 'AI_CLASSIFIED', 'ADMIN_REVIEW', 'ASSIGNED',
            'ACCEPTED', 'IN_PROGRESS', 'WORK_COMPLETED', 'ADMIN_VERIFIED',
            'RESOLVED', 'REJECTED', 'CANCELLED', 'ON_HOLD', 'REOPENED'
        )),

    campus text not null default 'Main Campus',
    building text not null,
    block text,
    floor text,
    room text not null,
    specific_location text,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    resolved_at timestamptz
);

create index if not exists idx_complaints_complaint_number on complaints(complaint_number);
create index if not exists idx_complaints_student_id on complaints(student_id);
create index if not exists idx_complaints_status on complaints(status);
create index if not exists idx_complaints_priority on complaints(priority);
create index if not exists idx_complaints_category_id on complaints(category_id);
create index if not exists idx_complaints_department_id on complaints(department_id);
create index if not exists idx_complaints_created_at on complaints(created_at);

drop trigger if exists trg_complaints_updated_at on complaints;
create trigger trg_complaints_updated_at
    before update on complaints
    for each row
    execute function set_updated_at();

-- ============================================================
-- Human-friendly complaint number generator: CF-YYYY-00001
-- Sequence resets logically per year based on existing count,
-- never exposing the internal UUID (per §23).
-- ============================================================

create or replace function generate_complaint_number()
returns trigger as $$
declare
    year_part text;
    next_seq int;
    candidate text;
begin
    year_part := to_char(now(), 'YYYY');

    select coalesce(max(
        cast(substring(complaint_number from 'CF-\d{4}-(\d+)') as int)
    ), 0) + 1
    into next_seq
    from complaints
    where complaint_number like 'CF-' || year_part || '-%';

    candidate := 'CF-' || year_part || '-' || lpad(next_seq::text, 5, '0');
    new.complaint_number := candidate;

    return new;
end;
$$ language plpgsql;

drop trigger if exists trg_generate_complaint_number on complaints;
create trigger trg_generate_complaint_number
    before insert on complaints
    for each row
    when (new.complaint_number is null or new.complaint_number = '')
    execute function generate_complaint_number();