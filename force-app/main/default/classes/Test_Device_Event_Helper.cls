/*---------------------------------------------------------------------------------------------------------
Test Class Name : Test_Device_Event_Helper. Related to object Device_Event__c
Description : This is a Test class to test Device_Event_Helper class and Device_Event_Trigger trigger

Date        Version    Modified by        Change details
-------     -------    -------------      --------------------------------------------------------
06-19-2019    1.0      Gagan Brar        SDS-1096: NV System Call Home (Phase 1) 
  
-----------------------------------------------------------------------------------------------------------*/

@isTest
public class Test_Device_Event_Helper {
    
    final static String NAME = 'Test_Device_Event_Helper'; 
    final static String AGENT_PROFILE_NAME = 'Service Cloud Generic User';
    final static String NV_AGENT_ROLE = 'NV Agent';
    
    @isTest
    static void test_TriggerHandler() {
        NV_TriggerHandler th = new NV_TriggerHandler();
        th.init();
        th.beforeInsert();
        th.beforeUpdate();
        th.afterInsert();
        th.afterUpdate();
    }
    @isTest
    static void Test_Device_Event_Helper_Trigger() {
   
        //Create an User
        //Profile agentProfile = [select id from profile  where name =: AGENT_PROFILE_NAME];
        //UserRole nvAgentRole = [SELECT Id FROM UserRole where Name =: NV_AGENT_ROLE];
        //User u1 = createUser(agentProfile, NAME+'1', nvAgentRole.Id);
        //insert u1;
        
        Test.startTest();
        //Create an Account
        Account acct = createAccount(NAME);
        insert acct;
        
        //Create an Asset
        Asset ast = createAsset(NAME, acct.Id);
        insert ast;

        //Create a Contact       
        Contact cont = createContact(NAME+'1', acct.Id);
        insert cont;

        //Create Device Event    
        Device_Event__c evnt = createDeviceEvent(NAME, ast.Id);
        insert evnt;
        List<Device_Event__c> testevnt1 = [SELECT Id,Case__c FROM Device_Event__c WHERE id = :evnt.Id AND Case__c != NULL];
        //System.assertEquals(1,testevnt1.size());

        evnt.Severity__c ='Cleared';
        update evnt;
        List<Device_Event__c> testevnt2 = [SELECT Id,Case__c FROM Device_Event__c WHERE id = :evnt.Id AND Case__c != NULL];
        //System.assertEquals(1,testevnt2.size());
        
        //Test Device Event with Same Batch ID
        Device_Event__c evnt2 = createDeviceEvent(NAME, ast.Id);
        evnt2.Batch_Id__c = evnt.Batch_Id__c;
        insert evnt2;
        List<Device_Event__c> testevnt3 = [SELECT Id,Case__c FROM Device_Event__c WHERE id = :evnt2.Id AND Case__c != NULL];
        //System.assertEquals(1,testevnt3.size());

        //Create Device Event    
        Device_Event__c evnt3 = createDeviceEvent(NAME, ast.Id);
        evnt3.Batch_Id__c = NULL;
        evnt3.Contact_Email__c = NULL;
        insert evnt3;
        List<Device_Event__c> testevnt4 = [SELECT Id,Case__c FROM Device_Event__c WHERE id = :evnt.Id AND Case__c != NULL];
        //System.assertEquals(1,testevnt4.size());
        
        Test.stopTest();
    }
    
    static User createUser(Profile p, String NAME, String roleId) {
    
        User testuser = new User(
                                    Alias           = 'testUser', 
                                    Email           = NAME+'@test.com',
                                    Emailencodingkey= 'UTF-8', 
                                    Lastname        = NAME, 
                                    Languagelocalekey= 'en_US',
                                    Localesidkey    = 'en_US',
                                    Profileid       = p.Id, 
                                    Timezonesidkey  = 'America/Los_Angeles', 
                                    Username        = NAME+'@test.com',
                                    UserRoleId      = roleId,
                                    IsActive        = true
                                );
       return testuser;
    }
    
    static Account createAccount(String NAME){
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];       
        Account acct = new Account();
        acct.Name               = NAME;
        acct.BillingState       = 'California';
        acct.BillingCountry     = 'United States';
        acct.BillingStreet      = 'Test';
        acct.BillingCity        = 'Santa Clara';
        acct.BillingPostalCode  = '95051';
        acct.Billing_Region__c  = 'NALA';
        acct.RecordTypeId       = rt.Id;
        acct.Automotive_Startup__c = 'No';
        return acct;
    }
    
    static Contact createContact(String NAME, Id acctId){
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Contact' AND DeveloperName='SalesContact'];       
        Contact cont        = new Contact();
        cont.FirstName      = 'firstname';
        cont.LastName       = NAME;
        cont.AccountId      = acctId;
        cont.Title          = 'TEST CONTACT';
        cont.Role__c        = 'Technical';
        cont.Email          = NAME+'@mailinator.com';
        cont.Phone          = '4081001001';
        cont.RecordTypeId   = rt.Id;
        return cont;
    }

    static Asset createAsset(String NAME, id acctId){    
        Asset ast = new Asset();
        ast.AccountId = acctId;
        ast.Name = NAME+'12345';
        ast.Name = NAME+'12345';
        ast.Quantity = 1;
        ast.SerialNumber = NAME+'12345';
        ast.Serial_Number__c = NAME+'12345';
        ast.Status = 'Installed';
        
        Product2 prd = new Product2();
        prd.Base_SKU__c = NAME+'-Base-SKU';
        prd.Description = NAME+'-Description';
        prd.Family = 'DGX-1 Volta Product Family';
        prd.IsActive = true;
        prd.Name = NAME+'-product';
        prd.ProductCode = NAME+'-ProductCode';
        prd.Product_Line__c = NAME+'-Product_Line';
        prd.Product_Type__c = 'Hardware';
        insert prd;
        
        ast.Product2Id = prd.id;
        return ast;
    }
    
    static Device_Event__c createDeviceEvent(String NAME, Id assetId) {
        Device_Event__c evnt = new Device_Event__c();
        evnt.System_Name__c             = NAME+'-SYSTEM-NAME';
        evnt.Asset__c                   = assetId;
        evnt.Alert_Id__c                = NAME+'-ALERT-ID';
        evnt.Component_Id__c            = NAME+'-COMPONENT-ID';
        evnt.Alert_Create_DateTime__c   = system.now().format();
        evnt.Contact_Email__c           = NAME+'@mailinator.com';
        evnt.Device_Event_ID__c         = NAME+'-EVENT-ID-'+system.now();
        evnt.System_Serial_Number__c    = NAME+'12345';
        evnt.Severity__c                = 'Critical';
        evnt.Batch_Id__c                = NAME+'-BATCH-ID-'+system.now();
        evnt.Message__c                 = NAME+'-MESSAGE';
        evnt.Message_Details__c         = NAME+'-MESSAGE-DETAILS';
        return evnt;
    }
}