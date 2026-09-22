AMBARA SAIL AQUATIC — WEB APP + ADMIN

Files:
- index.html = public website + registration to WhatsApp and Supabase
- admin.html = admin login/dashboard
- admin.css = admin styling
- script.js = public website logic + Supabase connection
- style.css = public website styling
- database_patch.sql = small database update (add age column)

Supabase project URL is embedded in the client files. The publishable key is intended for browser use; never put a Supabase secret/service_role key in these files.

IMPORTANT SECURITY:
Run the admin security SQL provided in the chat before using admin.html. It restricts management tables to the admin UID and leaves public student registration insert available.
