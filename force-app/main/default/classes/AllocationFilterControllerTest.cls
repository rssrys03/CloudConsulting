@isTest
public with sharing class AllocationFilterControllerTest {
    @isTest static void getRequiredRolesTest() {
        Project__c project = setUpData();

        List<Required_Role__c> reqRoles = AllocationFilterController.getRequiredRoles(project.Id);

        System.assertEquals( 3,
        reqRoles.size(),
        'There must be at least 3 required roles'
        );
    }

    @isTest static void findUsersWithRequiredRolesTest() {
        Project__c project = setUpData();

        List<User> devs = AllocationFilterController.findUsersWithRequiredRoles('Developer');
        List<User> arch = AllocationFilterController.findUsersWithRequiredRoles('Architect');
        List<User> consul = AllocationFilterController.findUsersWithRequiredRoles('Consultant');

        System.assertEquals( 4,
        devs.size(),
        'There must be at least 2 users with Developer role'
        );
        System.assertEquals( 4,
        arch.size(),
        'There must be at least 1 users with Architect role'
        );
        System.assertEquals( 4,
        consul.size(),
        'There must be at least 2 users with Consultant role'
        );

    }

    @isTest static void checkAllocatedResourcesTest() {
        Project__c project = setUpData();

        List<User> devs = AllocationFilterController.checkAllocatedResources(project.Id, 'Developer');
        List<User> arch = AllocationFilterController.checkAllocatedResources(project.Id, 'Architect');
        List<User> consul = AllocationFilterController.checkAllocatedResources(project.Id, 'Consultant');
        User evaristoConsul = [
            SELECT Id 
            FROM User 
            WHERE FirstName = 'Evaristo' 
            AND LastName='Miller' 
            LIMIT 1];
        
        System.assertEquals( 4,
        devs.size(),
        'There must be at least 4 users with Developer role'
        );
        System.assertEquals( 4,
        arch.size(),
        'There must be at least 4 users with Architect role'
        );
        System.assertEquals( 3,
        consul.size(),
        'There must be at least 3 users with Consultant role'
        );
        System.assertEquals( false,
        consul.contains(evaristoConsul),
        'Evaristo Miller is allocated, he shouldn\'\t be in the available users'
        );

    }

    //helper
    private static Project__c setUpData(){
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
                                          CloseDate= Date.today().addDays(5));
        insert opp;
        

        Date today = Date.today().addDays(10);
        //project
        Project__c newProject = new Project__c(
            Opportunity__c = opp.Id,
            Account__c = opp.AccountId,
            Start_Date__c = today,
            End_Date__c = today.addDays(90),
            Total_Hours_Sold__c = 300,
            Status__c = 'Pre Kick Off'
            );
        insert newProject;
        //req roles
        List<Required_Role__c> newReqRoles = new List<Required_Role__c>{
            new Required_Role__c(
            Project__c = newProject.Id,
            Quantity__c = 100,
            Name='Developers',
            Role__c = 'Developer'
            ),
            new Required_Role__c(
            Project__c = newProject.Id,
            Quantity__c = 100,
            Name='Architects',
            Role__c = 'Architect'
            ),
            new Required_Role__c(
            Project__c = newProject.Id,
            Quantity__c = 100,
            Name='Consultants',
            Role__c = 'Consultant'
            )
        };

        insert newReqRoles;

        User evaristoConsul = [
            SELECT Id 
            FROM User 
            WHERE FirstName = 'Evaristo' 
            AND LastName='Miller' 
            LIMIT 1];

        Required_Role__c consulReqRole = [
            SELECT Id 
            FROM Required_Role__c 
            WHERE Project__c =: newProject.Id 
            AND Name = 'Consultants' 
            LIMIT 1];

       	Resource_Allocation__c newResourceAlloc = new Resource_Allocation__c(
            Name='Evaristo Consul Allocation',
         	Resources__c= evaristoConsul.Id,
         	Required_Role__c = consulReqRole.Id,
         	StartDate__c = today.addDays(15),
          	EndDate__c = today.addDays(25)
        );
        
        insert newResourceAlloc;

        return newProject;
    }
}