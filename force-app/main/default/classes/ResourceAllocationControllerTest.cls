@isTest
private  class ResourceAllocationControllerTest {
    @isTest
    static void insertResourceAllocationsTest() {
       User Lancelotdeveloper = [
            SELECT Id 
            FROM User 
            WHERE LastName='Lancelot' 
            LIMIT 1];
        
        List<Object> alocacionTest= new List<Object>{
            '{"StartDate":"2021/11/15", "EndDate":"2021/11/22","Id":"0055f000004jryfAAA"}'
        };
        Required_Role__c  reqRoles= setUpData();
    }

    //helper
    private static Required_Role__c  setUpData(){
        Account acc = new Account(Name = 'TestAcc');
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'testOpp', 
                                          AccountId= acc.Id, 
                                          Project_Manager__c = [
                                              SELECT Id 
                                              FROM User 
                                              WHERE FirstName='Agustin' 
                                              AND LastName='Perdomo'
                                              LIMIT 1].Id,
                                          StageName='Negotiation/Review',
                                          CloseDate= Date.today().addDays(40));
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