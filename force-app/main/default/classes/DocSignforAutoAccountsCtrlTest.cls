/*
 * Author: @Manideep
 * Date : 12/4/2018
 * Description: This is a test class which covers code coverage for Apex Classes below,
       - DocSignforAutoAccountsCtrl.cls
       - DocSignforAutoContactsTemplate.cls
       - DocSignforAutoSignersTemplate.cls
   
*/

@isTest
public class DocSignforAutoAccountsCtrlTest {
  
  private static testMethod void allAccountAndContactsPassed() {
    
    // Create Users
    Id Pid = [Select Id from Profile where Name = 'System Administrator'].Id;
    Id RoleId = [Select Id From UserRole where Name = 'Administrator'].Id;
            
    List<User> userList = new List<User>();
    User u;
  
    u = new User(FirstName = 'test', LastName = 'user 1', email = 'tusr1@example.com', Username = 'tusr1@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u); 
    u = new User(FirstName = 'test', LastName = 'user 2', email = 'tusr2@example.com', Username = 'tusr2@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    userList.add(u);
    
    User usr = [Select Id from User where Id = :UserInfo.getUserId()];
    system.runAs(usr) {
      insert userList;
    } 
    
    // Create Custom Setting "DocuSign for Automotive"
    List<DosuSign_for_Automotive__c> dSignAutoList = new List<DosuSign_for_Automotive__c>(); 
    DosuSign_for_Automotive__c dSignAuto;
  
    // list of Signers
    dSignAuto = new DosuSign_for_Automotive__c(Name = 'Signer 1', Category__c = 'Signer', User_Email__c = 'tusr1@example.com');
    dSignAutoList.add(dSignAuto);
    dSignAuto = new DosuSign_for_Automotive__c(Name = 'Signer 2', Category__c = 'Signer', User_Email__c = 'tusr2@example.com');
    dSignAutoList.add(dSignAuto);
    
    // DocuSign template Id
    dSignAuto = new DosuSign_for_Automotive__c(Name = 'DocuSign Template 1', Category__c = 'Default_DST',
                                               DocuSign_Template_Name__c = 'Automotive Account DocuSign (EcoSystem Partner NDA)', DST__c = '5028478c-e49a-4c27-a329-d67b7bc529d2');
    dSignAutoList.add(dSignAuto);
    
    insert dSignAutoList;   
    
    // Create Account and its Contacts.
    
    RecordType newRT = [SELECT Id, Name FROM RecordType Where Name = 'New Customer Account'];  
    Account acc = new Account();
    acc.Name = 'allAccountAndContactsPassed Acc 1';
    acc.RecordTypeId = newRT.Id;
    acc.Automotive_Startup__c = 'No';
    insert acc;
    
    list<Contact> ctcList = new list<Contact>();
    for(integer i=0; i<3; i++) {
        Contact ctc = new Contact();
        ctc.FirstName = 'allAccountAndContactsPassed';
        ctc.LastName = 'ctc' + i;
        ctc.Email = 'testctc'+ i + '@test.com';
        ctc.AccountId = acc.Id;
        if(i == 1) 
           ctc.Role__c = 'Partner Parimary Contact';
        else if(i == 2)
           ctc.Role__c = 'Sales';
        
        ctcList.add(ctc);
    }  
    insert ctcList;
    
    Test.StartTest();
    
    PageReference pageRef = Page.DocSignforAutoAccounts;
    pageRef.getParameters().put('accId', string.valueOf(acc.Id));
    Test.setCurrentPage(pageRef);
    
    DocSignforAutoAccountsCtrl obj = new DocSignforAutoAccountsCtrl();
    obj.showDocSignButton = true; 
        
    // Contact Wrapper
    obj.lstCtcWrapper.add(new DocSignforAutoContactsTemplate(ctcList[0], true)); 
    obj.SubmitTheContact(); 
    obj.fetchSigners();
    
    // Signer Wrapper
    obj.lstSignersTemplate.add(new DocSignforAutoSignersTemplate(userList[0], true));
    obj.SubmitTheSigner();  
     
    obj.disableSelectedCheckboxforContact();   
    obj.disableSelectedCheckboxforSigner();
    obj.Cancel(); 
    obj.SendwithDocuSign(); 
    
    Test.StopTest();     
        
  }
  
  private static testMethod void noAccountAndContactsPassed() {
            
    Test.StartTest();
    
    PageReference pageRef = Page.DocSignforAutoAccounts;
    pageRef.getParameters().put('accId', null);
    Test.setCurrentPage(pageRef);
    
    DocSignforAutoAccountsCtrl obj = new DocSignforAutoAccountsCtrl();    
    obj.fetchSigners();
           
    Test.StopTest();     
        
  }
  
}