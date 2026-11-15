import test from 'node:test';
import assert from 'node:assert/strict';
import { nights, cents, totals, validateStay } from '../lib/domain.mjs';
test('noites respeitam saída exclusiva e virada de mês',()=>assert.deepEqual(nights('2026-11-30','2026-12-02'),['2026-11-30','2026-12-01']));
test('rejeita data inválida, intervalo inverso e longo',()=>{for(const a of [['2026-02-30','2026-03-03'],['2026-12-02','2026-12-01'],['2026-01-01','2027-01-01']])assert.throws(()=>nights(...a));});
test('centavos sem fração ou negativos',()=>{assert.equal(cents(12345),12345);assert.throws(()=>cents(-1));assert.throws(()=>cents(1.5));});
test('capacidade e noites válidas',()=>{assert.equal(validateStay({checkIn:'2026-12-01',checkOut:'2026-12-08',guests:4},4),7);assert.throws(()=>validateStay({checkIn:'2026-12-01',checkOut:'2026-12-08',guests:6},4));});
test('saldo inclui reembolso e ignora contratos cancelados',()=>{assert.deepEqual(totals([{id:'a',status:'confirmed',total:10000},{id:'b',status:'cancelled',total:9000}],[{kind:'income',amount:6000,reservationId:'a'},{kind:'expense',amount:1000,reservationId:'a'},{kind:'expense',amount:500,reservationId:null}]),{income:6000,expense:1500,cash:4500,receivable:5000});});
