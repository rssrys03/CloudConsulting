trigger ResourceAllocationTrigger on Resource_Allocation__c (before insert) {
    if(Trigger.isInsert && Trigger.isBefore){
        ResourceAllocationHelper.onbeforeinsert(Trigger.new);
    }
}