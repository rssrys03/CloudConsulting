public with sharing class ResourceAllocationHelper {
    public static void onbeforeInsert(List<Resource_Allocation__c> newResourcesData) {
        Map<Id, List<Required_Role__c>> resourceAllocationByRequiredRoleId = new Map<Id, List<Required_Role__c>>();
        
        for(Resource_Allocation__c resourceData : newResourcesData){
            resourceAllocationByRequiredRoleId.put(resourceData.Required_Role__c, new List<Required_Role__c>());
        }
        
        List<Required_Role__c> projectsData = [
            SELECT Project__r.Start_Date__c, Project__r.End_Date__c
            FROM Required_Role__c 
            WHERE Id 
            IN: resourceAllocationByRequiredRoleId.keySet()];
        

        for(Required_Role__c projectdata: projectsData){
            if(resourceAllocationByRequiredRoleId.containsKey(projectdata.Id)){
                resourceAllocationByRequiredRoleId.get(projectdata.Id).add(projectdata);
            }
        }


        for(Resource_Allocation__c resource : newResourcesData){
                for(Required_Role__c resourceData : resourceAllocationByRequiredRoleId.get(resource.Required_Role__c)){
                    Date startProjectDate = resourceData.Project__r.Start_Date__c;
                    Date endProjectDate = resourceData.Project__r.End_Date__c;
            
                    if(resource.StartDate__c < startProjectDate || resource.StartDate__c > endProjectDate || resource.EndDate__c < startProjectDate || resource.EndDate__c > endProjectDate){
                        resource.addError('Either the Start Date or End Date you defined for a Resource is out of the project date range');
                        break;
                    }
            }
        }

        //evitar inserción manual de recursos en tabla resource allocation validando que el recurso no este alocado en ningun otro proyecto y haga intersección en el actual

        Map<Id, List<Resource_Allocation__c>> resourceAllocationsByUserId = new Map<Id, List<Resource_Allocation__c>>();
        for(Resource_Allocation__c allocation : newResourcesData){
            resourceAllocationsByUserId.put(allocation.Resources__c, new List<Resource_Allocation__c>());
        }

        List<Resource_Allocation__c> allocationsToCheck = [
            SELECT StartDate__c, EndDate__c, Resources__c, Required_Role__r.Project__r.Start_Date__c, Required_Role__r.Project__r.End_Date__c 
            FROM Resource_Allocation__c 
            WHERE Resources__c IN: resourceAllocationsByUserId.keySet() 
            AND Required_Role__r.Project__r.Status__c != 'Completed'];

        for(Resource_Allocation__c allocation : allocationsToCheck){
            if(resourceAllocationsByUserId.containsKey(allocation.Resources__c)){
                resourceAllocationsByUserId.get(allocation.Resources__c).add(allocation);              
            }
        }

        for(Resource_Allocation__c newInsert : newResourcesData){
            if(resourceAllocationsByUserId.get(newInsert.Resources__c).size() > 0){
                for(Resource_Allocation__c existentAllocation : resourceAllocationsByUserId.get(newInsert.Resources__c)){

                    if( (existentAllocation.StartDate__c >= newInsert.StartDate__c && existentAllocation.StartDate__c <= newInsert.EndDate__c) || ( existentAllocation.EndDate__c >= newInsert.StartDate__c && existentAllocation.EndDate__c <= newInsert.StartDate__c)){
                        newInsert.addError('You are trying to allocate a resource that is already busy in other project. Please check your options');
                        break;
                    }
                }
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
