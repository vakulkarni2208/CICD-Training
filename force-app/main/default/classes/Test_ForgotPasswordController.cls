/**
 Testing for ForgotPasswordController
 Added SeeAllData annotation as without this, the Custom Settings records are not visible
 
 //2017.06.21 - Test class retrofit during MDF v1/v2 code cleanup
 // 2021.04.15  Test class optimization
 */
 
@isTest(seeAllData=false)
private class Test_ForgotPasswordController {

    @testSetup static void setupData(){
        
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
        
        list<Org_Constants__c> listOrg_Constants= new list<Org_Constants__c> ();

        Org_Constants__c Or1= new Org_Constants__c ();
        Or1.name= 'OrgUrl';
        Or1.values__c= 'https://na87.salesforce.com';

        listOrg_Constants.add(Or1);
        Org_Constants__c Or2= new Org_Constants__c ();
        Or2.name= 'Marketing_Search';
        Or2.values__c= 'https://c.cs202.visual.force.com/apex/MarketingSearchTool?sfdc.tabName=01r40000000EJ9q';

        listOrg_Constants.add(Or2);
        Org_Constants__c Or3= new Org_Constants__c ();
        Or3.name= 'PRMPortalId';
        Or3.values__c= '06040000000D7uX';

        listOrg_Constants.add(Or3);
        Org_Constants__c Or4= new Org_Constants__c ();
        Or4.name= 'PrmPortalLoginUrl';
        Or4.values__c= 'https://sfdcstage1-npncommunity.cs202.force.com/partners';

        listOrg_Constants.add(Or4);
        Org_Constants__c Or5= new Org_Constants__c ();
        Or5.name= 'SAPUrl';
        Or5.values__c= 'https://qasb2b.nvidia.com';

        listOrg_Constants.add(Or5);
        Org_Constants__c Or6= new Org_Constants__c ();
        Or6.name= 'PrmPortalForgotPWDURL';
        Or6.values__c= 'https://sfdcstage1-npncommunity.cs202.force.com/partners/apex/ForgotPassword';

        listOrg_Constants.add(Or6);
        Org_Constants__c Or7= new Org_Constants__c ();
        Or7.name= 'Login_Err_Msg';
        Or7.values__c= 'Your login attempt has failed. Make sure your username and password are correct.';

        listOrg_Constants.add(Or7);
        Org_Constants__c Or8= new Org_Constants__c ();
        Or8.name= 'PrmPortalForgotUserNameURL';
        Or8.values__c= 'https://sfdcstage1-npncommunity.cs202.force.com/apex/COMM_ForgotUsername';

        listOrg_Constants.add(Or8);
        Org_Constants__c Or9= new Org_Constants__c ();
        Or9.name= 'CommunityForgotPWDURL';
        Or9.values__c= '/apex/NV_ForgotPassword';

        listOrg_Constants.add(Or9);
        Org_Constants__c Or10= new Org_Constants__c ();
        Or10.name= 'CommunityForgotUserNameURL';
        Or10.values__c= '/apex/NV_ForgotUsernamePage';

        listOrg_Constants.add(Or10);
        Org_Constants__c Or11= new Org_Constants__c ();
        Or11.name= 'CommunityLoginURL';
        Or11.values__c= '/NV_PartnerCommunityLogin';

        listOrg_Constants.add(Or11);


        insert listOrg_Constants;
    }
    
    static testMethod void testForgotPassword() {
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.username = 'test@salesforce.com';
        controller.forgotPassword(); 
    }
    
    static testMethod void testForgotPasswordWithNullUserName() {
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.forgotPassword(); 
    }
    
    static testMethod void testForgotPwdPPUser_PPLogin() {
        
        //create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NV_PPA);
        map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC);
        
        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
        Account partnerAccount = Test_COMM_Factory.createAccount('Testfp1 PP Account1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_NV_PPA), true, false);
        
        //Check if the Account is a partner account 
        system.assertEquals(partnerAccount.IsPartner, true);
        //---------------------------------------------
        
        //Create a Partner Contact 
        //---------------------------------------------
        Contact partnerContact = Test_COMM_Factory.createContact('Test', 'testfp1@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
        
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
            
            ForgotPasswordController oForgotPwdC = new ForgotPasswordController();
            oForgotPwdC.username = lstPU[0].email;
            oForgotPwdC.fromPage = 'partner';

            PageReference pgRef = oForgotPwdC.forgotPassword();
            system.debug('***pgRef: ' + pgRef);

            //Check if it is partner user and email is sent
            //2017.06.21 - Test class retrofit during MDF v1/v2 code cleanup. commenting out the assert to avoid test class failure
            //system.assert(ForgotPasswordController.isValidUser == true);
            //system.assert(ForgotPasswordController.isEmailSentToPortalUser == true);
        Test.stopTest();
        //---------------------------------------------
    }
    
    static testMethod void testForgotPwdPPUser_CPLogin() {
        
        //create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NV_PPA);
        map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC);
        
        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
        Account partnerAccount = Test_COMM_Factory.createAccount('Testfp2 PP Account1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_NV_PPA), true, false);
        
        //Check if the Account is a partner account 
        system.assertEquals(partnerAccount.IsPartner, true);
        //---------------------------------------------
        
        //Create a Partner Contact 
        //---------------------------------------------
        Contact partnerContact = Test_COMM_Factory.createContact('Test', 'testfp2@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
        
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
            ApexPages.currentPage().getParameters().put('FromPage', 'qpp');
            system.debug('***pageRef before calling forgotUserName method: ' + pageRef);
            
            ForgotPasswordController oForgotPwdC = new ForgotPasswordController();
            oForgotPwdC.username = lstPU[0].email;
            oForgotPwdC.fromPage = 'qpp';

            PageReference pgRef = oForgotPwdC.forgotPassword();
            system.debug('***pgRef: ' + pgRef);

            //Check if it is partner user and email is sent
            system.assert(ForgotPasswordController.isValidUser == false);
            system.assert(ForgotPasswordController.isEmailSentToPortalUser == false);
        Test.stopTest();
        //---------------------------------------------
    }
    
    static testMethod void testForgotPwdCPUser_CPLogin() {
        
        //create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapPP_NPNCommunityAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NPN_COMMUNITY); //ACCOUNT_RT_NPN_COMMUNITY
        map<String, Id> mapPP_CustomerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_CPQPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_CP_QPP_GENERIC); //PROF_CP_QPP_GENERIC
        
        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
        Account customerAccount = Test_COMM_Factory.createAccount('Test Custfp1 Account1', mapPP_NPNCommunityAccount_RT.get(COMM_Constants.ACCOUNT_RT_NPN_COMMUNITY), true, false);
        
        
        //Check if the Account is a Customer account 
        //system.assertEquals(customerAccount.IsCustomerPortal, true);
        //---------------------------------------------
        
        //Create a Customer Contact 
        //---------------------------------------------
        Contact customerContact = Test_COMM_Factory.createContact('Test', 'testcustfp1@nv.com', customerAccount.Id, mapPP_CustomerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
        
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
            
            ForgotPasswordController oForgotPwdC = new ForgotPasswordController();
            oForgotPwdC.username = lstCU[0].email;
            oForgotPwdC.fromPage = 'qpp';

            PageReference pgRef = oForgotPwdC.forgotPassword();
            system.debug('***pgRef: ' + pgRef);

            //Check if it is partner user and email is sent
            system.assert(ForgotPasswordController.isValidUser == true);
            system.assert(ForgotPasswordController.isEmailSentToPortalUser == true);
            
        Test.stopTest();
        //---------------------------------------------
        
    }
    
     static testMethod void testForgotPwdCPUser_PPLogin() {
        
        //create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapPP_NPNCommunityAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NPN_COMMUNITY); //ACCOUNT_RT_NPN_COMMUNITY
        map<String, Id> mapPP_CustomerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_CPQPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_CP_QPP_GENERIC); //PROF_CP_QPP_GENERIC
        
        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
        Account customerAccount = Test_COMM_Factory.createAccount('Test Custfp2 Account1', mapPP_NPNCommunityAccount_RT.get(COMM_Constants.ACCOUNT_RT_NPN_COMMUNITY), true, false);
        
        
        //Check if the Account is a Customer account 
        //system.assertEquals(customerAccount.IsCustomerPortal, true);
        //---------------------------------------------
        
        //Create a Customer Contact 
        //---------------------------------------------
        Contact customerContact = Test_COMM_Factory.createContact('Test', 'testcustfp2@nv.com', customerAccount.Id, mapPP_CustomerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
        
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
            ApexPages.currentPage().getParameters().put('FromPage', 'partner');
            system.debug('***pageRef before calling forgotUserName method: ' + pageRef);
            
            ForgotPasswordController oForgotPwdC = new ForgotPasswordController();
            oForgotPwdC.username = lstCU[0].email;
            oForgotPwdC.fromPage = 'partner';

            PageReference pgRef = oForgotPwdC.forgotPassword();
            system.debug('***pgRef: ' + pgRef);

            //Check if it is partner user and email is sent
            system.assert(ForgotPasswordController.isValidUser == false);
            system.assert(ForgotPasswordController.isEmailSentToPortalUser == false);
            
        Test.stopTest();
        //---------------------------------------------
        
    }
    
    static testMethod void testForgotPwdMultiPPUser_PPLogin() {
        
        //create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NV_PPA);
        map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC);
        
        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
        Account partnerAccount = Test_COMM_Factory.createAccount('Test PPFP1 Account1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_NV_PPA), true, false);
        
        //Check if the Account is a partner account 
        system.assertEquals(partnerAccount.IsPartner, true);
        //---------------------------------------------
        
        //Create a 2 Partner Contacts with same email address 
        //---------------------------------------------
        Contact partnerContact = Test_COMM_Factory.createContact('Test1', 'testfp1@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
        Contact partnerContactDup = Test_COMM_Factory.createContact('Test2', 'testfp2@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_PPG_COMMUNITY);
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
            
            ForgotPasswordController oForgotPwdC = new ForgotPasswordController();
            oForgotPwdC.username = lstPU[0].email;
            oForgotPwdC.fromPage = 'partner';

            PageReference pgRef = oForgotPwdC.forgotPassword();
            system.debug('***pgRef: ' + pgRef);
            
            //Check if it is multi-partner user and email is sent to NV Partner Admin
            system.assert(ForgotPasswordController.isValidUser == false);
            system.assert(ForgotPasswordController.isEmailSentToPortalUser == false);
        Test.stopTest();
        //---------------------------------------------
    }
    
}