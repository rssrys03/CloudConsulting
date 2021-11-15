public with sharing class ResourceAllocationController {
    @AuraEnabled
    public static void insertResourceAllocations(List<Object> allocationData, Id requiredRoleId) {

        List<Resource_Allocation__c> allocationToInserts = new List<Resource_Allocation__c>();

        for(Object dataMap : allocationData){
            Map<Object, Object> resourceAllocatedData = (Map<Object, Object>)dataMap;
    
            Date start = Date.valueOf((String) resourceAllocatedData.get('StartDate'));
            Date endDate = Date.valueOf((String) resourceAllocatedData.get('EndDate'));

            allocationToInserts.add(new Resource_Allocation__c(
                Resources__c = (Id) resourceAllocatedData.get('Id'),
                Required_Role__c = requiredRoleId,
                StartDate__c = start,
                EndDate__c = endDate,
                Total_Hours__c = HoursAssignment.calculateHours(start, endDate)
            ));
            
        }

        insert allocationToInserts;
    }
}