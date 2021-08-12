/*
 * Author: @Manideep
 * Date : 12/4/2018
 * Description: This is a test class which covers code coverage for Apex Classes 'NV_Account_DocuSignCtrl'. 
*/

@isTest
public class NV_Account_DocuSignCtrlTest {
    
  @testSetup static void dataSetup() {
    
    // Create Users
    Id Pid = [Select Id from Profile where Name = 'System Administrator'].Id;
    Id sPId = [Select Id from Profile where Name = 'Sales Profile'].Id;
    Id RoleId = [Select Id From UserRole where Name = 'Administrator'].Id;
            
    List<User> userList = new List<User>();
    User u;
     
    u = new User(FirstName = 'test', LastName = 'user 1', email = 'tusr1@example.com', Username = 'tusr1@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'test', LastName = 'user 2', email = 'tusr2@example.com', Username = 'tusr2@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = sPId, UserRoleId = RoleId);  
    userList.add(u);
    u = new User(FirstName = 'test', LastName = 'user 3', email = 'tusr3@example.com', Username = 'tusr3@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = sPId, UserRoleId = RoleId);  
    userList.add(u);
    
    User usr = [Select Id from User where Id = :UserInfo.getUserId()];
    system.runAs(usr) {
      insert userList;
    }
    
    // Create Custom Setting "DocuSign for Automotive"
    List<DosuSign_for_Automotive__c> dSignAutoList = new List<DosuSign_for_Automotive__c>(); 
    DosuSign_for_Automotive__c dSignAuto;
  
    // Profiles
    dSignAuto = new DosuSign_for_Automotive__c(Name = 'Profile 1', Category__c = 'Profile', Profile_Name__c = 'System Administrator');
    dSignAutoList.add(dSignAuto);
    dSignAuto = new DosuSign_for_Automotive__c(Name = 'Profile 2', Category__c = 'Profile', Profile_Name__c = 'Sales Profile - Partner Admin');
    dSignAutoList.add(dSignAuto); 
    
    // Permission Set
    dSignAuto = new DosuSign_for_Automotive__c(Name = 'Permission Set 1', Category__c = 'Permission_Set', Permission_Set_Name__c = 'LEAD_Automotive_Sales_Leadership_Field_Edit_Permission');
    dSignAutoList.add(dSignAuto);
    
    // Page Message
    dSignAuto = new DosuSign_for_Automotive__c(Name = 'Page Message', Category__c = 'Page_Message_NA', Page_Message__c = 'You do not have permission to access the DocuSign. Please Contact System Administrator for any questions.');
    dSignAutoList.add(dSignAuto); 
        
    insert dSignAutoList; 
    
    // Fetch the Permisison Set Name form the Custom Setting
    list<DosuSign_for_Automotive__c> dOAList = [SELECT Id, Category__c, Permission_Set_Name__c 
                                                FROM DosuSign_for_Automotive__c 
                                                WHERE Category__c = 'Permission_Set' 
                                                AND Permission_Set_Name__c = 'LEAD_Automotive_Sales_Leadership_Field_Edit_Permission'];    
    list<PermissionSet> pSetList = [SELECT Id, Name 
                                    FROM PermissionSet 
                                    WHERE Name =:dOAList[0].Permission_Set_Name__c];
     
    User u3 = [SELECT Id, Name 
               FROM User 
               WHERE Email = 'tusr3@example.com'
               AND isActive = true 
               AND CreatedDate = Today];
   
   // Assign PermisisonSet to one of the Users created above.
   system.runAs(usr) {
    PermissionSetAssignment psa = new PermissionSetAssignment();
    psa.AssigneeId = u3.Id;
    psa.PermissionSetId = pSetList[0].Id;
    insert psa;
   }
   
   /*
   // Check if the Permission Set is assigned to the User.           
   list<PermissionSetAssignment> pSetAssignment = [SELECT Id, AssigneeId, Assignee.Name, PermissionSetId, PermissionSet.Name, PermissionSet.Label 
                                                   FROM PermissionSetAssignment 
                                                   WHERE PermissionSetId = pSetList[0].Id];
   */                                                  
    
  }
  
  // Run as System Administrator
  private static testMethod void invokeVFPageMethodasAdmin() { 
    
    User adminUser = [Select Id, Name from User where profile.Name = 'System Administrator' AND Email = 'tusr1@example.com' AND isActive = true AND CreatedDate = Today];
        
    system.runAs(adminUser) {
     RecordType newRT = [SELECT Id, Name FROM RecordType Where Name = 'New Customer Account'];
     Account acc = new Account();
     acc.Name = 'NV_Account_DocuSignCtrlTest Acc 1';
     acc.Automotive_Startup__c = 'No';
     acc.RecordTypeId = newRT.Id;
     insert acc;
     
     Test.StartTest();
      ApexPages.StandardController stdctrl = new ApexPages.StandardController(acc);
      NV_Account_DocuSignCtrl testSC = new NV_Account_DocuSignCtrl(stdctrl);
      testSC.invokeVFPage();
     Test.StopTest(); 
    } 
    
  }
  
  // Run as Sales User with Permission Set assigned
  private static testMethod void invokeVFPageMethodasNonAdminPSetAssigned() { 
    
    User pSetSalesUser = [Select Id, Name from User where profile.Name = 'Sales Profile' AND Email = 'tusr3@example.com' AND isActive = true AND CreatedDate = Today];
        
    system.runAs(pSetSalesUser) {
     RecordType newRT = [SELECT Id, Name FROM RecordType Where Name = 'New Customer Account'];
     Account acc = new Account();
     acc.Name = 'NV_Account_DocuSignCtrlTest Acc 2';
     acc.Automotive_Startup__c = 'No';
     acc.RecordTypeId = newRT.Id;
     acc.BillingCountry = 'United States';
     acc.BillingState = 'California';
     acc.BillingCity = 'Santa Clara';
     acc.BillingStreet = '123 NV Way';
     acc.BillingPostalCode = '95123';
     insert acc;
     
     Test.StartTest();
      ApexPages.StandardController stdctrl = new ApexPages.StandardController(acc);
      NV_Account_DocuSignCtrl testSC = new NV_Account_DocuSignCtrl(stdctrl);
      testSC.invokeVFPage();
     Test.StopTest();  
    } 
    
  }
  
  // Run as Sales User and no Permission Set assigned
  private static testMethod void invokeVFPageMethodasNonAdmin() { 
    
    User nonAdminUser = [Select Id, Name from User where profile.Name = 'Sales Profile' AND Email = 'tusr2@example.com' AND isActive = true AND CreatedDate = Today];
        
    system.runAs(nonAdminUser) {
    
     RecordType newRT = [SELECT Id, Name FROM RecordType Where Name = 'New Customer Account'];
     Account acc = new Account();
     acc.Name = 'NV_Account_DocuSignCtrlTest Acc 2';
     acc.Automotive_Startup__c = 'No';
     acc.RecordTypeId = newRT.Id;
     acc.BillingCountry = 'United States';
     acc.BillingState = 'California';
     acc.BillingCity = 'Santa Clara';
     acc.BillingStreet = '123 NV Way';
     acc.BillingPostalCode = '95123';
     insert acc;
     
     Test.StartTest();
      ApexPages.StandardController stdctrl = new ApexPages.StandardController(acc);
      NV_Account_DocuSignCtrl testSC = new NV_Account_DocuSignCtrl(stdctrl);
      testSC.invokeVFPage();
     Test.StopTest();  
    } 
    
  }
   
}