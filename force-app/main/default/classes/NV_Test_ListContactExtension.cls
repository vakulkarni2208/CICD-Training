@isTest(seeAllData = false)
private class NV_Test_ListContactExtension {

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
        contact1.RecordTypeId   =   contactRecTypeId;
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

        // Create multiple temp contacts contacts

        List<Temporary_Contact__c> tempContactList = new List<Temporary_Contact__c>();
        for(Integer i=0; i<2; i++) {
            Temporary_Contact__c objTemporaryContact = new Temporary_Contact__c();
            objTemporaryContact.Account_ID__c = testAccts[0].Id;
            objTemporaryContact.Status__c = 'Pending';
            tempContactList.add(objTemporaryContact);
        }

        insert tempContactList;
        
        
        List<NPN_Bulk_Contact_Request__c> blkContactList = new List<NPN_Bulk_Contact_Request__c>();
        for(Integer i=0; i<2; i++) {
            String accId = testAccts[i].Id;
            for(Integer j=0; j<2; j++) {
                NPN_Bulk_Contact_Request__c objBlkContactReq = new NPN_Bulk_Contact_Request__c();
                objBlkContactReq.Account_Name__c = accId;
                objBlkContactReq.Status__c = 'Pending';
                objBlkContactReq.Requested_By__c = comUser.Id;
                blkContactList.add(objBlkContactReq);
            }
        }
        insert blkContactList;
    }

    @isTest
    static void methodOne(){
    
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        List<Account> acctList = [SELECT Id FROM Account WHERE Name IN ('TestAcct1','TestAcct2')];

        Contact contact1 = new Contact();
        contact1.FirstName      =   'Jake';
        contact1.LastName       =   'Paul';
        contact1.Email          =   'jake.paul@abc.com';
        contact1.Phone          =   '789-978-5529';
        contact1.AccountId      =   acctList[0].Id;
        contact1.Role__c        =   'Sales';
        contact1.Title          =   'Sales Analyst';
        contact1.RecordTypeId   =   contactRecTypeId;
        insert contact1;

        User contextuser = [SELECT Id FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];

        test.startTest();
        system.RunAs(contextuser){
            PageReference pageRef = Page.NV_ListPartnerContacts;
            Test.setCurrentPageReference(pageRef);
            NV_ListContactExtension controllerExt = new NV_ListContactExtension();
            pageRef.getParameters().put('contactId',contact1.Id);
            pageRef.getParameters().put('actionToPerform','Edit');
            controllerExt.getContacts();
            controllerExt.getTemporaryContacts();
            controllerExt.checkContactStatus();
            controllerExt.addContact();
            controllerExt.getBulkContactRequests();
        }
        test.stopTest();

    }

    @isTest
    static void methodTwo(){
    
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        List<Account> acctList = [SELECT Id FROM Account WHERE Name IN ('TestAcct1','TestAcct2')];

        Contact contact1 = new Contact();
        contact1.FirstName      =   'Jake';
        contact1.LastName       =   'Paul';
        contact1.Email          =   'jake.paul@abcc.com';
        contact1.Phone          =   '789-978-5529';
        contact1.AccountId      =   acctList[0].Id;
        contact1.Role__c        =   'Technical';
        contact1.Title          =   'Lead';
        contact1.RecordTypeId   =   contactRecTypeId;
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

        User contextuser = [SELECT Id FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];

        test.startTest();
        system.RunAs(contextuser){
            PageReference pageRef = Page.NV_ListPartnerContacts;
            Test.setCurrentPageReference(pageRef);
            NV_ListContactExtension controllerExt = new NV_ListContactExtension();
            pageRef.getParameters().put('contactId',contact1.Id);
            pageRef.getParameters().put('actionToPerform','Delete');
            controllerExt.getContacts();
            controllerExt.getTemporaryContacts();
            controllerExt.getBulkContactRequests();
            controllerExt.checkContactStatus();
            controllerExt.closePopup();         
        }
        test.stopTest();

    }

    @isTest
    static void methodThree(){
    
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        List<Account> acctList = [SELECT Id FROM Account WHERE Name IN ('TestAcct1','TestAcct2')];

        Contact contact1 = new Contact();
        contact1.FirstName      =   'Jake';
        contact1.LastName       =   'Paul';
        contact1.Email          =   'jake.paul@abcc.com';
        contact1.Phone          =   '789-978-5529';
        contact1.AccountId      =   acctList[0].Id;
        contact1.Role__c        =   'Technical';
        contact1.Title          =   'Lead';
        contact1.RecordTypeId   =   contactRecTypeId;
        insert contact1;

        List<Profile> comntyProfileList = [SELECT Id FROM Profile WHERE Name = 'NPN Partner Community(LOGIN)'];
        User contact1User = new User(
            LastName='one',
            Alias = 'tsale',
            Email = 'nvpartnerTwo@foo.com',
            Username = 'nvvippartnerTwo@foo.com.crqext',
            CommunityNickname = 'nvvippartnerTwo',
            ProfileId = comntyProfileList[0].Id,
            ContactId=contact1.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
            );
        insert contact1User;

        Temporary_Contact__c objTemporaryContact = new Temporary_Contact__c();
        objTemporaryContact.First_Name__c = contact1.FirstName;
        objTemporaryContact.Last_Name__c = contact1.LastName;
        objTemporaryContact.Email__c = contact1.Email;
        objTemporaryContact.Phone__c = contact1.Phone;
        objTemporaryContact.Account_ID__c = acctList[0].Id;
        objTemporaryContact.Role__c = contact1.Role__c;
        objTemporaryContact.Title__c= contact1.Title;
        objTemporaryContact.Status__c = 'Completed';
        objTemporaryContact.Action_requested__c = 'Delete';
        objTemporaryContact.Reason_for_Deactivation_Deletion__c = 'Delete for testing';
        objTemporaryContact.ContactId__c = contact1.Id;
        objTemporaryContact.Requested_By__c = UserInfo.getUserId();
        objTemporaryContact.OwnerId = UserInfo.getUserId();
        insert objTemporaryContact;

        contact1.AddEditTempContactID__c = objTemporaryContact.Id;
        contact1.Community_User__c = contact1User.Id;
        update contact1;

        Contact con1 = [SELECT Id, Community_User__c, AddEditTempContactID__c FROM Contact WHERE Id = :contact1.Id];

        system.assertEquals(objTemporaryContact.Id, con1.AddEditTempContactID__c);
        system.assertEquals(contact1User.Id, con1.Community_User__c);

        User contextuser = [SELECT Id FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];

        test.startTest();
        system.RunAs(contextuser){
            PageReference pageRef = Page.NV_ListPartnerContacts;
            Test.setCurrentPageReference(pageRef);
            NV_ListContactExtension controllerExt = new NV_ListContactExtension();
            pageRef.getParameters().put('contactId',contact1.Id);
            pageRef.getParameters().put('actionToPerform','Delete');
            controllerExt.getContacts();
            controllerExt.getTemporaryContacts();
            controllerExt.getBulkContactRequests();
            controllerExt.checkContactStatus();
            controllerExt.removeContact();          
        }
        test.stopTest();

    }

    @isTest
    static void methodFour(){
    
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        List<Account> acctList = [SELECT Id FROM Account WHERE Name IN ('TestAcct1','TestAcct2')];

        Contact contact1 = new Contact();
        contact1.FirstName      =   'Jake';
        contact1.LastName       =   'Paul';
        contact1.Email          =   'jake.paul@abcc.com';
        contact1.Phone          =   '789-978-5529';
        contact1.AccountId      =   acctList[0].Id;
        contact1.Role__c        =   'Technical';
        contact1.Title          =   'Lead';
        contact1.RecordTypeId   =   contactRecTypeId;
        insert contact1;

        List<Profile> comntyProfileList = [SELECT Id FROM Profile WHERE Name = 'NPN Partner Community(LOGIN)'];
        User contact1User = new User(
            LastName='one',
            Alias = 'tsale',
            Email = 'nvpartnerTwo@foo.com',
            Username = 'nvvippartnerTwo@foo.com.crqext',
            CommunityNickname = 'nvvippartnerTwo',
            ProfileId = comntyProfileList[0].Id,
            ContactId=contact1.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
            );
        insert contact1User;

        Temporary_Contact__c objTemporaryContact = new Temporary_Contact__c();
        objTemporaryContact.First_Name__c = contact1.FirstName;
        objTemporaryContact.Last_Name__c = contact1.LastName;
        objTemporaryContact.Email__c = contact1.Email;
        objTemporaryContact.Phone__c = contact1.Phone;
        objTemporaryContact.Account_ID__c = acctList[0].Id;
        objTemporaryContact.Role__c = contact1.Role__c;
        objTemporaryContact.Title__c= contact1.Title;
        objTemporaryContact.Status__c = 'Pending';
        objTemporaryContact.Action_requested__c = 'Delete';
        objTemporaryContact.Reason_for_Deactivation_Deletion__c = 'Delete for testing';
        objTemporaryContact.ContactId__c = contact1.Id;
        objTemporaryContact.Requested_By__c = UserInfo.getUserId();
        objTemporaryContact.OwnerId = UserInfo.getUserId();
        insert objTemporaryContact;

        contact1.AddEditTempContactID__c = objTemporaryContact.Id;
        contact1.Community_User__c = contact1User.Id;
        update contact1;

        Contact con1 = [SELECT Id, Community_User__c, AddEditTempContactID__c FROM Contact WHERE Id = :contact1.Id];

        system.assertEquals(objTemporaryContact.Id, con1.AddEditTempContactID__c);
        system.assertEquals(contact1User.Id, con1.Community_User__c);

        User contextuser = [SELECT Id FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];

        test.startTest();
        system.RunAs(contextuser){
            PageReference pageRef = Page.NV_ListPartnerContacts;
            Test.setCurrentPageReference(pageRef);
            NV_ListContactExtension controllerExt = new NV_ListContactExtension();
            controllerExt.resonForRemoval = 'Delete for testing';
            pageRef.getParameters().put('contactId',contact1.Id);
            pageRef.getParameters().put('actionToPerform','Delete');
            controllerExt.getContacts();
            controllerExt.getTemporaryContacts();
            controllerExt.getBulkContactRequests();
            controllerExt.checkContactStatus();
            controllerExt.removeContact();
        }
        test.stopTest();
    }

    @isTest
    static void methodFive(){

        List<Account> acctList = [SELECT Id FROM Account WHERE Name IN ('TestAcct1','TestAcct2')];

        User contextuser = [SELECT Id FROM User WHERE Username = 'nvvippartnerone@foo.com.crqext'];

        String parentId =acctList[0].Id;
        String attachmentId ='';
        String fileName ='acd.xlsx';
        String contentType ='';
        String base64BlobValue='w4lXJ8OqwrFBw6Vpw7Ukfg0pf0dWwoPCicOXw5bCqRsdc0pJa8Ouw7zD';

        String attachmentIdStr = NV_ListContactExtension.attachBlob(parentId,  attachmentId,  fileName,  contentType, base64BlobValue);
        system.assertNotEquals(null, attachmentIdStr);

        String sendEmailRet = NV_ListContactExtension.sendEmail(attachmentIdStr);

        system.assertEquals(null, sendEmailRet);

    }
}