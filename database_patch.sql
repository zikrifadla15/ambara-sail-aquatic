-- Jalankan sekali setelah database utama dibuat
alter table public.students add column if not exists age integer;
