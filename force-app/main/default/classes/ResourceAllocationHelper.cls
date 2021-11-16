public class ResourceAllocationHelper {
    public static void onbeforeInsert(List<Resource_Allocation__c> newResourcesData) {
        Set<Id> requiredRolesIds = new Set<Id>();
        
        for(Resource_Allocation__c resourceData : newResourcesData){
            requiredRolesIds.add(resourceData.Required_Role__c);
        }
        
        Map<Id, Required_Role__c> projectsData = new Map<Id, Required_Role__c>([
            SELECT Project__r.Start_Date__c, Project__r.End_Date__c
            FROM Required_Role__c 
            WHERE Id 
            IN: requiredRolesIds]);
        

        for(Resource_Allocation__c resource : newResourcesData){
            Required_Role__c requiredRoleData = projectsData.get(resource.Required_Role__c);
            Date startProjectDate = requiredRoleData.Project__r.Start_Date__c;
            Date endProjectDate = requiredRoleData.Project__r.End_Date__c;
        
            if(resource.StartDate__c < startProjectDate || resource.StartDate__c > endProjectDate || resource.EndDate__c < startProjectDate || resource.EndDate__c > endProjectDate){
                resource.addError('Either the Start Date or End Date you defined for a Resource is out of the project date range');
            }
        }

        //evitar inserción manual de recursos en tabla resource allocation validando que el recurso no este alocado en ningun otro proyecto y haga intersección en el actual

        Map<Id, List<Resource_Allocation__c>> resourceAllocationsByUserId = new Map<Id, List<Resource_Allocation__c>>();
        
        Date startDate = Date.newInstance(3000, 01, 01);
        Date endDate = Date.newInstance(1900, 02, 01);

        for(Resource_Allocation__c allocation : newResourcesData){
            if(allocation.StartDate__c < startDate){
                startDate = allocation.StartDate__c;
            }
            if(allocation.EndDate__c > endDate){
                endDate = allocation.EndDate__c;
            }

            resourceAllocationsByUserId.put(allocation.Resources__c, new List<Resource_Allocation__c>());
        }
        System.debug('AllocationDate' + startDate + 'endDate' + endDate );

        List<Resource_Allocation__c> allocationsToCheck = [
            SELECT StartDate__c, EndDate__c, Resources__c, Required_Role__r.Project__r.Start_Date__c, Required_Role__r.Project__r.End_Date__c 
            FROM Resource_Allocation__c 
            WHERE Resources__c IN: resourceAllocationsByUserId.keySet() 
            AND Required_Role__r.Project__r.Status__c != 'Completed'
            AND (StartDate__c >=: startDate OR StartDate__c <=: endDate) 
            AND (EndDate__c <=: endDate OR EndDate__c >=: startDate)];  
            
            // jose 18/11---30//11      sd 19----24 ed
        
        System.debug('ALLOCATIONS TO CHECK'+ allocationsToCheck);

        for(Resource_Allocation__c allocation : allocationsToCheck){
            if(resourceAllocationsByUserId.containsKey(allocation.Resources__c)){
                resourceAllocationsByUserId.get(allocation.Resources__c).add(allocation);              
            }
        }

        System.debug('MAPA' + resourceAllocationsByUserId);

        Map<Id, List<Resource_Allocation__c>> noPreExistentData = new Map<Id, List<Resource_Allocation__c>>();

        for(Resource_Allocation__c newInsert : newResourcesData){
            if(resourceAllocationsByUserId.get(newInsert.Resources__c).size() > 0){
                Boolean failed = false;
                for(Resource_Allocation__c existentAllocation : resourceAllocationsByUserId.get(newInsert.Resources__c)){
                    //      existent              newInsert
                    // jose 18/11---30//11      sd 19----24 ed
                    if( (newInsert.StartDate__c >= existentAllocation.StartDate__c && newInsert.StartDate__c <= existentAllocation.EndDate__c) || ( newInsert.EndDate__c >= existentAllocation.StartDate__c && newInsert.EndDate__c <= existentAllocation.EndDate__c)){
                        newInsert.addError('You are trying to allocate a resource that is already busy in other project. Please check your options');
                        failed = true;
                    }
                }
                if(!failed){
                    resourceAllocationsByUserId.get(newInsert.Resources__c).add(newInsert);
                }
            }else{
                resourceAllocationsByUserId.get(newInsert.Resources__c).add(newInsert);
            }
        }


    }

}
                
        // Set<Id> usersIds = new Set<Id>();
        // for(Resource_Allocation__c allocation : newResourcesData){
        //     usersIds.add(allocation.Resources__c);
        // }

        // List<Resource_Allocation__c> allocationsToCheck = [SELECT StartDate__c, EndDate__c, Resources__c FROM Resource_Allocation__c WHERE Resources__c IN: usersIds AND Required_Role__r.Project__r.Status__c != 'Completed' AND EndDate__c >:  startProjectDate AND StartDate__c <: endProjectDate];

        // for(Resource_Allocation__c allocation : allocationsToCheck){
        //     for(Resource_Allocation__c newInsert : newResourcesData){
        //         if(allocation.Resources__c == newInsert.Resources__c){
        //             newInsert.addError('Either the Start Date or End Date you defined for a Resource is out of the project date range');
        //         }
        //     }
        // }
