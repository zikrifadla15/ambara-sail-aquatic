function toggleMenu(){document.getElementById('navLinks').classList.toggle('show')}
function sendWhatsApp(e){
  e.preventDefault();
  const nama=document.getElementById('nama').value.trim();
  const usia=document.getElementById('usia').value.trim();
  const program=document.getElementById('programSelect').value;
  const lokasi=document.getElementById('lokasiSelect').value;
  const nomor='6285772822651';
  const pesan=`Halo Ambara Sail Aquatic,%0A%0ASaya ingin mendaftar les renang.%0A%0ANama: ${encodeURIComponent(nama)}%0AUsia: ${encodeURIComponent(usia)}%0AProgram: ${encodeURIComponent(program)}%0ALokasi: ${encodeURIComponent(lokasi)}%0A%0AMohon informasi jadwal yang tersedia.`;
  window.open(`https://wa.me/${nomor}?text=${pesan}`,'_blank');
}