/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Author: Manideep
 * Created Date: 02/14/2020
 * JIRA # SDS-1493
 * Description: This Test Class contains unit tests for code coverage of classes adn triggers below
                - TegraEmbdRegstrExpry_tgr.trg
                - TegraEmbdRegstrExpry_tgr_cls.cls
 */
@isTest
private class TegraEmbdRegstrExpry_tgr_cls_Test {

  static testMethod void testInsertandinActivateTegraEmbdRegstrForPartner() {
   
    //Create Partner Users
    Id Pid = [Select Id from Profile where Name = 'Sales Profile - Tegra Embedded'].Id;
    Id RoleId = [Select Id From UserRole where Name = 'Sales Europe Manager - Tegra Auto/Emb'].Id;
        
    List<User> Users = new List<User>();
    User u;
  
    u = new User(FirstName = 'test', LastName = 'user 1', email = 'tusr1@example.com', Username = 'tusr1@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    Users.add(u); 
    u = new User(FirstName = 'test', LastName = 'default Owner', email = 'testdefaultowner@nvidia.com', Username = 'testdefaultowner@nvidia.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    Users.add(u);
            
    User usr = [Select Id from User where Id = :UserInfo.getUserId()];
    system.runAs(usr) {
     insert Users;
    }       
    
    List<User> UserList = [Select Id, Name from User where CreatedDate = Today AND ProfileId = :Pid AND UserRoleId = :RoleId ORDER BY email ASC];
    
    // Create Custom Setting to define various reminder timelines, Default Owner, Send email as, cc users in Notifications etc.,
    list<Tegra_Embedded_Registration_Expirations__c> tegEmbRegExpList = new list<Tegra_Embedded_Registration_Expirations__c>(); 
    Tegra_Embedded_Registration_Expirations__c terExp = new Tegra_Embedded_Registration_Expirations__c(Default_Threshold_for_all_Partners__c = 60, First_Reminder__c = 14, Second_Reminder__c = 5, Third_Reminder__c = 0, 
                                                                                                       Default_Oppty_Owner_Email_Id__c = 'testdefaultowner@nvidia.com',
                                                                                                       Default_Cc_Email_Ids__c = 'testdefaultowner@nvidia.com', OWD_Sender_Email_Address__c = 'no_reply@nvidia.com', 
                                                                                                       Opportunity_Detail_Link_for_Partner_User__c = 'https://stid.nvidia.com/sfdcContent/index.html?retURL=/',                                        
                                                                                                       Opportunity_Stages_to_Exclude__c = 'Closed Won;Closed Lost;Closed - Program Canceled;');                                                                                                                                                                                                                                                                
    tegEmbRegExpList.add(terExp);
    insert tegEmbRegExpList; // Create Custom Setting values 
                                                                                                         
    list<Opportunity> tEmdOpplst = new list<Opportunity>();  // list for Opportunities
            
    // Fetch the Opportunity Record Type 'Tegra Embedded Partner Opportunity' by Name 
    map<string, Id> map_tEmbd_Opportunity_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_OPPORTUNITY, COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY);
       
    // Create Partner Account, Contact and User
    map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NV_PPA);
    map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
    map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC); 
        
    // Create Partner Account (string Name, string RecordTypeId, Boolean isPartner, Boolean isCustomerPortal)
    Account partnerAccount = Test_COMM_Factory.createAccount('TegraEmb_Regstr_Expirations_trg_Test_Acc_1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_NV_PPA), true, false);    
    
    //Create a Partner Contact     
    Contact partnerContact = Test_COMM_Factory.createContact('TegraEmb_Regstr_Expirations_trg_Test_PC_1', 'TestPC1@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
      
    //Create a Partner User     
    User partnerUser = Test_COMM_Factory.createUserWithEmail(partnerContact.Id, partnerContact.email, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC));
    list<user> lstPU = [Select email, IsPortalEnabled, UserType From User Where id =:partnerUser.Id AND IsPortalEnabled = TRUE]; 
            
    // Create records for the Custom object 'Tegra Embedded Regstr Expiration by Partner'
    list<Tegra_Embd_Regstr_Expiration_by_Partners__c> tembRegExpbyPartnerList = new list<Tegra_Embd_Regstr_Expiration_by_Partners__c>();
    
    Account pAct = [Select Id, Name, RecordTypeId, RecordType.Name, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode from Account where Id =:partnerAccount.Id];
    pAct.BillingStreet = '1234 Test Street';
    pAct.BillingCity = 'Santa Clara';
    pAct.BillingState = 'California';
    pAct.BillingCountry = 'United States';
    pAct.BillingPostalCode = '12345';
    update pAct;
       
    // Create Tegra Embedded Registration Expiration by Partner
    Tegra_Embd_Regstr_Expiration_by_Partners__c tep = new Tegra_Embd_Regstr_Expiration_by_Partners__c();
    tep.Partner_Sales_Rep_Company__c = pAct.Id;
    tep.Default_Threshold_Limit_for_Partner__c = 60;
    tep.Expire_Registration__c = True;
    insert tep;  // Create records in Custom Object
    
    // login as Partner User and Create the Opportunity    
    system.runAs(partnerUser) {   
      // Create a single Opportunity
      Opportunity opp = new Opportunity();
      opp.Name = 'trg_Context_Test_Tegra_Embd_Opp_1';
      opp.AccountId = partnerAccount.Id;
      opp.StageName = 'Prospect';
      opp.RecordTypeId = map_tEmbd_Opportunity_RT.get(COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY);
      opp.DR_Partner_Sales_Rep_Company__c = partnerAccount.Id;
      opp.DR_SalesOps_Approver__c = partnerUser.Id; 
      opp.LastModifiedDate_by_Partner__c = (Date.Today() - 46);
      opp.CloseDate = system.today() + 10;
      opp.Region__c = 'EMEA';
      insert opp;
    }
       
    list<Opportunity> oppLst = [SELECT Id, Name, OwnerId, StageName, LastModifiedDate_by_Partner__c, Opportunity_Expired__c  
                                FROM Opportunity 
                                WHERE Name = 'trg_Context_Test_Tegra_Embd_Opp_1'];
                                   
    // Validate the Before Insert logic in 'tegraEmbdPartnerOpptyRegExpInsert()' of the 'Opportuntiy_tgr_cls' class.
    system.assertEquals(oppLst[0].LastModifiedDate_by_Partner__c, Date.Today()); 
      
    Test.StartTest();
       
     // Populate the 'LastModifiedDate_by_Partner__c' field as System User
     for(Opportunity tegOpp: oppLst) {
         tegOpp.LastModifiedDate_by_Partner__c = (system.today() - 46);
     }
     update oppLst; 
       
     list<Opportunity> oppLst2 = [SELECT Id, LastModifiedDate_by_Partner__c, Opportunity_Expired__c 
                                  FROM Opportunity 
                                  WHERE Name = 'trg_Context_Test_Tegra_Embd_Opp_1'];
       
     // Validate the Before 'Update' logic in 'tegraEmbdPartnerOpptyRegExpUpdate()' of the 'Opportuntiy_tgr_cls' class.
     system.assertEquals(oppLst2[0].LastModifiedDate_by_Partner__c, (Date.Today() - 46)); 
     system.assertEquals(oppLst2[0].Opportunity_Expired__c, false); 
    
     // Update the Expire_Registration__c for the 'Tegra Embedded Registration Expiration by Partner' to false
     list<Tegra_Embd_Regstr_Expiration_by_Partners__c> tepList = [SELECT Id, Partner_Sales_Rep_Company__c, Default_Threshold_Limit_for_Partner__c, Expire_Registration__c
                                                                  FROM Tegra_Embd_Regstr_Expiration_by_Partners__c
                                                                  WHERE Partner_Sales_Rep_Company__c =:pAct.Id];
     tepList[0].Expire_Registration__c = false;
     update tepList;  // update records in Custom Object 
             
  }
  
  static testMethod void testInsertandDeleteTegraEmbdRegstrForPartner() {
   
    //Create Partner Users
    Id Pid = [Select Id from Profile where Name = 'Sales Profile - Tegra Embedded'].Id;
    Id RoleId = [Select Id From UserRole where Name = 'Sales Europe Manager - Tegra Auto/Emb'].Id;
        
    List<User> Users = new List<User>();
    User u;
  
    u = new User(FirstName = 'test', LastName = 'user 1', email = 'tusr1@example.com', Username = 'tusr1@example.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    Users.add(u); 
    u = new User(FirstName = 'test', LastName = 'default Owner', email = 'testdefaultowner@nvidia.com', Username = 'testdefaultowner@nvidia.com', Alias='bd', TimeZoneSidKey = 'America/Los_Angeles',
                 EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Pid, UserRoleId = RoleId);  
    Users.add(u);
            
    User usr = [Select Id from User where Id = :UserInfo.getUserId()];
    system.runAs(usr) {
     insert Users;
    }       
    
    List<User> UserList = [Select Id, Name from User where CreatedDate = Today AND ProfileId = :Pid AND UserRoleId = :RoleId ORDER BY email ASC];
    
    // Create Custom Setting to define various reminder timelines, Default Owner, Send email as, cc users in Notifications etc.,
    list<Tegra_Embedded_Registration_Expirations__c> tegEmbRegExpList = new list<Tegra_Embedded_Registration_Expirations__c>(); 
    Tegra_Embedded_Registration_Expirations__c terExp = new Tegra_Embedded_Registration_Expirations__c(Default_Threshold_for_all_Partners__c = 60, First_Reminder__c = 14, Second_Reminder__c = 5, Third_Reminder__c = 0, 
                                                                                                       Default_Oppty_Owner_Email_Id__c = 'testdefaultowner@nvidia.com',
                                                                                                       Default_Cc_Email_Ids__c = 'testdefaultowner@nvidia.com', OWD_Sender_Email_Address__c = 'no_reply@nvidia.com', 
                                                                                                       Opportunity_Detail_Link_for_Partner_User__c = 'https://stid.nvidia.com/sfdcContent/index.html?retURL=/',
                                                                                                       Opportunity_Stages_to_Exclude__c = 'Closed Won;Closed Lost;Closed - Program Canceled;');                                                                                                                                                                                                                                                                
    tegEmbRegExpList.add(terExp);
    insert tegEmbRegExpList; // Create Custom Setting values 
                                                                                                         
    list<Opportunity> tEmdOpplst = new list<Opportunity>();  // list for Opportunities
            
    // Fetch the Opportunity Record Type 'Tegra Embedded Partner Opportunity' by Name 
    map<string, Id> map_tEmbd_Opportunity_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_OPPORTUNITY, COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY);
       
    // Create Partner Account, Contact and User
    map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NV_PPA);
    map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
    map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC); 
        
    // Create Partner Account (string Name, string RecordTypeId, Boolean isPartner, Boolean isCustomerPortal)
    Account partnerAccount = Test_COMM_Factory.createAccount('TegraEmb_Regstr_Expirations_trg_Test_Acc_1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_NV_PPA), true, false);    
    
    //Create a Partner Contact     
    Contact partnerContact = Test_COMM_Factory.createContact('TegraEmb_Regstr_Expirations_trg_Test_PC_1', 'TestPC1@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
      
    //Create a Partner User     
    User partnerUser = Test_COMM_Factory.createUserWithEmail(partnerContact.Id, partnerContact.email, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC));
    list<user> lstPU = [Select email, IsPortalEnabled, UserType From User Where id =:partnerUser.Id AND IsPortalEnabled = TRUE]; 
            
    // Create records for the Custom object 'Tegra Embedded Regstr Expiration by Partner'
    list<Tegra_Embd_Regstr_Expiration_by_Partners__c> tembRegExpbyPartnerList = new list<Tegra_Embd_Regstr_Expiration_by_Partners__c>();
    
    Account pAct = [Select Id, Name, RecordTypeId, RecordType.Name, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode from Account where Id =:partnerAccount.Id];
    pAct.BillingStreet = '1234 Test Street';
    pAct.BillingCity = 'Santa Clara';
    pAct.BillingState = 'California';
    pAct.BillingCountry = 'United States';
    pAct.BillingPostalCode = '12345';
    update pAct;
       
    // Create Tegra Embedded Registration Expiration by Partner
    Tegra_Embd_Regstr_Expiration_by_Partners__c tep = new Tegra_Embd_Regstr_Expiration_by_Partners__c();
    tep.Partner_Sales_Rep_Company__c = pAct.Id;
    tep.Default_Threshold_Limit_for_Partner__c = 60;
    tep.Expire_Registration__c = True;
    insert tep;  // Create records in Custom Object
    
    // login as Partner User and Create the Opportunity    
    system.runAs(partnerUser) {   
      // Create a single Opportunity
      Opportunity opp = new Opportunity();
      opp.Name = 'trg_Context_Test_Tegra_Embd_Opp_1';
      opp.AccountId = partnerAccount.Id;
      opp.StageName = 'Prospect';
      opp.RecordTypeId = map_tEmbd_Opportunity_RT.get(COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY);
      opp.DR_Partner_Sales_Rep_Company__c = partnerAccount.Id;
      opp.DR_SalesOps_Approver__c = partnerUser.Id; 
      opp.LastModifiedDate_by_Partner__c = (Date.Today() - 46);
      opp.CloseDate = system.today() + 10;
      opp.Region__c = 'EMEA';
      insert opp;
    }
       
    list<Opportunity> oppLst = [SELECT Id, Name, OwnerId, StageName, LastModifiedDate_by_Partner__c, Opportunity_Expired__c  
                                FROM Opportunity 
                                WHERE Name = 'trg_Context_Test_Tegra_Embd_Opp_1'];
    system.assertEquals(oppLst[0].LastModifiedDate_by_Partner__c, Date.Today()); 
      
    Test.StartTest();
       
     // Populate the 'LastModifiedDate_by_Partner__c' field as System User
     for(Opportunity tegOpp: oppLst) {
         tegOpp.LastModifiedDate_by_Partner__c = (system.today() - 46);
     }
     update oppLst; 
       
     list<Opportunity> oppLst2 = [SELECT Id, LastModifiedDate_by_Partner__c, Opportunity_Expired__c 
                                  FROM Opportunity 
                                  WHERE Name = 'trg_Context_Test_Tegra_Embd_Opp_1'];
     system.assertEquals(oppLst2[0].LastModifiedDate_by_Partner__c, (Date.Today() - 46)); 
     system.assertEquals(oppLst2[0].Opportunity_Expired__c, false); 
    
     // Update the Expire_Registration__c for the 'Tegra Embedded Registration Expiration by Partner' to false
     list<Tegra_Embd_Regstr_Expiration_by_Partners__c> tepList = [SELECT Id, Partner_Sales_Rep_Company__c, Default_Threshold_Limit_for_Partner__c, Expire_Registration__c
                                                                  FROM Tegra_Embd_Regstr_Expiration_by_Partners__c
                                                                  WHERE Partner_Sales_Rep_Company__c =:pAct.Id];
     delete tepList;  // Delete records in Custom Object 
    
  }
  
}