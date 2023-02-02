trigger CaseAutomacaoEnviaCobranca on Case (after update) {
    // Recupera a lista de casos atualizados
    List<Case> cases = Trigger.new;
    
    // Loop por cada caso atualizado
    for (Case c : cases) {
        // Verifica se o campo "Cobrança" é verdadeiro
        if (c.Cobran_a__c) {
            // Verifica se o cliente respondeu
            if (c.Last_Client_Response_Date__c != null && c.Last_Client_Response_Date__c > System.now()) {
                c.Cliente_Respondeu__c = true;
            }
                c.Cobran_a__c = false;
                
                // Cria uma nova instância do objeto de email
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                // Configura as informações do email
                email.setToAddresses(new String[] {c.Owner.Email});
                email.setSubject('Cliente respondeu o caso');
                email.setPlainTextBody('O cliente respondeu o caso ' + c.CaseNumber + ', não é mais necessário enviar lembretes de cobrança.');
                
                // Envia o email
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            } else {
                // Verifica se 3 horas se passaram desde o último envio de email
                if (c.Last_Client_Response_Date__c == null || (System.now().getTime() - c.Last_Client_Response_Date__c.getTime()) / (1000 * 60 * 60) >= 3) {
                    // Cria uma nova instância do objeto de email
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    
                    // Configura as informações do email
                    email.setToAddresses(new String[] {c.Contact.Email});
                    email.setSubject('Lembrete de cobrança');
                    email.setPlainTextBody('Este é um lembrete de cobrança para o caso ' + c.CaseNumber);
                    
                    // Envia o email
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                    
                    // Atualiza a data da última resposta do cliente
                    c.Last_Client_Response_Date__c = System.now();
                }
            }
        }
    // Atualiza os casos na base de dados
    update cases;
}
