-- ============================================================
-- 007_complaint_timeline.sql
-- CampFix: complaint timeline (auto-populated audit trail)
-- ============================================================

create table if not exists complaint_timeline (
    id uuid primary key default uuid_generate_v4(),
    complaint_id uuid not null references complaints(id) on delete cascade,
    performed_by uuid references profiles(id) on delete set null,
    role text,                          -- role of performer at time of action (STUDENT/STAFF/ADMIN/SYSTEM)

    old_status text,
    new_status text not null,
    message text,

    created_at timestamptz not null default now()
);

create index if not exists idx_timeline_complaint_id on complaint_timeline(complaint_id);
create index if not exists idx_timeline_created_at on complaint_timeline(created_at);

-- ============================================================
-- Auto-log a timeline entry whenever a complaint is created
-- ============================================================

create or replace function log_complaint_created()
returns trigger as $$
begin
    insert into complaint_timeline (complaint_id, performed_by, role, old_status, new_status, message)
    values (
        new.id,
        new.student_id,
        'STUDENT',
        null,
        new.status,
        'Complaint submitted'
    );
    return new;
end;
$$ language plpgsql;

drop trigger if exists trg_log_complaint_created on complaints;
create trigger trg_log_complaint_created
    after insert on complaints
    for each row
    execute function log_complaint_created();

-- ============================================================
-- Auto-log a timeline entry whenever a complaint's status changes
-- (performed_by/role are set by the backend via a session variable,
-- since a raw SQL trigger cannot know "who" made an API call - see note below)
-- ============================================================

create or replace function log_complaint_status_change()
returns trigger as $$
begin
    if new.status is distinct from old.status then
        insert into complaint_timeline (complaint_id, performed_by, role, old_status, new_status, message)
        values (
            new.id,
            nullif(current_setting('campfix.current_user_id', true), '')::uuid,
            nullif(current_setting('campfix.current_role', true), ''),
            old.status,
            new.status,
            null
        );

        if new.status = 'RESOLVED' and old.resolved_at is null then
            new.resolved_at := now();
        end if;
    end if;
    return new;
end;
$$ language plpgsql;

drop trigger if exists trg_log_complaint_status_change on complaints;
create trigger trg_log_complaint_status_change
    before update on complaints
    for each row
    execute function log_complaint_status_change();