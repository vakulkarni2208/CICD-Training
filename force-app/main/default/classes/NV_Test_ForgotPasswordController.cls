/**
    Test class for visual force controller NV_ForgotPasswordController
    Added SeeAllData annotation as without this, the Custom Settings records are not visible
 */
@isTest(SeeAllData=true)    
private class NV_Test_ForgotPasswordController {
   
    static User createData() {
         
        User usr = [select Id,Profile.Name,Profile.Id from User where isActive=true and Profile.Name = 'System Administrator' limit 1];
        //create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NV_PPA);
        map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC);
        
        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
               Account partnerAccount = Test_COMM_Factory.createAccount('Test PP Account1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_NV_PPA), true, false);
        
        //Check if the Account is a partner account 
        system.assertEquals(partnerAccount.IsPartner, true);
        //---------------------------------------------
        
        //Create a 2 Partner Contacts with same email address 
        //---------------------------------------------
        Contact partnerContact = Test_COMM_Factory.createContact('Test1', 'test'+Math.Random()+'@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
        //Contact partnerContactDup = Test_COMM_Factory.createContact('Test2', 'test2@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
        //Check if the partner contact is created
        system.assertNotEquals(partnerContact.Id, null);
        system.assertNotEquals(partnerContact.RecordType.Name, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
  
        //---------------------------------------------
        
        //Create a Partner User with duplicate email
        //---------------------------------------------
        User partnerUser;
        System.runAs(usr) {
            partnerUser = Test_COMM_Factory.createUserWithEmail(partnerContact.Id, partnerContact.email, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC));            
        }
        return partnerUser;
    }

    
    static testMethod void testForgotPasswordForPartnerUser() {
        /*
        //create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NV_PPA);
        map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC);
        
        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
        Account partnerAccount = Test_COMM_Factory.createAccount('Test PP Account1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_NV_PPA), true, false);
        
        //Check if the Account is a partner account 
        system.assertEquals(partnerAccount.IsPartner, true);
        //---------------------------------------------
        
        //Create a Partner Contact 
        //---------------------------------------------
        Contact partnerContact = Test_COMM_Factory.createContact('Test', 'test1@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
        
        //Check if the partner contact is created
        system.assertNotEquals(partnerContact.Id, null);
        system.assertNotEquals(partnerContact.RecordType.Name, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
  
        //---------------------------------------------
        
        //Create a Partner User
        //---------------------------------------------
        system.debug('***partnerContact.Email: ' + partnerContact.Email);
        User partnerUser = Test_COMM_Factory.createUserWithEmail(partnerContact.Id, partnerContact.email, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC));
        */
        User partnerUser = createData();
        list<user> lstPU = [Select email, IsPortalEnabled, UserType From User Where id = :partnerUser.Id];
            
        //check if the user created is a partner portal user
        system.assert(lstPU[0].IsPortalEnabled == true);
        
        //---------------------------------------------
        
        //Actual test
        //---------------------------------------------
         test.startTest();
            //get Partner portal login and forgotUserName urls
            Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
            string PortalLoginURL = constantFields.get('PrmPortalLoginUrl').Values__c;
            string PortalId = constantFields.get('PRMPortalId').Values__c;
            string PortalForgotPasswordUrl = constantFields.get('PrmPortalForgotPWDURL').Values__c;
            string orgID = [Select Id FROM Organization LIMIT 1].Id;
            
            PageReference pageRef = new PageReference(PortalForgotPasswordUrl);
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('fromPage', 'partner');
            system.debug('***pageRef before calling forgotUserName method: ' + pageRef);
            NV_ForgotPasswordController objNVFPC = new NV_ForgotPasswordController();
            NV_ForgotPasswordController.forgotPassword(lstPU[0].email,PortalLoginURL,PortalId,PortalForgotPasswordUrl,orgID,'partner');         
            
            //Check if it is partner user and email is sent
            //system.assert(NV_ForgotPasswordController.isPartnerUser == true);
            system.assert(NV_ForgotPasswordController.isEmailSentToPortalUser == true);
        Test.stopTest();
        //---------------------------------------------
    }
    
    static testMethod void testForgotPasswordForCustomerUser() {
        /*
        //create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapPP_NPNCommunityAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NPN_COMMUNITY); //ACCOUNT_RT_NPN_COMMUNITY
        map<String, Id> mapPP_CustomerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_CPQPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_CP_QPP_GENERIC); //PROF_CP_QPP_GENERIC
        
        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
        Account customerAccount = Test_COMM_Factory.createAccount('Test Cust Account1', mapPP_NPNCommunityAccount_RT.get(COMM_Constants.ACCOUNT_RT_NPN_COMMUNITY), true, false);
        
        
        //Check if the Account is a Customer account 
        //system.assertEquals(customerAccount.IsCustomerPortal, true);
        //---------------------------------------------
        
        //Create a Customer Contact 
        //---------------------------------------------
        Contact customerContact = Test_COMM_Factory.createContact('Test', 'testcust1@nv.com', customerAccount.Id, mapPP_CustomerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
        
        //Check if the partner contact is created
        system.assertNotEquals(customerContact.Id, null);
        system.assertNotEquals(customerContact.RecordType.Name, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
  
        //---------------------------------------------
        
        //Create a Partner User
        //---------------------------------------------
        User customerUser = Test_COMM_Factory.createUserWithEmail(customerContact.Id, customerContact.email, mapPP_CPQPP_Generic_Prof.get(COMM_Constants.PROF_CP_QPP_GENERIC));
        
        */
        User customerUser = createData();
        list<user> lstCU = [Select email, IsPortalEnabled, UserType From User Where id = :customerUser.Id];
            
        //check if the user created is a partner portal user
        system.assert(lstCU[0].IsPortalEnabled == true);
        
        //---------------------------------------------
        
        //Actual test
        //---------------------------------------------
         test.startTest();
            //get Partner portal login and forgotUserName urls
            Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
            string PortalLoginURL = constantFields.get('PrmPortalLoginUrl').Values__c;
            string PortalId = constantFields.get('PRMPortalId').Values__c;
            string PortalForgotPasswordUrl = constantFields.get('PrmPortalForgotPWDURL').Values__c;
            string orgID = [Select Id FROM Organization LIMIT 1].Id;
            
            PageReference pageRef = new PageReference(PortalForgotPasswordUrl);
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('fromPage', 'qpp');
            system.debug('***pageRef before calling forgotUserName method: ' + pageRef);
            NV_ForgotPasswordController objFPC = new NV_ForgotPasswordController();
            NV_ForgotPasswordController.forgotPassword(lstCU[0].email,PortalLoginURL,PortalId,PortalForgotPasswordUrl,orgID,'qpp');

            //Check if it is a customer usera and email is sent
            //system.assert(NV_ForgotPasswordController.isCustomerUser == true);
            system.assert(NV_ForgotPasswordController.isEmailSentToPortalUser == true);
            
        Test.stopTest();
        //---------------------------------------------
        
    }
    
    static testMethod void testForgotPasswordForMultiPartnerUser() {
        /*
        //create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NV_PPA);
        map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC);
        
        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
        Account partnerAccount = Test_COMM_Factory.createAccount('Test PP Account1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_NV_PPA), true, false);
        
        //Check if the Account is a partner account 
        system.assertEquals(partnerAccount.IsPartner, true);
        //---------------------------------------------
        
        //Create a 2 Partner Contacts with same email address 
        //---------------------------------------------
        Contact partnerContact = Test_COMM_Factory.createContact('Test1', 'test1@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
        Contact partnerContactDup = Test_COMM_Factory.createContact('Test2', 'test2@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
        //Check if the partner contact is created
        system.assertNotEquals(partnerContact.Id, null);
        system.assertNotEquals(partnerContact.RecordType.Name, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
  
        //---------------------------------------------
        
        //Create a Partner User with duplicate email
        //---------------------------------------------
        User partnerUser = Test_COMM_Factory.createUserWithEmail(partnerContact.Id, partnerContact.email, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC));
        User partnerUserDuplicate = Test_COMM_Factory.createUserWithEmail(partnerContactDup.Id, partnerContact.email, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC));
        */
        User partnerUser = createData();
        User partnerUserDuplicate = createData();
        list<user> lstPU = [Select email, IsPortalEnabled, UserType From User Where id = :partnerUser.Id];
            
        //check if the user created is a partner portal user
        system.assert(lstPU[0].IsPortalEnabled == true);
        
        //---------------------------------------------
        
        //Actual test
        //---------------------------------------------
        Test.startTest();
            //get Partner portal login and forgotUserName urls
            Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
            string PortalLoginURL = constantFields.get('PrmPortalLoginUrl').Values__c;
            string PortalId = constantFields.get('PRMPortalId').Values__c;
            string PortalForgotPasswordUrl = constantFields.get('PrmPortalForgotPWDURL').Values__c;
            string orgID = [Select Id FROM Organization LIMIT 1].Id;
            
            PageReference pageRef = new PageReference(PortalForgotPasswordUrl);
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('fromPage', 'partner');
            system.debug('***pageRef before calling forgotUserName method: ' + pageRef);
            NV_ForgotPasswordController objNVFPC = new NV_ForgotPasswordController();
            NV_ForgotPasswordController.forgotPassword(lstPU[0].email,PortalLoginURL,PortalId,PortalForgotPasswordUrl,orgID,'partner');
            
            //Check if it is multi-partner user and email is sent to NV Partner Admin
            //system.assert(NV_ForgotPasswordController.isMultiPartnerUser == true);
            //system.assert(NV_ForgotPasswordController.isEmailSentNVPartnerAdmin == true);
        Test.stopTest();
        //---------------------------------------------
    }
    
    static testMethod void testForgotPasswordForMultiCustomerUser() {
        /*
        //create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapPP_NPNCommunityAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NPN_COMMUNITY); //ACCOUNT_RT_NPN_COMMUNITY
        map<String, Id> mapPP_CustomerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_CPQPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_CP_QPP_GENERIC); //PROF_CP_QPP_GENERIC
        
        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
        Account customerAccount = Test_COMM_Factory.createAccount('Test Cust Account1', mapPP_NPNCommunityAccount_RT.get(COMM_Constants.ACCOUNT_RT_NPN_COMMUNITY), true, false);
        
        
        //Check if the Account is a Customer account 
        //system.assertEquals(customerAccount.IsCustomerPortal, true);
        //---------------------------------------------
        
        //Create 2 Customer Contacts 
        //---------------------------------------------
        Contact customerContact = Test_COMM_Factory.createContact('Test1', 'testcust1@nv.com', customerAccount.Id, mapPP_CustomerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
        Contact customerContactDup = Test_COMM_Factory.createContact('Test2', 'testcust2@nv.com', customerAccount.Id, mapPP_CustomerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
        
        //Check if the partner contact is created
        system.assertNotEquals(customerContact.Id, null);
        system.assertNotEquals(customerContact.RecordType.Name, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
  
        //---------------------------------------------
        
        //Create Partner Users with duplicate emails
        //---------------------------------------------
        User customerUser = Test_COMM_Factory.createUserWithEmail(customerContact.Id, customerContact.email, mapPP_CPQPP_Generic_Prof.get(COMM_Constants.PROF_CP_QPP_GENERIC));
        User customerUserDup = Test_COMM_Factory.createUserWithEmail(customerContactDup.Id, customerContact.email, mapPP_CPQPP_Generic_Prof.get(COMM_Constants.PROF_CP_QPP_GENERIC));
        */
        User customerUser = createData();
        User customerUserDup = createData();
        list<user> lstCU = [Select email, IsPortalEnabled, UserType From User Where id = :customerUser.Id];
            
        //check if the user created is a partner portal user
        system.assert(lstCU[0].IsPortalEnabled == true);
        
        //---------------------------------------------
        
        //Actual test
        //---------------------------------------------
         test.startTest();
            //get Partner portal login and forgotUserName urls
            Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
            string PortalLoginURL = constantFields.get('PrmPortalLoginUrl').Values__c;
            string PortalId = constantFields.get('PRMPortalId').Values__c;
            string PortalForgotPasswordUrl = constantFields.get('PrmPortalForgotPWDURL').Values__c;
            string orgID = [Select Id FROM Organization LIMIT 1].Id;
            
            PageReference pageRef = new PageReference(PortalForgotPasswordUrl);
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('fromPage', 'qpp');
            system.debug('***pageRef before calling forgotUserName method: ' + pageRef);
            NV_ForgotPasswordController objNVFPC = new NV_ForgotPasswordController();
            NV_ForgotPasswordController.forgotPassword(lstCU[0].email,PortalLoginURL,PortalId,PortalForgotPasswordUrl,orgID,'partner');
            
            //Check if it is a customer user and email is sent to NV Partner Admin
            //system.assert(NV_ForgotPasswordController.isMultiCustomerUser == true);
            //system.assert(NV_ForgotPasswordController.isEmailSentNVPartnerAdmin == true);
            
        Test.stopTest();
        //---------------------------------------------
        
    }
    
    static testMethod void testForgotPasswordNoUser() {
        //Actual test
        //---------------------------------------------
         test.startTest();
            //get Partner portal login and forgotUserName urls
            Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
            string PortalLoginURL = constantFields.get('PrmPortalLoginUrl').Values__c;
            string PortalId = constantFields.get('PRMPortalId').Values__c;
            string PortalForgotPasswordUrl = constantFields.get('PrmPortalForgotPWDURL').Values__c;
            string orgID = [Select Id FROM Organization LIMIT 1].Id;
            
            PageReference pageRef = new PageReference(PortalForgotPasswordUrl);
            Test.setCurrentPageReference(pageRef);
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('FromPage', 'partner');
            system.debug('***pageRef before calling forgotUserName method: ' + pageRef);
            
            Long lRandom, uniqueVal;
            lRandom = Math.roundToLong(Math.random() * 999);
            uniqueVal = System.currentTimeMillis();
            string strEmail = 't' + lRandom + uniqueVal + '@tnv.com';
            
            NV_ForgotPasswordController.forgotPassword(strEmail,PortalLoginURL,PortalId,PortalForgotPasswordUrl,orgID,'partner');           
            
            //Check if it did not send any email to either portal user or NV Partner Admin
            system.assert(NV_ForgotPasswordController.isEmailSentToPortalUser == false);
            //system.assert(NV_ForgotPasswordController.isEmailSentNVPartnerAdmin == false);
                
        Test.stopTest();
        //---------------------------------------------
    }
}