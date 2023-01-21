// Gatilho que pega o Objeto Lead, e quando criado, ele atribui no campo "Lead Source" a informação "Other".
// Pode ser aplicado em qualquer tipo de objeto...

trigger LeadTrigger on Lead (before insert){
  for (Lead leadRecord : Trigger.new){
    leadRecord.LeadSource = 'Other';
    }
}
