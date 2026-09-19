-- ============================================================
-- 006_complaint_assignments.sql
-- CampFix: complaint assignment history (supports reassignment)
-- ============================================================

create table if not exists complaint_assignments (
    id uuid primary key default uuid_generate_v4(),
    complaint_id uuid not null references complaints(id) on delete cascade,
    staff_id uuid not null references profiles(id) on delete cascade,
    assigned_by uuid not null references profiles(id) on delete cascade,

    status text not null default 'ASSIGNED'
        check (status in ('ASSIGNED', 'ACCEPTED', 'REJECTED', 'IN_PROGRESS', 'COMPLETED', 'REASSIGNED')),

    notes text,

    assigned_at timestamptz not null default now(),
    accepted_at timestamptz,
    completed_at timestamptz
);

create index if not exists idx_assignments_complaint_id on complaint_assignments(complaint_id);
create index if not exists idx_assignments_staff_id on complaint_assignments(staff_id);
create index if not exists idx_assignments_status on complaint_assignments(status);

-- Helper: a staff member's current active workload (used for §32 recommendation)
create or replace view staff_active_workload as
select
    staff_id,
    count(*) as active_assignments
from complaint_assignments
where status in ('ASSIGNED', 'ACCEPTED', 'IN_PROGRESS')
group by staff_id;