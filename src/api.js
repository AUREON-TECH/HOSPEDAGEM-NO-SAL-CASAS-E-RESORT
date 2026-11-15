const BASE='https://veznreiamwstlulkpocz.supabase.co';
const KEY='sb_publishable_7ukoyUiZh73XRZxzBDhqjw_OsvJ8_JB';
let session=null,refreshing;
try{session=JSON.parse(localStorage.getItem('hns-session')||'null');}catch{localStorage.removeItem('hns-session');}
export const getSession=()=>session;
function save(s){session=s; s?localStorage.setItem('hns-session',JSON.stringify(s)):localStorage.removeItem('hns-session');}
export function clearSession(){save(null);}
function friendly(e){let s=e.msg||e.error_description||e.message||e.error||'Não foi possível concluir. Tente novamente.';if(s.includes('Invalid login'))s='E-mail ou senha incorretos.';if(s.includes('Email not confirmed'))s='Confirme o e-mail para entrar.';if(s.includes('User already registered'))s='Este e-mail já está cadastrado.';if(s.includes('rate limit'))s='Muitas tentativas. Aguarde alguns minutos.';if(s.includes('row-level security'))s='Você não tem permissão para esta ação.';if(s.includes('duplicate key'))s='As datas acabaram de ser ocupadas. Escolha outro período.';return Error(s);}
async function raw(path,options={},token){const r=await fetch(BASE+path,{...options,headers:{apikey:KEY,...(token?{Authorization:'Bearer '+token}:{}),...options.headers}});const t=await r.text();let d;try{d=t?JSON.parse(t):null;}catch{d={message:t};}if(!r.ok){const e=friendly(d||{});e.status=r.status;throw e;}return d;}
async function refresh(){if(!session?.refresh_token)return; if(!refreshing)refreshing=raw('/auth/v1/token?grant_type=refresh_token',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({refresh_token:session.refresh_token})}).then(save).catch(()=>save(null)).finally(()=>refreshing=null);await refreshing;}
export async function call(path,options={}){if(session&&session.expires_at<Date.now()/1000+60)await refresh();try{return await raw(path,options,session?.access_token);}catch(e){if(e.status===401&&session){await refresh();return raw(path,options,session?.access_token);}throw e;}}
export const query=(table,filter='')=>call('/rest/v1/'+table+'?'+filter);
export const insert=(table,data)=>call('/rest/v1/'+table,{method:'POST',headers:{'Content-Type':'application/json',Prefer:'return=representation'},body:JSON.stringify(data)});
export const update=(table,id,data)=>call('/rest/v1/'+table+'?id=eq.'+encodeURIComponent(id),{method:'PATCH',headers:{'Content-Type':'application/json',Prefer:'return=representation'},body:JSON.stringify(data)});
export const remove=(table,id)=>call('/rest/v1/'+table+'?id=eq.'+encodeURIComponent(id),{method:'DELETE'});
export async function login(email,password){const s=await raw('/auth/v1/token?grant_type=password',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({email:email.trim().toLowerCase(),password})});save({...s,expires_at:Math.floor(Date.now()/1000)+s.expires_in});return s.user;}
export async function signup(name,email,password){const s=await raw('/auth/v1/signup',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({email:email.trim().toLowerCase(),password,data:{name}})});if(s.access_token)save({...s,expires_at:Math.floor(Date.now()/1000)+s.expires_in});return !!s.access_token;}
export async function identity(){if(!session)return null;return call('/auth/v1/user');}
export async function logout(){try{await call('/auth/v1/logout',{method:'POST'});}finally{save(null);}}
export async function password(value){return call('/auth/v1/user',{method:'PUT',headers:{'Content-Type':'application/json'},body:JSON.stringify({password:value})});}
export const isAdmin=()=>call('/rest/v1/rpc/hns_is_admin',{method:'POST',headers:{'Content-Type':'application/json'},body:'{}'});
export async function upload(file){if(file.size>8*1024*1024)throw Error('Cada foto deve ter até 8 MB.');if(!['image/jpeg','image/png','image/webp'].includes(file.type))throw Error('Use fotos JPG, PNG ou WebP.');const ext={'image/jpeg':'jpg','image/png':'png','image/webp':'webp'}[file.type],path=crypto.randomUUID()+'.'+ext;await call('/storage/v1/object/hns-photos/'+path,{method:'POST',headers:{'Content-Type':file.type},body:file});return BASE+'/storage/v1/object/public/hns-photos/'+path;}
