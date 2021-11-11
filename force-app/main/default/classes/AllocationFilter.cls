public with sharing class AllocationFilter {
    public static List<Required_Role__c> getRequiredRoles(Id projectID) {
        List<Required_Role__c> requiredRoles = [
            SELECT Role__c, Quantity__c, TotalCoverage__c, Project__r.Start_Date__c, Project__r.End_Date__c
            FROM Required_Role__c
            WHERE Project__c =: projectID];

            return requiredRoles;
    }

    public static List<User> findUsersWithRequiredRoles(List<Required_Role__c> requiredRoles) {
        List<String> roles = new List<String>();

        for(Required_Role__c requiredRole : requiredRoles){
            roles.add(requiredRole.Role__c);
        }

        List<User> resourcesMeetingRequirements = [SELECT FirstName, LastName, UserRole.Name 
        FROM User 
        WHERE UserRole.Name
        IN: roles];

        return resourcesMeetingRequirements;
    }


    public static List<User> checkAllocatedResources(Id projectID){

        List<Required_Role__c> requiredRoleWithProjectDates = getRequiredRoles(projectID);
        List<User> resources = findUsersWithRequiredRoles(requiredRoleWithProjectDates);

        List<Id> rosurcesIdsToFilter = new List<Id>(); //(id1, id2)
        
        for(User resource : resources){
            rosurcesToFilter.add(resource.Id);
        }
        
        //recursos con fechas para comparar
        //[pepeFechasP, MAriaFechas, pepeFechaP2]
        List<Resource_Allocation__c> resourcesAllocated = [SELECT StartDate__c, EndDate__c, Resources__c FROM Resource_Allocation__c WHERE Resource__c IN: rosurcesToFilter AND Required_Role__r.Project__r.Status__c != 'Completed'] //(id1)

        //mapa key: userId, value: lista de fechas de proyectos (resourcesAllocated)
        //mapa -> {pepeId : [PepeFecha1, PepeFecha2]
        //        mariaIdI: [mariaFecha]}
        Map<Id, List<Resource_Allocation__c>> resourceAllocationsByUserId = new Map<Id, List<Resource_Allocation__c>>;
        
        //armado de mapa con userId : lista de allocation vacia.
        for(Id userId : rosurcesIdsToFilter){
            resourceAllocationsByUserId.put(userId, new List<Resource_Allocation__c>());
        }

        for(Resource_Allocation__c resourceAllocated : resourcesAllocated){
            if(resourceAllocationsByUserId.containsKey(resourceAllocated.Resources__c)){
                resourceAllocationsByUserId.get(resourceAllocated.Resources__c).add(resourceAllocated);
            }
        }
        
        Date ProjectStartDate = requiredRoleWithProjectDates[0].Start_Date__c;
        Date ProjectEndDate = requiredRoleWithProjectDates[0].End_Date__c;

        Set<Id> filteredResourcesIds = new List<Id>(); //guardar users Ids disponibles en la fecha de project

        for(Id userId : resourceAllocationsByUserId.keySet()){
            if(resourceAllocationsByUserId.get(userID).size > 0){
                Boolean available = true;
                for(Resource_Allocation__c resourceAllocatedDates : resourceAllocationsByUserId.get(userID)){
 
                    if( ( resourceAllocatedDates.StartDate__c < ProjectStartDate && ( resourceAllocatedDates.EndDate__c < ProjectEndDate || resourceAllocatedDates.EndDate__c < ProjectStartDate ) ) || resourceAllocatedDates.StartDate__c > ProjectEndDate ){
                        continue;
                    }else{
                        available = false;
                        break;
                    }
                }
                if(available){
                    filteredResourcesIds.add(userId);
                }
            }else{
                filteredResourcesIds.add(userId);
            }
        }

        //query para buscar los usurios y devolverlos en una lista de user
        List<User> usersAvailables = [SELECT FirstName, LastName, UserRole.Name 
        FROM User 
        WHERE Id
        IN: filteredResourcesIds];

        return usersAvailables;
    }

    public static List<User> filterUserByRole(Id projectId, String roleName){
        List<User> users = checkAllocatedResources(projectId);
        
        List<User> usersByRol = new List<User>();
        for(User user : users){
            if(user.UserRole.Name == roleName){
                usersByRol.add(user);
            }
        }

        return usersByRol;
    }
}
