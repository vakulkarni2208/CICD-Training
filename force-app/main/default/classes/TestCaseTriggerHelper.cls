/**************************************************************************************************
* Name       : TestCaseTriggerHelper
* Purpose    : Test class for Trigger CaseTriggerHelper. 
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 1/5/2017        | Initial Draft
*Akhilesh Gupta     | 1.1        | 08/15/2018      | Code Formatting changes and Test code update for Owner Assignment logic change
*Akhilesh Gupta     | 2.0        | 08/15/2018      | Fix for CPQ 2.0
*Akhilesh Gupta     | 3.0        | 08/18/2018      | Use Common utility functions.
*Manideep Patchava  | 3.0        | 02/13/2019      | Added [Automotive_Startup__c = 'No'] field at Account creation in all the methods below to fix the Validaition error.
*Akhilesh Gupta     | 3.0        | 09/09/2019      | Use Common utility functions and 
                                                     Move NV_TriggerHandler code to separate class.
*Akhilesh Gupta     | 3.0        | 20/26/2020      | Updated Test code for changes related
                                                        ESP_Constants class, Use of ESP_Utility Class.
Note: Need to remove commented code in next cleanup
**************************************************************************************************/

@isTest
private class TestCaseTriggerHelper
{
    final static String NAME                = 'TestCaseTriggerHelper'; 
    final static String AGENT_PROFILE_NAME  = 'Service Cloud Generic User';
    final static String NV_AGENT_ROLE       = 'NV Agent';
    final static String NCR_AGENT_ROLE      = 'NCR Agent';
    
    @TestSetup
    static void setup() {
        
        Profile agentProfile    = [select id from profile  where name =: AGENT_PROFILE_NAME];
        UserRole nvAgentRole    = [SELECT Id FROM UserRole where Name =: NV_AGENT_ROLE];
        UserRole ncrAgentRole   = [SELECT Id FROM UserRole where Name =: NCR_AGENT_ROLE];
        
        List<User> userList = new List<User>();
        User u1 = Test_COMM_Factory.getUser(agentProfile.Id, NAME+'1', ncrAgentRole.Id);
        User u2 = Test_COMM_Factory.getUser(agentProfile.Id, NAME+'2', ncrAgentRole.Id);
        User u3 = Test_COMM_Factory.getUser(agentProfile.Id, NAME+'3', nvAgentRole.Id);
        User u4 = Test_COMM_Factory.getUser(agentProfile.Id, NAME+'4', null);
        User u5 = Test_COMM_Factory.getUser(agentProfile.Id, NAME+'5', ncrAgentRole.Id);
        
        userList.add(u1);
        userList.add(u2);
        userList.add(u3);
        userList.add(u4);
        userList.add(u5);
        
        insert userList;
        
    }

    
    @isTest
    static void test_updateEntitlements() {
        User u4 = [select Id from User where LastName =: NAME+'4'];
        User u5 = [select Id from User where LastName =: NAME+'5'];
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];       
        
        Test.startTest();
        Test_COMM_Factory.insertLeadSpaceCS();
        //1.Account Create - Account Name, Support level, Designated Eng, 
        Account acct                = Test_COMM_Factory.getAccount(NAME);
        acct.RecordTypeId           = rt.Id;
        acct.Designated_Engineer__c = u4.Id;
        //acct.Support_Level__c     = ESP_Utility.ESPConstants.ServiceCloudSettings.SLA_24x7Support_Label__c;
        acct.Automotive_Startup__c  = 'No';
        acct.BillingState       = 'California';
        acct.BillingCountry     = 'United States';
        acct.BillingStreet      = 'Test';
        acct.BillingCity        = 'Santa Clara';
        acct.BillingPostalCode  = '95051';
        acct.Billing_Region__c  = 'NALA';
        acct.website = 'google.com';
        insert acct;
        
        //Entitlement create- Entitlement Process Name, Account
        Entitlement Ent = Test_COMM_Factory.getEntitlement(Name, acct.id);
        //Ent.AccountId = acct.Id;
        //Ent.Name = NAME+'Ent';
        insert Ent;
        
        acct.Support_Level__c = ESP_Utility.ESPConstants.ServiceCloudSettings.SLA_24x7Support_Label__c;
        update acct;
        
        //Entitlement create- Entitlement Process Name, Account
        Entitlement Ent2 = Test_COMM_Factory.getEntitlement(Name, acct.id);
        //Ent.AccountId = acct.Id;
        //Ent.Name = NAME+'Ent';
        Ent2.Name       = NAME+'Ent2';
        insert Ent2;
        
        Test.stopTest();
    }
    
    @isTest
    static void test_bussiness_critical_support() {
        User u4 = [select Id from User where LastName =: NAME+'4'];
        User u5 = [select Id from User where LastName =: NAME+'5'];
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];       
        
        
        Test_COMM_Factory.insertLeadSpaceCS();
        //1.Account Create - Account Name, Support level, Designated Eng, 
        Account acct                = Test_COMM_Factory.getAccount(NAME);
        acct.RecordTypeId           = rt.Id;
        acct.Designated_Engineer__c = u4.Id;
        acct.Support_Level__c       = ESP_Utility.ESPConstants.ServiceCloudSettings.SLA_24x7Support_Label__c;
        acct.Automotive_Startup__c  = 'No';
        acct.BillingState       = 'California';
        acct.BillingCountry     = 'United States';
        acct.BillingStreet      = 'Test';
        acct.BillingCity        = 'Santa Clara';
        acct.BillingPostalCode  = '95051';
        acct.Billing_Region__c  = 'NALA';
        acct.website = 'google.com';
        insert acct;
        
        //Create product
        Product2 product        = Test_COMM_Factory.getProduct('Test Product');
        product.Product_Type__c = 'Software';
        product.Product_Line__c = 'Grid';
        product.ProductCode     = 'PRD001';
        product.IsActive        = true;
        product.Support_level__c= ESP_Utility.ESPConstants.SLA_24X7SUPPORT;
        insert product;
        
        //Create Entitlement - 
        Entitlement Ent                 = Test_COMM_Factory.getEntitlement(Name, acct.Id);
        Ent.Hardware_Serial_Number__c   = 'Serial111';
        Ent.PAK_ID__c                   = '12345';
        Ent.Service_product__c          = product.Id;
        Ent.EndDate                     = Date.today();
        Ent.StartDate                   = Date.today().addDays(-1);
        //Ent.Subscription__c           = subscription1.Id;
        
        insert Ent;
        
        //case create - Account*, Entitlement*, Case owner, incident status, case origin*, status*, subject , description, sevrity* 
        
        Case_Keyword_Queue_Assignment__c ckey = new Case_Keyword_Queue_Assignment__c();
        ckey.name='Fleet Command';
        ckey.Keywords__c = 'Fleet Command;';
        ckey.Queue_Name__c = 'FLS Queue';
        insert ckey;
        
        RecordType crt  = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
        Case c          = Test_COMM_Factory.getCase(acct.Id, crt.Id);
        c.Severity__c   = 'S1:_Catastrophic';
        c.Origin        = 'Web';
        c.EntitlementId = Ent.Id;
        c.subject = 'Fleet Command';
        insert c;
        
        //check 3 milestone created
        //SELECT CaseId,CompletionDate,CreatedDate,ElapsedTimeInMins,Id,IsCompleted,IsDeleted,IsViolated,
          //  MilestoneTypeId,MilestoneType.Name,StartDate FROM CaseMilestone WHERE CaseId='5000R000004zTvM';
        List<CaseMilestone> CaseMile = [select Id,MilestoneTypeId,MilestoneType.Name FROM CaseMilestone WHERE CaseId=:c.Id];
        for(CaseMilestone cm :CaseMile )
            system.debug(cm.MilestoneType.Name);
        //System.assertEquals(CaseMile.size(), 3);
        //Just Check
        //Integer count = [select count(MilestoneTypeId) FROM CaseMilestone WHERE CaseId=:c.Id];
        //System.debug(count);/
        //case owner - to NCR Agent
        c.OwnerId = u5.Id;
        //update c;
        //case incident status and incident sub status 
        c.Incident_Status__c    = 'Enterprise Support';
        c.Incident_Substatus__c = '3rd party software issue';//Software Issues (? - Software bugs, 3rd party problem)';
        Test.startTest();
        update c;
        //check auto assign to designated engineer and one more milestone created and SLA text and Milestone status and ckeck boxs 1 is updated
       // System.assertEquals(u5.Id,c.OwnerId);
        //Check One New designated Milestone created
        List<CaseMilestone> CaseMile2 = [select Id,MilestoneTypeId,MilestoneType.Name FROM CaseMilestone WHERE CaseId=:c.Id];
        //System.assertEquals(CaseMile2.size(),4);
        //Change case owner - to bussiness critical Queue  
        List<Group> BCSQueue = [SELECT Id, DeveloperName FROM Group WHERE Type='Queue' AND DeveloperName = : CaseTriggerHelper.QUEUE_DEV_NANE_BCS];
        c.OwnerId = BCSQueue[0].Id;
        c.Assigned_to_Business_Critical_Queue__c = true;
        update c;
        
        //check one more mileston created for BSC Queue
        List<CaseMilestone> CaseMile3 = [select Id,MilestoneTypeId,MilestoneType.Name FROM CaseMilestone WHERE CaseId=:c.Id];
       // System.assertEquals(CaseMile3.size(),5);
        //Update Milestone Status to trigger Emails
        c.Milestone_Status__c = 'Reassign to BusinessCriticalSupportQueue';
        update c;
       
        //close case
        //all milestone closed 
        List<CaseMilestone> CaseMile5 = [SELECT MilestoneTypeId,MilestoneType.Name FROM CaseMilestone WHERE CaseId=:c.Id and IsCompleted =:true];
        
        Test.stopTest();
    }
    
    @isTest
    static void test_case_close() {
        User u4 = [select Id from User where LastName =: NAME+'4'];
        User u5 = [select Id from User where LastName =: NAME+'5'];
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];       
        
        Test.startTest();
        Test_COMM_Factory.insertLeadSpaceCS();
        //1.Account Create - Account Name, Support level, Designated Eng, 
        Account acct                = Test_COMM_Factory.getAccount(NAME);
        acct.RecordTypeId           = rt.Id;
        acct.Designated_Engineer__c = u4.Id;
        acct.Support_Level__c       = ESP_Utility.ESPConstants.ServiceCloudSettings.SLA_24x7Support_Label__c;
        acct.Automotive_Startup__c  = 'No';
        acct.BillingState       = 'California';
        acct.BillingCountry     = 'United States';
        acct.BillingStreet      = 'Test';
        acct.BillingCity        = 'Santa Clara';
        acct.BillingPostalCode  = '95051';
        acct.Billing_Region__c  = 'NALA';
        acct.website = 'google.com';
        insert acct;
        
        //Entitlement create- Entitlement Process Name, Account
        Entitlement Ent = Test_COMM_Factory.getEntitlement(Name, acct.id);
        //Ent.AccountId = acct.Id;
        //Ent.Name = NAME+'Ent';
        insert Ent;

        RecordType crt  = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
        Case c          = Test_COMM_Factory.getCase(acct.Id, crt.Id);
        c.Severity__c   = 'S1:_Catastrophic';
        c.Origin        = 'Web';
        c.EntitlementId = Ent.Id;
        c.Engineering_Support_Hours__c = 10;
        insert c;
        
        c.Status                = 'Closed';
        c.Incident_Status__c    = 'Closed';
        c.Incident_Substatus__c = 'Customer Closure';
        c.Engineering_Support_Hours__c = 20;
        update c;
        
        Test.stoptest();   
    }    
    
    @isTest
    static void test_setAccountForDomain() {
        User u4 = [select Id from User where LastName =: NAME+'4'];
        User u5 = [select Id from User where LastName =: NAME+'5'];
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];       
        
        Test.startTest();
        Test_COMM_Factory.insertLeadSpaceCS();
        //1.Account Create - Account Name, Support level, Designated Eng, 
        Account acct                = Test_COMM_Factory.getAccount(NAME);
        acct.RecordTypeId           = rt.Id;
        acct.Designated_Engineer__c = u4.Id;
        acct.Support_Level__c       = ESP_Utility.ESPConstants.ServiceCloudSettings.SLA_24x7Support_Label__c;
        acct.Automotive_Startup__c  = 'No';
        acct.BillingState       = 'California';
        acct.BillingCountry     = 'United States';
        acct.BillingStreet      = 'Test';
        acct.BillingCity        = 'Santa Clara';
        acct.BillingPostalCode  = '95051';
        acct.Billing_Region__c  = 'NALA';
        acct.website = 'google.com';
        insert acct;
        
        //Entitlement create- Entitlement Process Name, Account
        Entitlement Ent = Test_COMM_Factory.getEntitlement(Name, acct.id);
        //Ent.AccountId = acct.Id;
        //Ent.Name = NAME+'Ent';
        insert Ent;
        
        RecordType crt = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
        Case c          = Test_COMM_Factory.getCase(Null, crt.Id);
        c.Severity__c   = 'S1:_Catastrophic';
        c.Origin        = 'Email';
        c.suppliedEmail = 'abc@'+ NAME + '.com';
        c.EntitlementId = Ent.Id;
        c.Engineering_Support_Hours__c = 10; 
        c.Last_Activity_User_Type__c ='Customer';
        insert c;
        Test.stoptest();
    }
    
@isTest
    static void test_escalation_and_mirror_NCR() {
        User u1 = [select Id from User where LastName =: NAME+'1'];
        User u2 = [select Id from User where LastName =: NAME+'2'];
        User u3 = [select Id from User where LastName =: NAME+'3'];
        User u4 = [select Id from User where LastName =: NAME+'4'];
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];       
        
        Test.startTest();
        Test_COMM_Factory.insertLeadSpaceCS();
        Account acct        = Test_COMM_Factory.getAccount(NAME);
        acct.RecordTypeId   = rt.Id;
        acct.Automotive_Startup__c = 'No';
        acct.BillingState       = 'California';
        acct.BillingCountry     = 'United States';
        acct.BillingStreet      = 'Test';
        acct.BillingCity        = 'Santa Clara';
        acct.BillingPostalCode  = '95051';
        acct.Billing_Region__c  = 'NALA';
        acct.website = 'google.com';
        insert acct;
        
        //Create Case
        RecordType crt = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
        Case c = Test_COMM_Factory.getCase(acct.Id, crt.Id);
        insert c;
        
        //check Case_Owner__c field is updated with Owner Name
        c.OwnerId = u1.Id;
        system.debug('1232019 Case: '+ c);
        
        update c;
        Test.stoptest();
    }

@isTest
    static void test_escalation_and_mirror_NCR1() {
        User u1 = [select Id from User where LastName =: NAME+'1'];
        User u2 = [select Id from User where LastName =: NAME+'2'];
        User u3 = [select Id from User where LastName =: NAME+'3'];
        User u4 = [select Id from User where LastName =: NAME+'4'];
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];       
        
        Test.startTest();
        Test_COMM_Factory.insertLeadSpaceCS();
        Account acct        = Test_COMM_Factory.getAccount(NAME);
        acct.RecordTypeId   = rt.Id;
        acct.Automotive_Startup__c = 'No';
        acct.BillingState       = 'California';
        acct.BillingCountry     = 'United States';
        acct.BillingStreet      = 'Test';
        acct.BillingCity        = 'Santa Clara';
        acct.BillingPostalCode  = '95051';
        acct.Billing_Region__c  = 'NALA';
        acct.website = 'google.com';
        insert acct;
        
        //Create Case
        RecordType crt = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
        Case c = Test_COMM_Factory.getCase(acct.Id, crt.Id);
        insert c;
        
        Case updatedCase = [SELECT OwnerId, Case_Owner__c,RecordType.Name, Incident_Status__c FROM Case WHERE Id = :c.Id];
        system.debug('1232019 Case: '+ c);
        system.debug('1232019 updatedCase: '+ updatedCase);
        //System.assertEquals(NAME+'1', updatedCase.Case_Owner__c);
        
        c.Incident_Status__c = CaseTriggerHelper.STATUS_AAA;
        update c;
        Test.stoptest();
    }
    
@isTest
    static void test_escalation_and_mirror_NCR2() {
        User u1 = [select Id from User where LastName =: NAME+'1'];
        User u2 = [select Id from User where LastName =: NAME+'2'];
        User u3 = [select Id from User where LastName =: NAME+'3'];
        User u4 = [select Id from User where LastName =: NAME+'4'];
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];       
        
        Test.startTest();
        Test_COMM_Factory.insertLeadSpaceCS();
        Account acct        = Test_COMM_Factory.getAccount(NAME);
        acct.RecordTypeId   = rt.Id;
        acct.Automotive_Startup__c = 'No';
        acct.BillingState       = 'California';
        acct.BillingCountry     = 'United States';
        acct.BillingStreet      = 'Test';
        acct.BillingCity        = 'Santa Clara';
        acct.BillingPostalCode  = '95051';
        acct.Billing_Region__c  = 'NALA';
        acct.website = 'google.com';
        insert acct;
        
        //Create Case
        RecordType crt = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
        Case c = Test_COMM_Factory.getCase(acct.Id, crt.Id);
        insert c;
        
        Case updatedCase = [SELECT OwnerId, Case_Owner__c,RecordType.Name FROM Case WHERE Id = :c.Id];
        System.debug('case owner id:' + c.OwnerId);
        String sOwnerId = updatedCase.OwnerId;
        //Group g = [SELECT DeveloperName FROM Group WHERE Id = :updatedCase.OwnerId];
        
        c.Incident_Status__c = 'Troubleshooting-Sub';
        update c;
        Test.stoptest();
    }
        
@isTest
    static void test_escalation_and_mirror_NCR3() {
        User u1 = [select Id from User where LastName =: NAME+'1'];
        User u2 = [select Id from User where LastName =: NAME+'2'];
        User u3 = [select Id from User where LastName =: NAME+'3'];
        User u4 = [select Id from User where LastName =: NAME+'4'];
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];       
        
        Test.startTest();
        Test_COMM_Factory.insertLeadSpaceCS();
        Account acct        = Test_COMM_Factory.getAccount(NAME);
        acct.RecordTypeId   = rt.Id;
        acct.Automotive_Startup__c = 'No';
        acct.BillingState       = 'California';
        acct.BillingCountry     = 'United States';
        acct.BillingStreet      = 'Test';
        acct.BillingCity        = 'Santa Clara';
        acct.BillingPostalCode  = '95051';
        acct.Billing_Region__c  = 'NALA';
        acct.website = 'google.com';
        insert acct;
        
        //Create Case
        RecordType crt = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
        Case c = Test_COMM_Factory.getCase(acct.Id, crt.Id);
        insert c;
        
        c.OwnerId = u2.Id;
        update c;
        Case updatedCase = [SELECT OwnerId, Case_Owner__c FROM Case WHERE Id = :c.Id];
        System.debug('case owner id:' + c.OwnerId);
        Test.stoptest();
        
    }
    
@isTest
    static void test_escalation_and_mirror_NCR4() {
        User u1 = [select Id from User where LastName =: NAME+'1'];
        User u2 = [select Id from User where LastName =: NAME+'2'];
        User u3 = [select Id from User where LastName =: NAME+'3'];
        User u4 = [select Id from User where LastName =: NAME+'4'];
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];       
        
        Test.startTest();
        Test_COMM_Factory.insertLeadSpaceCS();
        Account acct        = Test_COMM_Factory.getAccount(NAME);
        acct.RecordTypeId   = rt.Id;
        acct.Automotive_Startup__c = 'No';
        acct.BillingState       = 'California';
        acct.BillingCountry     = 'United States';
        acct.BillingStreet      = 'Test';
        acct.BillingCity        = 'Santa Clara';
        acct.BillingPostalCode  = '95051';
        acct.Billing_Region__c  = 'NALA';
        acct.website = 'google.com';
        insert acct;
        
        //Create Case
        RecordType crt = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
        Case c = Test_COMM_Factory.getCase(acct.Id, crt.Id);
        insert c;
        
        //Setting Incident Status to "Enterprise Support" should assign Case to ESP_L3 Queue
        c.Incident_Status__c    = CaseTriggerHelper.STATUS_ES; 
        c.Incident_Substatus__c = '3rd party software issue'; //Unable to Solve the Issue (Can\'t solve the issue and need further escalation)';
        //c.Incident_Substatus__c = 'Others (? - Reason not covered above - enter reason in Case Comments -- Internal Only)'; 
        update c;
        Case updatedCase = [SELECT OwnerId, Case_Owner__c, Ownership_frozen__c FROM Case WHERE Id = :c.Id];
        System.debug('case owner id:' + c.OwnerId);
        string sOwnerId = updatedCase.OwnerId;
        Group g = [SELECT DeveloperName FROM Group WHERE Id = :updatedCase.OwnerId];
        
        //Once Ownership is frozen, changing Owner to NV_Agent should not change Case_Owner__c field.
        c.OwnerId = u3.Id;
        
        update c;
        updatedCase = [SELECT OwnerId, Case_Owner__c FROM Case WHERE Id = :c.Id];
        System.debug('case owner id:' + c.OwnerId);
        //Once Ownership is frozen, changing Owner non-NV_Agent should not change Case_Owner__c field.
        c.OwnerId = u4.Id;
        update c;
        updatedCase = [SELECT OwnerId, Case_Owner__c FROM Case WHERE Id = :c.Id];
        System.debug('case owner id:' + c.OwnerId);
        
        Test.stopTest();
    }

    @isTest
    static void test_escalation_and_mirror_JAPAN(){
        User u1 = [select Id from User where LastName =: NAME+'1'];
        User u2 = [select Id from User where LastName =: NAME+'2'];
        User u3 = [select Id from User where LastName =: NAME+'3'];
        User u4 = [select Id from User where LastName =: NAME+'4'];
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];       
        
        Test.startTest();
        
        list<Country_List__c> lstCountry  = new list<Country_List__c>();
        Country_List__c countryUS         = new Country_List__c (
                            name          = COMM_Constants.ADDRESS_COUNTRY, 
                            ISO_Code__c   = COMM_Constants.ADDRESS_US_ISO2, 
                            ISO_Code_3__c = COMM_Constants.ADDRESS_US_ISO3, 
                            Region__c     = COMM_Constants.ADDRESS_REGION_NALA, 
                            Sub_Region__c = COMM_Constants.ADDRESS_SUBREGION_LA, 
                            Territory__c  = COMM_Constants.ADDRESS_TERRITORY_LA
                        );
        lstCountry.add(countryUS);
        Country_List__c countryJapan          = new Country_List__c (
                                name          = 'Japan', 
                                ISO_Code__c   = 'JP', 
                                ISO_Code_3__c = 'JPN', 
                                Region__c     = 'JAPAN', 
                                Sub_Region__c = 'JAPAN', 
                                Territory__c  = ''
                            );
        lstCountry.add(countryJapan);
        map<string, Country_List__c> mapCountryList = Test_COMM_Factory.setCountryList(lstCountry);
        
        
        //createAccountWithBillingAddress()
        Test_COMM_Factory.insertLeadSpaceCS();
        Account acct            = Test_COMM_Factory.getAccount(NAME);
        acct.RecordTypeId       = rt.Id;
        acct.Billing_Region__c  = 'JAPAN';
        acct.BillingCountry     = 'Japan';
        acct.BillingState       ='';
        acct.Automotive_Startup__c = 'No';
        acct.website = 'google.com';        
        insert acct;
        
        //acct.BillingCountry ='United States';
        System.debug('98761 Account Billing'+ [select Id, Billing_Region__c from Account where Id =:acct.Id].Billing_Region__c);
        
        RecordType crt = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
        Case c = Test_COMM_Factory.getCase(acct.Id, crt.Id);       
        insert c;
        
        c.OwnerId = u1.Id;
        update c;
        
        Case updatedCase = [SELECT OwnerId, Case_Owner__c FROM Case WHERE Id = :c.Id];
        System.debug('case owner id:' + c.OwnerId);
        //System.assertEquals(name+'1',updatedCase.Case_Owner__c);
        
        c.Incident_Status__c = 'Troubleshooting-Sub';
        update c;
        
        c.Incident_Status__c = CaseTriggerHelper.STATUS_AAA;
        update c;
        updatedCase = [SELECT OwnerId, Case_Owner__c FROM Case WHERE Id = :c.Id];
        System.debug('case owner id:' + c.OwnerId);
        String sOwnerId = updatedCase.OwnerId;
        //System.assert(sOwnerid.startsWith('00G'), sOwnerId);
        
        Group g = [SELECT DeveloperName FROM Group WHERE Id = :updatedCase.OwnerId];
        //System.assertEquals(CaseTriggerHelper.QUEUE_DEV_NAME_JTP_L2 , g.DeveloperName);
        
        c.OwnerId = u2.Id;
        update c;
        updatedCase = [SELECT OwnerId, Case_Owner__c FROM Case WHERE Id = :c.Id];
        System.debug('case owner id:' + c.OwnerId);
        //System.assertEquals(name+'2',updatedCase.Case_Owner__c);
        
        c.Incident_Status__c = CaseTriggerHelper.STATUS_ES; 
        c.Incident_Substatus__c = 'Unable to Solve the Issue';// (Can\'t solve the issue and need further escalation)';
        //c.Incident_Substatus__c = 'Others (? - Reason not covered above - enter reason in Case Comments -- Internal Only)'; 
        update c;
        updatedCase = [SELECT OwnerId, Case_Owner__c FROM Case WHERE Id = :c.Id];
        System.debug('case owner id:' + c.OwnerId);
        sOwnerId = updatedCase.OwnerId;
        System.assert(sOwnerid.startsWith('00G'), sOwnerId);
        
        c.OwnerId = u3.Id;
        update c;
        updatedCase = [SELECT OwnerId, Case_Owner__c FROM Case WHERE Id = :c.Id];
        System.debug('case owner id:' + c.OwnerId);
        System.assertEquals(name+'2',updatedCase.Case_Owner__c);
        
        c.OwnerId = u4.Id;
        update c;
        updatedCase = [SELECT OwnerId, Case_Owner__c FROM Case WHERE Id = :c.Id];
        System.debug('case owner id:' + c.OwnerId);
        System.assertEquals(name+'2',updatedCase.Case_Owner__c);
        
        Test.stopTest();
    }

    @isTest
    static void test_updateProductFamily(){
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];       
        Date startDate = date.newInstance(System.now().year(), System.now().month(), System.now().day());
        Test_COMM_Factory.insertLeadSpaceCS();
        Account acct        = Test_COMM_Factory.getAccount(NAME);
        acct.RecordTypeId   = rt.Id;
        acct.Automotive_Startup__c = 'No';
        acct.BillingState       = 'California';
        acct.BillingCountry     = 'United States';
        acct.BillingStreet      = 'Test';
        acct.BillingCity        = 'Santa Clara';
        acct.BillingPostalCode  = '95051';
        acct.Billing_Region__c  = 'NALA';
        acct.website = 'google.com';
        insert acct;
        
        //Opportunity creation
        List<Opportunity> opptList = new List<Opportunity>();
        for(Integer i=0; i<2; i++){
            Opportunity oppt = Test_COMM_Factory.getOpportunity(NAME+i, acct.Id);//new Opportunity();
            //oppt.Name      = NAME+i;
            //oppt.StageName = 'Discovery';
            //oppt.AccountId = acct.Id;
            //oppt.CloseDate = Date.today();
            opptList.add(oppt);
        }
        insert opptList;

        //Contract creation
        List<Contract> contractList = new List<Contract>();
        for(Integer i=0; i<2; i++){
            Contract contract   = Test_COMM_Factory.getContract(acct.Id); /*new Contract();
            contract.AccountId  = acct.Id;
            contract.Status     ='Draft';
            contract.StartDate  = startDate;
            //contract.SBQQ__Opportunity__c=opptList[i].Id;*/
            contractList.add(contract);
        }
        insert contractList;
        
        //Activate contract
        contractList[0].Status = 'Activated';
        contractList[1].Status = 'Activated';
        update contractList;
        
        //Product creation
        List<Product2> prodList = new List<Product2>();        
        Product2 product1 = Test_COMM_Factory.getProduct(Name);//new Product2(Name ='Test Product', Family='DGX-1 Pascal Product Family');
        Product2 product2 = Test_COMM_Factory.getProduct(Name);//new Product2(Name ='Test Product', Family='DGX-1 Volta Product Family');
        product2.Family = 'DGX-1 Volta Product Family';
        prodList.add(product1);
        prodList.add(product2);
        insert prodList;
     
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        for(Integer i=0; i<2; i++){
            SBQQ__Subscription__c subscription = Test_COMM_Factory.getSubscription(acct.Id, prodList[i].Id, contractList[i].Id);
            subscription.Hardware_Serial_Number__c ='Serial111'+i;
            /*SBQQ__Subscription__c subscription = new SBQQ__Subscription__c
                                        (
                                            SBQQ__Account__c    = acct.Id, 
                                            SBQQ__Product__c    = prodList[i].Id,
                                            SBQQ__Contract__c   = contractList[i].Id, 
                                            SBQQ__Quantity__c   = 2,
                                            Hardware_Serial_Number__c ='Serial111'+i
                                        );*/
            subList.add(subscription);
        }
        insert subList;
        List<Entitlement> lstEnt = new List<Entitlement>();
        Entitlement Ent = Test_COMM_Factory.getEntitlement(Name, acct.id);
        //Ent.AccountId = acct.Id;
        //Ent.Name = NAME+'Ent';
        Ent.Service_Product__c = product1.id;
        lstEnt.add(Ent);
        
        //Entitlement create- Entitlement Process Name, Account
        Entitlement Ent2 = Test_COMM_Factory.getEntitlement(Name, acct.id);
        //Ent.AccountId = acct.Id;
        Ent2.Name = NAME+'Ent2';
        Ent2.Service_Product__c = product2.id;
        lstEnt.add(Ent2);           
        insert lstEnt;
        
        Part__c pt = new Part__c(Part_Number__c='920-200-2500',description__c='test',Full_System__c=true);
        insert pt;
        List<Entitlement> entiList = [SELECT Id,Product_Family__c FROM Entitlement WHERE AccountId = :acct.Id];
        System.assertEquals(2,entiList.size());
        String expectedPF = entiList[0].Product_Family__c;
        
        Test.startTest();
        
        RecordType crt = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
        Case c1 = Test_COMM_Factory.getCase(acct.Id, crt.Id);
        c1.EntitlementId = entiList[0].Id;
        insert c1;
        Case updatedC1 = [SELECT Product_Family__c FROM Case WHERE Id = :c1.Id];
        System.assertEquals(expectedPF,updatedC1.Product_Family__c);
        
        c1.EntitlementId = entiList[1].Id;
        update c1;
        expectedPF = entiList[1].Product_Family__c;
        updatedC1 = [SELECT Product_Family__c FROM Case WHERE Id = :c1.Id];
        System.assertEquals(expectedPF,updatedC1.Product_Family__c);

        List<Entitlement__c> cusEntiList = [SELECT Id FROM Entitlement__c WHERE Account__c = :acct.Id];
        //RecordType crt = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
        Case c2 = Test_COMM_Factory.getCase(acct.Id, crt.Id);
        c2.Entitlement__c = cusEntiList[0].Id;
        insert c2;
        Case updatedC2 = [SELECT Product_Family__c FROM Case WHERE Id = :c2.Id];
        System.assertNotEquals(null,updatedC2.Product_Family__c);
        
        String pf1 = updatedC2.Product_Family__c;
        c2.Entitlement__c = cusEntiList[1].Id;
        update c2;
        updatedC2 = [SELECT Product_Family__c FROM Case WHERE Id = :c2.Id];
        System.assertNotEquals(pf1,updatedC2.Product_Family__c);
        
        Test.stopTest();
    }
}