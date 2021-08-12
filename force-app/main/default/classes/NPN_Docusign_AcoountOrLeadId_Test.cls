@isTest(seeAllData=false)
private class NPN_Docusign_AcoountOrLeadId_Test {

    @isTest static void testNPNKeyContactTest(){
        
        genericMock fakeResp = new genericMock(200,'Complete',
           '<?xml version="1.0" encoding="UTF-8"?>'+
           '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/>'+
           '<soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com">'+
           '<ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage>'+
           '</ax21:errorMessage><ax21:statusCode>success</ax21:statusCode>'+
           '<ax21:syncType>PartnerUser</ax21:syncType></ns:return>'+
           '</ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);

        System.Test.setMock(HttpCalloutMock.class, fakeResp);
        
        NV_NPN_TestDataFactory.setupCustomSettings();

        map<String, Id> mapProfNameId;
        Account partnerAcc;
        Contact partnerContact1;
        User partnerUser1;
        Id accRecTypeId;
        Id contactRecTypeId;
        String userName;

        accRecTypeId     = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();
        contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();

        //get All Profiles (PROF_PP_VGX_GENERIC = NPN Partner Community(LOGIN), PROF_INT_PARTNER_ADMIN = Sales Profile - Partner Admin)
        list<string> lstProfNames = new list<string> {COMM_Constants.PROF_PP_VGX_GENERIC, COMM_Constants.PROF_INT_PARTNER_ADMIN };
        mapProfNameId = Test_COMM_Factory.getProfsByName(lstProfNames);

        //Create a NPN Account with Billing Country, Region
        partnerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('DRNPNAccountRegistry1', accRecTypeId);
        system.debug('***partnerAcc: ' + partnerAcc);


        //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
        partnerAcc.IsPartner = true;
        update partnerAcc;

        //Create a Partner Contact
        partnerContact1 = Test_COMM_Factory.createContactWithMailingAddress('LDRJena11', 'FContact11', partnerAcc.Id, 'drcontactjena11@nv.com', contactRecTypeId, COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );

        List<NPN_PartnerAttributes_Modifiaction__c> listPAMObj = new List<NPN_PartnerAttributes_Modifiaction__c>();

        NPN_PartnerAttributes_Modifiaction__c pamObj1 = new NPN_PartnerAttributes_Modifiaction__c(

            PartnerAttributes_Modification__c = 'Add On Contracts Packet',
            Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_GV+';'+COMM_Constants.TEST_PORTAL_COMPETENCY_PV+';'+COMM_Constants.TEST_PORTAL_COMPETENCY_DL,
            Competency_Level__c = COMM_Constants.PA_LEVEL_PREF,
            Sync__c = false,
            CSP_Yes_No__c = false,
            Account__c = partnerAcc.Id,
            Program_Type__c = COMM_Constants.PA_PROGRAM_SP,
            Termination_Initiated__c = false,
            Competency_Termination_30_days_Complete__c = false,
            Contact__c = partnerContact1.Id,
            DocuSign_Envelope_ID__c = '457BCA2E-DA5E-4064-B1B5-F9E6B8690A9C'
            );
        listPAMObj.add(pamObj1);

        insert listPAMObj;

        NPN_Key_Contact__c nkcObj = new NPN_Key_Contact__c(
            Name = 'Adam Riffle',
            //Account__c = partnerAcc.Id,
            AccountOrLead_ID__c = listPAMObj[0].Id,
            Job_Role__c = 'Sales',
            Email__c = 'adam.riffle@whitehatvirtual.com.invalid',
            Leads_and_Opportunities__c = false,
            Sales_Training__c = false,
            Technical_Training__c = false,
            synced__c = false);
        insert nkcObj;
    }
}