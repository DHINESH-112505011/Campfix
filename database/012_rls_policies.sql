-- ============================================================
-- 012_rls_policies.sql
-- CampFix: Row Level Security policies (§48)
-- ============================================================

-- ============================================================
-- Helper function: get the profile id + role of the currently
-- authenticated Supabase user (auth.uid() maps to auth_user_id)
-- ============================================================

create or replace function current_profile_id()
returns uuid as $$
    select id from profiles where auth_user_id = auth.uid();
$$ language sql stable security definer;

create or replace function current_profile_role()
returns text as $$
    select role from profiles where auth_user_id = auth.uid();
$$ language sql stable security definer;

-- ============================================================
-- PROFILES
-- ============================================================
alter table profiles enable row level security;

create policy "profiles_select_own_or_admin"
on profiles for select
using (
    auth_user_id = auth.uid()
    or current_profile_role() in ('ADMIN', 'SUPER_ADMIN')
);

create policy "profiles_update_own"
on profiles for update
using (auth_user_id = auth.uid())
with check (auth_user_id = auth.uid());

create policy "profiles_insert_own"
on profiles for insert
with check (auth_user_id = auth.uid());

-- ============================================================
-- DEPARTMENTS (public read - needed for dropdowns; admin-only write)
-- ============================================================
alter table departments enable row level security;

create policy "departments_select_all"
on departments for select
using (true);

create policy "departments_write_admin_only"
on departments for all
using (current_profile_role() in ('ADMIN', 'SUPER_ADMIN'))
with check (current_profile_role() in ('ADMIN', 'SUPER_ADMIN'));

-- ============================================================
-- CATEGORIES (public read; admin-only write)
-- ============================================================
alter table categories enable row level security;

create policy "categories_select_all"
on categories for select
using (true);

create policy "categories_write_admin_only"
on categories for all
using (current_profile_role() in ('ADMIN', 'SUPER_ADMIN'))
with check (current_profile_role() in ('ADMIN', 'SUPER_ADMIN'));

-- ============================================================
-- LOCATIONS (public read; admin-only write)
-- ============================================================
alter table locations enable row level security;

create policy "locations_select_all"
on locations for select
using (true);

create policy "locations_write_admin_only"
on locations for all
using (current_profile_role() in ('ADMIN', 'SUPER_ADMIN'))
with check (current_profile_role() in ('ADMIN', 'SUPER_ADMIN'));

-- ============================================================
-- COMPLAINTS
-- Student: only own complaints
-- Staff: only complaints assigned to them
-- Admin/Super Admin: all complaints
-- ============================================================
alter table complaints enable row level security;

create policy "complaints_select_scoped"
on complaints for select
using (
    student_id = current_profile_id()
    or current_profile_role() in ('ADMIN', 'SUPER_ADMIN')
    or exists (
        select 1 from complaint_assignments ca
        where ca.complaint_id = complaints.id
        and ca.staff_id = current_profile_id()
    )
);

create policy "complaints_insert_own"
on complaints for insert
with check (student_id = current_profile_id());

create policy "complaints_update_scoped"
on complaints for update
using (
    current_profile_role() in ('ADMIN', 'SUPER_ADMIN')
    or exists (
        select 1 from complaint_assignments ca
        where ca.complaint_id = complaints.id
        and ca.staff_id = current_profile_id()
    )
    or student_id = current_profile_id()  -- student can cancel/reopen own complaint
);

-- ============================================================
-- COMPLAINT IMAGES
-- ============================================================
alter table complaint_images enable row level security;

create policy "complaint_images_select_scoped"
on complaint_images for select
using (
    exists (
        select 1 from complaints c
        where c.id = complaint_images.complaint_id
        and (
            c.student_id = current_profile_id()
            or current_profile_role() in ('ADMIN', 'SUPER_ADMIN')
            or exists (
                select 1 from complaint_assignments ca
                where ca.complaint_id = c.id and ca.staff_id = current_profile_id()
            )
        )
    )
);

create policy "complaint_images_insert_scoped"
on complaint_images for insert
with check (uploaded_by = current_profile_id());

-- ============================================================
-- COMPLAINT ASSIGNMENTS
-- Student: no direct access (they see status via complaints table)
-- Staff: only their own assignments
-- Admin/Super Admin: all
-- ============================================================
alter table complaint_assignments enable row level security;

create policy "assignments_select_scoped"
on complaint_assignments for select
using (
    staff_id = current_profile_id()
    or current_profile_role() in ('ADMIN', 'SUPER_ADMIN')
);

create policy "assignments_write_admin_or_staff"
on complaint_assignments for all
using (
    current_profile_role() in ('ADMIN', 'SUPER_ADMIN')
    or staff_id = current_profile_id()
)
with check (
    current_profile_role() in ('ADMIN', 'SUPER_ADMIN')
    or staff_id = current_profile_id()
);

-- ============================================================
-- COMPLAINT TIMELINE (read-only for everyone who can see the complaint)
-- ============================================================
alter table complaint_timeline enable row level security;

create policy "timeline_select_scoped"
on complaint_timeline for select
using (
    exists (
        select 1 from complaints c
        where c.id = complaint_timeline.complaint_id
        and (
            c.student_id = current_profile_id()
            or current_profile_role() in ('ADMIN', 'SUPER_ADMIN')
            or exists (
                select 1 from complaint_assignments ca
                where ca.complaint_id = c.id and ca.staff_id = current_profile_id()
            )
        )
    )
);

-- No insert/update/delete policy for normal users - timeline is only
-- written by triggers (running as the table owner) or the backend
-- using the service role key, which bypasses RLS entirely.

-- ============================================================
-- COMPLAINT COMMENTS
-- ============================================================
alter table complaint_comments enable row level security;

create policy "comments_select_scoped"
on complaint_comments for select
using (
    exists (
        select 1 from complaints c
        where c.id = complaint_comments.complaint_id
        and (
            c.student_id = current_profile_id()
            or current_profile_role() in ('ADMIN', 'SUPER_ADMIN')
            or exists (
                select 1 from complaint_assignments ca
                where ca.complaint_id = c.id and ca.staff_id = current_profile_id()
            )
        )
    )
);

create policy "comments_insert_scoped"
on complaint_comments for insert
with check (user_id = current_profile_id());

-- ============================================================
-- COMPLAINT FEEDBACK
-- ============================================================
alter table complaint_feedback enable row level security;

create policy "feedback_select_scoped"
on complaint_feedback for select
using (
    student_id = current_profile_id()
    or current_profile_role() in ('ADMIN', 'SUPER_ADMIN')
);

create policy "feedback_insert_own"
on complaint_feedback for insert
with check (student_id = current_profile_id());

-- ============================================================
-- NOTIFICATIONS (strictly own notifications only)
-- ============================================================
alter table notifications enable row level security;

create policy "notifications_select_own"
on notifications for select
using (user_id = current_profile_id());

create policy "notifications_update_own"
on notifications for update
using (user_id = current_profile_id())
with check (user_id = current_profile_id());

-- ============================================================
-- AUDIT LOGS (Super Admin only - per §47, ordinary users cannot
-- read or modify audit logs; even ADMIN is excluded, only SUPER_ADMIN)
-- ============================================================
alter table audit_logs enable row level security;

create policy "audit_logs_select_super_admin_only"
on audit_logs for select
using (current_profile_role() = 'SUPER_ADMIN');

-- No insert/update/delete policy for any client role - audit logs are
-- written exclusively by the backend using the service role key.           