AMBARA SAIL AQUATIC — PORTAL 3 ROLE
====================================

Paket ini memperluas project GitHub/Supabase Ambara Sail Aquatic yang sudah ada.

FITUR
-----
1. Portal login Admin, Siswa, Coach.
2. Admin: siswa, coach, akun login, jadwal, reminder, absensi, evaluasi, kolam,
   Sub Event, pemasukan/pengeluaran, gaji coach, dan laporan PDF.
3. Siswa: profil, foto URL, biodata, jadwal, absensi, evaluasi, grafik,
   level Beginner/Basic/Intermediate/Advanced, Sub Event, kolam, pembayaran, reminder.
4. Coach: profil, foto URL, jadwal, daftar siswa, evaluasi, Sub Event, kolam,
   pembayaran/gaji yang sudah dicatat Admin, reminder.
5. Login siswa/coach dapat memakai ID atau nomor HP + password/PIN.
6. Tidak ada service_role key di browser.

FILE
----
index.html              = halaman login
admin.html              = portal admin
student.html            = portal siswa
coach.html              = portal coach
app.css                 = styling
config.js               = URL + publishable key Supabase
common.js               = fungsi umum
ambara_portal.sql       = database/RLS
supabase/functions/...  = Edge Function pembuatan akun siswa/coach

CARA ONLINE GRATIS
------------------
A. Supabase
1. Buka project Supabase yang sekarang.
2. SQL Editor -> jalankan admin_security.sql yang sudah ada jika belum pernah.
3. Jalankan ambara_portal.sql.
4. Buat/aktifkan Edge Function create-user:
   - upload isi folder supabase/functions/create-user/index.ts
   - set secret SUPABASE_SERVICE_ROLE_KEY pada Edge Function.
   - deploy function dengan nama create-user.
5. Pastikan Email provider Supabase aktif. Function membuat email internal dan langsung
   mengonfirmasi akun, jadi siswa/coach tidak perlu membuka email.

B. GitHub
1. Upload index.html, admin.html, student.html, coach.html, app.css, config.js, common.js.
2. Jangan upload service_role key.
3. Aktifkan GitHub Pages dari branch main/root.
4. URL portal menjadi:
   https://zikrifadla15.github.io/ambara-sail-aquatic/index.html

C. ADMIN PERTAMA
Gunakan akun Admin Supabase yang sudah ada. Pastikan UID admin ada di public.admin_users.
SQL lama di repository memang sudah menyediakan public.is_admin().

D. MEMBUAT AKUN SISWA/COACH
1. Admin login.
2. Tambahkan data siswa/coach.
3. Klik "Buat/Reset Akun".
4. Masukkan password/PIN minimal 6 karakter.
5. Siswa/coach login memakai ID/nomor HP dan password tersebut.

KEAMANAN
--------
- RLS membatasi data siswa ke siswa sendiri.
- Coach hanya melihat jadwal/evaluasi siswa yang terkait dengannya.
- Data keuangan hanya Admin.
- Pool dan Event dapat dilihat user authenticated.
- Service role hanya berada di Edge Function.

CATATAN
-------
- Foto profil menggunakan URL gambar pada versi ini supaya tetap gratis dan tanpa storage tambahan.
- Laporan keuangan PDF dibuat langsung di browser.
- Reminder saat ini adalah notifikasi di dalam portal. Untuk WhatsApp/push notification
  otomatis, diperlukan integrasi layanan tambahan.
- Jika tabel lama memiliki policy yang lebih luas, hapus policy lama yang memberi akses
  SELECT ke semua authenticated users agar RLS tidak membuka data lintas siswa.