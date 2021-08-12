/**
 * @name: NPN_QueableClassForDocuSignDML_Test
 * @description: Test class for NPN_QueableClassForDocuSignDML class
 */
@isTest(seeAllData=false)
private class NPN_QueableClassForDocuSignDML_Test {
    @isTest static void testQueue(){

        genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
        Test.startTest();
        System.Test.setMock(HttpCalloutMock.class, fakeResp);
        Id accRecTypeId     = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();

        List<Account> accountsForUpdate = new List<Account>();
        List<Contact> contactsForInsert = new List<Contact>();
        List<Contact> contactsForUpdate = new List<Contact>();
        List<Contact> existingContactsForUpdate = new List<Contact>();
        List<Contact> convertedContactsForUpdate = new List<Contact>();
        List<Partner_Attribute__c> partnerAttributesForInsert = new List<Partner_Attribute__c>();
        List<Partner_Attribute__c> partnerAttributesForUpdate = new List<Partner_Attribute__c>();
        list<NPN_Key_Contact__c> NPNKCForUpdate = new List<NPN_Key_Contact__c>();
        list<Attachment> attachmentsForInsert = new List<Attachment>();
        list<Attachment> attachmentsForDelete = new List<Attachment>();
        

        //Create a NPN Account with Billing Country, Region
        Account partnerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('DRNPNAccountRegistry1', accRecTypeId);
        system.debug('***partnerAcc: ' + partnerAcc);

        //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
        partnerAcc.IsPartner = true;
        update partnerAcc;

        accountsForUpdate.add(partnerAcc);
        
        Partner_Attribute__c pAttrb0 = new Partner_Attribute__c(
            Account_Name__c  = partnerAcc.id,
            Partner_Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_CV,
            Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP,
            Program_Level__c = COMM_Constants.PA_LEVEL_PREF,
            ATP_Partner_Termination_Date__c = null,
            Date_Competency_Terminated__c = null,
            ATP_Partner_Start_Date__c = Date.valueOf(system.today())
            );
        insert pAttrb0;
        
        partnerAttributesForUpdate.add(pAttrb0);
        Attachment att = new Attachment(parentId = partnerAcc.id, name='test Att', body = Blob.valueOf('Str'));
        insert att;
        
        attachmentsForDelete.add(att);
        
        Partner_Attribute__c pAttrb1 = new Partner_Attribute__c(
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
        partnerAttributesForInsert.add(pAttrb1);

        Partner_Attribute__c pAttrb2 = new Partner_Attribute__c(
            Account_Name__c  = partnerAcc.id,
            Partner_Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_PV,
            Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP,
            Program_Level__c = COMM_Constants.PA_LEVEL_PREF,
            ATP_Partner_Termination_Date__c = null,
            Date_Competency_Terminated__c = null,
            ATP_Partner_Start_Date__c = Date.valueOf(system.today())
            );
        partnerAttributesForInsert.add(pAttrb2);

        Partner_Attribute__c pAttrb3 = new Partner_Attribute__c(
            Account_Name__c  = partnerAcc.id,
            Partner_Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_GV,
            Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP,
            Program_Level__c = COMM_Constants.PA_LEVEL_PREF,
            ATP_Partner_Termination_Date__c = null,
            Date_Competency_Terminated__c = null,
            ATP_Partner_Start_Date__c = Date.valueOf(system.today())
            );
        partnerAttributesForInsert.add(pAttrb3);

        Contact testContact= new Contact(
            firstName = 'testFirstName',
            LastName= 'TestLastName1',
            Email='testEmail1@testingtest.com.invalid',
            AccountId = partnerAcc.Id,
            RecordTypeId = contactRecTypeId
            );

        contactsForInsert.add(testContact);

        Contact testContact2= new Contact(
            firstName = 'testFirstName',
            LastName= 'TestLastName2',
            Email='testEmail2@testingtest.com.invalid',
            AccountId = partnerAcc.Id,
            RecordTypeId = contactRecTypeId
            );
        insert testContact2;

        contactsForUpdate.add(testContact2);


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
        NPNKCForUpdate.add(nkcObj);
        
        Attachment att1 = new Attachment(parentId = partnerAcc.id, name='test Att111', body = Blob.valueOf('Str'));
        attachmentsForInsert.add(att1);

        System.enqueueJob(new NPN_QueableClassForDocuSignDML(contactsForInsert, contactsForUpdate, partnerAttributesForInsert, NPNKCForUpdate));
        System.enqueueJob(new NPN_QueableClassForDocuSignDML(attachmentsForInsert, attachmentsForDelete, contactsForInsert, contactsForUpdate, contactsForUpdate, partnerAttributesForInsert));
        System.enqueueJob(new NPN_QueableClassForDocuSignDML(contactsForUpdate, partnerAttributesForUpdate, accountsForUpdate));
        Test.stopTest();
    }
}