@isTest(seeAllData=true)
private class Test_SalesManagerNameForDeactivatedUser {

    static testMethod void myUnitTest() {
      Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
      User u = new User(Alias = 'standt', Email='standarduser123@testorg.com', 
      EmailEncodingKey='UTF-8', LastName='Testing123', LanguageLocaleKey='en_US', 
      LocaleSidKey='en_US', ProfileId = p.Id,isActive=false, 
      TimeZoneSidKey='America/Los_Angeles', UserName='standarduser321@testorg.com');
      insert u;
      
      NV_Contacts__c  nvContact = new NV_Contacts__c();
      nvContact.Name = 'Test';
      nvContact.Product_Line__c = 'TESLA';
      nvContact.Sales_Manager_Email__c = u.email;
      insert nvContact;
        
    }
}