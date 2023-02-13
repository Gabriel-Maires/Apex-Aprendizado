trigger RemoveUsuarioGruposTrigger on User (after update) {
    // Cria uma lista para armazenar os IDs dos usuários desativados
    List<Id> inactiveUserIds = new List<Id>();
    
    // Itera sobre cada usuário que está sendo atualizado
    for (User user : Trigger.new) {
        // Verifica se o usuário está sendo desativado (campo IsActive mudou para false)
        if (!user.IsActive && Trigger.oldMap.get(user.Id).IsActive) {
            // Adiciona o ID do usuário na lista
            inactiveUserIds.add(user.Id);
        }
    }
    
    // Se houver usuários desativados, chama o método que remove eles dos grupos
    if (!inactiveUserIds.isEmpty()) {
        removeUserFromGroups(inactiveUserIds);
    }
        public void removeUserFromGroups(List<Id> inactiveUserIds) {
        // Cria uma lista para armazenar os IDs dos grupos que o usuário fará parte
        List<Id> groupIds = new List<Id>();
        
        // Consulta todos os membros de grupo relacionados aos usuários desativados
        for (GroupMember member : [SELECT GroupId FROM GroupMember WHERE UserOrGroupId IN :inactiveUserIds]) {
            // Adiciona o ID do grupo na lista
            groupIds.add(member.GroupId);
        }
        
        // Remove os usuários desativados dos grupos encontrados
        if (!groupIds.isEmpty()) {
            Database.delete(
                [SELECT Id FROM GroupMember WHERE UserOrGroupId IN :inactiveUserIds AND GroupId IN :groupIds],
                false
            );
        }
	}
}
