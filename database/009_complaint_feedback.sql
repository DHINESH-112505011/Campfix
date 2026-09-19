-- ============================================================
-- 009_complaint_feedback.sql
-- CampFix: student feedback after complaint resolution
-- ============================================================

create table if not exists complaint_feedback (
    id uuid primary key default uuid_generate_v4(),
    complaint_id uuid not null unique references complaints(id) on delete cascade,
    student_id uuid not null references profiles(id) on delete cascade,

    rating int not null check (rating between 1 and 5),
    resolved_successfully boolean not null,
    comment text,

    created_at timestamptz not null default now()
);

create index if not exists idx_feedback_complaint_id on complaint_feedback(complaint_id);
create index if not exists idx_feedback_student_id on complaint_feedback(student_id);

-- ============================================================
-- Helper view: average rating per staff member (§63 Staff Performance)
-- Joins feedback -> complaint -> the ACCEPTED/COMPLETED assignment
-- for that complaint, so ratings attribute correctly to whoever did the work.
-- ============================================================

create or replace view staff_average_rating as
select
    ca.staff_id,
    round(avg(cf.rating)::numeric, 2) as average_rating,
    count(cf.id) as total_ratings
from complaint_feedback cf
join complaint_assignments ca on ca.complaint_id = cf.complaint_id
where ca.status = 'COMPLETED'
group by ca.staff_id;   