-- ============================================================
-- 005_complaint_images.sql
-- CampFix: complaint images (Cloudinary URLs only, never binaries)
-- ============================================================

create table if not exists complaint_images (
    id uuid primary key default uuid_generate_v4(),
    complaint_id uuid not null references complaints(id) on delete cascade,
    uploaded_by uuid not null references profiles(id) on delete cascade,

    image_type text not null default 'COMPLAINT'
        check (image_type in ('COMPLAINT', 'COMPLETION')),

    cloudinary_url text not null,
    cloudinary_public_id text not null,

    created_at timestamptz not null default now()
);

create index if not exists idx_complaint_images_complaint_id on complaint_images(complaint_id);
create index if not exists idx_complaint_images_uploaded_by on complaint_images(uploaded_by);