@isTest(SeeAllData=false)
private class NV_Test_CommunityHomePageContactUsCtrl {
    
    static void makeData(){
        
        //NV_NPN_TestDataFactory.setupCustomSettings();
        
        Id accRT= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();

        NV_NPN_TestDataFactory.setupCustomSettings();

        Account accSobj = new Account(
            Name = 'AddOnTesting',
            Phone = '922497367',
            NPN_Program_Signed_Date__c = Date.valueOf(system.today()),
            Inactive__c = false,
            Approved__c = false,
            //Account_Email__c = 'pardeshiakash143@gmail.com.invalid',
            MDF_Program_Active__c = false,
            RecordTypeId = accRT,
            BillingCountry ='China'            
            );
        insert accSobj;

        Contact contact1 = new Contact();
        contact1.FirstName      =   'partner';
        contact1.LastName       =   'one';
        contact1.Email          =   'nvpartnerone@foo.com';
        contact1.Phone          =   '789-978-5529';
        contact1.AccountId      =   accSobj.Id;
        contact1.Role__c        =   'Partner Primary Contact';
        contact1.Portal_Groups__c = 'Manager; NPN Compliance Tab; SOEM Portal Lite; SP Tesla Elite; SA DGX Preferred;';
        contact1.RecordTypeId   =   contactRecTypeId;
        insert contact1;

        Contact contact2 = new Contact();
        contact2.FirstName      =   'partner';
        contact2.LastName       =   'two';
        contact2.Email          =   'nvpartnerTwo@foo.com';
        contact2.Phone          =   '789-978-5529';
        contact2.AccountId      =   accSobj.Id;
        contact2.Role__c        =   'Partner Primary Contact';
        contact2.Portal_Groups__c = 'Manager; NPN Compliance Tab; SOEM Portal Lite; SP Tesla Elite; SA DGX Preferred;';
        contact2.RecordTypeId   =   contactRecTypeId;
        insert contact2;

        List<Profile> comntyProfileList = [SELECT Id FROM Profile WHERE Name = 'NPN Partner Community(LOGIN)'];
        User comUser = new User(
            LastName='one',
            Alias = 'tsale',
            Email = 'nvpartnerone@foo.com',
            Username = 'nvvippartnerone@foo.com.crqext',
            CommunityNickname = 'nvvippartnerone',
            ProfileId = comntyProfileList[0].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true,
            ContactId = contact1.Id
            );
        insert comUser;
        
        NV_Contacts__c nvContactObj1 = new NV_Contacts__c(
            Name = 'SP Tesla China Jerry Wang',                     
            Region__c = 'APAC',                                     
            Program_Type__c = COMM_Constants.PA_PROGRAM_SP,                  
            Sub_Region__c = 'CHINA',                                
            Product_Line__c = COMM_Constants.TEST_PORTAL_COMPETENCY_AC,                              
            Billing_Country__c = 'China',                                    
            Sales_Title__c = 'Partner Business Manager',            
            Sales_Manager_Email__c = 'jerrywang@nvvidia.com.invalid',        
            Sales_Manager_Contact_Number__c = '+86 13601185537',    
            Marketing_Manager_Name__c = 'Michael Zhao',             
            Marketing_Title__c = 'Marketing Manager',               
            Marketing_Manager_Email__c = 'mzhao@nvvidia.com.invalid',        
            Marketing_Manager_Contact_Number__c = '+86 13381025393',
            Support_Manager_Name__c = 'Hua Ping Luo',               
            Support_Title__c = 'SA Manager',                        
            Support_Manager_Email__c = 'hluo@nvvidia.com.invalid'
            );
        insert nvContactObj1;
        
        NV_Contacts__c nvContactObj2 = new NV_Contacts__c(
            Name = 'SA DGX China Stephen Wu',                   
            Region__c = 'APAC',                                 
            Program_Type__c = COMM_Constants.PA_PROGRAM_SA,               
            Sub_Region__c = 'CHINA',                            
            Product_Line__c = COMM_Constants.TEST_PORTAL_COMPETENCY_DL ,                            
            Billing_Country__c = 'China',                      
            Sales_Title__c = 'Partner Business Manager',        
            Sales_Manager_Email__c = 'stepwu@nvvidia.com.invalid',       
            Sales_Manager_Contact_Number__c = '+86 13301322288',
            Marketing_Manager_Name__c = 'Michael Zhao',         
            Marketing_Title__c = 'Marketing Manager',           
            Marketing_Manager_Email__c = 'mzhao@nvvidia.com.invalid'     
            );
        insert nvContactObj2;
        
        NV_Contacts__c nvContactObj3 = new NV_Contacts__c(
            Name = 'SP Tesla China Tom Wang',                     
            Region__c = 'APAC',                                     
            Program_Type__c = COMM_Constants.PA_PROGRAM_SP,                  
            Sub_Region__c = 'CHINA',                                
            Product_Line__c = COMM_Constants.TEST_PORTAL_COMPETENCY_AC,                              
            Billing_Country__c = 'China',                                    
            Sales_Title__c = 'Partner Business Manager',            
            Sales_Manager_Email__c = 'tomwang@nvvidia.com.invalid',        
            Sales_Manager_Contact_Number__c = '+86 13601185537',    
            Marketing_Manager_Name__c = 'Michael Zhao',             
            Marketing_Title__c = 'Marketing Manager',               
            Marketing_Manager_Email__c = 'mzhao@nvvidia.com.invalid',        
            Marketing_Manager_Contact_Number__c = '+86 13381025393',
            Support_Manager_Name__c = 'Hua Ping Luo',               
            Support_Title__c = 'SA Manager',                        
            Support_Manager_Email__c = 'hluo@nvvidia.com.invalid'
            );
        insert nvContactObj3;
        
 
    }

    @isTest
    static void getNVContactsTest(){
        
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
        
        User u = [SELECT Id, Name, AccountId, ContactId FROM User WHERE Username ='nvvippartnerone@foo.com.crqext'];
        Test.StartTest();
        System.runAs(u){

            list<NV_UtilityClass.NVIDIAContactsProductWiseWrapper> pwlist = new list<NV_UtilityClass.NVIDIAContactsProductWiseWrapper>();

            pwlist = NV_CommunityHomePageContactUsController.getNVContacts();
        }
        Test.stopTest();
    }

    @isTest
    static void getContactUsDataTest(){
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
        User u = [SELECT Id, Name, AccountId, ContactId FROM User WHERE Username ='nvvippartnerone@foo.com.crqext'];
        Test.StartTest();
        System.runAs(u){

            NV_CommunityHomePageContactUsController.ContactUsData wrpObject = NV_CommunityHomePageContactUsController.getContactUsData();
        }
        Test.stopTest();
    }

    @isTest
    static void sendEmail_askAQuestionTest(){
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
        User u = [SELECT Id, Name, AccountId, ContactId FROM User WHERE Username ='nvvippartnerone@foo.com.crqext'];
        String pid = String.valueOf(u.ContactId);
        Attachment at = new Attachment (ParentId =pid, Name='testAttachment', Body= Blob.valueof('test Attachment Body'));
        insert at;
        Test.StartTest();
        System.runAs(u){
            boolean boolObj = NV_CommunityHomePageContactUsController.sendEmail_askAQuestion(COMM_Constants.TEST_PORTAL_COMPETENCY_DL ,'Test Subject','testBody','testStepsToReproduce',at.id);
        }
        Test.stopTest();
    }

    @isTest
    static void sendEmail_TrainingRequestTest(){
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

        User u = [SELECT Id, Name, AccountId, ContactId FROM User WHERE Username ='nvvippartnerone@foo.com.crqext'];
        String pid = String.valueOf(u.ContactId);
        Attachment at = new Attachment (ParentId =pid, Name='testAttachment', Body= Blob.valueof('test Attachment Body'));
        insert at;
        Test.StartTest();
        System.runAs(u){
            boolean boolObj = NV_CommunityHomePageContactUsController.sendEmail_TrainingRequest(COMM_Constants.TEST_PORTAL_COMPETENCY_DL ,'Test Subject','testBody','testStepsToReproduce',at.id);
        }
        Test.stopTest();
    }

    @isTest
    static void logASupportRequestTest(){
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
        User u = [SELECT Id, Name, AccountId, ContactId FROM User WHERE Username ='nvvippartnerone@foo.com.crqext'];
        Test.StartTest();
        System.runAs(u){

            NV_CommunityHomePageContactUsController.LogASupportRequest lsr = new NV_CommunityHomePageContactUsController.LogASupportRequest();
            lsr.strCompetency=COMM_Constants.TEST_PORTAL_COMPETENCY_DL ;
            lsr.strAccountName='';
            lsr.strAccountId='';
            lsr.strName='testName';
            lsr.strEmail='abc@xyz.com.invalid';
            lsr.strPhone='454678754';
            lsr.strProblemType='testProblemType';
            lsr.strProblemDescription='testDescription';
            lsr.strStepsToReproduce='testStepsToReproduce';

            boolean boolObj = NV_CommunityHomePageContactUsController.sendEmail_LogASupportRequest(lsr);
        }
        Test.stopTest();
    }

    @isTest
    static void saveTheFileTest(){
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
        User u = [SELECT Id, Name, AccountId, ContactId FROM User WHERE Username ='nvvippartnerone@foo.com.crqext'];
        String pid = String.valueOf(u.ContactId);
        Test.StartTest();
        System.runAs(u){
            Id idValObj1 = NV_CommunityHomePageContactUsController.saveTheFile(pid,'Test file Name','testBody base64Data','text/plain');

            Id idValObj2 = NV_CommunityHomePageContactUsController.saveTheChunk(pid,'Test file Name','testBody base64Data','text/plain',idValObj1);
        }
        Test.stopTest();
    }

}