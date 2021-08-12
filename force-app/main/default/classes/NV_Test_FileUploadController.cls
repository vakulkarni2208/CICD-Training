@isTest(SeeAllData=false)
private class NV_Test_FileUploadController{

    private static map<string, Country_List__c> mapCountryList{get;set;}
    private static map<string, Id> mapProfNameId{get;set;}
    private static map<string, Id> mapRTNameId{get;set;}
    private static Account partnerAcc{get;set;}
    private static Contact partnerContact1{get;set;}
    private static Contact partnerContact2{get;set;}
    private static User partnerUser1{get;set;}
    
    static testMethod void myUnitTest() {
        //Create infrastructure - to allow parnters to create a deal reg record
      //---------------------------------------------------------------------------
        createDRInfrastructure();
        partnerContact1 = [Select Email,accountId From Contact Where Id = :partnerContact1.Id];
      
        Lead oDRLead;
        genericMock fakeResp = new genericMock(200,  'Complete', '{"StatusCode": "200","Status": "Success","Message": "Success : Found Records","Data": {"Type": "NPN Account Registry","Name": "Solution Advisor J1","Id": "001n000000Sozo4AAB"}}',null);
        
        System.Test.setMock(HttpCalloutMock.class, fakeResp);
        Test.startTest();

        system.runAs(partnerUser1){
            NV_FileUploadController objNVFC = new NV_FileUploadController();
            String attachmentID = NV_FileUploadController.attachBlob(partnerContact1.accountId, null, 'test.xlsx', 'application/vnd.ms-excel', EncodingUtil.base64Encode(Blob.valueOf('test')));
            NV_FileUploadController.sendEmail(attachmentID, 'April', '2018', 'REP','test notes','TIX', 'Standard','Initial','File Rejected','APAC');
            String attachmentID1 = NV_FileUploadController.attachBlob(partnerContact1.accountId, null, 'test.xlsx', 'application/vnd.ms-excel', EncodingUtil.base64Encode(Blob.valueOf('test')));
            NV_FileUploadController.sendEmail(attachmentID1, 'April', '2018', 'REP','test notes','TIX', 'Standard','Revision','File Rejected','APAC');
            //Code Coverage for MonthlyPOSTrigger
            List<Monthly_POS__c> mPosList = [Select Id, Status__c from Monthly_POS__c LIMIT 1];
            for(Monthly_POS__c mpos: mPosList) {
                mpos.Status__c = 'Approved';
            }
            update mPosList;
        }
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
        partnerContact1 = Test_COMM_Factory.createContactWithMailingAddress('LDRJena11', 'FContact11', partnerAcc.Id, 'drcontactjena11@nv.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        partnerContact2 = Test_COMM_Factory.createContactWithMailingAddress('LDRJena22', 'FContact22', partnerAcc.Id, 'drcontactjena22@nv.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        
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