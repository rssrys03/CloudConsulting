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
        User consulUser = [
            SELECT FirstName, LastName, UserRole.Name
            FROM User 
            WHERE FirstName = 'Test Consul' 
            AND LastName='Testing' 
            LIMIT 1];
        User devUser = [
            SELECT FirstName, LastName, UserRole.Name
            FROM User 
            WHERE FirstName = 'Test Dev' 
            AND LastName='Testing' 
            LIMIT 1];
        System.debug('USER' + devUser);
        User archUser = [
            SELECT FirstName, LastName, UserRole.Name
            FROM User 
            WHERE FirstName = 'Test Arch' 
            AND LastName='Testing' 
            LIMIT 1];

        List<User> devs = AllocationFilterController.findUsersWithRequiredRoles('Developer');
        List<User> arch = AllocationFilterController.findUsersWithRequiredRoles('Architect');
        List<User> consul = AllocationFilterController.findUsersWithRequiredRoles('Consultant');

        System.assertEquals(true,
        devs.contains(devUser),
        'Devs list must have in their users the dev test user'
        );
        System.assertEquals( true,
        arch.contains(archUser),
        'Arch list must have in their users the architect test user'
        );
        System.assertEquals( true,
        consul.contains(consulUser),
        'Consul list must have in their users the consul test user'
        );

    }

    @isTest static void checkAllocatedResourcesTest() {
       Project__c project = setUpData();

        List<User> devs = AllocationFilterController.checkAllocatedResources(project.Id, 'Developer');
        List<User> arch = AllocationFilterController.checkAllocatedResources(project.Id, 'Architect');
        List<User> consul = AllocationFilterController.checkAllocatedResources(project.Id, 'Consultant');
        User consulUser = [
            SELECT FirstName, LastName, UserRole.Name
            FROM User 
            WHERE FirstName = 'Test Consul' 
            AND LastName='Testing' 
            LIMIT 1];

        User devUser = [
            SELECT FirstName, LastName, UserRole.Name
            FROM User 
            WHERE FirstName = 'Test Dev' 
            AND LastName='Testing' 
            LIMIT 1];

        User archUser = [
            SELECT FirstName, LastName, UserRole.Name
            FROM User 
            WHERE FirstName = 'Test Arch' 
            AND LastName='Testing' 
            LIMIT 1];
        
         System.assertEquals(true,
        devs.contains(devUser),
        'Devs list must have in their users the dev test user'
        );
        System.assertEquals( true,
        arch.contains(archUser),
        'Arch list must have in their users the architect test user'
        );
        System.assertEquals( false,
        consul.contains(consulUser),
        'Evaristo Miller is allocated, he shouldn\'\t be in the available users'
        );

    }

    //helper
     @testSetUp
    private static void setUpUserData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole devId = [SELECT Id FROM UserRole WHERE Name='Developer' LIMIT 1];
        UserRole archId = [SELECT Id FROM UserRole WHERE Name='Architect' LIMIT 1];
        UserRole consulId = [SELECT Id FROM UserRole WHERE Name='Consultant' LIMIT 1];
        
        
        List<User> users = new List<User>();
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
        users.add(dev);

        User arch = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            FirstNAme='Test Arch',
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            UserRoleId=archId.Id,
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='testarchkaiken@testorg.com'
        );
        users.add(arch);

        User consul = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', 
            FirstNAme='Test Consul',
            LastName='Testing', 
            LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', 
            ProfileId = p.Id, 
            UserRoleId=consulId.Id,
            TimeZoneSidKey='America/Los_Angeles', 
            UserName='testconsulkaiken@testorg.com'
        );
        users.add(consul);

        insert users;
    }
    
    private static Project__c setUpData(){
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
            CloseDate= Date.today().addDays(5)
        );
        insert opp;
        

        Date today = Date.today().addDays(10);
        //project
        Project__c newProject = new Project__c(
            Name='Test Project',
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

        Required_Role__c consulReqRole = [
            SELECT Id 
            FROM Required_Role__c 
            WHERE Project__c =: newProject.Id 
            AND Name = 'Consultants' 
            LIMIT 1];
        
		User consul = [
            SELECT Id 
            FROM User 
            WHERE FirstName = 'Test Consul' 
            AND LastName='Testing' 
            LIMIT 1];
        
       	Resource_Allocation__c newResourceAlloc = new Resource_Allocation__c(
            Name='Evaristo Consul Allocation',
         	Resources__c= consul.Id,
         	Required_Role__c = consulReqRole.Id,
         	StartDate__c = today.addDays(15),
          	EndDate__c = today.addDays(25)
        );
        
        insert newResourceAlloc;

        return newProject;
    }
}