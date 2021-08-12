@isTest(seeAllData=false)
private class NV_Test_PartnerCommunityTabs {


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
            PermissionSet ps = new PermissionSet();
            partnerUser = Test_COMM_Factory.createUserWithEmail(partnerContact.Id, partnerContact.email, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC));
            ps.label = 'Campaigns Permission Box';
            ps.name = 'Campaigns_Permission_Box';
            insert ps;
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = partnerUser.id;
            psa.PermissionSetId = ps.id;
            insert psa;
        }
        return partnerUser;
    }

    static testMethod void myUnitTest() {

        NV_NPN_TestDataFactory.setupCustomSettings();
        
        genericMock fakeResp = new genericMock(200,'Complete',
           '<?xml version="1.0" encoding="UTF-8"?>'+
           '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/>'+
           '<soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com">'+
           '<ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage>'+
           '</ax21:errorMessage><ax21:statusCode>success</ax21:statusCode>'+
           '<ax21:syncType>PartnerUser</ax21:syncType></ns:return>'+
           '</ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);

        System.Test.setMock(HttpCalloutMock.class, fakeResp);

        ApexPages.CurrentPage().getParameters().put('tab','Sales');
        GRID_VCA_Instant_Message__c objGridVCAMsg = new GRID_VCA_Instant_Message__c();
        objGridVCAMsg.Start_Date__c = System.today();
        objGridVCAMsg.Expiration_Date__c = System.today() + 2;
        objGridVCAMsg.Message__c = 'Hello World';
        insert objGridVCAMsg;

        Partner_Portal__c objPartnerPortal = new Partner_Portal__c();
        objPartnerPortal.Name = 'GRID_VCA_Partner Portal';
        objPartnerPortal.Login_URL__c = 'https://cs12.salesforce.com/secur/login_portal.jsp?orgId=00DV000000054qp&portalId=06040000000D7uX';
        insert objPartnerPortal;

        //   Partner_Portal_Tab__c objPartnerPortalTab = new Partner_Portal_Tab__c();
        // objPartnerPortalTab.Name = 'Sales';
        //   objPartnerPortalTab.Tab_URL__c = 'http:///apex/GRID_portalSales1?tab=Sales';
        //   objPartnerPortalTab.Partner_Profiles__c = 'GRID_VCA_Marketing; GRID_VCA_Sales; GRID_VCA_Manager';
        // objPartnerPortalTab.Sort_Order__c = 1;
        //objPartnerPortalTab.Partner_PortalName__c = objPartnerPortal.Id;
        //insert objPartnerPortalTab;

        User u = createData();
        u = [select id,contactId,contact.accountId, accountId,Profile.Name,Profile.Id from User where id=:u.id];
        GRID_Portal_Profiles__c objGRID_Portal_Profile = new GRID_Portal_Profiles__c();
        objGRID_Portal_Profile.Name = [select Id,Profile.Name from User where Id=:UserInfo.getUserId()].Profile.Name;
        insert objGRID_Portal_Profile;


        Portal_Permission_Sets__c objPortalPermissionSet = new Portal_Permission_Sets__c();
        objPortalPermissionSet.Name = 'Campaigns_Permission_Box';
        insert objPortalPermissionSet;
        Portal_Permission_Sets__c objPortalPermissionSet1 = new Portal_Permission_Sets__c();
        objPortalPermissionSet1.Name = 'Product_Information_Permission_Box';
        insert objPortalPermissionSet1;

        Portal_Home_Page_Box__c objPortal_Home_Page_Box = new Portal_Home_Page_Box__c();
        objPortal_Home_Page_Box.Name = 'REPORT A PROBLEM BUTTON';
        objPortal_Home_Page_Box.Box_Serial_Number__c = 2;
        objPortal_Home_Page_Box.Portal_Permission_Set__c = objPortalPermissionSet1.Id;
        insert objPortal_Home_Page_Box;


        Partner_Portal_Label__c objPartnerPortalLabels = new Partner_Portal_Label__c();
        objPartnerPortalLabels.Name = 'Product Information';
        //   objPartnerPortalLabels.Partner_Portal_Tab__c =  objPartnerPortalTab.Id;
        objPartnerPortalLabels.Label_Serial_Number__c = 1;
        objPartnerPortalLabels.Display_Bullet__c  = true;
        objPartnerPortalLabels.Permission_Set__c  = objPortalPermissionSet.Id;
        objPartnerPortalLabels.GRID_Portal_Profile__c = objGRID_Portal_Profile.Id;
        objPartnerPortalLabels.Portal_Tab__c  = 'Home; Sales; Marketing; Training; Support; News';
        objPartnerPortalLabels.Portal_Content_Type__c  = ''+COMM_Constants.TEST_PORTAL_COMPETENCY_AC+'';
        insert objPartnerPortalLabels;

        Partner_Portal_Links__c objPartner_Portal_Links = new Partner_Portal_Links__c();
        objPartner_Portal_Links.Partner_Portal_Label__c = objPartnerPortalLabels.Id;
        objPartner_Portal_Links.Link_Serial_Number__c = 1;
        objPartner_Portal_Links.Name = 'Specifications';
        objPartner_Portal_Links.Display_Page__c = 'Open in a New Tab';
        objPartner_Portal_Links.URL__c  = 'http://www.google.co.in/';
        objPartner_Portal_Links.Portal_Link_Name__c = 'Specifications';
        insert objPartner_Portal_Links;

        Partner_Portal_Links__c objPartner_Portal_Links1 = new Partner_Portal_Links__c();
        objPartner_Portal_Links1.Partner_Portal_Label__c = objPartnerPortalLabels.Id;
        objPartner_Portal_Links1.Link_Serial_Number__c = 2;
        objPartner_Portal_Links1.Name = 'Specifications';
        objPartner_Portal_Links1.Display_Page__c = 'Open in a New Tab';
        objPartner_Portal_Links1.URL__c  = 'http://www.google.co.in/';
        objPartner_Portal_Links1.Portal_Link_Name__c = 'Specifications';
        insert objPartner_Portal_Links1;

        Partner_Portal_Label__c objPartnerPortalLabels1 = new Partner_Portal_Label__c();
        objPartnerPortalLabels1.Name = 'Competitive Info';
        //    objPartnerPortalLabels1.Partner_Portal_Tab__c =  objPartnerPortalTab.Id;
        objPartnerPortalLabels1.Label_Serial_Number__c = 2;
        objPartnerPortalLabels1.Permission_Set__c  = objPortalPermissionSet1.Id;
        objPartnerPortalLabels1.Display_Bullet__c  = true;

        objPartnerPortalLabels1.GRID_Portal_Profile__c = objGRID_Portal_Profile.Id;
        insert objPartnerPortalLabels1;

        Partner_Portal_Links__c objPartner_Portal_Links2 = new Partner_Portal_Links__c();
        objPartner_Portal_Links2.Partner_Portal_Label__c = objPartnerPortalLabels1.Id;
        objPartner_Portal_Links2.Link_Serial_Number__c = 1;
        objPartner_Portal_Links2.Name = 'Specifications';
        objPartner_Portal_Links2.Display_Page__c = 'Open in a New Tab';
        objPartner_Portal_Links2.URL__c  = 'http://www.google.co.in/';
        objPartner_Portal_Links2.Portal_Link_Name__c = 'Specifications';
        insert objPartner_Portal_Links2;


        Partner_Portal_Label__c objPartnerPortalLabels2 = new Partner_Portal_Label__c();
        objPartnerPortalLabels2.Name = 'Case Studies';
        //    objPartnerPortalLabels2.Partner_Portal_Tab__c =  objPartnerPortalTab.Id;
        objPartnerPortalLabels2.Label_Serial_Number__c = 3;
        objPartnerPortalLabels2.Display_Bullet__c  = true;
        objPartnerPortalLabels2.Portal_Tab__c  = 'Home; Sales; Marketing; Training; Support; News';
        objPartnerPortalLabels2.GRID_Portal_Profile__c = objGRID_Portal_Profile.Id;
        objPartnerPortalLabels2.Permission_Set__c = objPortalPermissionSet1.Id;
        insert objPartnerPortalLabels2;

        Partner_Portal_Links__c objPartner_Portal_Links3 = new Partner_Portal_Links__c();
        objPartner_Portal_Links3.Partner_Portal_Label__c = objPartnerPortalLabels2.Id;
        objPartner_Portal_Links3.Link_Serial_Number__c = 1;
        objPartner_Portal_Links3.Name = 'Specifications';
        objPartner_Portal_Links3.Display_Page__c = 'Open in a New Tab';
        objPartner_Portal_Links3.URL__c  = 'http://www.google.co.in/';
        objPartner_Portal_Links3.Portal_Link_Name__c = 'Specifications';
        insert objPartner_Portal_Links3;



        /* NV_PartnerCommunityTabs.wrapperData wrapData = new clsPartnerPortalTabs.wrapperData();
           clsPartnerPortalTabs.wrapper wrap = new clsPartnerPortalTabs.wrapper();
           List<clsPartnerPortalTabs.wrapper> lstWrap = new List<clsPartnerPortalTabs.wrapper>();
           lstWrap.add(wrap);
           clsPartnerPortalTabs.CustomWrap customWrap = new clsPartnerPortalTabs.CustomWrap(lstWrap);
         *///try{
        //User u = [select id from User where isActive=true and userName=:Label.PortalUserName   limit 1];  //
        System.runAs(u){
            NV_PartnerCommunityTabs obj = new NV_PartnerCommunityTabs();
            //obj.showPopup();
            //obj.email = 'test@salesforce.com';
            //obj.phoneNumber = '9876543210'  ;
            //obj.Attach = blob.valueOf('abc');
            NV_PartnerCommunityTabs.sendEmail('{"contact":{"FirstName":"Test","AccountName":"Partner 1 Test Account","Email":"vakulkarni@nvidia.com","Phone":"1234432123","MobilePhone":"","Id":"'+u.contactId+'","AccountId":"'+u.accountId+'"},"problemType":"test","problemDescription":"test","stepsToReproduce":"","selectedContentType":{"label":"'+COMM_Constants.TEST_PORTAL_COMPETENCY_AC+'","value":"'+COMM_Constants.TEST_PORTAL_COMPETENCY_AC+'","$$hashKey":"006"},"portalContentTypes":[{"label":"--None--","value":"--None--","$$hashKey":"005"},{"label":"'+COMM_Constants.TEST_PORTAL_COMPETENCY_AC+'","value":"'+COMM_Constants.TEST_PORTAL_COMPETENCY_AC+'","$$hashKey":"006"},{"label":"'+COMM_Constants.TEST_PORTAL_COMPETENCY_GV+'","value":"'+COMM_Constants.TEST_PORTAL_COMPETENCY_GV+'","$$hashKey":"007"},{"label":"'+COMM_Constants.TEST_PORTAL_COMPETENCY_DL+'","value":"'+COMM_Constants.TEST_PORTAL_COMPETENCY_DL+'","$$hashKey":"008"},{"label":"'+COMM_Constants.TEST_PORTAL_COMPETENCY_PV+'","value":"'+COMM_Constants.TEST_PORTAL_COMPETENCY_PV+'","$$hashKey":"009"}],"stepToReproduce":"test"}');
            //pageReference pg = obj.closePopup();
            obj.insertCustomSettings();
            obj.selectContentType();
        }
        //}Catch(Exception ee){

        //}
    }
}