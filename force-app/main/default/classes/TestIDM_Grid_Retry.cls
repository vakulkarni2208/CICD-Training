/**************************************************************************************************
* Name       : TestIDM_Grid_Retry
* Purpose    : Test class for IDM_Grid_Retry
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 1/11/2018       | Initial Draft
*Perficient         | 2.0        | 1/19/2018       | Final Draft
*Akhilesh           | 2.0        | 11/01/2019      | Licensing 2.0: removed use of DGXRegistration.createUser function.
**************************************************************************************************/
@isTest
public class TestIDM_Grid_Retry {
    public final static String NAME = 'TestIDM_Grid_Retry';
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
        con.Synced_IDM_GRID__c = false;
        
        insert con;
        
        //Licensing 2.0: removed use of DGXRegistration.createUser function.
        Test_COMM_Factory.Createuser(new List<Id>{con.Id});
    }
    
    @isTest
    public static void DGX_Retry_happyPath(){
        Test.setMock(HttpCalloutMock.Class, new TestCalloutMock('SUCCESS'));
        String query = PRFT_DomainLayer.buildQueryFields('Contact',' Where is_GRID_Contact__c = true and Synced_IDM_GRID__c  = false','Select ');
        
        List<Contact> contList = Database.query(query);
        System.assertEquals(1,contList.size());
        User usr = [SELECT FederationIdentifier FROM User WHERE ContactId=:contList[0].Id];
        System.assertNotEquals(EMAIL.toLowerCase(),usr.FederationIdentifier);

        Test.startTest();
        Database.BatchableContext     bc;
        IDM_Grid_Retry gridRetry = new IDM_Grid_Retry();
        System.runAs(new User(Id=UserInfo.getUserId())){
            gridRetry.start(bc);
            gridRetry.execute(bc,contList);
            gridRetry.finish(bc);
        }
        Test.stopTest();
        usr = [SELECT FederationIdentifier FROM User WHERE ContactId=:contList[0].Id];
        System.assertEquals(EMAIL.toLowerCase(),usr.FederationIdentifier);
        Contact updatedCont = [SELECT Synced_IDM_GRID__c FROM Contact WHERE Id= :contList[0].Id];
        System.assertEquals(true,updatedCont.Synced_IDM_GRID__c);
    }
    
    @isTest
    public static void DGX_Retry_updateUserError(){
        Test.setMock(HttpCalloutMock.Class, new TestCalloutMock('SUCCESS'));
        String query = PRFT_DomainLayer.buildQueryFields('Contact',' Where is_GRID_Contact__c = true and Synced_IDM_GRID__c  = false','Select ');
        
        List<Contact> contList = Database.query(query);
        System.assertEquals(1,contList.size());
        User usr = [SELECT FederationIdentifier FROM User WHERE ContactId=:contList[0].Id];
        System.assertNotEquals(EMAIL.toLowerCase(),usr.FederationIdentifier);

        Test.startTest();
        Database.BatchableContext     bc;
        IDM_Grid_Retry gridRetry = new IDM_Grid_Retry(contList[0].Id);        
        gridRetry.start(bc);
        gridRetry.execute(bc,contList);
        gridRetry.finish(bc);        
        Test.stopTest();
        usr = [SELECT FederationIdentifier FROM User WHERE ContactId=:contList[0].Id];
        //System.assertNotEquals(EMAIL.toLowerCase(),usr.FederationIdentifier);
        Contact updatedCont = [SELECT Synced_IDM_GRID__c FROM Contact WHERE Id= :contList[0].Id];
        //System.assertEquals(true,updatedCont.Synced_IDM_GRID__c);
    }

    @isTest
    public static void DGX_Retry_calloutException(){
        Test.setMock(HttpCalloutMock.Class, new TestCalloutMock(''));
        String query = PRFT_DomainLayer.buildQueryFields('Contact',' Where is_GRID_Contact__c = true and Synced_IDM_GRID__c  = false','Select ');
        
        List<Contact> contList = Database.query(query);
        System.assertEquals(1,contList.size());
        User usr = [SELECT FederationIdentifier FROM User WHERE ContactId=:contList[0].Id];
        System.assertNotEquals(EMAIL.toLowerCase(),usr.FederationIdentifier);

        Test.startTest();
        Database.BatchableContext     bc;
        IDM_Grid_Retry gridRetry = new IDM_Grid_Retry();
        System.runAs(new User(Id=UserInfo.getUserId())){
            gridRetry.start(bc);
            gridRetry.execute(bc,contList);
            gridRetry.finish(bc);
        }
        Test.stopTest();
        usr = [SELECT FederationIdentifier FROM User WHERE ContactId=:contList[0].Id];
        System.assertNotEquals(EMAIL.toLowerCase(),usr.FederationIdentifier);
        Contact updatedCont = [SELECT Synced_IDM_GRID__c FROM Contact WHERE Id= :contList[0].Id];
        System.assertEquals(false,updatedCont.Synced_IDM_GRID__c);
    }
}