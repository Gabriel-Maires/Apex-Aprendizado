// Realiza cobrança de Email se o campo "Cobrança" estiver ativo.

trigger EnviarEmailCobranca on Case (before insert, before update) {
  
    List<Case> cases = Trigger.new;
  
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
  
    for(Case c : cases) {
    
        if(c.Cobranca__c == true) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] {c.Cliente_Email__c});
            email.setSubject('Lembrete de Caso');
            email.setPlainTextBody('Olá, algum retorno sobre a solução anterior?');
            emails.add(email);
        }
    }
    if(emails.size() > 0) {
        Messaging.sendEmail(emails);
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
