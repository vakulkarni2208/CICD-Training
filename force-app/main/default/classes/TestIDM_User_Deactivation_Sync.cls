/**************************************************************************************************
* Name       : TestIDM_User_Deactivation_Sync
* Purpose    : Test class for IDM_User_Deactivation_Sync
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 1/16/2018       | Initial Draft
*Perficient         | 1.0        | 1/24/2018       | Final Draft
*Akhilesh           | 2.0        | 11/01/2019      | Licensing 2.0: removed use of DGXRegistration.createUser function.
**************************************************************************************************/
@isTest(seeAllData=false)
public class TestIDM_User_Deactivation_Sync {
    
    @testSetup 
    public static void TestUserCreation(){
        Date startDate = date.newInstance(System.now().year(), System.now().month(), System.now().day());
        Date endDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        
        Account acc = new Account(Name ='Test Account');
        insert acc;
        List<Contact> lstContact = new List<Contact>();
        for(Integer i=0;i<10;i++){
            Contact con = new Contact();
            con.firstName = 'firstName';
            con.lastName = 'lastName';
            con.Email = 'test37838'+String.valueOf(i)+'@test.com';
            con.MailingStreet = 'Street1';
            con.Mailing_Street_2__c = 'Street2';
            con.MailingCity = 'Pittsburgh';
            con.MailingState = 'Punjab';
            con.MailingCountry = 'India';
            con.MailingPostalCode = '15213';
            con.IDM_ExternalId__c = acc.Id+'-'+'test37838'+String.valueOf(i)+'@test.com';
            con.AccountId = acc.Id;
            con.is_GRID_Contact__c =true;
            con.is_DGX_Contact__c = true;
            lstContact.add(con);
        }
        insert lstContact;
        
        List<Id> lstId = new List<Id>();
        for(Contact con:lstContact){
            if(con.Id !=null)
                lstId.add(con.Id);
        }
        
        //Licensing 2.0: removed use of DGXRegistration.createUser function.
        if(lstId.size() >0)
            Test_COMM_Factory.Createuser(lstId);
    }
    
    @isTest
    public static void DeactivateUserDGXSuccess(){
        Test.setMock(HttpCalloutMock.Class, new TestCalloutMock('SUCCESS'));
        
        Map<Id,Contact> Contacts = new Map<Id,Contact>
            ([SELECT Id,is_GRID_Contact__c,is_DGX_Contact__c FROM Contact 
              WHERE is_GRID_Contact__c =:true OR is_DGX_Contact__c=:true]);
     
        List<User> lstUser =[select id,isActive,contactId from User WHERE contactId =:Contacts.keySet()];
        List<User> updateUser = new List<User>();
        for(User user :lstUser){
            User u = new User(Id = user.Id, Deactivation_Sync_IDM_DGX__c = false, IsActive = false, Community_ContactId__c= user.contactId);
            updateUser.add(u);
        }
        update updateUser;
        
        Test.StartTest();
        
        IDM_User_Deactivation_Sync deactivateUser = new IDM_User_Deactivation_Sync();
        deactivateUser.MESSAGE_TEXT ='success';
        deactivateUser.MESSAGE_TYPE  ='success';
        Database.executeBatch(deactivateUser,2000);
        Test.StopTest();
        validate();     
    }

    @isTest
    public static void DeactivateUserDGXSuccess2(){
        Test.StartTest();
         Map<Id,Contact> Contacts = new Map<Id,Contact>
            ([SELECT Id,is_GRID_Contact__c,is_DGX_Contact__c FROM Contact 
              WHERE is_GRID_Contact__c =:true OR is_DGX_Contact__c=:true]);
     
        List<User> lstUser =[select id,isActive,contactId from User WHERE contactId =:Contacts.keySet() limit 1];
       IDM_User_Deactivation_Sync deactivateUser = new IDM_User_Deactivation_Sync(lstUser[0].id);
       Database.executeBatch(deactivateUser,2000);
        Test.StopTest();    
    }
    
/*    @isTest
    public static void DeactivateUserGRIDSuccess(){
        Test.setMock(HttpCalloutMock.Class, new TestCalloutMock('SUCCESS'));
        Map<Id,Contact> Contacts = new Map<Id,Contact>
            ([SELECT Id,is_GRID_Contact__c,is_DGX_Contact__c FROM Contact 
              WHERE is_GRID_Contact__c =:true OR is_DGX_Contact__c=:true]);
        system.debug('Inserted contacts test class-->'+Contacts);
        List<User> lstUser =[select id,isActive from User WHERE contactId =:Contacts.keySet()];
        List<User> updateUser = new List<User>();
        for(User user :lstUser){
            User u = new User(Id = user.Id, Deactivation_Sync_IDM_GRID__c = false, IsActive = false);
            updateUser.add(u);
        }
        update updateUser;
        String query = PRFT_DomainLayer.buildQueryFields('User',' Where (Contact.is_DGX_Contact__c = true or Contact.is_GRID_Contact__c = true) and (Deactivation_Sync_IDM_DGX__c = false or Deactivation_Sync_IDM_GRID__c = false) and IsActive = false','Select Contact.is_DGX_Contact__c,Contact.is_GRID_Contact__c ,');
        lstUser = Database.query(query);
        Test.StartTest();
        
        IDM_User_Deactivation_Sync deactivateUser = new IDM_User_Deactivation_Sync();
        Database.BatchableContext     bc;
        System.runAs(new User(Id=UserInfo.getUserId())){
            deactivateUser.start(bc);
            deactivateUser.execute(bc,lstUser);
            deactivateUser.finish(bc);
        }
        Test.StopTest();
        validate();
    }
*/    
    public static void validate(){
        String query = PRFT_DomainLayer.buildQueryFields('User',' Where (Deactivation_Sync_IDM_DGX__c = true or Deactivation_Sync_IDM_GRID__c = true) and IsActive = false','Select ');
        
        List<User> lstUser = Database.query(query);
        for(User user:lstUser){
            system.assert((user.IDM_GRID_Deactivation_Callout_Message__c !=null) || (user.IDM_DGX_Deactivation_Callout_Message__c !=null));
        }
    }
}