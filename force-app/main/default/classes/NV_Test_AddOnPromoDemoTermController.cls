@isTest(seeAllData=false)
private class NV_Test_AddOnPromoDemoTermController {

    static void makeData(){
        map<String, Id> mapProfNameId;
        Account partnerAcc;
        Contact partnerContact1;

        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();

        list<string> lstProfNames = new list<string> {COMM_Constants.PROF_PP_VGX_GENERIC, COMM_Constants.PROF_INT_PARTNER_ADMIN };
        mapProfNameId = Test_COMM_Factory.getProfsByName(lstProfNames);

        //Create a NPN Account with Billing Country, Region
        partnerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('DRNPNAccountRegistry1', accRecTypeId);

        //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
        partnerAcc.IsPartner = true;
        partnerAcc.Billing_Region__c = 'NALA';
        update partnerAcc;

        //Create a Partner Contact
        partnerContact1 = Test_COMM_Factory.createContactWithMailingAddress('LDRJena11', 'FContact11', partnerAcc.Id, 'drcontactjena11@nv.com', contactRecTypeId, COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );

        list<Partner_Attribute__c> partnerAttrbList = new List<Partner_Attribute__c>();
        Partner_Attribute__c pAttrb = new Partner_Attribute__c(
            Account_Name__c  = partnerAcc.id,
            Partner_Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL,
            Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP,
            Partner_Sub_Program__c ='',
            Program_Level__c = COMM_Constants.PA_LEVEL_PREF,
            ATP_Partner__c = true,
            ATP_Partner_Termination_Date__c = null,
            Date_Competency_Terminated__c = null,
            Date_Competency_Signed__c = Date.valueOf (system.today()),
            ATP_Partner_Start_Date__c = Date.valueOf(system.today())
            );
        partnerAttrbList.add(pAttrb);

        Partner_Attribute__c pAttrb2 = new Partner_Attribute__c(
            Account_Name__c  = partnerAcc.id,
            Partner_Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_PV,
            Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP,
            Program_Level__c = COMM_Constants.PA_LEVEL_PREF,
            ATP_Partner_Termination_Date__c = null,
            Date_Competency_Terminated__c = null,
            Date_Competency_Signed__c = Date.valueOf (system.today()),
            ATP_Partner_Start_Date__c = Date.valueOf(system.today())
            );
        partnerAttrbList.add(pAttrb2);

        Partner_Attribute__c pAttrb3 = new Partner_Attribute__c(
            Account_Name__c  = partnerAcc.id,
            Partner_Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_GV,
            Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP,
            Program_Level__c = COMM_Constants.PA_LEVEL_PREF,
            ATP_Partner_Termination_Date__c = null,
            Date_Competency_Terminated__c = null,
            Date_Competency_Signed__c = Date.valueOf (system.today()),
            ATP_Partner_Start_Date__c = Date.valueOf(system.today())
            );
        partnerAttrbList.add(pAttrb3);

        insert partnerAttrbList;

        list<NPN_Contract_Packet_Config__c> listNPN_Contract_Packet_Config= new list<NPN_Contract_Packet_Config__c> ();

        NPN_Contract_Packet_Config__c NP1= new NPN_Contract_Packet_Config__c ();
        NP1.name= 'test';
        NP1.setupownerid= UserInfo.getOrganizationId();
        NP1.email_body__c= 'Attached you will find the NVIDIA Partner Network (NPN) Contacts Packet for review, completion and signature.';
        NP1.email_subject__c= 'NVIDIA Partner Network Contracts Packet for Review and Signature';
        NP1.vp_email__c= 'apardeshi@nvidia.com.invalid';
        NP1.vp_first_name__c= 'Anthony';
        NP1.vp_last_name__c= 'Medeiros';

        listNPN_Contract_Packet_Config.add(NP1);
        insert listNPN_Contract_Packet_Config;
    }

    @isTest static void docuSignTest1(){

        genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
        


        test.startTest();
        System.Test.setMock(HttpCalloutMock.class, fakeResp);
        
        makeData();
        
        Account partnerAccount = [SELECT Id, Name FROM Account LIMIT 1];

        Contact partnerContact = [SELECT Id FROM Contact WHERE AccountId = :partnerAccount.Id LIMIT 1];

        PageReference pageRef = Page.NV_AddOnPromoDemoTermination;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('id',partnerAccount.Id);
        NV_AddOnPromoDemoTerminationController controllerExt = new NV_AddOnPromoDemoTerminationController( new ApexPages.StandardController(partnerAccount));

        controllerExt.strDocumentIds = '4064457BCA2EDA5E457BCA2E4064B1B5F9E6B8690A9C, F9E6B8690A9C4064457BCA2EDA5E457BCA2E4064';
        controllerExt.objPAM = new NPN_PartnerAttributes_Modifiaction__c(
            PartnerAttributes_Modification__c = 'Add On Contracts Packet',
            Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL+';'+COMM_Constants.TEST_PORTAL_COMPETENCY_PV+';'+COMM_Constants.TEST_PORTAL_COMPETENCY_GV+';',
            Competency_Level__c = 'Preferred',
            Sync__c = false,
            CSP_Yes_No__c = false,
            Account__c = partnerAccount.Id,
            Program_Type__c = COMM_Constants.PA_PROGRAM_SP,
            Termination_Initiated__c = false,
            Competency_Termination_30_days_Complete__c = false,
            Contact__c = partnerContact.Id,
            DocuSign_Envelope_ID__c = '457BCA2E-DA5E-4064-B1B5-F9E6B8690A9C'

            );
        controllerExt.save();

        test.stopTest();

    }
    
    @isTest static void docuSignTest2(){

        genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
        


        test.startTest();
        System.Test.setMock(HttpCalloutMock.class, fakeResp);
        
        makeData();
        
        Account partnerAccount = [SELECT Id, Name FROM Account LIMIT 1];

        Contact partnerContact = [SELECT Id FROM Contact WHERE AccountId = :partnerAccount.Id LIMIT 1];

        PageReference pageRef = Page.NV_AddOnPromoDemoTermination;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('id',partnerAccount.Id);
        NV_AddOnPromoDemoTerminationController controllerExt = new NV_AddOnPromoDemoTerminationController( new ApexPages.StandardController(partnerAccount));

        controllerExt.strDocumentIds = '4064457BCA2EDA5E457BCA2E4064B1B5F9E6B8690A9C, F9E6B8690A9C4064457BCA2EDA5E457BCA2E4064';
        controllerExt.objPAM = new NPN_PartnerAttributes_Modifiaction__c(
            PartnerAttributes_Modification__c = 'Promotion',
            Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL+';'+COMM_Constants.TEST_PORTAL_COMPETENCY_PV+';'+COMM_Constants.TEST_PORTAL_COMPETENCY_GV+';',
            Competency_Level__c = 'Preferred',
            Sync__c = false,
            CSP_Yes_No__c = false,
            Account__c = partnerAccount.Id,
            Program_Type__c = COMM_Constants.PA_PROGRAM_SP,
            Termination_Initiated__c = false,
            Competency_Termination_30_days_Complete__c = false,
            Contact__c = partnerContact.Id,
            DocuSign_Envelope_ID__c = '457BCA2E-DA5E-4064-B1B5-F9E6B8690A9C'

            );
        controllerExt.save();

        test.stopTest();

    }
    
    @isTest static void docuSignTest3(){

        genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
        


        test.startTest();
        System.Test.setMock(HttpCalloutMock.class, fakeResp);
        
        makeData();
        
        Account partnerAccount = [SELECT Id, Name FROM Account LIMIT 1];

        Contact partnerContact = [SELECT Id FROM Contact WHERE AccountId = :partnerAccount.Id LIMIT 1];

        PageReference pageRef = Page.NV_AddOnPromoDemoTermination;
        Test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('id',partnerAccount.Id);
        NV_AddOnPromoDemoTerminationController controllerExt = new NV_AddOnPromoDemoTerminationController( new ApexPages.StandardController(partnerAccount));

        controllerExt.strDocumentIds = '4064457BCA2EDA5E457BCA2E4064B1B5F9E6B8690A9C, F9E6B8690A9C4064457BCA2EDA5E457BCA2E4064';
        controllerExt.objPAM = new NPN_PartnerAttributes_Modifiaction__c(
            PartnerAttributes_Modification__c = 'Demotion',
            Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL+';'+COMM_Constants.TEST_PORTAL_COMPETENCY_PV+';'+COMM_Constants.TEST_PORTAL_COMPETENCY_GV+';',
            Competency_Level__c = 'Preferred',
            Sync__c = false,
            CSP_Yes_No__c = false,
            Account__c = partnerAccount.Id,
            Program_Type__c = COMM_Constants.PA_PROGRAM_SP,
            Termination_Initiated__c = false,
            Competency_Termination_30_days_Complete__c = false,
            Contact__c = partnerContact.Id,
            DocuSign_Envelope_ID__c = '457BCA2E-DA5E-4064-B1B5-F9E6B8690A9C'

            );
        controllerExt.save();

        test.stopTest();

    }

}