-- ============================================================
-- 008_complaint_comments.sql
-- CampFix: comments and work notes on complaints
-- ============================================================

create table if not exists complaint_comments (
    id uuid primary key default uuid_generate_v4(),
    complaint_id uuid not null references complaints(id) on delete cascade,
    user_id uuid references profiles(id) on delete set null,

    comment text not null,
    comment_type text not null default 'STUDENT'
        check (comment_type in ('STUDENT', 'STAFF', 'ADMIN', 'SYSTEM')),

    created_at timestamptz not null default now()
);

create index if not exists idx_comments_complaint_id on complaint_comments(complaint_id);
create index if not exists idx_comments_created_at on complaint_comments(created_at);