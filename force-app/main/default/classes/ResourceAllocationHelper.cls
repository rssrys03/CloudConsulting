public with sharing class ResourceAllocationHelper {
    public static void onbeforeInsert(List<Resource_Allocation__c> newResourcesData) { //id:resouuceAllData
        Map<Id, List<Resource_Allocation__c>> resourceAllocationByRequiredRoleId = new Map<Id, List<Resource_Allocation__c>>();
        
        for(Resource_Allocation__c resourceData : newResourcesData){
            resourceAllocationByRequiredRoleId.put(resourceData.Required_Role__c, new List<Resource_Allocation__c>());
        }
        
        List<Resource_Allocation__c> projectsData = [
            SELECT StartDate__c, EndDate__c, Required_Role__r.Project__r.Start_Date__c, Required_Role__r.Project__r.End_Date__c, Required_Role__r.Project__c
            FROM Resource_Allocation__c 
            WHERE Required_Role__c 
            IN: resourceAllocationByRequiredRoleId.keySet()];
        

        for(Resource_Allocation__c projectdata: projectsData){
            if(resourceAllocationByRequiredRoleId.containsKey(projectdata.Required_Role__c)){
                resourceAllocationByRequiredRoleId.get(projectdata.Required_Role__c).add(projectdata);
            }
        }

        // Map<Id, List<Required_Role__c>> resourceProjectDatesByRequiredRoleId = new Map<Id, List<Date>>();
        
        // for(Resource_Allocation__c resourceData : newResourcesData){
        //     resourceProjectDatesByRequiredRoleId.put(resourceData.Required_Role__c, new List<Date>());
        // }


        // //validar que las fechas asignadas no sean no se salgan del rango de  fechas del proyecto
        // List<Required_Role__c> projectData = [SELECT Project__r.Start_Date__c, Project__r.End_Date__c FROM Required_Role__c WHERE Id  IN : resourceProjectDatesByRequiredRoleId.keySet()];


        for(Resource_Allocation__c resource : newResourcesData){
            if(resourceAllocationByRequiredRoleId.get(resource.Required_Role__c).size() > 0){
                for(Resource_Allocation__c resourceData : resourceAllocationByRequiredRoleId.get(resource.Required_Role__c)){
                    Date startProjectDate = resourceData.Required_Role__r.Project__r.Start_Date__c;
                    Date endProjectDate = resourceData.Required_Role__r.Project__r.End_Date__c;
                    if(resourceData.StartDate__c < startProjectDate || resourceData.StartDate__c > endProjectDate || resourceData.EndDate__c < startProjectDate || resourceData.EndDate__c > endProjectDate){
                        resource.addError('Either the Start Date or End Date you defined for a Resource is out of the project date range');
                    }   
                }
            }
        }

        //evitar insersion manual de recursos en tabla resource allocation validando que el recurso no este alocado en ningun otro proyecto y haga intersección en el actual
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

    }
}
