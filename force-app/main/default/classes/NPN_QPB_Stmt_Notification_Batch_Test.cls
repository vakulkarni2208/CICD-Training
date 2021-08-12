/***
 *  @description: Test class for NPN_QPB_Stmt_Notification_Batch
 */
@isTest(seeAllData = false)
private class NPN_QPB_Stmt_Notification_Batch_Test {


    static void createData(){
        map<String, Id> mapProfNameId;

        User partnerUser1;
        Id accRecTypeId;
        Id contactRecTypeId;
        Account partnerAcc;
        String userName;
        List<Contact> listContacts = new List<Contact>();
        List<User> listUsers = new List<User>();

        accRecTypeId     = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();
        contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();

        Profile partnerProf = [SELECT Id, Name FROM Profile WHERE Name = :COMM_Constants.PROF_PP_TPP_GENERIC LIMIT 1];

        accRecTypeId     = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();
        contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();

        //Create a NPN Account with Billing Country, Region
        partnerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('DRNPNAccountRegistry1', accRecTypeId);
        system.debug('***partnerAcc: ' + partnerAcc);


        //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
        partnerAcc.IsPartner = true;
        update partnerAcc;


        Contact cont = new Contact();
        cont.FirstName      =   'Runu';
        cont.LastName       =   'Mulay';
        cont.Email          =   'drcontactjena11@nv.com';
        cont.Phone          =   '789-978-5529';
        cont.AccountId      =   partnerAcc.Id;
        cont.MailingCountry =   COMM_Constants.ADDRESS_COUNTRY;
        cont.Role__c        =   'Partner Primary Contact;POS';
        cont.RecordTypeId   =   contactRecTypeId;
        insert cont;

        User comUser = new User(
            LastName = cont.LastName,
            Alias = cont.LastName,
            Email = cont.Email,
            Username = cont.LastName+'@slytherin.com.rpcf',
            CommunityNickname = cont.LastName+'nvvippartnerone',
            ProfileId = partnerProf.Id,
            ContactId=cont.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
            );
        insert comUser;

        cont.Community_User__c = comUser.Id;
        update cont;
    }

    static void makeData(){

        map<String, Id> mapProfNameId;
        Account partnerAcc;
        //Contact partnerContact1;
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
        partnerAcc.EMS_Update_Required__c= false;
        update partnerAcc;

        //Create a Partner Contact
        //partnerContact1 = Test_COMM_Factory.createContactWithMailingAddress('LDRJena11', 'FContact11', partnerAcc.Id, 'drcontactjena11@nv.com', contactRecTypeId, COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );

        Contact cont = new Contact();
        cont.FirstName      =   'Runu';
        cont.LastName       =   'Mulay';
        cont.Email          =   'drcontactjena11@nv.com';
        cont.Phone          =   '789-978-5529';
        cont.AccountId      =   partnerAcc.Id;
        cont.MailingCountry =   COMM_Constants.ADDRESS_COUNTRY;
        cont.Role__c        =   'Partner Primary Contact;POS';
        cont.RecordTypeId   =   contactRecTypeId;
        insert cont;

        //Create a Partner User with profile named 'NPN Partner Community(LOGIN)'
        User comUser = new User(
            LastName='one',
            Alias = 'tsale',
            Email = 'nvpartnerone@foo.com',
            Username = 'nvvippartnerone@foo.com.crqext',
            CommunityNickname = 'nvvippartnerone',
            ProfileId = mapProfNameId.get(COMM_Constants.PROF_PP_VGX_GENERIC),
            //ContactId=partnerContact1.Id,
            ContactId=cont.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
            );
        insert comUser;

        cont.Community_User__c = comUser.Id;
        update cont;
    }

    static void createQPBRecords(){

        Account partnerAcc = [SELECT Id FROM Account WHERE Name = 'DRNPNAccountRegistry1' LIMIT 1];
        List<QPB_Statement__c> recordsForInsert = new List<QPB_Statement__c>();
        List<QPB_Statement__c> recordsForUpdate = new List<QPB_Statement__c>();
        for(Integer i = 1; i<=4; i++) {
            recordsForInsert.add (new QPB_Statement__c (
                              Account__c = partnerAcc.Id,
                              Fiscal_Year__c = 'FY20',
                              Quarter__c = 'Q'+i,
                              Type__c = 'Final',
                              Status__c = 'Active',
                              Attachment_Uploaded__c =false,
                              Notified__c =false
                              ));
        }

        insert recordsForInsert;

        for(QPB_Statement__c qpbRec : recordsForInsert) {
            qpbRec.Attachment_Uploaded__c = true;
            recordsForUpdate.add(qpbRec);
        }

        update recordsForUpdate;
    }

    @isTest static void notifyPartnersForStmtTest(){
        genericMock fakeResp = new genericMock(200,'Complete',
           '<?xml version="1.0" encoding="UTF-8"?>'+
           '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/>'+
           '<soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com">'+
           '<ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage>'+
           '</ax21:errorMessage><ax21:statusCode>success</ax21:statusCode>'+
           '<ax21:syncType>PartnerUser</ax21:syncType></ns:return>'+
           '</ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);

        System.Test.setMock(HttpCalloutMock.class, fakeResp);
        Test.startTest();

        //createData();
        makeData();
        createQPBRecords();
        //List<AsyncApexJob> existingJob = [SELECT Id,JobType,Status FROM AsyncApexJob WHERE ApexClass.Name ='NPN_QPB_Stmt_Notification_Batch' AND JobType ='ScheduledApex' AND Status ='Queued'];

        /*if(existingJob.isEmpty()) {
            NPN_QPB_Stmt_Notification_Batch batchName = new NPN_QPB_Stmt_Notification_Batch();
            Database.executeBatch(batchName,20);
        }else{*/
            for(AsyncApexJob aJob : [SELECT Id,JobType,Status FROM AsyncApexJob WHERE ApexClass.Name ='NPN_QPB_Stmt_Notification_Batch' AND JobType ='ScheduledApex' AND Status ='Queued']){
                System.AbortJob(aJob.Id);
            }
            NPN_QPB_Stmt_Notification_Batch sch = new NPN_QPB_Stmt_Notification_Batch();
            String jobId = System.schedule('NPN_QPB_Stmt_Notification_Batch_TEST','0 0 * * * ?',sch);
        //}
        Test.stopTest();
    }
}