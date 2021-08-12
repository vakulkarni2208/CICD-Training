/**************************************************************************************************
* Name       : TestRMA_IDM_Callouts
* Purpose    : Test class for RMA_IDM_Callouts
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 1/10/2018       | Initial Draft
*Perficient         | 1.0        | 3/15/2018       | Final Draft
*Akhilesh           | 2.0        | 11/01/2019      | Licensing 2.0: removed use of DGXRegistration.createUser function.
**************************************************************************************************/
@isTest
public class TestRMA_IDM_Callouts {
    
    @testsetup
    public static void setupmethod(){
    
        Account acc = new Account(Name ='Test Account');
        insert acc;
        
        Contact con = new Contact();
        con.firstName = 'firstName';
        con.lastName = 'lastName';
        con.Email = 'test37838@test.com';
        con.MailingStreet = 'Street1';
        con.Mailing_Street_2__c = 'Street2';
        con.MailingCity = 'Pittsburgh';
        con.MailingState = 'Punjab';
        con.MailingCountry = 'India';
        con.MailingPostalCode = '15213';
        con.IDM_ExternalId__c = acc.Id+'-'+'test37838@test.com';
        con.AccountId = acc.Id;
        con.is_GRID_Contact__c =true;
        con.is_DGX_Contact__c = true;
        
        insert con;
        //Licensing 2.0: removed use of DGXRegistration.createUser function.
        Test_COMM_Factory.Createuser(new List<Id>{con.Id});
        
    }
    @isTest
    public static void TestUserDeactivationWithError(){
        
        Contact con = [SELECT Id FROM Contact WHERE email = 'test37838@test.com'];
        User usr = [SELECT Id, ContactId FROM User WHERE ContactId =: con.Id];
        
        Test.setMock(HttpCalloutMock.Class, new TestCalloutMock(''));
        Test.startTest();
        RMA_IDM_Callouts callout = new RMA_IDM_Callouts();
        
        String response = callout.invokeIDMDGXUserCreationCallout(usr.ContactId, 'en_US', usr.Id);
        system.assert(!response.contains('Success'));
        
        String response1 = callout.invokeIDMGridUserCreationCallout(usr.ContactId, 'en_US', usr.Id);
        system.assert(!response.contains('Success'));
        
        Test.stopTest();
    }
    
    @isTest
    public static void TestUserDeactivation(){
        Contact con = [SELECT Id FROM Contact WHERE email = 'test37838@test.com'];
        User usr = [SELECT Id, ContactId FROM User WHERE ContactId =: con.Id];
    
        Test.setMock(HttpCalloutMock.Class, new TestCalloutMock('SUCCESS'));
        Test.startTest();
        RMA_IDM_Callouts callout = new RMA_IDM_Callouts();
        
        String response = callout.invokeIDMDGXUserCreationCallout(con.Id, 'en_US', usr.Id);
        system.assert(response.contains('Success'));
        
        String response1 = callout.invokeIDMGridUserCreationCallout(con.Id, 'en_US', usr.Id);
        system.assert(response.contains('Success'));
        
        String response2 = callout.invokeIDMDGXUserDeactivationCallout(con.Id, 'en_US', usr.Id);
        system.assert(response.contains('Success'));
      
        String response3 = callout.invokeIDMGridUserDeactivationCallout(con.Id, 'en_US', usr.Id);
        system.assert(response.contains('Success'));
        
        Test.stopTest();
        //For code coverage
        RMA_IDM_Callouts.invokeStaticRMACallout(null);
        callout.invokeRMACallout(null);
        
    }
}