const SUPABASE_URL = "https://kahyuedvhhkeezolnkeh.supabase.co";
const SUPABASE_PUBLISHABLE_KEY = "sb_publishable_qaQ1yUb1JsF_nJRbY2b6mw_o0z9weT4";
const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY);

function toggleMenu(){document.getElementById('navLinks').classList.toggle('show')}

async function registerStudent(e){
  e.preventDefault();
  const nama=document.getElementById('nama').value.trim();
  const usia=Number(document.getElementById('usia').value);
  const telepon=document.getElementById('telepon').value.trim();
  const program=document.getElementById('programSelect').value;
  const lokasi=document.getElementById('lokasiSelect').value;
  try{
    const {error}=await supabaseClient.from('students').insert({name:nama,age:usia,phone:telepon,program,notes:`Lokasi pilihan: ${lokasi}`});
    if(error) throw error;
  }catch(err){
    console.error(err);
    alert('Pendaftaran WhatsApp tetap bisa dilanjutkan, tetapi data belum tersimpan ke sistem.');
  }
  const nomor='6285772822651';
  const pesan=`Halo Ambara Sail Aquatic,%0A%0ASaya ingin mendaftar les renang.%0A%0ANama: ${encodeURIComponent(nama)}%0AUsia: ${encodeURIComponent(usia)}%0ANo. WhatsApp: ${encodeURIComponent(telepon)}%0AProgram: ${encodeURIComponent(program)}%0ALokasi: ${encodeURIComponent(lokasi)}%0A%0AMohon informasi jadwal yang tersedia.`;
  window.open(`https://wa.me/${nomor}?text=${pesan}`,'_blank');
}
