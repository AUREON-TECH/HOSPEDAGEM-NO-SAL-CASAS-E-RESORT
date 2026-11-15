# Hospedagem no Sal — Casas e Resort

PWA responsivo com cinco resorts: Park, Exclusive, Beach, Premium e Aqualand.

Aplicativo publicado: https://hospedagem-no-sal-casas-resort.raphaelbueno-captaca.chatgpt.site/

A Vercel recusou a criação do projeto por falta de permissão na conta conectada. A versão atual está publicada na hospedagem alternativa; a configuração Vercel permanece pronta no repositório para uso futuro.

## Funcionalidades
- Catálogo, galeria, descrição, capacidade, diária e consulta de datas.
- Cadastro e login por e-mail/senha com autenticação gerenciada.
- Cliente consulta somente as suas reservas; solicitação pendente até confirmação manual.
- Painel da gestão: fotos do celular (JPG/PNG/WebP, 8 MB), edição das hospedagens, confirmações, bloqueios de calendário, entradas, saídas, saldo e exportação CSV.
- Bloqueio de datas protegido por chave única no banco, inclusive confirmações concorrentes.
- PWA com ícones PNG e tela offline. Informações privadas e API não entram no cache offline.

## Administrador
O e-mail administrador foi indicado pelo proprietário e é autorizado no servidor somente quando autenticado e confirmado. Nenhuma senha está no repositório. A criação automática da conta não foi concluída porque a revisão de segurança rejeitou a transmissão das credenciais; o cadastro pode ser feito pela tela do aplicativo e confirmado por e-mail.

## Executar
Node 22.13+.
```
npm install
npm test
npm run dev
npm run build
```
A Vercel monta e publica a versão estática já verificada em `site/`, sem instalar dependências no servidor. Para atualizar após editar o código: execute `npm run build`, copie `dist/index.html` e `dist/assets` para `site/` e faça o commit. A variável de base do Vite é relativa, permitindo publicar também no caminho do repositório no GitHub Pages. A integração de autenticação, tabelas com prefixo `hns_` e bucket `hns-photos` estão na base já conectada do proprietário; o SQL da aplicação encontra-se em `database/`.

## Operação
1. Cadastre e confirme a conta administrativa.
2. Abra Gestão → Hospedagens e edite fotos, descrição e diária.
3. Em Calendário, bloqueie períodos indisponíveis. O dia de saída fica livre.
4. Em Reservas, combine pagamento e confirme o valor total. Confirmar não lança recebimento.
5. Em Financeiro, registre sinal, saldo e despesas. Vincule pagamentos e reembolsos à reserva; despesas operacionais ficam sem vínculo.
6. Para corrigir um lançamento, registre um movimento inverso. Cancelar preserva o histórico financeiro.

As capacidades não informadas permanecem sob consulta. As diárias começam em zero (sob consulta). A imagem enviada foi incluída na opção Beach; o anúncio não define automaticamente a disponibilidade atual.
