@isTest(seeAllData=false)
private class NPN_PAMHelper_Test {


    static void makeData(){     
        
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

        //Create a Partner User with profile named 'NPN Partner Community(LOGIN)'
        User comUser = new User(
            LastName='one',
            Alias = 'tsale',
            Email = 'nvpartnerone@foo.com',
            Username = 'nvvippartnerone@foo.com.crqext',
            CommunityNickname = 'nvvippartnerone',
            ProfileId = mapProfNameId.get(COMM_Constants.PROF_PP_VGX_GENERIC),
            ContactId=partnerContact1.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
            );
        insert comUser;

        NPN_PartnerAttributes_Modifiaction__c pamObj = new NPN_PartnerAttributes_Modifiaction__c(

            PartnerAttributes_Modification__c = 'Add On Contracts Packet', // PartnerAttributes_Modification
            Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_GV+';'+COMM_Constants.TEST_PORTAL_COMPETENCY_PV+';'+COMM_Constants.TEST_PORTAL_COMPETENCY_DL,         // Competency
            Competency_Level__c = COMM_Constants.PA_LEVEL_PREF,           // Competency_Level
            Sync__c = true,                              // Sync
            CSP_Yes_No__c = false,                       // Does the CSP sell to other CSPs
            Account__c = partnerAcc.Id,              // Account
            //DocuSign_Envelope_ID__c = '457BCA2E-DA5E-4064-B1B5-F9E6B8690A9C', // DocuSign Envelope ID
            Program_Type__c = COMM_Constants.PA_PROGRAM_SP,       // Program Type
            Termination_Initiated__c = false,            // Termination Initiated
            Competency_Termination_30_days_Complete__c = false, // Competency Termination 30 days Complete
            Contact__c = partnerContact1.Id              // Partner Contact
            );
        insert pamObj;


    }


    @isTest static void testLinkDocuSignStatusMethod(){
        
        genericMock fakeResp = new genericMock(200,'Complete',
           '<?xml version="1.0" encoding="UTF-8"?>'+
           '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/>'+
           '<soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com">'+
           '<ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage>'+
           '</ax21:errorMessage><ax21:statusCode>success</ax21:statusCode>'+
           '<ax21:syncType>PartnerUser</ax21:syncType></ns:return>'+
           '</ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);

        System.Test.setMock(HttpCalloutMock.class, fakeResp);
        
        makeData();
        
        List<NPN_PartnerAttributes_Modifiaction__c> pamObjForUpdate = [SELECT Id, DocuSign_Envelope_ID__c FROM NPN_PartnerAttributes_Modifiaction__c ];
        List<dsfs__DocuSign_Status__c> docStatusList = new List<dsfs__DocuSign_Status__c>();
        List<Attachment> attachmentList = new List<Attachment>();

        for(NPN_PartnerAttributes_Modifiaction__c pamObj : pamObjForUpdate) {

            attachmentList.add(new Attachment(parentId = pamObj.Id, name='test Att', body = Blob.valueOf('Str')));

            dsfs__DocuSign_Status__c docStatusObj = new dsfs__DocuSign_Status__c(
                dsfs__Sent_Date_Time__c = System.today().addDays(-1),
                dsfs__DocuSign_Envelope_ID__c = '457BCA2E-DA5E-4064-B1B5-F9E6B8690A9C',
                dsfs__Viewed_Date_Time__c = System.today().addDays(-1),
                dsfs__Sender__c = 'Rajat Kamble',
                dsfs__Sender_Email__c = 'rkamble@nvidia.com.invalid',
                dsfs__Completed_Date_Time__c = System.today(),
                dsfs__Subject__c = 'NVIDIA Partner Network Contracts Packet for Review and Signature',
                dsfs__Envelope_Status__c = 'Completed',
                NPN_PartnerAttributes_Modifiaction__c = pamObj.Id
                );
            docStatusList.add(docStatusObj);

            pamObj.DocuSign_Envelope_ID__c = '457BCA2E-DA5E-4064-B1B5-F9E6B8690A9C';
        }

        if(!attachmentList.isEmpty()) {
            insert attachmentList;
        }

        if(!docStatusList.isEmpty()) {
            insert docStatusList;
        }
    
        Test.startTest();

        update pamObjForUpdate;

        Test.stopTest();
    }

/*  @isTest static void testLinkDocuSignStatusMethod(){

                // create PAM records.
                // create related docusign status records with a docusign envelope ids
                // update them with the same docusign envelope ids
                //
        }*/
}