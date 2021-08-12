/*
 * Author: Manideep
 * CreatedDate: 
 * Description: This class is a test class for the class 'UserDeactivatedCaseBatchClass.cls'.
 * @Manideep: 2/5/2019 - Fixed the test class by fixing the failures. 
*/
@isTest(seeAllData=false)
private class UserDeactivatedCaseBatchClassTest {
 
 // This method 
 private static testMethod void invokeUserdeactivatedCaseBatchClassMethod() {
   
   //Create Users
   Id Pid = [Select Id from Profile where Name = 'Sales Profile'].Id;
   Id RoleId = [Select Id From UserRole where Name = 'Sales Rep - Tesla/Quadro/GRID'].Id;
   
   list<User> userList = new list<User>();
   User u; 
   u = new User(FirstName = 'test Deactivate', LastName = 'User 0', email = 'testUser0@example.com', Username = 'testUrname1234@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
   userList.add(u); 
   u = new User(FirstName = 'test Deactivate', LastName = 'User 1', email = 'testUser1@example.com', Username = 'testUrname5678@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
   userList.add(u); 
   
   User usr = [Select Id from User where Id = :UserInfo.getUserId()];
   system.runAs(usr) {
    insert userList;
   } 
   
   test.startTest();
   
   DateTime dt = DateTime.now();
   SBQQ__QuoteTemplate__c Quotetemplate = new SBQQ__QuoteTemplate__c (name ='Approved Quote - Initial Sale');
            insert Quotetemplate;
            SBQQ__QuoteTemplate__c Quotetemplate1 = new SBQQ__QuoteTemplate__c (name ='Budgetary Quote - Initial Sale');
            insert Quotetemplate1;
            SOQ_QuoteCreation_Settings__c objSOQCS = new SOQ_QuoteCreation_Settings__c(Approved_Quote_Template_Id__c=Quotetemplate.id,Default_Template_Id__c=Quotetemplate1.id, Quote_Type_c__c = 'Quote', BATCHJOB_OppCreationCutOffDateTime__c=dt, Initial_Status__c = 'Draft', RecordTypeId__c=Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Initial Enterprise Sales Quote').getRecordTypeId());
   insert objSOQCS;
    
   // Create Accounts
   Id accRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('New Customer Account').getRecordTypeId();   
   list<Account> accList = new list<Account>();
   for(integer i=0; i<4; i++) {       
       Account acc = new Account();
       acc.Name = 'Test Account ' + i;
       acc.RecordTypeId = accRTId;
       acc.website = 'www.testAcc.com';
       acc.Account_Class__c = 'General Account';
       acc.Industry = 'IT Services';
       acc.Inactive__c = false;
       acc.Automotive_Startup__c = 'No';
       acc.Billing_Region__c = 'NALA';
       if(math.mod(i, 2) == 0) {
          acc.OwnerId = userList[0].Id;
       } else {
          acc.OwnerId = userList[1].Id; 
       }   
       accList.add(acc);
   }
   insert accList;
   
   // Create AccountTeamMembers
   list<AccountTeamMember> atmList = new list<AccountTeamMember>();
   for(integer i=0; i<4; i++) {
       AccountTeamMember atm = new AccountTeamMember();
       atm.AccountId = accList[i].Id;
       atm.TeamMemberRole = 'Sales Manager';
       if(math.mod(i, 2) == 0) {
          atm.UserId = userList[0].Id;
       } else {
          atm.UserId = userList[1].Id; 
       } 
       atm.AccountAccessLevel = 'Edit';
       atmList.add(atm);
   }
   insert atmList;  
   
   // Create Opportunities
   Id oppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Sales Opportunity').getRecordTypeId();   
   list<Opportunity> oppList = new list<Opportunity>();
   for(integer i=0; i<4; i++) {       
       Opportunity opp = new Opportunity();
       opp.Name = 'Test Opp ' + i;
       opp.RecordTypeId = oppRTId;
       if(math.mod(i, 2) == 0) {
          opp.OwnerId = userList[0].Id;
       } else {
          opp.OwnerId = userList[1].Id; 
       }
       opp.CloseDate = system.Today() + 3;
       opp.StageName = 'Prospecting';
       opp.ForecastCategoryName = 'Pipeline';
       opp.AccountId = accList[i].Id;
       oppList.add(opp);
   }
   insert oppList;
   
   // Create OpportunityTeamMembers
   list<OpportunityTeamMember> otmList = new list<OpportunityTeamMember>();
   for(integer i=0; i<4; i++) {
       OpportunityTeamMember otm = new OpportunityTeamMember();
       otm.OpportunityId = oppList[i].Id;
       otm.TeamMemberRole = 'Sales Manager';
       if(math.mod(i, 2) == 0) {
          otm.UserId = userList[0].Id;
       } else {
          otm.UserId = userList[1].Id;
       }
       otm.OpportunityAccessLevel = 'Edit';
       otmList.add(otm);
   }
   insert otmList;  
   
   // Create Contacts
   Id ctcRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales Contact').getRecordTypeId();   
   list<Contact> ctcList = new list<Contact>();
   for(integer i=0; i<4; i++) {       
       Contact ctc = new Contact();
       ctc.FirstName = 'Test ';
       ctc.LastName = 'Ctc ' + i;
       ctc.RecordTypeId = ctcRTId;
       if(math.mod(i, 2) == 0) {
          ctc.OwnerId = userList[0].Id;
       } else {
          ctc.OwnerId = userList[1].Id;
       }
       ctc.Email = 'testContact' + i + '@gmail.com';
       ctc.AccountId = accList[i].Id;
       ctcList.add(ctc);
   }
   insert ctcList;
   
   // Create Leads
   Id leadRTId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Enterprise Customer Lead').getRecordTypeId();   
   list<Lead> leadList = new list<Lead>();
   for(integer i=0; i<4; i++) {       
       Lead ld = new Lead();
       ld.FirstName = 'Test ';
       ld.LastName = 'Lead ' + i;
       ld.RecordTypeId = leadRTId;
       if(math.mod(i, 2) == 0) {
          ld.OwnerId = userList[0].Id;
       } else {
          ld.OwnerId = userList[1].Id;
       }
       ld.Status = 'Prospect';
       ld.Company = 'Test Account ' + i;
       ld.Email = 'testLead' + i + '@gmail.com';
       leadList.add(ld);
   }
   insert leadList;
   
   // Create Territory Mappings and Countries for them.
   list<Territory_Mapping__c> tamList = new list<Territory_Mapping__c>();
   
   // Countries
   Country_List__c ctry = new Country_List__c();
   ctry.Name = 'United States';
   ctry.ISO_Code__c = 'US';
   ctry.Region__c = 'NALA';
   ctry.Sub_Region__c = 'NA';
   ctry.Territory__c = 'NA';
   ctry.ISO_Code_3__c = 'USA';
   insert ctry;
   
   for(integer i=0; i<4; i++) {
       Territory_Mapping__c tam = new Territory_Mapping__c();
       tam.Name = 'NorCal 1';
       tam.Region__c = 'NALA';
       tam.Country__c = ctry.Id;
       tam.State__c = 'California';
       tam.City__c = 'Grass Valley' + i;
       if(math.mod(i, 2) == 0) {
          tam.Territory_Account_Manager__c = userList[0].Id;
       } else {
          tam.Territory_Account_Manager__c = userList[1].Id;
       }
       tamList.add(tam);
   }
   insert tamList;
   
   // Create Tasks (Activities)
   Id taskRTId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Task').getRecordTypeId(); 
   list<Task> taskList = new list<Task>();
   for(integer i=0; i<4; i++) {       
       Task tsk = new Task();
       tsk.RecordTypeId = taskRTId;
       if(math.mod(i, 2) == 0) {
          tsk.OwnerId = userList[0].Id;
       } else {
          tsk.OwnerId = userList[1].Id;
       }
       tsk.Subject = 'Other';
       tsk.whatId = accList[i].Id;
       tsk.Status = 'Not Started';
       tsk.Priority = 'Normal';
       taskList.add(tsk);
   }
   insert taskList;
    
   // Deactivate the Users
   for(User usrVar: userList) {
       usrVar.isActive = false;
       //usrVar.DeactivatedDate__c = Date.today()-1;
   }
   system.runAs(usr) { 
    update userList;
   } 
   
   // Update the Deactivation Date to yesterday. This is a manual hack.
   for(User usrVar: userList) {
       usrVar.DeactivatedDate__c = Date.today()-1;
   }
   system.runAs(usr) { 
    update userList;
   } 
    
   // invoke batch class
   //UserDeactivatedCaseBatchClass uDCasebatch = new UserDeactivatedCaseBatchClass();
   //Id batchJobId = Database.executeBatch(uDCasebatch);
    
   //Schedule Batch Class
   UserDeactivatedCaseBatchClass schBatch = new UserDeactivatedCaseBatchClass(); 
   String schTime = '0 0 8 * * ?';  // Daily at 8 AM
   system.schedule('Test check', schTime, schBatch); 
    
   test.stopTest();        
      
 }

}