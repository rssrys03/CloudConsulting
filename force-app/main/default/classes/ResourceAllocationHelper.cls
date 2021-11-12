public with sharing class ResourceAllocationHelper {
    public static void onbeforeInsert(List<Resource_Allocation__c> newResourcesData) {
        //validar que las fechas asignadas no sean no se salgan del rango de  fechas del proyecto
        Required_Role__c projectData = [SELECT Project__r.Start_Date__c, Project__r.End_Date__c FROM Required_Role__c WHERE Id  =: newResourcesData[0].Required_Role__c LIMIT 1];

        Date startProjectDate = projectData.Project__r.Start_Date__c;
        Date endProjectDate = projectData.Project__r.End_Date__c;

        for(Resource_Allocation__c resource : newResourcesData){
            if(resource.StartDate__c < startProjectDate || resource.StartDate__c > endProjectDate || resource.EndDate__c < startProjectDate || resource.EndDate__c > endProjectDate){
                resource.addError('Either the Start Date or End Date you defined for a Resource is out of the project date range');
            }
        }

        //evitar insersion manual de recursos en tabla resource allocation validando que el recurso no este alocado en ningun otro proyecto y haga intersección en el actual
        Set<Id> usersIds = new Set<Id>();
        for(Resource_Allocation__c allocation : newResourcesData){
            usersIds.add(allocation.Resources__c);
        }

        List<Resource_Allocation__c> allocationsToCheck = [SELECT StartDate__c, EndDate__c, Resources__c FROM Resource_Allocation__c WHERE Resources__c IN: usersIds AND Required_Role__r.Project__r.Status__c != 'Completed' AND EndDate__c >:  startProjectDate AND StartDate__c <: endProjectDate];

        for(Resource_Allocation__c allocation : allocationsToCheck){
            for(Resource_Allocation__c newInsert : newResourcesData){
                if(allocation.Resources__c == newInsert.Resources__c){
                    newInsert.addError('Either the Start Date or End Date you defined for a Resource is out of the project date range');
                }
            }
        }

    }
}
