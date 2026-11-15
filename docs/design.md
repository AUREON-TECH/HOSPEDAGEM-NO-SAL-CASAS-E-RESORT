# Hospedagem no Sal
Aplicativo PWA para vitrine pública de acomodações, solicitações manuais de reserva e painel de gestão privado. Cliente autenticado com e-mail e senha vê somente suas reservas. Gestão autorizada pelo e-mail proprietário em lista privada do banco, com e-mail confirmado.

Acomodações: descrição, localização, capacidade, comodidades, diária em centavos e fotos em armazenamento de fotos protegido. Reservas: entrada/saída, hóspedes, contato, valor combinado; aguardando, confirmada, concluída, recusada e cancelada. Confirmar usa bloqueio de noites por unidade, protegido por chave única no banco. Diária zero significa orçamento sob consulta. Sem cobrança automática.

Financeiro: lançamentos de entrada/saída em centavos, categoria, data e reserva opcional. Resultado de caixa = entradas menos saídas; saldo a receber = contratos confirmados/concluídos menos recebimentos líquidos vinculados. Reembolso é saída vinculada. Não excluir histórico financeiro nem reserva com lançamentos. Sem dados fictícios de faturamento.

PWA: manifest com ícones PNG, service worker para tela offline e cache de recursos públicos. APIs e informações privadas não são armazenadas no cache offline.

Revisão aprovada: cinco opções Park, Exclusive, Beach, Premium e Aqualand. Autenticação de e-mail/senha em serviço gerenciado existente, fonte no GitHub do usuário e publicação Vercel para preservar esse fluxo. Conta administrativa depende de cadastro e confirmação autorizados; não inserir senha em fonte.
