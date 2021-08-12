/*
    2017.11.29 - PJENA - Deal Registration - Test Class for DR_CreateDR_cls
    2018.07.20 - PJENA - SDS-587 (All NALA deal registrations to route to Anish Dave instead of following the Territory Alignment logic)
 */
 
@isTest(SeeAllData=false)
private class Test_DR_CreateDR_cls {

    
    private static map<string, Country_List__c> mapCountryList{get;set;}
    private static map<string, Id> mapProfNameId{get;set;}
    private static map<string, Id> mapRTNameId{get;set;}
    private static Account partnerAcc{get;set;}
    private static Contact partnerContact1{get;set;}
    private static Contact partnerContact2{get;set;}
    private static User partnerUser1{get;set;}

    static testMethod void testSaveDR() {
        genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);        
        System.Test.setMock(HttpCalloutMock.class, fakeResp);
        
        //Create infrastructure - to allow parnters to create a deal reg record
        //---------------------------------------------------------------------------
        createDRInfrastructure();
        //End: Create infrastructure - to allow parnters to create a deal reg record
        //---------------------------------------------------------------------------
        
        partnerContact2 = [Select Email From Contact Where Id = :partnerContact2.Id];
        
        Lead oDRLead;
        
        Test.startTest();
            system.runAs(partnerUser1){
                oDRLead = new Lead(Company = 'DRCustomerOne', Street = COMM_Constants.ADDRESS_STREET, City = COMM_Constants.ADDRESS_CITY, State = COMM_Constants.ADDRESS_STATE,  Country = COMM_Constants.ADDRESS_COUNTRY, 
                                    CountryCode= COMM_Constants.ADDRESS_US_ISO2, PostalCode = COMM_Constants.ADDRESS_ZIP, 
                                    FirstName = 'DRCustUsrFName1', LastName = 'DRCustUsrLName1', Title = 'CEO', Email = 'drf1l1cust1@customerone.com', Phone = '555-555-5555', Industry = 'Other', RecordTypeId = mapRTNameId.get(DR_Settings__c.getOrgDefaults().Lead_RecordTypeName_For_Deal_Reg__c),
                                    DR_Additional_Team_Member_Email__c = partnerContact2.Email);
                
                PageReference prDRCreateDR = new PageReference('/apex/DR_CreateDR');
                Test.setCurrentPage(prDRCreateDR);
                
                DR_CreateDR_cls ctlr = new DR_CreateDR_cls();
                ctlr.oDealReg = oDRLead;
                PageReference prSave = ctlr.saveDR();
                system.debug('***ctlr.oDealReg: ' + ctlr.oDealReg);
            }
        Test.stopTest();
    }
    
   
    static testMethod void testCancelDR() {
        Test.startTest();
            DR_CreateDR_cls ctlr = new DR_CreateDR_cls();
            PageReference prSave = ctlr.cancelDR();
        Test.stopTest();
    }
    
    
    
    private static void createDRInfrastructure(){
        //Create Country List record
        list<Country_List__c> lstCountry = new list<Country_List__c>();
        Country_List__c countryUS = new Country_List__c(name = COMM_Constants.ADDRESS_COUNTRY, ISO_Code__c = COMM_Constants.ADDRESS_US_ISO2, ISO_Code_3__c=COMM_Constants.ADDRESS_US_ISO3, Region__c = COMM_Constants.ADDRESS_REGION_NALA, Sub_Region__c = COMM_Constants.ADDRESS_SUBREGION_LA, Territory__c = COMM_Constants.ADDRESS_TERRITORY_LA); 
        lstCountry.add(countryUS);
        mapCountryList = Test_COMM_Factory.setCountryList(lstCountry);
        
        //Sets DR : Settings data - Deal Reg related setCSDRSettingsData
        //create custom settings for Deal data
        Test_COMM_Factory.setCSDRSettingsData();
        
        
        //get All Profiles (PROF_PP_VGX_GENERIC = NPN Partner Community(LOGIN), PROF_INT_PARTNER_ADMIN = Sales Profile - Partner Admin)
        list<string> lstProfNames = new list<string>{COMM_Constants.PROF_PP_VGX_GENERIC, COMM_Constants.PROF_INT_PARTNER_ADMIN };
        mapProfNameId = Test_COMM_Factory.getProfsByName(lstProfNames);
        
        //get all Record Types
        list<string> lstSObjects = new list<string>{'Account', 'Contact', 'Lead'};
        mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);
        
        //declare the Account and Contact variable so it is visible down below
        
        
        //Create a NPN Account with Billing Country, Region
        partnerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('DRNPNAccountRegistry1', mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY));
        system.debug('***partnerAcc: ' + partnerAcc);
        
        //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
        partnerAcc.IsPartner = true;
        update partnerAcc;
        
        //Create a Partner Contact 
        partnerContact1 = Test_COMM_Factory.createContactWithMailingAddress('LDRJena1', 'FContact1', partnerAcc.Id, 'drcontactjena1@nv.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        partnerContact2 = Test_COMM_Factory.createContactWithMailingAddress('LDRJena2', 'FContact2', partnerAcc.Id, 'drcontactjena2@nv.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        
        //Create a Partner User with profile named 'GRID VGX Partner Portal Profile(Generic)'
        partnerUser1 = Test_COMM_Factory.createUser(partnerContact1.Id, mapProfNameId.get(COMM_Constants.PROF_PP_VGX_GENERIC));
        
        //get hold of the logged on user to flip the context to avoid the MIXD DML issue
        list<User> lstInternalUsersWithPAProf;
        User self = [Select Id From User where id = :UserInfo.getUserId()];
        system.runAs(self){
            //Create Internal User with Partner Admin profile
            lstInternalUsersWithPAProf = Test_COMM_Factory.createUsers(1, mapProfNameId.get(COMM_Constants.PROF_INT_PARTNER_ADMIN));
        }
        
        //create custom setting for Sales Ops Admin: svcDeploy or current user is the SalesOps Admin for both United States and Others
        Test_COMM_Factory.setDRSalesOpsAdmin(lstInternalUsersWithPAProf[0].Username);
    }
}