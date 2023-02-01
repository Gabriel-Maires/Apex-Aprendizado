// Cria uma lista de contas, selecionando apenas as contas com o campo Grupo igual a "Varejo"
List<Account> accounts = [SELECT Id, Name FROM Account WHERE type = 'varejo' OR Grupo__c = 'varejo' OR Varejo_Legado__c = true OR Varejo_Premium__c = true];

// Loop através de cada conta na lista

for (Account account : accounts){ 
account.Observa_o__c = 'Sua farmácia está apta a vender pelo programa Viver Mais da GSK';
}

// Atualiza a lista de contas no banco de dados
update accounts;
