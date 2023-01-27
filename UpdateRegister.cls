// instanciar o objeto
Account acc = new Account();

// Selecionar qual registro exato você quer modificar
acc = [SELECT Name FROM Account 
       WHERE Name='GSK - Fidelização'
       LIMIT 1];

// alterar o registro
acc.Name = 'SOCIEDADE VIVEMOS';

// atualizar
update acc;
