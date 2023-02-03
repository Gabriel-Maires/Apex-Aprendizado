// Realiza cobrança de Email se o campo "Cobrança" estiver ativo.

// Código para enviar email a cada 3 horas para clientes com campo "Cobrança" ativo
// Este código é bulkificado para evitar problemas com mais de 50 mil registros

trigger EnviarEmailCobranca on Case (after update) {
  // Lista para armazenar os casos que devem receber um email de cobrança
  List<Case> casosParaCobranca = new List<Case>();
  
  // Percorre todos os casos atualizados
  for (Case c : Trigger.new) {
    // Verifica se o caso foi atualizado e se o campo "Cobrança" está ativo
    if (Trigger.oldMap.get(c.Id).Cobranca__c != c.Cobranca__c && c.Cobranca__c == true) {
      // Adiciona o caso à lista de casos para cobrança
      casosParaCobranca.add(c);
    }
  }
  
  // Verifica se há casos para cobrança
  if (!casosParaCobranca.isEmpty()) {
    // Envia o email de cobrança para cada caso na lista
    for (Case c : casosParaCobranca) {
      // Cria um novo objeto Email
      Email email = new Email();
      // Define o destinatário do email
      email.toAddress = c.Contact.Email;
      // Define o assunto do email
      email.subject = 'Lembrete de cobrança';
      // Define o corpo do email
      email.plainTextBody = 'Olá, este é um lembrete de cobrança para o caso número ' + c.CaseNumber + '.';
      // Envia o email
      Messaging.sendEmail(new Email[] { email });
    }
  }
}


// Verifica se o Cliente Respondeu        

trigger ValidarClienteRespondeu on Case (before insert, before update) {

    for (Case c : Trigger.new) {
        if (c.Cobranca__c == true) {
            // buscar a data do último envio de cobrança 
            Date dataUltimoEnvio = c.Data_ultimo_envio__c;

            // lista para armazenar as datas das respostas dos clientes
            List<Date> datasRespostaCliente = new List<Date>();

            // buscar os emails relacionados ao caso
            List<EmailMessage> emails = [SELECT CreatedDate FROM EmailMessage WHERE ParentId = :c.Id];
            for (EmailMessage email : emails) {
                // adicionar as datas das respostas dos clientes na lista
                datasRespostaCliente.add(email.CreatedDate);
            }

            // encontrar a data da última resposta do cliente
            Date dataUltimaRespostaCliente = datasRespostaCliente.isEmpty() ? null : datasRespostaCliente.sort().get(datasRespostaCliente.size() - 1);

            // se a data da última resposta do cliente for maior que a data do último envio, marcar como "cliente respondeu"
            if (dataUltimaRespostaCliente != null && dataUltimaRespostaCliente > dataUltimoEnvio) {
                c.Cobranca__c = false;
                c.Cliente_respondeu__c = true;

                // enviar notificação ao proprietário do caso
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setSubject('Cliente Respondeu');
                email.setPlainTextBody('O cliente respondeu a cobrança referente ao caso com ID: ' + c.Id);
                email.setToAddresses(new String[] {c.Owner.Email});
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            }
        }
    }
}
