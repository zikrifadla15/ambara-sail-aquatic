-- AMBARA SAIL AQUATIC - FULL PORTAL DATABASE
-- Jalankan setelah database lama. SQL ini mempertahankan tabel lama dan menambahkan modul portal.
-- Jangan pernah memasukkan service_role key ke HTML/JS.

create extension if not exists pgcrypto;

-- ---------- Common helpers ----------
create table if not exists public.user_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('admin','student','coach')),
  student_id uuid references public.students(id) on delete set null,
  coach_id uuid references public.coaches(id) on delete set null,
  full_name text,
  photo_url text,
  phone text,
  bio text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
alter table public.user_profiles enable row level security;

create or replace function public.is_admin()
returns boolean language sql security definer set search_path=public as $$
 select exists(select 1 from public.admin_users where user_id=auth.uid());
$$;

create or replace function public.current_role()
returns text language sql security definer set search_path=public as $$
 select role from public.user_profiles where user_id=auth.uid();
$$;

-- ---------- Student / coach account links ----------
alter table public.students add column if not exists auth_user_id uuid unique references auth.users(id) on delete set null;
alter table public.students add column if not exists student_code text unique;
alter table public.students add column if not exists level text default 'Beginner';
alter table public.students add column if not exists photo_url text;
alter table public.students add column if not exists birth_date date;
alter table public.students add column if not exists email text;
alter table public.students add column if not exists emergency_contact text;
alter table public.students add column if not exists gender text;
alter table public.students add column if not exists bio text;

alter table public.coaches add column if not exists auth_user_id uuid unique references auth.users(id) on delete set null;
alter table public.coaches add column if not exists coach_code text unique;
alter table public.coaches add column if not exists photo_url text;
alter table public.coaches add column if not exists email text;
alter table public.coaches add column if not exists birth_date date;
alter table public.coaches add column if not exists bio text;
alter table public.coaches add column if not exists bank_name text;
alter table public.coaches add column if not exists bank_account text;
alter table public.coaches add column if not exists hourly_rate numeric default 0;

-- ---------- Evaluation ----------
create table if not exists public.student_evaluations (
 id uuid primary key default gen_random_uuid(),
 student_id uuid not null references public.students(id) on delete cascade,
 coach_id uuid references public.coaches(id) on delete set null,
 evaluation_date date not null default current_date,
 floating_score integer check (floating_score between 0 and 100),
 breathing_score integer check (breathing_score between 0 and 100),
 freestyle_score integer check (freestyle_score between 0 and 100),
 breaststroke_score integer check (breaststroke_score between 0 and 100),
 backstroke_score integer check (backstroke_score between 0 and 100),
 butterfly_score integer check (butterfly_score between 0 and 100),
 water_entry_score integer check (water_entry_score between 0 and 100),
 confidence_score integer check (confidence_score between 0 and 100),
 overall_score integer check (overall_score between 0 and 100),
 level text,
 notes text,
 created_at timestamptz default now()
);
create index if not exists idx_eval_student_date on public.student_evaluations(student_id,evaluation_date desc);
alter table public.student_evaluations enable row level security;

-- ---------- Pools ----------
create table if not exists public.pools (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 address text,
 map_url text,
 phone text,
 capacity integer,
 facilities text,
 notes text,
 status text default 'aktif',
 created_at timestamptz default now()
);
alter table public.pools enable row level security;

-- ---------- Events / Sub Event ----------
create table if not exists public.events (
 id uuid primary key default gen_random_uuid(),
 title text not null,
 description text,
 event_date date,
 start_time time,
 end_time time,
 location text,
 pool_id uuid references public.pools(id) on delete set null,
 cover_url text,
 status text default 'aktif',
 created_by uuid references auth.users(id) on delete set null,
 created_at timestamptz default now()
);
alter table public.events enable row level security;

-- ---------- Notifications / reminders ----------
create table if not exists public.notifications (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 title text not null,
 message text not null,
 notification_type text default 'info',
 related_date date,
 is_read boolean default false,
 created_at timestamptz default now()
);
create index if not exists idx_notifications_user on public.notifications(user_id,created_at desc);
alter table public.notifications enable row level security;

-- ---------- Coach payroll ----------
create table if not exists public.coach_payments (
 id uuid primary key default gen_random_uuid(),
 coach_id uuid not null references public.coaches(id) on delete cascade,
 schedule_id uuid references public.schedules(id) on delete set null,
 payment_date date not null default current_date,
 amount numeric not null default 0,
 payment_type text default 'per_sesi',
 status text default 'dibayar',
 notes text,
 created_at timestamptz default now()
);
alter table public.coach_payments enable row level security;

-- ---------- General finance ----------
create table if not exists public.finance_transactions (
 id uuid primary key default gen_random_uuid(),
 transaction_date date not null default current_date,
 transaction_type text not null check(transaction_type in ('income','expense')),
 category text not null,
 description text,
 amount numeric not null default 0,
 student_id uuid references public.students(id) on delete set null,
 coach_id uuid references public.coaches(id) on delete set null,
 payment_method text,
 reference text,
 created_by uuid references auth.users(id) on delete set null,
 created_at timestamptz default now()
);
alter table public.finance_transactions enable row level security;

-- ---------- Profile policies ----------
drop policy if exists asa_profile_self on public.user_profiles;
drop policy if exists asa_profile_admin on public.user_profiles;
create policy asa_profile_self on public.user_profiles for select to authenticated
using (user_id=auth.uid());
create policy asa_profile_admin on public.user_profiles for all to authenticated
using (public.is_admin()) with check (public.is_admin());

-- ---------- Students ----------
drop policy if exists asa_student_self_select on public.students;
drop policy if exists asa_student_self_update on public.students;
create policy asa_student_self_select on public.students for select to authenticated
using (auth_user_id=auth.uid() or public.is_admin());
create policy asa_student_self_update on public.students for update to authenticated
using (auth_user_id=auth.uid() or public.is_admin())
with check (auth_user_id=auth.uid() or public.is_admin());

-- ---------- Coaches ----------
drop policy if exists asa_coach_self_select on public.coaches;
drop policy if exists asa_coach_self_update on public.coaches;
create policy asa_coach_self_select on public.coaches for select to authenticated
using (auth_user_id=auth.uid() or public.is_admin());
create policy asa_coach_self_update on public.coaches for update to authenticated
using (auth_user_id=auth.uid() or public.is_admin())
with check (auth_user_id=auth.uid() or public.is_admin());

-- ---------- Existing operational tables ----------
drop policy if exists asa_schedule_student_select on public.schedules;
drop policy if exists asa_schedule_coach_select on public.schedules;
create policy asa_schedule_student_select on public.schedules for select to authenticated
using (
 public.is_admin()
 or exists(select 1 from public.students s where s.id=schedules.student_id and s.auth_user_id=auth.uid())
 or exists(select 1 from public.coaches c where c.id=schedules.coach_id and c.auth_user_id=auth.uid())
);

drop policy if exists asa_att_student_select on public.attendance;
drop policy if exists asa_att_coach_select on public.attendance;
create policy asa_att_student_select on public.attendance for select to authenticated
using (
 public.is_admin()
 or exists(select 1 from public.students s where s.id=attendance.student_id and s.auth_user_id=auth.uid())
 or exists(
   select 1 from public.schedules sc
   join public.coaches c on c.id=sc.coach_id
   where sc.student_id=attendance.student_id and c.auth_user_id=auth.uid()
 )
);

drop policy if exists asa_payment_student_select on public.payments;
create policy asa_payment_student_select on public.payments for select to authenticated
using (
 public.is_admin()
 or exists(select 1 from public.students s where s.id=payments.student_id and s.auth_user_id=auth.uid())
);

-- ---------- Evaluation ----------
drop policy if exists asa_eval_student_select on public.student_evaluations;
drop policy if exists asa_eval_coach_select on public.student_evaluations;
drop policy if exists asa_eval_coach_insert on public.student_evaluations;
drop policy if exists asa_eval_coach_update on public.student_evaluations;
create policy asa_eval_student_select on public.student_evaluations for select to authenticated
using (
 public.is_admin()
 or exists(select 1 from public.students s where s.id=student_evaluations.student_id and s.auth_user_id=auth.uid())
);
create policy asa_eval_coach_select on public.student_evaluations for select to authenticated
using (
 exists(select 1 from public.coaches c where c.id=student_evaluations.coach_id and c.auth_user_id=auth.uid())
);
create policy asa_eval_coach_insert on public.student_evaluations for insert to authenticated
with check (
 public.is_admin()
 or exists(select 1 from public.coaches c where c.id=student_evaluations.coach_id and c.auth_user_id=auth.uid())
);
create policy asa_eval_coach_update on public.student_evaluations for update to authenticated
using (
 public.is_admin()
 or exists(select 1 from public.coaches c where c.id=student_evaluations.coach_id and c.auth_user_id=auth.uid())
)
with check (
 public.is_admin()
 or exists(select 1 from public.coaches c where c.id=student_evaluations.coach_id and c.auth_user_id=auth.uid())
);

-- ---------- Pools ----------
drop policy if exists asa_pools_read on public.pools;
drop policy if exists asa_pools_admin on public.pools;
create policy asa_pools_read on public.pools for select to authenticated using (true);
create policy asa_pools_admin on public.pools for all to authenticated
using(public.is_admin()) with check(public.is_admin());

-- ---------- Events ----------
drop policy if exists asa_events_read on public.events;
drop policy if exists asa_events_admin on public.events;
create policy asa_events_read on public.events for select to authenticated using (true);
create policy asa_events_admin on public.events for all to authenticated
using(public.is_admin()) with check(public.is_admin());

-- ---------- Notifications ----------
drop policy if exists asa_notif_self on public.notifications;
drop policy if exists asa_notif_admin on public.notifications;
create policy asa_notif_self on public.notifications for select to authenticated using(user_id=auth.uid());
create policy asa_notif_self_update on public.notifications for update to authenticated
using(user_id=auth.uid()) with check(user_id=auth.uid());
create policy asa_notif_admin on public.notifications for all to authenticated
using(public.is_admin()) with check(public.is_admin());

-- ---------- Coach payroll ----------
drop policy if exists asa_payroll_coach_select on public.coach_payments;
drop policy if exists asa_payroll_admin on public.coach_payments;
create policy asa_payroll_coach_select on public.coach_payments for select to authenticated
using(public.is_admin() or exists(select 1 from public.coaches c where c.id=coach_payments.coach_id and c.auth_user_id=auth.uid()));
create policy asa_payroll_admin on public.coach_payments for all to authenticated
using(public.is_admin()) with check(public.is_admin());

-- ---------- Finance ----------
drop policy if exists asa_finance_admin on public.finance_transactions;
create policy asa_finance_admin on public.finance_transactions for all to authenticated
using(public.is_admin()) with check(public.is_admin());

-- ---------- RPC for identifier login ----------
create or replace function public.login_email_for_identifier(identifier text)
returns text
language plpgsql
security definer
set search_path=public,auth
as $$
declare
  uid uuid;
  result_email text;
begin
  select auth_user_id into uid
  from public.students
  where lower(coalesce(student_code,''))=lower(trim(identifier))
     or regexp_replace(coalesce(phone,''),'[^0-9]','','g')=regexp_replace(trim(identifier),'[^0-9]','','g')
  limit 1;
  if uid is null then
    select auth_user_id into uid from public.coaches
    where lower(coalesce(coach_code,''))=lower(trim(identifier))
       or regexp_replace(coalesce(phone,''),'[^0-9]','','g')=regexp_replace(trim(identifier),'[^0-9]','','g')
    limit 1;
  end if;
  if uid is null then return null; end if;
  select email into result_email from auth.users where id=uid;
  return result_email;
end;
$$;
grant execute on function public.login_email_for_identifier(text) to anon, authenticated;

-- Helpful view for admin reporting (RLS still applies to base tables).
create or replace view public.finance_summary as
select transaction_type, coalesce(sum(amount),0) total
from public.finance_transactions
group by transaction_type;

-- Seed coach/student codes where absent.
update public.students
set student_code='SIS-'||upper(substr(replace(id::text,'-',''),1,6))
where student_code is null;
update public.coaches
set coach_code='COA-'||upper(substr(replace(id::text,'-',''),1,6))
where coach_code is null;

-- NOTE:
-- 1) Run admin_security.sql from the existing repository first if not already done.
-- 2) Create student/coach Auth users from the supplied Supabase Edge Function.
-- 3) Never put SUPABASE_SERVICE_ROLE_KEY in client-side files.