function esc(v){return String(v ?? "").replace(/[&<>"']/g,m=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#039;"}[m]));}
function rupiah(v){return "Rp "+Number(v||0).toLocaleString("id-ID");}
function fmtDate(v){return v?new Date(v+"T00:00:00").toLocaleDateString("id-ID",{day:"2-digit",month:"short",year:"numeric"}):"-";}
function toast(msg,ok=true){const e=document.querySelector("#toast");if(e){e.textContent=msg;e.className="toast show "+(ok?"ok":"bad");setTimeout(()=>e.className="toast",2800)}else alert(msg);}
async function requireLogin(roles=[]){
 const {data:{user}}=await db.auth.getUser();
 if(!user){location.href="index.html";return null;}
 const {data:p}=await db.from("user_profiles").select("*").eq("user_id",user.id).maybeSingle();
 let actualRole=p?.role||null;
 if(!actualRole){const {data:isAdmin}=await db.rpc("is_admin");if(isAdmin) actualRole="admin";}
 if(roles.length && (!actualRole || !roles.includes(actualRole))){alert("Akses portal tidak sesuai akun.");await db.auth.signOut();location.href="index.html";return null;}
 return {user,profile:p,role:actualRole};
}
async function logout(){await db.auth.signOut();location.href="index.html";}