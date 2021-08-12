@isTest(seeAllData=false)
private class NV_DocusignAccountHelper_Test {


@TestSetup
static void makeData(){

    NV_NPN_TestDataFactory.setupCustomSettings();
}

@isTest static void terminationMethodTest(){

    genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
    Test.startTest();
    System.Test.setMock(HttpCalloutMock.class, fakeResp);
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
        ATP_Partner_Start_Date__c = Date.valueOf(system.today())
        );
    partnerAttrbList.add(pAttrb3);

    insert partnerAttrbList;

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
        LanguageLocaleKey = 'en_US',
        IsActive = TRUE
        );
    insert comUser;

    partnerContact1.Community_User__c = comUser.Id;
    update partnerContact1;

    NPN_Key_Contact__c nkcObj = new NPN_Key_Contact__c(
        Name = 'Adam Riffle',
        Account__c = partnerAcc.Id,
        Job_Role__c = 'Sales',
        Email__c = 'adam.riffle@whitehatvirtual.com.invalid',
        Leads_and_Opportunities__c = false,
        Sales_Training__c = false,
        Technical_Training__c = false,
        synced__c = false);
    insert nkcObj;

    List<NPN_PartnerAttributes_Modifiaction__c> listPAMObj = new List<NPN_PartnerAttributes_Modifiaction__c>();

    NPN_PartnerAttributes_Modifiaction__c pamObj1 = new NPN_PartnerAttributes_Modifiaction__c(

        PartnerAttributes_Modification__c = 'Termination',
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

    NPN_PartnerAttributes_Modifiaction__c pamObj2 = new NPN_PartnerAttributes_Modifiaction__c(

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
    listPAMObj.add(pamObj2);

    NPN_PartnerAttributes_Modifiaction__c pamObj3 = new NPN_PartnerAttributes_Modifiaction__c(

        PartnerAttributes_Modification__c = 'Competency Termination',
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
    listPAMObj.add(pamObj3);

    NPN_PartnerAttributes_Modifiaction__c pamObj4 = new NPN_PartnerAttributes_Modifiaction__c(

        PartnerAttributes_Modification__c = 'Promotion',
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
    listPAMObj.add(pamObj4);

    NPN_PartnerAttributes_Modifiaction__c pamObj5 = new NPN_PartnerAttributes_Modifiaction__c(

        PartnerAttributes_Modification__c = 'Demotion',
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
    listPAMObj.add(pamObj5);

    insert listPAMObj;

    List<NPN_PartnerAttributes_Modifiaction__c> pamObjListForUpdate = new List<NPN_PartnerAttributes_Modifiaction__c>();
    List<dsfs__DocuSign_Status__c> docStatusList = new List<dsfs__DocuSign_Status__c>();
    List<Attachment> attachmentList = new List<Attachment>();

    for(NPN_PartnerAttributes_Modifiaction__c pamObj : [SELECT Id, PartnerAttributes_Modification__c,Competency_Termination_30_days_Complete__c FROM NPN_PartnerAttributes_Modifiaction__c WHERE PartnerAttributes_Modification__c IN ('Termination')]) { //,'Competency Termination'

        pamObj.Competency_Termination_30_days_Complete__c= true;
        pamObjListForUpdate.add(pamObj);

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
    }

    if(!docStatusList.isEmpty()) {
        insert docStatusList;
    }


    if(!pamObjListForUpdate.isEmpty()) {
        update pamObjListForUpdate;
    }
    Test.stopTest();

}

@isTest static void competencyTerminationMethodTest(){

    genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
    Test.startTest();
    System.Test.setMock(HttpCalloutMock.class, fakeResp);
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
        ATP_Partner_Start_Date__c = Date.valueOf(system.today())
        );
    partnerAttrbList.add(pAttrb3);

    insert partnerAttrbList;

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
        LanguageLocaleKey = 'en_US',
        IsActive = TRUE
        );
    insert comUser;

    partnerContact1.Community_User__c = comUser.Id;
    update partnerContact1;

    NPN_Key_Contact__c nkcObj = new NPN_Key_Contact__c(
        Name = 'Adam Riffle',
        Account__c = partnerAcc.Id,
        Job_Role__c = 'Sales',
        Email__c = 'adam.riffle@whitehatvirtual.com.invalid',
        Leads_and_Opportunities__c = false,
        Sales_Training__c = false,
        Technical_Training__c = false,
        synced__c = false);
    insert nkcObj;

    List<NPN_PartnerAttributes_Modifiaction__c> listPAMObj = new List<NPN_PartnerAttributes_Modifiaction__c>();

    NPN_PartnerAttributes_Modifiaction__c pamObj1 = new NPN_PartnerAttributes_Modifiaction__c(

        PartnerAttributes_Modification__c = 'Termination',
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

    NPN_PartnerAttributes_Modifiaction__c pamObj2 = new NPN_PartnerAttributes_Modifiaction__c(

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
    listPAMObj.add(pamObj2);

    NPN_PartnerAttributes_Modifiaction__c pamObj3 = new NPN_PartnerAttributes_Modifiaction__c(

        PartnerAttributes_Modification__c = 'Competency Termination',
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
    listPAMObj.add(pamObj3);

    NPN_PartnerAttributes_Modifiaction__c pamObj4 = new NPN_PartnerAttributes_Modifiaction__c(

        PartnerAttributes_Modification__c = 'Promotion',
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
    listPAMObj.add(pamObj4);

    NPN_PartnerAttributes_Modifiaction__c pamObj5 = new NPN_PartnerAttributes_Modifiaction__c(

        PartnerAttributes_Modification__c = 'Demotion',
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
    listPAMObj.add(pamObj5);

    insert listPAMObj;

    List<NPN_PartnerAttributes_Modifiaction__c> pamObjListForUpdate = new List<NPN_PartnerAttributes_Modifiaction__c>();
    List<dsfs__DocuSign_Status__c> docStatusList = new List<dsfs__DocuSign_Status__c>();
    List<Attachment> attachmentList = new List<Attachment>();

    for(NPN_PartnerAttributes_Modifiaction__c pamObj : [SELECT Id, PartnerAttributes_Modification__c,Competency_Termination_30_days_Complete__c FROM NPN_PartnerAttributes_Modifiaction__c WHERE PartnerAttributes_Modification__c = 'Competency Termination']) {

        pamObj.Competency_Termination_30_days_Complete__c= true;
        pamObjListForUpdate.add(pamObj);

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
    }

    if(!docStatusList.isEmpty()) {
        insert docStatusList;
    }

    if(!pamObjListForUpdate.isEmpty()) {
        update pamObjListForUpdate;
    }
    Test.stopTest();
}


@isTest static void promotion_demotionMethodTest(){
    genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
    Test.startTest();
    System.Test.setMock(HttpCalloutMock.class, fakeResp);
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
        ATP_Partner_Start_Date__c = Date.valueOf(system.today())
        );
    partnerAttrbList.add(pAttrb3);

    insert partnerAttrbList;

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
        LanguageLocaleKey = 'en_US',
        IsActive = TRUE
        );
    insert comUser;

    partnerContact1.Community_User__c = comUser.Id;
    update partnerContact1;

    NPN_Key_Contact__c nkcObj = new NPN_Key_Contact__c(
        Name = 'Adam Riffle',
        Account__c = partnerAcc.Id,
        Job_Role__c = 'Sales',
        Email__c = 'adam.riffle@whitehatvirtual.com.invalid',
        Leads_and_Opportunities__c = false,
        Sales_Training__c = false,
        Technical_Training__c = false,
        synced__c = false);
    insert nkcObj;

    List<NPN_PartnerAttributes_Modifiaction__c> listPAMObj = new List<NPN_PartnerAttributes_Modifiaction__c>();

    NPN_PartnerAttributes_Modifiaction__c pamObj1 = new NPN_PartnerAttributes_Modifiaction__c(

        PartnerAttributes_Modification__c = 'Termination',
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

    NPN_PartnerAttributes_Modifiaction__c pamObj2 = new NPN_PartnerAttributes_Modifiaction__c(

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
    listPAMObj.add(pamObj2);

    NPN_PartnerAttributes_Modifiaction__c pamObj3 = new NPN_PartnerAttributes_Modifiaction__c(

        PartnerAttributes_Modification__c = 'Competency Termination',
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
    listPAMObj.add(pamObj3);

    NPN_PartnerAttributes_Modifiaction__c pamObj4 = new NPN_PartnerAttributes_Modifiaction__c(

        PartnerAttributes_Modification__c = 'Promotion',
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
    listPAMObj.add(pamObj4);

    NPN_PartnerAttributes_Modifiaction__c pamObj5 = new NPN_PartnerAttributes_Modifiaction__c(

        PartnerAttributes_Modification__c = 'Demotion',
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
    listPAMObj.add(pamObj5);

    insert listPAMObj;

    List<NPN_PartnerAttributes_Modifiaction__c> pamObjListForUpdate = new List<NPN_PartnerAttributes_Modifiaction__c>();
    List<dsfs__DocuSign_Status__c> docStatusList = new List<dsfs__DocuSign_Status__c>();
    List<Attachment> attachmentList = new List<Attachment>();

    for(NPN_PartnerAttributes_Modifiaction__c pamObj : [SELECT Id, PartnerAttributes_Modification__c,Competency_Termination_30_days_Complete__c FROM NPN_PartnerAttributes_Modifiaction__c WHERE PartnerAttributes_Modification__c IN ('Promotion', 'Demotion')]) {

        pamObj.Competency_Termination_30_days_Complete__c= true;
        pamObjListForUpdate.add(pamObj);

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
    }

    if(!docStatusList.isEmpty()) {
        insert docStatusList;
    }

    if(!pamObjListForUpdate.isEmpty()) {
        update pamObjListForUpdate;
    }
    Test.stopTest();
}
}