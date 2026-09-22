-- ADMIN SECURITY PATCH
create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz default now()
);

alter table public.admin_users enable row level security;

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.admin_users
    where user_id = auth.uid()
  );
$$;

-- The admin UID shown in the Supabase Users screen
insert into public.admin_users (user_id)
values ('b5745d5f-c884-4cbd-b841-7a2566982553')
on conflict (user_id) do nothing;

-- Remove broad authenticated policies created earlier
DO $$
DECLARE p record;
BEGIN
  FOR p IN
    SELECT policyname, tablename
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename IN ('students','coaches','schedules','attendance','payments')
      AND policyname LIKE 'Authenticated users can%'
  LOOP
    EXECUTE format('drop policy if exists %I on public.%I', p.policyname, p.tablename);
  END LOOP;
END $$;

-- Students: public registration insert remains available.
create policy "Admins can view students"
on public.students for select to authenticated
using (public.is_admin());

create policy "Admins can update students"
on public.students for update to authenticated
using (public.is_admin()) with check (public.is_admin());

create policy "Admins can delete students"
on public.students for delete to authenticated
using (public.is_admin());

-- Other tables: admin only.
create policy "Admins can view coaches"
on public.coaches for select to authenticated using (public.is_admin());
create policy "Admins can insert coaches"
on public.coaches for insert to authenticated with check (public.is_admin());
create policy "Admins can update coaches"
on public.coaches for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Admins can delete coaches"
on public.coaches for delete to authenticated using (public.is_admin());

create policy "Admins can view schedules"
on public.schedules for select to authenticated using (public.is_admin());
create policy "Admins can insert schedules"
on public.schedules for insert to authenticated with check (public.is_admin());
create policy "Admins can update schedules"
on public.schedules for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Admins can delete schedules"
on public.schedules for delete to authenticated using (public.is_admin());

create policy "Admins can view attendance"
on public.attendance for select to authenticated using (public.is_admin());
create policy "Admins can insert attendance"
on public.attendance for insert to authenticated with check (public.is_admin());
create policy "Admins can update attendance"
on public.attendance for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Admins can delete attendance"
on public.attendance for delete to authenticated using (public.is_admin());

create policy "Admins can view payments"
on public.payments for select to authenticated using (public.is_admin());
create policy "Admins can insert payments"
on public.payments for insert to authenticated with check (public.is_admin());
create policy "Admins can update payments"
on public.payments for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "Admins can delete payments"
on public.payments for delete to authenticated using (public.is_admin());

-- Admins can only see their own admin membership record.
create policy "Admins can view own admin record"
on public.admin_users for select to authenticated
using (user_id = auth.uid());
