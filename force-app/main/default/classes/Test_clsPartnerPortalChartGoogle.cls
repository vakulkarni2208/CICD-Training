/*
    Test class for clsPartnerPortalChartGoogle.cls
    
    Change List:
    2016.12.14 - Opp Registration TAM - interim change - This class was breaking so retrofitted with account, opportunity creation from Test_COMM_Factory class
    2021.04.15  - Test class optimization
    
*/

@isTest(seeAllData=false)
private class Test_clsPartnerPortalChartGoogle {
    
    @TestSetup
    static void makeData(){
        NV_NPN_TestDataFactory.setupCustomSettings();
    }

    static User createData() {
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
        User u = createData();
        
        u = [SELECT Id, ContactId, Contact.AccountId, accountId,Profile.Name,Profile.Id from User where id=:u.id];
        
                
        //Account acct = new Account(Name='Test Account');
        //insert acct;
        //Create a Partner Account with Billing Country
        list<string> lstSObjects = new list<string>{'Account', 'Opportunity'};
        map<String, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);
    
        Account acct = Test_COMM_Factory.createAccountWithBillingAddress('PartnerAccount1', mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NV_PPA), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        system.debug('***partnerAcc: ' + acct);
        
        //Map<String, Id> myRTMap = Utils.GetAllRecordTypeIdsByName();
    
        Opportunity opp = new Opportunity(
            AccountId=acct.Id, 
            Name = 'The Opp', 
            StageName = COMM_Constants.OPPTY_STAGE_PROSPECTING, 
            CloseDate=System.today(), 
            LeadSource='the street',
            RecordTypeId = mapRTNameId.get(COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY), 
            Design_Start_Date__c = System.today().addMonths(1), 
            Design_EOL_Date__c = System.today().addMonths(2));
        insert opp;
        
        
        Lead lead = new Lead();
        lead.Status = 'Qualified';
        lead.LastName = 'Last Name';
        lead.FirstName = 'First Name';
        lead.Company = 'Company name';
        insert lead;
       
        
        System.runAs(u){
            clsPartnerPortalChartGoogle obj = new clsPartnerPortalChartGoogle();

            clsPartnerPortalChartGoogle.loadOpportunitiesByOwner();
            clsPartnerPortalChartGoogle.loadOpportunitiesByStage();
            clsPartnerPortalChartGoogle.loadLeadsByOwner();
            clsPartnerPortalChartGoogle.loadLeadsByStatus();
        }
    }
}