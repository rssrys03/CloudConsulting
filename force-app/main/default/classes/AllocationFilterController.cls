public with sharing class AllocationFilterController {
    //devuelve una lista con RequiredRole Objects para acceder a los roles requeridos y fechas de proyecto
    @AuraEnabled(cacheable=true)
    public static List<Required_Role__c> getRequiredRoles(Id projectID) {
        List<Required_Role__c> requiredRoles = [
            SELECT Role__c, Quantity__c, TotalCoverage__c, Project__r.Start_Date__c, Project__r.End_Date__c
            FROM Required_Role__c
            WHERE Project__c =: projectID];

            return requiredRoles;
    }

    // a partir de un rol dado trae una lista de usuarios con ese rol
    public static List<User> findUsersWithRequiredRoles(String roleName) {

        List<User> resourcesMeetingRequirements = [SELECT FirstName, LastName, UserRole.Name 
        FROM User 
        WHERE UserRole.Name =: roleName];

        return resourcesMeetingRequirements;
    }

    //recibe el projectId y a partir de un rol dado busca los usuarios y devuelve los disponibles para su fecha de start y end 
    @AuraEnabled(cacheable=true)
    public static List<User> checkAllocatedResources(Id projectID, String roleName){
        List<Required_Role__c> requiredRoleWithProjectDates = getRequiredRoles(projectID);
        List<User> resources = findUsersWithRequiredRoles(roleName);

        List<Id> resourcesIdsToFilter = new List<Id>(); //(id1, id2)
        
        for(User resource : resources){
            resourcesIdsToFilter.add(resource.Id);
        }
        
        Date ProjectStartDate = requiredRoleWithProjectDates[0].Project__r.Start_Date__c;
        Date ProjectEndDate = requiredRoleWithProjectDates[0].Project__r.End_Date__c;

        //tenemos los no disponibles = con intersecciones
        List<Resource_Allocation__c> resourcesAllocated = [SELECT StartDate__c, EndDate__c, Resources__c FROM Resource_Allocation__c WHERE Resources__c IN: resourcesIdsToFilter AND Required_Role__r.Project__r.Status__c != 'Completed' AND EndDate__c >:  ProjectStartDate AND StartDate__c <: ProjectEndDate];

        Map<Id, List<Resource_Allocation__c>> resourceAllocationsByUserId = new Map<Id, List<Resource_Allocation__c>>();
        
        //armado de mapa con userId : lista de allocation vacia.
        for(Id userId : resourcesIdsToFilter){
            resourceAllocationsByUserId.put(userId, new List<Resource_Allocation__c>());
        }

        for(Resource_Allocation__c resourceAllocated : resourcesAllocated){
            if(resourceAllocationsByUserId.containsKey(resourceAllocated.Resources__c)){
                resourceAllocationsByUserId.get(resourceAllocated.Resources__c).add(resourceAllocated);
            }
        }
        
        Set<Id> filteredResourcesIds = new Set<Id>(); //guardar users Ids disponibles en la fecha de project

        for(Id userId : resourceAllocationsByUserId.keySet()){
            if(resourceAllocationsByUserId.get(userID).size() == 0){
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
    
}