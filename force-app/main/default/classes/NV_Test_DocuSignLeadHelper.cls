@isTest
private class NV_Test_DocuSignLeadHelper {
    
    static Id leadId;
    static void createData() {
        
        NV_NPN_TestDataFactory.setupCustomSettings();
        RecordType leadRec = [select id from RecordType where sobjectType='Lead' and developerName='NPN_Web_Onboard_Form'];
        
        Lead objLead = new Lead();
        
        objLead.Approved_Competencies__c = 'Accelerated Computing; GPU Virtualization';
        objLead.Approved_Program_Type__c = 'Service Delivery Partner';
        objLead.Approved_SubProgram_Type__c= 'EDU Services';
        objLead.Program_Level__c = 'Elite';
        objLead.lastname = 'Varun Test';
        objLead.email = 'varun1234@test.com';
        objLead.Company = 'NVD';
        objLead.Country = 'India';
        objLead.recordTypeId = leadRec.id;
        insert objLead;
        leadId = objLead.id;
        Attachment att = new Attachment(parentId = objLead.id, name='test Att', body = Blob.valueOf('Str'));
        insert att;
        NPN_Key_Contact__c objNPN = new NPN_Key_Contact__c(lead__c = objLead.id, email__c = 'varun232@test.com', Job_Role__c = 'POS', sales_training__c = true, technical_Training__c = true);
        insert objNPN;
        
    }
    
    static void createData1() {
        
        NV_NPN_TestDataFactory.setupCustomSettings();
        RecordType leadRec = [select id from RecordType where sobjectType='Lead' and developerName='NPN_Web_Onboard_Form'];
        RecordType AccRec = [select id from RecordType where sobjectType='Account' and developerName='NPN_Community_Account'];
        RecordType ConRec = [select id from RecordType where sobjectType='Contact' and developerName='Partner'];
        Lead objLead = new Lead();
        Account ObjAcc = new Account();
        Contact ObjCon = new Contact();
        ObjAcc.Name = 'NVD';
        ObjCon.lastname = 'Varun Test';
        ObjCon.email='varun@test.com';
        objLead.Approved_Competencies__c = 'Accelerated Computing; GPU Virtualization';
        objLead.Approved_Program_Type__c = 'Solution Provider (VAR)';
        objLead.Program_Level__c = 'Elite';
        objLead.lastname = 'Varun Test';
        objLead.email = 'varun@test.com';
        objLead.Company = 'NVD';
        objLead.Country = 'India';
        objLead.recordTypeId = leadRec.id;
        objAcc.recordTypeId = AccRec.id;
        objCon.recordTypeId = ConRec.id;
        insert objLead;
        insert ObjAcc;
        leadId = objLead.id;
        ObjCon.Accountid=ObjAcc.id;
        Attachment att = new Attachment(parentId = objLead.id, name='test Att', body = Blob.valueOf('Str'));
        insert att;
        NPN_Key_Contact__c objNPN = new NPN_Key_Contact__c(lead__c = objLead.id, email__c = 'varun@test.com', Job_Role__c = 'POS', sales_training__c = true, technical_Training__c = true);
        NPN_Key_Contact__c objNPN1 = new NPN_Key_Contact__c(lead__c = objLead.id, email__c = 'varun@test.com', Job_Role__c = 'POS', sales_training__c = true, technical_Training__c = true);
        insert objNPN;
        insert objNPN1;
        
        insert ObjCon;
    }
    
    static testmethod void convertLeadTest() {
        genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
        Test.startTest();
            System.Test.setMock(HttpCalloutMock.class, fakeResp);
            createData();
            dsfs__DocuSign_Status__c objDCS = new dsfs__DocuSign_Status__c(dsfs__Lead__c = leadId, dsfs__Envelope_Status__c = 'Sent');
            insert objDCS;
            objDCS.dsfs__Envelope_Status__c = 'Completed';
            update objDCS; 
        Test.stopTest();
    }
    
    static testmethod void convertLeadTest1() {
        genericMock fakeResp = new genericMock(200,'Complete', '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><ns:SyncServiceResponse xmlns:ns="http://nvidiasapemsconnector.nvidiaaxis2service.nvidia.smps.gmlto.com"><ns:return xmlns:ax21="http://dto.nvidiaaxis2service.nvidia.smps.gmlto.com/xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ax21:SyncResponse"><ax21:errorMessage></ax21:errorMessage><ax21:statusCode>success</ax21:statusCode><ax21:syncType>PartnerUser</ax21:syncType></ns:return></ns:SyncServiceResponse></soapenv:Body></soapenv:Envelope>',null);
        Test.startTest();
            System.Test.setMock(HttpCalloutMock.class, fakeResp);
            createData1();
            dsfs__DocuSign_Status__c objDCS = new dsfs__DocuSign_Status__c(dsfs__Lead__c = leadId, dsfs__Envelope_Status__c = 'Sent');
            insert objDCS;
            objDCS.dsfs__Envelope_Status__c = 'Completed';
            update objDCS; 
        Test.stopTest();
    }
    
}