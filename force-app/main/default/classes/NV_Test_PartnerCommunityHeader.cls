/**
 *  @description    :   Test class for NV_PartnerCommunityHeader
 */
@isTest(seeAllData=false)
private class NV_Test_PartnerCommunityHeader {

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
            partnerUser = Test_COMM_Factory.createUserWithEmail(partnerContact.Id, partnerContact.email, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC));
            PermissionSet ps = new PermissionSet();
            ps.label = 'PP : COMM: HOME TAB';
            ps.name = 'PP_COMM_HOMME_TAB';
            insert ps;
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = partnerUser.id;
            psa.PermissionSetId = ps.id;
            insert psa;
        }
        return partnerUser;
    }


    static testMethod void myUnitTest() {

        User u = createData();
        u = [select id,accountId, contactId, Profile.Name, Profile.Id from User where id=:u.id limit 1];
        GRID_Portal_Profiles__c obj1 = new GRID_Portal_Profiles__c();
        obj1.Name = u.Profile.Name;
        insert obj1;


        Partner_Portal__c objPartnerPortal = new Partner_Portal__c();
        objPartnerPortal.Name = COMM_Constants.PP_GRID_VCA_NAME;
        objPartnerPortal.Login_URL__c = 'https://cs12.salesforce.com/secur/login_portal.jsp?orgId=00DV000000054qp&portalId=06040000000D7uX';
        insert objPartnerPortal;

        Portal_Permission_Sets__c objPortalPermissionSet = new Portal_Permission_Sets__c();
        objPortalPermissionSet.Name = 'PP_COMM_HOMME_TAB';
        insert objPortalPermissionSet;

        Partner_Portal_Tab__c objPartnerPortalTab = new Partner_Portal_Tab__c();
        objPartnerPortalTab.Name = 'Sales';
        objPartnerPortalTab.Tab_URL__c = 'http:///apex/GRID_portalSales1?tab=Sales';
        objPartnerPortalTab.Partner_Profiles__c = 'GRID_VCA_Marketing; GRID_VCA_Sales; GRID_VCA_Manager';
        objPartnerPortalTab.Sort_Order__c = 1;
        objPartnerPortalTab.Partner_PortalName__c = objPartnerPortal.Id;
        objPartnerPortalTab.Permission_Set__c = objPortalPermissionSet.Id;
        insert objPartnerPortalTab;

        System.runAs(u){
            NV_PartnerCommunityHeader.PPTabWrapper objppTabWrapper = new NV_PartnerCommunityHeader.PPTabWrapper();
            ApexPages.currentPage().getHeaders().put('Referer','https://c.cs12.visual.force.com/apex/portalNewsPage?tab=Sales');
            NV_PartnerCommunityHeader obj = new NV_PartnerCommunityHeader();
            /*Portal_Content_Type__c objCustomSetting = new Portal_Content_Type__c();
               objCustomSetting.Name = UserInfo.getUserId();
               objCustomSetting.Content_Type__c= 'VCA123';
               insert objCustomSetting;*/
            obj.deleteCustomSettingBeforeLogOut();
            obj.home();
        }

    }

    static testMethod void COMMUtilityTest() {
        COMM_Utility.Community_User_Local_Settings_Wrapper obj = new COMM_Utility.Community_User_Local_Settings_Wrapper('','','','','','','','',false);
        COMM_Utility.Community_User_Local_Settings_Wrapper obj1 = new COMM_Utility.Community_User_Local_Settings_Wrapper('','','','','','','','');
    }
}