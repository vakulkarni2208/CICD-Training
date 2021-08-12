/**************************************************************************************************
* Name       : TestIDM_DGX_RETRY
* Purpose    : Test class for IDM_DGX_RETRY
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 1/11/2018       | Initial Draft
*Perficient         | 2.0        | 1/19/2018       | Final Draft
*Akhilesh           | 2.0        | 11/01/2019      | Licensing 2.0: removed use of DGXRegistration.createUser function.
**************************************************************************************************/
@isTest
public class TestIDM_DGX_RETRY {
    public final static String NAME = 'TestIDM_DGX_RETRY';
    public final static String EMAIL = NAME + '@test.com';

    @testsetup
    public static void setupmethod(){
    
        Account acc = new Account(Name =NAME);
        insert acc;
        
        Contact con = new Contact();
        con.firstName = 'firstName';
        con.lastName = 'lastName';
        con.Email = EMAIL;
        con.MailingStreet = 'Street1';
        con.Mailing_Street_2__c = 'Street2';
        con.MailingCity = 'Pittsburgh';
        con.MailingState = 'Punjab';
        con.MailingCountry = 'India';
        con.MailingPostalCode = '15213';
        con.IDM_ExternalId__c = acc.Id+'-'+EMAIL;
        con.AccountId = acc.Id;
        con.is_GRID_Contact__c =true;
        con.is_DGX_Contact__c = true;
        con.Synced_IDM_DGX__c = false;
        
        insert con;
        
        //Licensing 2.0: removed use of DGXRegistration.createUser function.
        Test_COMM_Factory.Createuser(new List<Id>{con.Id});
    }

    @isTest
    public static void DGX_Retry_happyPath(){
        String query = PRFT_DomainLayer.buildQueryFields('Contact',' Where is_DGX_Contact__c = true and Synced_IDM_DGX__c  = false','Select ');
        
        List<Contact> contList = Database.query(query);
        System.assertEquals(1,contList.size());
        User usr = [SELECT FederationIdentifier FROM User WHERE ContactId=:contList[0].Id];
        System.assertNotEquals(EMAIL.toLowerCase(),usr.FederationIdentifier);
        Test.startTest();
        Test.setMock(HttpCalloutMock.Class, new TestCalloutMock('SUCCESS'));
        IDM_DGX_RETRY dgxRetry = new IDM_DGX_RETRY();
        Database.BatchableContext     bc;
        System.runAs(new User(Id=UserInfo.getUserId())){
            dgxRetry.start(bc);
            dgxRetry.execute(bc,contList);
            dgxRetry.finish(bc);
        }
        Test.stopTest();

        usr = [SELECT FederationIdentifier FROM User WHERE ContactId=:contList[0].Id];
        System.assertEquals(EMAIL.toLowerCase(),usr.FederationIdentifier);
        Contact updatedCont = [SELECT Synced_IDM_DGX__c FROM Contact WHERE Id= :contList[0].Id];
        System.assertEquals(true,updatedCont.Synced_IDM_DGX__c);
    }

    @isTest
    public static void DGX_Retry_updateUserError(){        
        List<Contact> contList = [SELECT Id FROM Contact WHERE Email=:EMAIL];
        System.assertEquals(1,contList.size());
        User usr = [SELECT FederationIdentifier FROM User WHERE ContactId = :contList[0].Id];
        System.assertNotEquals(EMAIL.toLowerCase(),usr.FederationIdentifier);
        Test.startTest();
        Test.setMock(HttpCalloutMock.Class, new TestCalloutMock('SUCCESS'));
        IDM_DGX_RETRY dgxRetry = new IDM_DGX_RETRY(contList[0].Id);
        Database.BatchableContext     bc;  
        dgxRetry.start(bc);      
        dgxRetry.execute(bc,contList);
        dgxRetry.finish(bc);        
        Test.stopTest();

        usr = [SELECT FederationIdentifier FROM User WHERE ContactId=:contList[0].Id];
        //System.assertNotEquals(EMAIL.toLowerCase(),usr.FederationIdentifier);
        Contact updatedCont = [SELECT Synced_IDM_DGX__c FROM Contact WHERE Id= :contList[0].Id];
        //System.assertEquals(true,updatedCont.Synced_IDM_DGX__c);
    }

    @isTest
    public static void DGX_Retry_calloutException(){
        String query = PRFT_DomainLayer.buildQueryFields('Contact',' Where is_DGX_Contact__c = true and Synced_IDM_DGX__c  = false','Select ');
        
        List<Contact> contList = Database.query(query);
        System.assertEquals(1,contList.size());
        User usr = [SELECT FederationIdentifier FROM User WHERE ContactId=:contList[0].Id];
        System.assertNotEquals(EMAIL.toLowerCase(),usr.FederationIdentifier);
        Test.startTest();
        Test.setMock(HttpCalloutMock.Class, new TestCalloutMock(''));
        IDM_DGX_RETRY dgxRetry = new IDM_DGX_RETRY();
        Database.BatchableContext     bc;
        System.runAs(new User(Id=UserInfo.getUserId())){
            dgxRetry.start(bc);
            dgxRetry.execute(bc,contList);
            dgxRetry.finish(bc);
        }
        Test.stopTest();

        usr = [SELECT FederationIdentifier FROM User WHERE ContactId=:contList[0].Id];
        System.assertNotEquals(EMAIL.toLowerCase(),usr.FederationIdentifier);
        Contact updatedCont = [SELECT Synced_IDM_DGX__c FROM Contact WHERE Id= :contList[0].Id];
        System.assertEquals(false,updatedCont.Synced_IDM_DGX__c);
    }
}