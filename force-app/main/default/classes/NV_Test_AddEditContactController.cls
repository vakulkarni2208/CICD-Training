@isTest(seeAllData = false)
private class NV_Test_AddEditContactController {

    @TestSetup
    static void makeData(){
        
        Id accRecTypeId     = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        List<Account> testAccts = new List<Account>();
        List<Temporary_Contact__c> testTempContacts = new List<Temporary_Contact__c>();
        List<Partner_Attribute__c> testPartnerAttrb = new List<Partner_Attribute__c>();

        for(Integer i=0; i<2; i++) {
            testAccts.add(
                new Account(
                    Name                        = 'TestAcct'+i,
                    RecordTypeId                = accRecTypeId,
                    SAP_Partner_Number__c       = '45684'+i,
                    NPN_Program_Signed_Date__c  = Date.valueOf(System.today())
                    )
                );
        }
        insert testAccts;

        Contact contact1 = new Contact();
        contact1.FirstName      =   'partner';
        contact1.LastName       =   'one';
        contact1.Email          =   'nvpartnerone@foo.com';
        contact1.Phone          =   '789-978-5529';
        contact1.AccountId      =   testAccts[0].Id;
        contact1.Role__c        =   'Partner Primary Contact';
        insert contact1;

        List<Profile> comntyProfileList = [SELECT Id FROM Profile WHERE Name = 'NPN Partner Community(LOGIN)'];
        User comUser = new User(
            LastName='one',
            Alias = 'tsale',
            Email = 'nvpartnerone@foo.com',
            Username = 'nvvippartnerone@foo.com.crqext',
            CommunityNickname = 'nvvippartnerone',
            ProfileId = comntyProfileList[0].Id,
            ContactId=contact1.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
            );
        insert comUser;
    }

    @isTest static void methodOne(){

        List<Account> acctList = [SELECT Id FROM Account WHERE Name IN ('TestAcct1','TestAcct2')];

        Contact contact1 = new Contact();
        contact1.FirstName      =   'Jake';
        contact1.LastName       =   'Paul';
        contact1.Email          =   'jake.paul@abc.com';
        contact1.Phone          =   '789-978-5529';
        contact1.AccountId      =   acctList[0].Id;
        contact1.Role__c        =   'Sales';
        contact1.Title          =   'Sales Analyst';
        //insert contact1;

        User contextuser = [SELECT Id FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];

        test.startTest();
        system.RunAs(contextuser){
            PageReference pageRef = Page.NV_AddEditContact;
            Test.setCurrentPageReference(pageRef);
            NV_AddEditContactController controllerExt = new NV_AddEditContactController( new ApexPages.StandardController(contact1));
            controllerExt.saveContact();
        }
        test.stopTest();
    }

    @isTest static void methodTwo(){

        List<Account> acctList = [SELECT Id FROM Account WHERE Name IN ('TestAcct1','TestAcct2')];

        Contact contact1 = new Contact();
        contact1.FirstName      =   'Andy';
        contact1.LastName       =   'P';
        contact1.Email          =   'andy.paul@abc.com';
        contact1.Phone          =   '789-978-5529';
        contact1.AccountId      =   acctList[0].Id;
        contact1.Role__c        =   'Parter Primary Contact';
        contact1.Title          =   'Sales Analyst';
        insert contact1;

        contact1.FirstName = 'Andrew';
        contact1.LastName = 'Paul';
        contact1.Role__c = 'Technical';
        contact1.Phone   = '485-978-5529';
        contact1.Title   = 'Sales Analyst';

        User contextuser = [SELECT Id FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];

        test.startTest();
        system.RunAs(contextuser){
            PageReference pageRef = Page.NV_AddEditContact;
            Test.setCurrentPageReference(pageRef);
            NV_AddEditContactController controllerExt = new NV_AddEditContactController( new ApexPages.StandardController(contact1));
            controllerExt.saveContact();
            controllerExt.getSelect();
            controllerExt.getDeselect();
            controllerExt.getDeselectedValues();
            controllerExt.getDeselectedValues();
        }
        test.stopTest();
    }

    @isTest static void methodThree(){

        List<Account> acctList = [SELECT Id FROM Account WHERE Name IN ('TestAcct1','TestAcct2')];

        Contact contact1 = new Contact();
        contact1.FirstName      =   'Andy';
        contact1.LastName       =   'Paul';
        contact1.Email          =   'andy.paul@abc.com';
        contact1.Phone          =   '789-978-5529';
        contact1.AccountId      =   acctList[0].Id;
        contact1.Role__c        =   'RMA';
        contact1.Title          =   'Sales Analyst';
        insert contact1;

        Temporary_Contact__c objTemporaryContact = new Temporary_Contact__c();
        objTemporaryContact.First_Name__c = contact1.FirstName;
        objTemporaryContact.Last_Name__c = contact1.LastName;
        objTemporaryContact.Email__c = contact1.Email;
        objTemporaryContact.Phone__c = contact1.Phone;
        objTemporaryContact.Account_ID__c = acctList[0].Id;
        objTemporaryContact.Role__c = contact1.Role__c;
        objTemporaryContact.Title__c= contact1.Title;
        objTemporaryContact.Status__c = 'Completed';
        objTemporaryContact.Requested_By__c = UserInfo.getUserId();
        objTemporaryContact.OwnerId = UserInfo.getUserId();
        insert objTemporaryContact;

        contact1.AddEditTempContactID__c = objTemporaryContact.Id;
        update contact1;

        contact1.FirstName = 'Andrew';
        contact1.LastName = 'Paul';
        contact1.Role__c = 'Technical';
        contact1.Phone   = '485-978-5529';
        contact1.Title   = 'Analyst';

        User contextuser = [SELECT Id FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];

        test.startTest();
        system.RunAs(contextuser){
            PageReference pageRef = Page.NV_AddEditContact;
            Test.setCurrentPageReference(pageRef);
            NV_AddEditContactController controllerExt = new NV_AddEditContactController( new ApexPages.StandardController(contact1));
            controllerExt.saveContact();
            controllerExt.getSelect();
            controllerExt.getDeselect();
            controllerExt.getDeselectedValues();
            controllerExt.getSelectedValues();
        }
        test.stopTest();
    }

    @isTest static void cancelTest(){
        List<Account> acctList = [SELECT Id FROM Account WHERE Name IN ('TestAcct1','TestAcct2')];

        Contact contact1 = new Contact();
        contact1.FirstName      =   'Jake';
        contact1.LastName       =   'Paul';
        contact1.Email          =   'nvpartnerone@foo.com';
        contact1.Phone          =   '789-978-5529';
        contact1.AccountId      =   acctList[0].Id;
        contact1.Role__c        =   'Sales';
        contact1.Title          =   'Analyst';


        User contextuser = [SELECT Id FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];

        test.startTest();
        system.RunAs(contextuser){
            PageReference pageRef = Page.NV_AddEditContact;
            Test.setCurrentPageReference(pageRef);
            NV_AddEditContactController controllerExt = new NV_AddEditContactController( new ApexPages.StandardController(contact1));
            controllerExt.cancelContact();
        }
        test.stopTest();
    }

    @isTest static void exceptionTest(){
    
        List<Account> acctList = [SELECT Id FROM Account WHERE Name IN ('TestAcct1','TestAcct2')];

        Contact contact1 = new Contact();
        contact1.FirstName      =   'Jake';
        contact1.LastName       =   'Paul';
        contact1.Email          =   'nvpartnerone@foo.com';
        contact1.Phone          =   '789-978-5529';
        contact1.AccountId      =   acctList[0].Id;
        contact1.Role__c        =   'Sales';
        contact1.Title          =   'Analyst';


        User contextuser = [SELECT Id FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];

        test.startTest();
        system.RunAs(contextuser){
            PageReference pageRef = Page.NV_AddEditContact;
            Test.setCurrentPageReference(pageRef);
            NV_AddEditContactController controllerExt = new NV_AddEditContactController( new ApexPages.StandardController(contact1));
            controllerExt.saveContact();
        }
        test.stopTest();
    }
}