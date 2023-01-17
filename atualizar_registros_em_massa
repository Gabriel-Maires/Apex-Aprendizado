List<Account> accs = [SELECT Name from Account];

Integer i = 0;
Integer x = accs.size() // Função que pega o tamanho da lista, seria o len do python

for (i < x){
  System.debug(accs[i])
}


// Maneira mais fácil porém mais dificil de entender:

List<Account> accs = [SELECT Name from Account];

for ( Account acc : accs){
  System.debug(accs[i])
}


// Maneira ainda mais minimizada:

for ( Account acc : [SELECT Name from Account]){
  System.debug(accs[i])
}
