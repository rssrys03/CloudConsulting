@isTest
public with sharing class ResourceAllocationHelperTest {
    @isTest
    static void onbeforeInsertTest() {
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
        
        List<Resource_allocation__c> newResourcesDataTest = new List<Resource_allocation__c>();     
        
        // Una alocación de recursos con fechas que van con el proyecto
        Resource_allocation__c resourceTestYes = new Resource_allocation__c();
        resourceTestYes.StartDate__c = today.addDays(11);
        resourceTestYes.EndDate__c =today.addDays(12);
        resourceTestYes.Required_Role__c = newReqRoles.get(0).Id;
        
        //Alocación con fechas menores a las del proyecto
        Resource_allocation__c resourceTestNo1= new Resource_allocation__c();
        resourceTestNo1.StartDate__c = today.addDays(9);
        resourceTestNo1.EndDate__c = today.addDays(11);
        resourceTestNo1.Required_Role__c = newReqRoles.get(0).Id;
        
        //Alocación con fechas mayores a las del proyecto
        Resource_allocation__c resourceTestNo2 = new Resource_allocation__c();
        resourceTestNo2.StartDate__c = today.addDays(11);
        resourceTestNo2.EndDate__c = today.addDays(100);
        resourceTestNo2.Required_Role__c = newReqRoles.get(0).Id;
        
        //agrego cada Resource Allocation a mi lista
        //newResourcesDataTest.add(resourceTestYes);
        
        Test.startTest();
        
        //Hago un insert de mi lista para cargar todos los resource allocation en salesforce 
        try {
            newResourcesDataTest.add(resourceTestYes);
            insert newResourcesDataTest; 
        } catch (DMLException e) {
        }
        newResourcesDataTest.clear();
        try {
            newResourcesDataTest.add(resourceTestNo1);
            insert newResourcesDataTest; 
        } catch (DMLException e) {
        }
        newResourcesDataTest.clear();
        
        try {
            newResourcesDataTest.add(resourceTestNo2);
            insert newResourcesDataTest; 
        } catch (DMLException e) {
        }
        
        Test.stopTest();
        
        //Traigo todos los resource allocation de las base de datos
        List<Resource_allocation__c> listOfResourceAllocationFromDb = [            
            SELECT Id, StartDate__c, EndDate__c, Resources__c 
            FROM Resource_Allocation__c ];
        
        System.assertEquals(listOfResourceAllocationFromDb.get(0).Id,resourceTestYes.Id);
        System.assertNotEquals(listOfResourceAllocationFromDb.get(0).Id, resourceTestNo1.Id);
        System.assertNotEquals(listOfResourceAllocationFromDb.get(0).Id, resourceTestNo2.Id);
        
    }
    
}