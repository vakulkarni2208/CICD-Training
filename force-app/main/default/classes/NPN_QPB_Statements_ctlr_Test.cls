/**
 * Test class for NPN_QPB_Statements_ctlr
 */
@isTest(seeAllData = false)
private class NPN_QPB_Statements_ctlr_Test {

    static User contextUser;

    static void setupData(){

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
        partnerAcc.EMS_Update_Required__c= false;
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

        /*PermissionSet qpbPermSet = [SELECT Id FROM PermissionSet WHERE Name = 'PP_NPN_QPB_Statements' LIMIT 1];

           PermissionSetAssignment psaObj = new PermissionSetAssignment();
           psaObj.AssigneeId = comUser.Id;
           psaObj.PermissionSetId = qpbPermSet.Id;

           insert psaObj;*/
    }

    static void createQPBRecords(){

        contextUser = [SELECT Id, Email, ContactId, Contact.AccountId FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];

        List<QPB_Statement__c> recordsForInsert = new List<QPB_Statement__c>();
        List<ContentVersion> contentForInsert = new List<ContentVersion>();
        List<ContentDocumentLink> cdlForInsert = new List<ContentDocumentLink>();

        for(Integer i = 1; i<=4; i++) {
            recordsForInsert.add (new QPB_Statement__c (
                              Account__c = contextUser.Contact.AccountId,
                              Fiscal_Year__c = 'FY20', // Fiscal Year
                              Quarter__c = 'Q'+i, // Quarter
                              Type__c = 'Final', // Type
                              Status__c = 'Active', // Status
                              Attachment_Uploaded__c = true // Attachment Uploaded?
                              ));

            ContentVersion cv = new ContentVersion();
            cv.title = 'test content trigger';
            cv.PathOnClient ='test';
            cv.VersionData = Blob.valueOf('beforeblob');
            cv.IsMajorVersion = true;
            contentForInsert.add(cv);
        }

        insert recordsForInsert;

        system.debug('recordsForInsert '+recordsForInsert);
        insert contentForInsert;
        system.debug('contentForInsert '+contentForInsert);

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        for(Integer i=0; i< recordsForInsert.size(); i++) {
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = recordsForInsert[i].id;
            cdl.ContentDocumentId = documents[i].Id;
            cdl.ShareType = 'V ';
            cdl.Visibility='AllUsers';
            cdlForInsert.add(cdl);
        }

        insert cdlForInsert;
        system.debug('cdlForInsert '+cdlForInsert);
    }


    @isTest static void noQPBRecordsTest(){


        setupData();
        contextUser = [SELECT Id, Email, ContactId, AccountId FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];

        system.RunAs(contextUser){

            test.startTest();
            PageReference pageRef = Page.NPN_QPB_Statements;
            Test.setCurrentPageReference(pageRef);
            NPN_QPB_Statements_ctlr controllerExt = new NPN_QPB_Statements_ctlr();
            test.stopTest();
        }

    }

    @isTest static void defaultTest(){


        setupData();
        createQPBRecords();

        contextUser = [SELECT Id, Email, ContactId, AccountId FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];
        system.debug('contextUser '+contextUser);

        system.RunAs(contextUser){
            test.startTest();
            PageReference pageRef = Page.NPN_QPB_Statements;
            Test.setCurrentPageReference(pageRef);
            NPN_QPB_Statements_ctlr controllerExt = new NPN_QPB_Statements_ctlr();
            test.stopTest();
        }

    }
    
    @isTest static void defaultLWCTest(){


        setupData();
        createQPBRecords();

        contextUser = [SELECT Id, Email, ContactId, AccountId FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];
        system.debug('contextUser '+contextUser);

        system.RunAs(contextUser){
            test.startTest();
            NPN_LWCQPBStatementsController objNPNLWCQPBStatementsController = new NPN_LWCQPBStatementsController();
            NPN_LWCQPBStatementsController.getQPBStatements();
            test.stopTest();
        }

    }

}