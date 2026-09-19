-- ============================================================
-- 011_audit_logs.sql
-- CampFix: audit trail for sensitive actions (§47)
-- ============================================================

create table if not exists audit_logs (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references profiles(id) on delete set null,

    action text not null,              -- e.g. 'PRIORITY_CHANGED', 'STAFF_REASSIGNED', 'USER_DISABLED'
    entity_type text not null,         -- e.g. 'complaint', 'profile', 'category'
    entity_id uuid not null,

    old_value jsonb,
    new_value jsonb,

    created_at timestamptz not null default now()
);

create index if not exists idx_audit_logs_user_id on audit_logs(user_id);
create index if not exists idx_audit_logs_entity on audit_logs(entity_type, entity_id);
create index if not exists idx_audit_logs_created_at on audit_logs(created_at);