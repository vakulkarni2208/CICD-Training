@isTest(seeAllData=false)
private class NPN_Test_TempContactHelper {

    @testSetup static void setup() {

        NV_NPN_TestDataFactory.setupCustomSettings();
        
        Id accRecTypeId     = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();
        Id contactRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        List<Account> testAccts = new List<Account>();
        List<Temporary_Contact__c> testTempContacts = new List<Temporary_Contact__c>();
        List<Partner_Attribute__c> testPartnerAttrb = new List<Partner_Attribute__c>();

        Id profileId = [SELECT Id FROM Profile WHERE Name = :COMM_Constants.PROF_PP_TPP_GENERIC LIMIT 1].Id;
        for(Integer i=0; i<2; i++) {
            testAccts.add(
                new Account(
                    Name                        = 'TestAcct'+i,
                    RecordTypeId                = accRecTypeId,
                    NPN_Program_Signed_Date__c  = Date.valueOf(System.today())
                    )
                );
        }
        insert testAccts;


        testPartnerAttrb.add(
            new Partner_Attribute__c(
                Account_Name__c             = testAccts[0].id,
                Partner_Competency__c       = COMM_Constants.TEST_PORTAL_COMPETENCY_GV,
                Partner_Program_Name__c     = COMM_Constants.PA_PROGRAM_SP,
                Program_Level__c            = COMM_Constants.PA_LEVEL_PREF,
                Date_Competency_Signed__c   = Date.valueOf(system.today())
                )
            );

        testPartnerAttrb.add(
            new Partner_Attribute__c(
                Account_Name__c             = testAccts[0].id,
                Partner_Competency__c       = COMM_Constants.TEST_PORTAL_COMPETENCY_DL,
                Partner_Program_Name__c     = COMM_Constants.PA_PROGRAM_SA,
                Program_Level__c            = COMM_Constants.PA_LEVEL_PREF,
                Date_Competency_Signed__c   = Date.valueOf(system.today())
                )
            );

        testPartnerAttrb.add(
            new Partner_Attribute__c(
                Account_Name__c             = testAccts[1].id,
                Partner_Competency__c       = COMM_Constants.TEST_PORTAL_COMPETENCY_GV,
                Partner_Program_Name__c     = COMM_Constants.PA_PROGRAM_SA,
                Program_Level__c            = COMM_Constants.PA_LEVEL_PREF,
                Date_Competency_Signed__c   = Date.valueOf(system.today())
                )
            );

        testPartnerAttrb.add(
            new Partner_Attribute__c(
                Account_Name__c             = testAccts[1].id,
                Partner_Competency__c       = COMM_Constants.TEST_PORTAL_COMPETENCY_AC,
                Partner_Program_Name__c     = COMM_Constants.PA_PROGRAM_SA,
                Program_Level__c            = COMM_Constants.PA_LEVEL_PREF,
                Date_Competency_Signed__c   = Date.valueOf(system.today())
                )
            );

        insert testPartnerAttrb;
        
        Contact contact1 = new Contact();
        contact1.FirstName      =   'Jake';
        contact1.LastName       =   'Paul';
        contact1.Email          =   'jake.paul@abc.com';
        contact1.Phone          =   '789-978-5529';
        contact1.AccountId      =   testAccts[1].Id;
        contact1.Role__c        =   'Sales';
        contact1.Title          =   'Sales Analyst';
        contact1.RecordTypeId   =   contactRecTypeId;
        insert contact1;

        User commUsr = new User();
        commUsr.FirstName           =   'Jake';
        commUsr.LastName            =   'Paul';
        commUsr.Email               =   'jake.paul@abc.com';
        commUsr.Phone               =   '789-978-5529';
        commUsr.Alias               =   'jliv';
        commUsr.Username            =   'jake.paul@abc.com.community';
        commUsr.ProfileId           =   profileId;
        commUsr.TimeZoneSidKey      =   'GMT';
        commUsr.LanguageLocaleKey   =   'en_US';
        commUsr.EmailEncodingKey    =   'UTF-8';
        commUsr.LocaleSidKey        =   'en_US';
        commUsr.ContactId           =   contact1.Id;
        commUsr.IsActive            =   true;
        insert commUsr;

        contact1.Community_User__c  =  commUsr.Id;
        update contact1;

        Temporary_Contact__c temp = new Temporary_Contact__c();
        temp.First_Name__c  =   'John';
        temp.Last_Name__c   =   'Doe';
        temp.Email__c       =   'john.doe@abc.com';
        temp.Phone__c       =   '789-978-5569';
        temp.Account_Id__c  =   testAccts[0].Id;
        temp.Role__c        =   'Technical';
        temp.Title__c       =   'Lead analyst';
        testTempContacts.add(temp);

        Temporary_Contact__c temp1 = new Temporary_Contact__c();
        temp1.First_Name__c     =   'Jake';
        temp1.Last_Name__c      =   'Paul';
        temp1.Email__c          =   'jake.paul@abc.com';
        temp1.Phone__c          =   '789-978-5522';
        temp1.Account_Id__c     =   testAccts[1].Id;
        temp1.Role__c           =   'Sales';
        temp1.Title__c          =   'Sales Analyst';
        temp1.ContactId__c      =   contact1.Id;
        temp.Partner_User__c    =   contact1.Community_User__c;
        testTempContacts.add(temp1);

        insert testTempContacts;
    }

    @isTest static void newContactReqTest() {

        Map<Id,Temporary_Contact__c> tempContacts = new Map<Id, Temporary_Contact__c> ([SELECT Id, Status__c FROM Temporary_Contact__c]);

        system.assertEquals(2,tempContacts.size());

        Test.startTest();
        for(Temporary_Contact__c tc : tempContacts.values()) {
            tc.Status__c = 'Completed';
            tc.Action_Requested__c  = 'New';
        }

        update tempContacts.values();
        Test.stopTest();
        system.assertEquals('Completed',tempContacts.values()[0].Status__c);
    }

    @isTest static void updateRequestTest() {

        Map<Id,Temporary_Contact__c> tempContacts = new Map<Id, Temporary_Contact__c> ([SELECT Id, Status__c FROM Temporary_Contact__c]);
        system.assertEquals(2, tempContacts.size());

        Test.startTest();
        for(Temporary_Contact__c tc : tempContacts.values()) {
            tc.Role__c = 'Partner Primary Contact; Technical';
            tc.Status__c = 'Completed';
            tc.Action_Requested__c  = 'Update - (Role)';
        }
        update tempContacts.values();
        Test.stopTest();
        system.assertEquals('Completed',tempContacts.values()[0].Status__c);
    }

    @isTest static void newContactReqRejectedtTest() {

        Map<Id,Temporary_Contact__c> tempContacts = new Map<Id, Temporary_Contact__c> ([SELECT Id, Status__c FROM Temporary_Contact__c]);
        system.assertEquals(2, tempContacts.size());

        Test.startTest();
        for(Temporary_Contact__c tc : tempContacts.values()) {
            tc.Status__c = 'Rejected';
            tc.Action_Requested__c  = 'Update - (Role)';
        }
        update tempContacts.values();
        Test.stopTest();
        system.assertEquals('Rejected',tempContacts.values()[0].Status__c);
    }

    @isTest static void ContactDisableReqTest() {

        Map<Id,Temporary_Contact__c> tempContacts = new Map<Id, Temporary_Contact__c> ([SELECT Id, Status__c FROM Temporary_Contact__c]);
        system.assertEquals(2, tempContacts.size());

        Test.startTest();
        for(Temporary_Contact__c tc : tempContacts.values()) {
            tc.Status__c = 'Completed';
            tc.Action_Requested__c = 'Deactivate';
        }
        update tempContacts.values();
        Test.stopTest();
        system.assertEquals('Completed',tempContacts.values()[0].Status__c);
        system.assertEquals('Deactivate',tempContacts.values()[0].Action_Requested__c);
    }
}