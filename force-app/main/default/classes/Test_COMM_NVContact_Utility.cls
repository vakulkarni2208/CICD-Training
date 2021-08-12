/*
    Test class for COMM_NVContact_Utility
    
    2017.07.18 - Country/State picklist rollout changes
 */
@isTest(SeeAllData=false)
private class Test_COMM_NVContact_Utility {
    
    static testMethod void testPutAllNVIDIACONTACTDetail() {
    
        string SP_PROVIOZ_PREF = 'SP Tesla Preferred';
        string OEM_AC_PREF = 'OEM Tesla Preferred';
        string PORTAL_GROUP = 'SP Tesla Preferred;OEM Tesla Preferred';

        set<string> setContactUserPortalGroups = new set<string>{SP_PROVIOZ_PREF,OEM_AC_PREF};
        //list<COMM_NVContact_Utility.NVIDIAContactsProductWiseWrapper> lstNVIDIAContactsProductWiseWrapper = new list<COMM_NVContact_Utility.NVIDIAContactsProductWiseWrapper>();

        //get All Profiles
        list<string> lstProfNames = new list<string>{COMM_Constants.PROF_PP_VGX_GENERIC, COMM_Constants.PROF_INT_PARTNER_ADMIN};
        map<string, Id> mapProfNameId = Test_COMM_Factory.getProfsByName(lstProfNames);

        //get all Record Types
        list<string> lstSObjects = new list<string>{'Account', 'Contact'};
        map<String, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);

        //declare the Account and Contact variable so it is visible down below
        Account partnerAcc;
        Contact partnerContact;

        //Create a Partner Account with Billing Country

        partnerAcc = Test_COMM_Factory.createAccountWithBillingAddress('NVPartnerAccount1', mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NV_PPA), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );

        //partnerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('NVPartnerAccount1', mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NV_PPA));
        system.debug('***partnerAcc: ' + partnerAcc);

        //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
        partnerAcc.IsPartner = true;
        partnerAcc.NPN_Program_Signed_Date__c = date.today();
        update partnerAcc;

        //Create a Partner Contact 
        partnerContact = Test_COMM_Factory.createContactWithMailingAddress('NVLJena1', 'FContact', partnerAcc.Id, 'nvcontactjena1@nv.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        partnerContact.Portal_Groups__c = PORTAL_GROUP;
        update partnerContact;

        //Create a Partner User with profile named 'GRID VGX Partner Portal Profile(Generic)'
        User partnerUser = Test_COMM_Factory.createUser(partnerContact.Id, mapProfNameId.get(COMM_Constants.PROF_PP_VGX_GENERIC));
            
        //fill the NV COntacts related Custom Settings
        //Test_COMM_Factory.set_NV_Permissions_and_PCL_Mapping();

        list<NV_Permissions_and_PCL_Mapping__c> lstNVContactsSettings = new list<NV_Permissions_and_PCL_Mapping__c>();

        NV_Permissions_and_PCL_Mapping__c NVContactsSettings = new NV_Permissions_and_PCL_Mapping__c();
        NVContactsSettings.name = 'SP Tesla Preferred';
        NVContactsSettings.Program_Name__c = 'Solution Provider';
        NVContactsSettings.Competency__c = 'Tesla';
        NVContactsSettings.Level__c = 'Preferred';
        NVContactsSettings.Combination__c = 'SP Tesla Preferred';
        lstNVContactsSettings.add(NVContactsSettings);

        NV_Permissions_and_PCL_Mapping__c NVContactsSettings2 = new NV_Permissions_and_PCL_Mapping__c();
        NVContactsSettings2.name = 'OEM Tesla Preferred';
        NVContactsSettings2.Program_Name__c = 'OEM';
        NVContactsSettings2.Competency__c = 'Tesla';
        NVContactsSettings2.Level__c = 'Preferred';
        NVContactsSettings2.Combination__c = 'OEM Tesla Preferred';
        lstNVContactsSettings.add(NVContactsSettings2);

        insert lstNVContactsSettings;


        //Fill the NV Contacts records
        list<User> lstSalesManager = Test_COMM_Factory.createUsers(2, mapProfNameId.get(COMM_Constants.PROF_INT_PARTNER_ADMIN));

        //Test_COMM_Factory.set_NVContacts(lstSalesManager[0].Id, lstSalesManager[1].Id);

        list<NV_Contacts__c> lstNVContacts = new list<NV_Contacts__c>();

        NV_Contacts__c NVContact = new NV_Contacts__c();
        NVContact.Name = 'Tesal US One';
        NVContact.Program_Type__c = 'Solution Provider';
        NVContact.Product_Line__c = 'Tesla';
        NVContact.Billing_Country__c = 'United States';
        //NVContact.US_States__c = '';
        //NVContact.Region__c = '';
        //NVContact.Sub_Region__c = '';
        NVContact.Account_Owner_Name__c = lstSalesManager[0].Id;
        NVContact.Sales_Manager_Name__c = lstSalesManager[1].Id;
        NVContact.Sales_Title__c = 'Sales Manager';
        NVContact.Sales_Manager_Email__c = 'salesmanagerproviz@nvidia.com';
        NVContact.Sales_Manager_Contact_Number__c = '5555555555';
        lstNVContacts.add(NVContact);

        NVContact = new NV_Contacts__c();
        NVContact.Name = 'Tesla US Two';
        NVContact.Program_Type__c = 'Solution Provider';
        NVContact.Product_Line__c = 'Tesla';
        NVContact.Billing_Country__c = 'United States';
        //NVContact.US_States__c = '';
        //NVContact.Region__c = '';
        //NVContact.Sub_Region__c = '';
        NVContact.Account_Owner_Name__c = lstSalesManager[0].Id;
        NVContact.Sales_Manager_Name__c = lstSalesManager[1].Id;
        NVContact.Sales_Title__c = 'Sales Manager';
        NVContact.Sales_Manager_Email__c = 'salesmanagerac@nvidia.com';
        NVContact.Sales_Manager_Contact_Number__c = '5555555555';
        lstNVContacts.add(NVContact);

        insert lstNVContacts;
        
        //Run as the Portal User
        Test.startTest();

        system.runAs(partnerUser){
            //Get hold of the Partner Portal Home page
            //---------------------------------------------------------
            PageReference pageRef = new PageReference('/apex/vfPartnerPortalHome');
            Test.setCurrentPage(pageRef);
            
            //custom contorller
            clsPartnerPortalHome ctlrPPHome = new clsPartnerPortalHome(); 
            
            set<string> contentTypes = new set<string>();
            list<NV_Permissions_and_PCL_Mapping__c> lstNV_Permissions_and_PCL_Mapping = NV_Permissions_and_PCL_Mapping__c.getall().values();
            for(NV_Permissions_and_PCL_Mapping__c objNV_Permissions_and_PCL_Mapping : lstNV_Permissions_and_PCL_Mapping) {
                if(setContactUserPortalGroups.contains(objNV_Permissions_and_PCL_Mapping.combination__c)) {
                    string strProgramNameCompetencyType = objNV_Permissions_and_PCL_Mapping.Program_Name__c + objNV_Permissions_and_PCL_Mapping.Competency__c;
                    contentTypes.add(strProgramNameCompetencyType);
                }
            }
            
            
            Contact contactDetail = [   Select FirstName, LastName, Email, Phone, MobilePhone, Portal_User_Content_Type__c, Portal_Groups__c, Account.name, Account.Owner.Name, Account.Owner.email,
                                        Account.Owner.Phone,Account.BillingCountry, Account.BillingState, Account.Billing_Region__c,Account.Billing_Sub_Region__c
                                    From Contact 
                                    Where Id =:partnerContact.Id];
                                    
                                    
            system.debug('*** contactDetail:: '+ contactDetail);
            system.debug('*** contentTypes:: '+ contentTypes);
                                    
            list<COMM_NVContact_Utility.NVIDIAContactsProductWiseWrapper> lstNVIDIAContactsProductWiseWrapper = COMM_NVContact_Utility.putAllNVIDIACONTACTDetail(contactDetail, contentTypes);

        }
        Test.stopTest();
    }

}