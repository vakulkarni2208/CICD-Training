/**
    Test class for visual force controller NV_ForgotUsernameController
    Added SeeAllData annotation as without this, the Custom Settings records are not visible
 */
@isTest(seeAllData=false)    
private class NV_Test_ForgotUsernameController {
    
    /*static testMethod void testForgotUsernameWithNullEmail() {
        NV_ForgotUsernameController controller = new NV_ForgotUsernameController();
        //controller.forgotUsername(); 
        //Check if it did not send any email to either portal user or NV Partner Admin.
        system.assert(NV_ForgotUsernameController.isEmailSentToPortalUser == false);
        system.assert(NV_ForgotUsernameController.isEmailSentNVPartnerAdmin == false);
    }
    
    static testMethod void testForgotUsernameWithInvalidEmail() {
        NV_ForgotUsernameController controller = new NV_ForgotUsernameController();
        controller.email = 'abcd';
        //controller.forgotUsername();
        //Check if it did not send any email to either portal user or NV Partner Admin
        system.assert(NV_ForgotUsernameController.isEmailSentToPortalUser == false);
        system.assert(NV_ForgotUsernameController.isEmailSentNVPartnerAdmin == false);
    }*/
    
    static void setupData(){
        NV_NPN_TestDataFactory.setupCustomSettings();
        
        list<Customer_Portal_QPP__c> listCustomer_Portal_QPP= new list<Customer_Portal_QPP__c> ();

        Customer_Portal_QPP__c Cu1= new Customer_Portal_QPP__c ();
        Cu1.name= 'a1G400000031aSH';
        Cu1.setupownerid= UserInfo.getOrganizationId();
        Cu1.id__c= '06040000000PrnT';
        Cu1.login_url__c= 'https://sfdcstage1-npncommunity.cs202.force.com/qpp';
        Cu1.org_url__c= 'https://nvcrm--sfdcstage1.my.salesforce.com/';
        Cu1.forgot_pwd_url__c= 'https://nvcrm--sfdcstage1.my.salesforce.com/qpp/apex/ForgotPassword';
        Cu1.login_err_msg__c= 'Your login attempt has failed. Make sure your username and password are correct.';
        Cu1.forgot_password_err_msg__c= 'Your reset password request was not successful. Please try again.';
        Cu1.forgot_password_multiuser_err_msg__c= 'Multiple users found. Please try with your username.';
        Cu1.forgot_password_nouser_err_msg__c= 'Not a valid user.';
        Cu1.forgot_username_nouser_err_msg__c= 'Not a valid user.';
        Cu1.forgot_username_multiuser_err_msg__c= 'You will be contacted by the NVIDIA Partner Team.';
        Cu1.forgot_username_singleuser_err_msg__c= 'An email with your Username has been sent to your email address.';
        Cu1.forgot_username_customer_email_template__c= 'COMM_Forgot_Username_To_Customer_User';
        Cu1.forgot_username_partner_email_template__c= 'COMM_Forgot_Username_To_Partner_User';
        Cu1.forgot_username_url__c= 'https://sfdcstage1-npncommunity.cs202.force.com/qpp/apex/COMM_ForgotUsername';
        Cu1.forgot_username_email_partneradmin__c= 'nvidiapartnerportal@nvidia.com';

        listCustomer_Portal_QPP.add(Cu1);


        insert listCustomer_Portal_QPP;
    }
    
    static testMethod void testForgotUserNameForPartnerUser() {
      
        setupData();
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
        list<user> lstPU = [Select email, IsPortalEnabled, UserType From User Where id = :partnerUser.Id];
        
            
        //check if the user created is a partner portal user
        system.assert(lstPU[0].IsPortalEnabled == true);
        
        system.assert(lstPU[0].email == partnerContact.email);
        //---------------------------------------------
        //Actual test
        //---------------------------------------------
         test.startTest();
            //get Partner portal login and forgotUserName urls
            Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
            string PortalLoginURL = constantFields.get('PrmPortalLoginUrl').Values__c;
            string PortalForgotUserNameUrl = constantFields.get('PrmPortalForgotUserNameURL').Values__c;
            
            PageReference pageRef = new PageReference(PortalForgotUserNameUrl);
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('FromPage', 'partner');
            system.debug('***pageRef before calling forgotUserName method: ' + pageRef);
            
            NV_ForgotUsernameController oForgotUserName = new NV_ForgotUsernameController();
            oForgotUserName.email = lstPU[0].email;
            oForgotUserName.fromPage = 'partner';

            NV_ForgotUsernameController.forgotUsername(lstPU[0].email,PortalLoginURL,PortalForgotUserNameUrl,'partner');            
            
            //Check if it is partner user and email is sent
            system.assert(NV_ForgotUsernameController.isPartnerUser == true);
            system.assert(NV_ForgotUsernameController.isEmailSentToPortalUser == true);
        Test.stopTest();
        //---------------------------------------------
    }
    
    static testMethod void testForgotUserNameForCustomerUser() {
        setupData();
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
        list<user> lstCU = [Select email, IsPortalEnabled, UserType From User Where id = :customerUser.Id];
            
        //check if the user created is a partner portal user
        system.assert(lstCU[0].IsPortalEnabled == true);
        
        system.assert(lstCU[0].email == customerContact.email);
        //---------------------------------------------
        
        //Actual test
        //---------------------------------------------
         test.startTest();
            //get Partner portal login and forgotUserName urls
            string PortalLoginURL  = Customer_Portal_QPP__c.getOrgDefaults().Login_URL__c;
            string PortalForgotUserNameUrl = Customer_Portal_QPP__c.getOrgDefaults().Forgot_UserName_URL__c;
            
            PageReference pageRef = new PageReference(PortalForgotUserNameUrl);
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('FromPage', 'qpp');
            system.debug('***pageRef before calling forgotUserName method: ' + pageRef);
            
            NV_ForgotUsernameController oForgotUserName = new NV_ForgotUsernameController();
            oForgotUserName.email = lstCU[0].email;
            oForgotUserName.fromPage = 'qpp';

            NV_ForgotUsernameController.forgotUsername(lstCU[0].email,PortalLoginURL,PortalForgotUserNameUrl,'partner');
            

            //Check if it is a customer usera and email is sent
            system.assert(NV_ForgotUsernameController.isCustomerUser == true);
            system.assert(NV_ForgotUsernameController.isEmailSentToPortalUser == true);
            
        Test.stopTest();
        //---------------------------------------------
        
    }
    
    static testMethod void testForgotUserNameForMultiPartnerUser() {
        
        setupData();
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
        list<user> lstPU = [Select email, IsPortalEnabled, UserType From User Where id = :partnerUser.Id];
            
        //check if the user created is a partner portal user
        system.assert(lstPU[0].IsPortalEnabled == true);
        
        system.assert(lstPU[0].email == partnerContact.email);
        //---------------------------------------------
        
        //Actual test
        //---------------------------------------------
         test.startTest();
            //get Partner portal login and forgotUserName urls
            Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
            string PortalLoginURL = constantFields.get('PrmPortalLoginUrl').Values__c;
            string PortalForgotUserNameUrl = constantFields.get('PrmPortalForgotUserNameURL').Values__c;
            
            PageReference pageRef = new PageReference(PortalForgotUserNameUrl);
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('FromPage', 'partner');
            system.debug('***pageRef before calling forgotUserName method: ' + pageRef);
            
            NV_ForgotUsernameController oForgotUserName = new NV_ForgotUsernameController();
            oForgotUserName.email = lstPU[0].email;
            oForgotUserName.fromPage = 'partner';

            NV_ForgotUsernameController.forgotUsername(lstPU[0].email,PortalLoginURL,PortalForgotUserNameUrl,'partner');
            
            
            //Check if it is multi-partner user and email is sent to NV Partner Admin
            system.assert(NV_ForgotUsernameController.isMultiPartnerUser == true);
            system.assert(NV_ForgotUsernameController.isEmailSentNVPartnerAdmin == true);
        Test.stopTest();
        //---------------------------------------------
    }
    
    static testMethod void testForgotUserNameForMultiCustomerUser() {
        
        setupData();
        
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
        list<user> lstCU = [Select email, IsPortalEnabled, UserType From User Where id = :customerUser.Id];
            
        //check if the user created is a partner portal user
        system.assert(lstCU[0].IsPortalEnabled == true);
        
        system.assert(lstCU[0].email == customerContact.email);
        //---------------------------------------------
        
        //Actual test
        //---------------------------------------------
         test.startTest();
            //get Partner portal login and forgotUserName urls
            string PortalLoginURL  = Customer_Portal_QPP__c.getOrgDefaults().Login_URL__c;
            string PortalForgotUserNameUrl = Customer_Portal_QPP__c.getOrgDefaults().Forgot_UserName_URL__c;
            
            PageReference pageRef = new PageReference(PortalForgotUserNameUrl);
            Test.setCurrentPageReference(pageRef);
            ApexPages.currentPage().getParameters().put('FromPage', 'qpp');
            system.debug('***pageRef before calling forgotUserName method: ' + pageRef);
            
            NV_ForgotUsernameController oForgotUserName = new NV_ForgotUsernameController();
            oForgotUserName.email = lstCU[0].email;
            oForgotUserName.fromPage = 'qpp';

            NV_ForgotUsernameController.forgotUsername(lstCU[0].email,PortalLoginURL,PortalForgotUserNameUrl,'partner');
            
            //Check if it is a customer user and email is sent to NV Partner Admin
            system.assert(NV_ForgotUsernameController.isMultiCustomerUser == true);
            system.assert(NV_ForgotUsernameController.isEmailSentNVPartnerAdmin == true);
            
        Test.stopTest();
        //---------------------------------------------
        
    }
    
    
    static testMethod void testForgotUserNameNoUser() {
        setupData();
        //Actual test
        //---------------------------------------------
         test.startTest();
            //get Partner portal login and forgotUserName urls
            Map<string, Org_Constants__c> constantFields = Org_Constants__c.getAll();
            string PortalLoginURL = constantFields.get('PrmPortalLoginUrl').Values__c;
            string PortalForgotUserNameUrl = constantFields.get('PrmPortalForgotUserNameURL').Values__c;
            
            PageReference pageRef = new PageReference(PortalForgotUserNameUrl);
            Test.setCurrentPageReference(pageRef);
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('FromPage', 'partner');
            system.debug('***pageRef before calling forgotUserName method: ' + pageRef);
            
            NV_ForgotUsernameController oForgotUserName = new NV_ForgotUsernameController();
            
            Long lRandom, uniqueVal;
            lRandom = Math.roundToLong(Math.random() * 999);
            uniqueVal = System.currentTimeMillis();
            string strEmail = 't' + lRandom + uniqueVal + '@tnv.com';
            
            oForgotUserName.email = strEmail;
            oForgotUserName.fromPage = 'partner';

            NV_ForgotUsernameController.forgotUsername(strEmail,PortalLoginURL,PortalForgotUserNameUrl,'partner');
            
            //Check if it did not send any email to either portal user or NV Partner Admin
            system.assert(NV_ForgotUsernameController.isEmailSentToPortalUser == false);
            system.assert(NV_ForgotUsernameController.isEmailSentNVPartnerAdmin == false);
                
        Test.stopTest();
        //---------------------------------------------
    }
}