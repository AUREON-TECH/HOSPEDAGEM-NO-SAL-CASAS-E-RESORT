export function nights(start,end){
 const parse=s=>{if(!/^\d{4}-\d{2}-\d{2}$/.test(s))throw Error('Data inválida');const d=new Date(s+'T12:00:00Z');if(!Number.isFinite(+d)||d.toISOString().slice(0,10)!==s)throw Error('Data inválida');return +d;};
 const a=parse(start),b=parse(end),n=(b-a)/86400000;if(!Number.isInteger(n)||n<1||n>90)throw Error('Escolha de 1 a 90 noites');return Array.from({length:n},(_,i)=>new Date(a+i*86400000).toISOString().slice(0,10));
}
export function cents(v){if(!Number.isSafeInteger(v)||v<0||v>100000000)throw Error('Valor inválido');return v;}
export function validateStay(v,max){const n=nights(v.checkIn,v.checkOut);if(!Number.isInteger(v.guests)||v.guests<1||v.guests>max)throw Error('Quantidade de hóspedes acima da capacidade');return n.length;}
export function totals(bookings,entries){const income=entries.filter(x=>x.kind==='income').reduce((s,x)=>s+x.amount,0),expense=entries.filter(x=>x.kind==='expense').reduce((s,x)=>s+x.amount,0);const receivable=bookings.filter(x=>['confirmed','completed'].includes(x.status)).reduce((s,b)=>s+Math.max(0,b.total-entries.filter(x=>x.reservationId===b.id).reduce((v,x)=>v+(x.kind==='income'?x.amount:-x.amount),0)),0);return{income,expense,cash:income-expense,receivable};}
