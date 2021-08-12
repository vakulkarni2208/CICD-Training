/**
 * @description   :   This is the test class for  NV_CommunityHomePageController
 */
@isTest(seeAllData = false)
private class NV_Test_CommunityHomePageController {

    static User createData() {
        NV_NPN_TestDataFactory.setupCustomSettings();
        User usr = [SELECT Id,Profile.Name,Profile.Id FROM User WHERE isActive=true and Profile.Name = 'System Administrator' LIMIT 1];

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

    static testMethod void myUnitTest() {
        
        genericMock fakeResp = new genericMock(200,'Complete',
           '<?xml version="1.0" encoding="UTF-8"?>'+
           '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/>'+
           '<soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com">'+
           '<ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage>'+
           '</ax21:errorMessage><ax21:statusCode>success</ax21:statusCode>'+
           '<ax21:syncType>PartnerUser</ax21:syncType></ns:return>'+
           '</ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);

        System.Test.setMock(HttpCalloutMock.class, fakeResp);
        
        GRID_VCA_Instant_Message__c objGridVCAMsg = new GRID_VCA_Instant_Message__c();
        objGridVCAMsg.Start_Date__c = System.today();
        objGridVCAMsg.Expiration_Date__c = System.today() + 2;
        objGridVCAMsg.Message__c = 'Hello World';
        insert objGridVCAMsg;

        User u = createData();
        u = [SELECT Id, ContactId, Contact.AccountId, accountId,Profile.Name,Profile.Id from User where id=:u.id];
        GRID_Portal_Profiles__c obj = new GRID_Portal_Profiles__c();
        obj.Name = u.Profile.Name;
        insert obj;
        system.runAs(u){
            PermissionSet ps = new PermissionSet();
            ps.label = 'SALES_PARTNER_PORTAL_PARTNER_DEPOT_Box';
            ps.name = 'SALES_PARTNER_PORTAL_PARTNER_DEPOT_Box';
            insert ps;
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = u.id;
            psa.PermissionSetId = ps.id;
            insert psa;
        }

        Portal_Permission_Sets__c objPortalPermissionSet = new Portal_Permission_Sets__c();
        objPortalPermissionSet.Name = 'SALES_PARTNER_PORTAL_PARTNER_DEPOT_Box';
        insert objPortalPermissionSet;

        Portal_Home_Page_Box__c objectPortalHomeBox = new Portal_Home_Page_Box__c();
        objectPortalHomeBox.Portal_Permission_Set__c = objPortalPermissionSet.id;
        objectPortalHomeBox.Name = objPortalPermissionSet.Name;
        objectPortalHomeBox.Box_Serial_Number__c = 1;
        objectPortalHomeBox.Language__c = 'English';
        objectPortalHomeBox.Presentation_Type__c = 'NVIDIA CONTACTS';
        insert objectPortalHomeBox;

        Partner_Portal_Label__c objPartner_Portal_Label = new Partner_Portal_Label__c();
        objPartner_Portal_Label.Permission_Set__c = objPortalPermissionSet.Id;
        objPartner_Portal_Label.Portal_Content_Type__c = 'GRID';
        objPartner_Portal_Label.Label_Serial_Number__c = 1;
        insert objPartner_Portal_Label;

        List<Portal_Presentation__c> lstToInsert = new List<Portal_Presentation__c>();
        for(integer i =0; i<5; i++) {
            Portal_Presentation__c pBox = new Portal_Presentation__c();
            pBox.Name = 'Selling GPU';
            pBox.Image_URL__c = 'https://cs12.salesforce.com/resource/1370038993000/GRID_Presentation_Image1';
            pBox.Portal_Profile__c = u.Profile.Name;
            pBox.Presentation_Type__c = 'NEW TECHNICAL PRESENTATIONS';
            pBox.Presentation_URL__c = 'http://www.brainshark.com/nvidia/vu?pi=832992210&sid=498375518&sky=8fdd8cd8a0834446a05fffc977fc6fea&uid=1286900';
            pBox.Permission_Set__c = objPortalPermissionSet.id;
            pBox.Portal_Home_Page_Box__c = objectPortalHomeBox.Id;
            pBox.Community_Presentation_Text__c = 'TEST TEXT';
            lstToInsert.add(pBox);
        }

        if(lstToInsert.size()>0) {
            insert lstToInsert;
        }

        System.runAs(u){
            NV_CommunityHomePageController objGridPortal = new NV_CommunityHomePageController();
            //Account acc = [SELECT id from account limit 1];
            //Contact con = [SELECT id from Contact where accountId = :acc.id limit 1];
            /*objGridPortal.emailReportAProblem = 'test@salesforce.com';
               objGridPortal.phoneNumber = '9876543210';
               objGridPortal.Attach = blob.valueOf('abc');
               objGridPortal.problemDescription = '';
               objGridPortal.steptoReproduceProblem = '';*/

            /*NV_CommunityHomePageController.wrapperMain objWrapperMain = new NV_CommunityHomePageController.wrapperMain();
               NV_CommunityHomePageController.wrapper objWrapper = new NV_CommunityHomePageController.wrapper();
               NV_CommunityHomePageController.wrapperMain objWrapperMain1 = new NV_CommunityHomePageController.wrapperMain();
               NV_CommunityHomePageController.wrapper objWrapper1 = new NV_CommunityHomePageController.wrapper();

               List<clsPartnerPortalHome.wrapper> lstWrapper = new List<clsPartnerPortalHome.wrapper>();
               objWrapper.serialNo  = 1;
               objWrapper1.serialNo  = 2;
               lstWrapper.add(objWrapper);
               lstWrapper.add(objWrapper1);

               List<clsPartnerPortalHome.wrapperMain> lstWrapperMain = new List<clsPartnerPortalHome.wrapperMain>();
               objWrapperMain.srno = 1.00;
               objWrapperMain1.srno = 2.00;
               objWrapperMain.lstW  = lstWrapper;
               objWrapperMain1.lstW  = lstWrapper;
               lstWrapperMain.add(objWrapperMain);
               lstWrapperMain.add(objWrapperMain1);

               objGridPortal.sorting(lstWrapperMain);
               objGridPortal.sorting(lstWrapper);   */
            Test.startTest();
            NV_CommunityHomePageController.sendEmail_LogASupportRequest('{"contact" : {"FirstName" : "Test","AccountName" : "Partner 1 Test Account","Email" : "vakulkarni@nvidia.com","Phone" : "1234432123","MobilePhone" : "","Id" : "'+u.contactId+'","AccountId" : "'+u.contact.accountId+'"},"problemType" : "test","problemDescription" : "test","stepsToReproduce" : "","selectedContentType" : {"label" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_GV+'","value" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_GV+'","$$hashKey" : "006"},"portalContentTypes" :[{"label" : "--None--","value" : "--None--","$$hashKey" : "005"},{"label" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_GV+'","value" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_GV+'","$$hashKey" : "006"},{"label" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_PV+'","value" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_PV+'","$$hashKey" : "007"},{"label" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_DL+'","value" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_DL+'","$$hashKey" : "008"},{"label" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_AC+'","value" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_AC+'","$$hashKey" : "009"}],"stepToReproduce" : "test","emailBody" : "test test body"}');

            NV_CommunityHomePageController.sendEmail_AskAQuestion('{"contact" : {"FirstName" : "Test","AccountName" : "Partner 1 Test Account","Email" : "vakulkarni@nvidia.com","Phone" : "1234432123","MobilePhone" : "","Id" : "'+u.contactId+'","AccountId" : "'+u.contact.accountId+'"},"problemType" : "test","problemDescription" : "test","stepsToReproduce" : "","selectedContentType" : {"label" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_AC+'","value" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_AC+'","$$hashKey" : "009"},"portalContentTypes" :[{"label" : "--None--","value" : "--None--","$$hashKey" : "005"},{"label" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_GV+'","value" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_GV+'","$$hashKey" : "006"},{"label" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_PV+'","value" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_PV+'","$$hashKey" : "007"},{"label" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_DL+'","value" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_DL+'","$$hashKey" : "008"},{"label" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_AC+'","value" : "'+COMM_Constants.TEST_PORTAL_COMPETENCY_AC+'","$$hashKey" : "009"}],"stepToReproduce" : "test","emailBody" : "test test body"}');
            Test.stopTest();

        }

    }
}