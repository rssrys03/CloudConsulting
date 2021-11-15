public with sharing class ResourceAllocationHelper {
    public static void onbeforeInsert(List<Resource_Allocation__c> newResourcesData) {
        //validar que las fechas asignadas no sean no se salgan del rango de  fechas del proyecto
        Required_Role__c projectData = [SELECT Project__r.Start_Date__c, Project__r.End_Date__c 
                                        FROM Required_Role__c 
                                        WHERE Id  =: newResourcesData[0].Required_Role__c LIMIT 1];

        Date startProjectDate = projectData.Project__r.Start_Date__c;
        Date endProjectDate = projectData.Project__r.End_Date__c;

        for(Resource_Allocation__c resource : newResourcesData){
            if(resource.StartDate__c < startProjectDate 
                || resource.StartDate__c > endProjectDate 
                || resource.EndDate__c < startProjectDate 
                || resource.EndDate__c > endProjectDate){
                resource.addError('Either the Start Date or End Date you defined for a Resource is out of the project date range');
            }
        }

        //evitar insersion manual de recursos en tabla resource allocation validando que el recurso no este alocado en ningun otro proyecto y haga intersección en el actual
        
        Map<Id, List<Resource_Allocation__c>> resourceAllocationsByUserId = new Map<Id, List<Resource_Allocation__c>>();

        Map<Id, Resource_Allocation__c> newAllocationByUserId = new Map<Id, Resource_Allocation__c>();
        for(Resource_Allocation__c d : newResourcesData){
            newAllocationByUserId.put(d.Resources__c, d);
        }

        for(Resource_Allocation__c resource : newResourcesData){
            resourceAllocationsByUserId.put(resource.Id, new List<Resource_Allocation__c>());
        }

        List<Resource_Allocation__c> resourcesDatesToCheck = [SELECT StartDate__c, EndDate__c, Resources__c FROM Resource_Allocation__c WHERE Resources__c IN: resourceAllocationsByUserId.keySet() AND Required_Role__r.Project__r.Status__c != 'Completed' AND EndDate__c >:  startProjectDate AND StartDate__c <: endProjectDate];
        

        for(Resource_Allocation__c resourceAllocated : resourcesDatesToCheck){
            if(resourceAllocationsByUserId.containsKey(resourceAllocated.Resources__c)){
                resourceAllocationsByUserId.get(resourceAllocated.Resources__c).add(resourceAllocated);
            }
        }

        for(Id userId : resourceAllocationsByUserId.keySet()){
            if(resourceAllocationsByUserId.get(userId).size() > 0){
                newAllocationByUserId.get(userId).addError('No loquitos admitted');
                }
            }
        }

    }