-- ============================================================
-- 010_notifications.sql
-- CampFix: in-app notifications
-- ============================================================

create table if not exists notifications (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references profiles(id) on delete cascade,

    title text not null,
    message text not null,

    type text not null default 'GENERAL'
        check (type in (
            'COMPLAINT_SUBMITTED', 'COMPLAINT_ASSIGNED', 'WORK_STARTED',
            'COMPLAINT_COMPLETED', 'COMPLAINT_RESOLVED', 'COMPLAINT_REOPENED',
            'NEW_ASSIGNMENT', 'ASSIGNMENT_CHANGED', 'URGENT_COMPLAINT',
            'CRITICAL_COMPLAINT', 'NEW_COMPLAINT', 'GENERAL'
        )),

    related_complaint_id uuid references complaints(id) on delete cascade,

    is_read boolean not null default false,
    created_at timestamptz not null default now()
);

create index if not exists idx_notifications_user_id on notifications(user_id);
create index if not exists idx_notifications_is_read on notifications(is_read);
create index if not exists idx_notifications_created_at on notifications(created_at);