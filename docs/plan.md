# Hospedagem no Sal Implementation Plan

> **For agentic workers:** Execute inline with superpowers:executing-plans.

**Goal:** Publicar a vitrine PWA com reservas manuais e gestão financeira.
**Architecture:** Vite/React, API com RLS e triggers no banco, autenticação gerenciada e armazenamento de fotos.
**Tech Stack:** JavaScript, React, Postgres e Vercel.
**Spec:** docs/design.md

## Global Constraints
- Valores em centavos; reservas manuais; financeiro privado; instalação PWA.
- Usar e-mail do proprietário confirmado pela plataforma para autorizar a gestão.

## Review Focus
- Duas confirmações concorrentes: índice único de noites e transação de lote.
- Entrada/saída invertidas e capacidade excedida: rejeitar no servidor.
- Cliente tenta ler financeiro ou alterar hospedagem: responder 403.
- Arquivos inválidos e grandes: rejeitar MIME/assinatura/tamanho.
- Reembolso e cancelamento: preservar lançamentos e saldo correto.

### Task 1: Domínio e armazenamento
- [ ] Criar testes de intervalo, valores, capacidade, saldo e sobreposição em tests/domain.test.mjs.
- [ ] Implementar lib/domain.mjs e database/schema.sql; aplicar migração Postgres.
- [ ] Rodar node --test tests/domain.test.mjs.

### Task 2: API
- [ ] Implementar src/api.js e database/schema.sql: catálogo, reservas próprias, administração e upload.
- [ ] Proteger todas as mutações e leituras privadas no servidor.
- [ ] Verificar autorização e transações em testes de integração locais.

### Task 3: Interface e PWA
- [ ] Implementar src/main.jsx e src/style.css com catálogo, reservas, calendário e financeiro.
- [ ] Manifest/ícones/service worker, navegação responsiva, formulários com feedback.
- [ ] Build, inspeção no navegador e verificação de fluxos.

### Task 4: Publicação
- [ ] Sincronizar fonte no GitHub do usuário, registrar URL e instruções.
- [ ] Empacotar e publicar, confirmar resultado e entregar link.
