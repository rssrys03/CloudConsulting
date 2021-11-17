@isTest
private  class ResourceAllocationControllerTest {
    @isTest
    static void insertResourceAllocationsTest() {
       User developer = [
            SELECT Id 
            FROM User 
            WHERE LastName='Testing' 
            AND FirstName='Test Dev'
            LIMIT 1];

        Required_Role__c  reqRole= setUpData();
        Map<Object, Object> newMap = new Map<Object, Object>();

        newMap.put('StartDate', '2021-11-22');
        newMap.put('EndDate', '2021-11-24');
        newMap.put('Id', developer.Id);

        List<Map<Object, Object>> listMap = new List<Map<Object, Object>>{newMap};
        
        ResourceAllocationController.insertResourceAllocations(listMap, reqRole.Id);
        Resource_Allocation__c resource = [SELECT Total_Hours__c  FROM Resource_Allocation__c WHERE Required_Role__c =: reqRole.Id];
        System.assertEquals(24, resource.Total_Hours__c);
    }

    //helper
    @TestSetup
    static void makeUserData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole devId = [SELECT Id FROM UserRole WHERE Name='Developer' LIMIT 1];
        User dev = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            FirstName='Test Dev',
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            UserRoleId= devId.Id,
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='testdevkaiken@testorg.com'
            );

        insert dev;
    }

    private static Required_Role__c  setUpData(){
        Account acc = new Account(Name = 'TestAcc');
        insert acc;
        
        Opportunity opp = new Opportunity(
            Name = 'testOpp', 
            AccountId= acc.Id, 
            Project_Manager__c = [
                SELECT Id 
                FROM User 
                WHERE FirstName='Agustin' 
                AND LastName='Perdomo'
                LIMIT 1].Id,
            StageName='Negotiation/Review',
            CloseDate= Date.today().addDays(40)
        );
        insert opp;
        
    //project
    Project__c newProject = new Project__c(
        Opportunity__c = opp.Id,
        Account__c = opp.AccountId,
        Start_Date__c = date.newInstance(2021,11,15),
        End_Date__c = date.newInstance(2021,11,15).addDays(90),
        Total_Hours_Sold__c = 100,
        Status__c = 'Pre Kick Off'
        );
    insert newProject;

    //req roles
    Required_Role__c newReqRoles =
        new Required_Role__c(
        Project__c = newProject.Id,
        Quantity__c = 100,
        Name='Developers',
        Role__c = 'Developer'
        );

        insert newReqRoles;
        return newReqRoles;
}
}