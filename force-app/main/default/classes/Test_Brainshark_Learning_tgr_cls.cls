/*
    Test class for Brainshark_Learning_tgr_cls.cls
    - Create a partner/customer account
    - Create a partner/customer contact with email address
    - Create brainshark learning recrods and check if the ContactId and AccountId is getting set with the matching email address
    
    2017.04.25 : CR : set BRNSHRK__SFDC_ID__c field to internal nvidia SFDC user Id with email having @nvidia.com and BRNSHRK__SFDC_ID__c is not already set
    
 */
@isTest(SeeAllData=false)
private class Test_Brainshark_Learning_tgr_cls {

    static testMethod void testSingleBSLRecordInsert() {
    
        //create NPN Community Lead which creates the Contact, Account and Customer User by the Lead trigger
        string brainSharkUserEmail = 'NPNbsl1@nv.com';
        string leadEmail = 'npnbsl1@nv.com';
        Lead l1 = new Lead(LastName = 'NPNLeadForBSLearning', Email = leadEmail, Lead_Orgin__c = COMM_Constants.LEAD_ORIGIN_NPN_COMMUNITY_WEB_FORM, Company='TEST-NPN-BSL');
        list<lead> lstLeads = new list<lead>();
        lstLeads.add(l1);
        insert lstLeads;
        
        test.startTest();
            //create brainshark learning record
            BRNSHRK__Brainshark_Learning__c bsLearning = new BRNSHRK__Brainshark_Learning__c(BRNSHRK__Course_Title__c = 'Title1', BRNSHRK__User_Email__c = brainSharkUserEmail);
            insert bsLearning;
            
            list<BRNSHRK__Brainshark_Learning__c> bsLearningDetails = [Select BRNSHRK__User_Email__c, SFDC_Contact_ID__c, SFDC_Account_ID__c From BRNSHRK__Brainshark_Learning__c Where Id = :bsLearning.Id];
            list<Contact> lstMatchingContacts = [   Select Email, AccountId 
                                                    From Contact
                                                    Where Email = :brainSharkUserEmail];
            system.assert(bsLearningDetails.size() == 1);
            system.assert(bsLearningDetails[0].SFDC_Contact_ID__c == lstMatchingContacts[0].Id);
            system.assert(bsLearningDetails[0].SFDC_Account_ID__c == lstMatchingContacts[0].AccountId);
        test.stopTest();
    }
    
    
    static testMethod void testMultiBSLRecordInsert() {
    
        //create NPN Community Lead which creates the Contact, Account and Customer User by the Lead trigger
        string brainSharkUserEmail = 'npnbsl2@nv.com';
        integer numRecordsToTest = 10;
        
        Lead l1 = new Lead(LastName = 'NPNLeadForBSLearning', Email = brainSharkUserEmail, Lead_Orgin__c = COMM_Constants.LEAD_ORIGIN_NPN_COMMUNITY_WEB_FORM, Company='TEST-NPN-BSL-2');
        list<lead> lstLeads = new list<lead>();
        lstLeads.add(l1);
        insert lstLeads;
        
        test.startTest();
            //create brainshark learning records
            list<BRNSHRK__Brainshark_Learning__c> lstBSLearnings = new list<BRNSHRK__Brainshark_Learning__c>();
            for (integer i = 0; i < numRecordsToTest; i++){
                lstBSLearnings.add (new BRNSHRK__Brainshark_Learning__c(BRNSHRK__Course_Title__c = 'Title' + i, BRNSHRK__User_Email__c = brainSharkUserEmail));
            }
            insert lstBSLearnings;
            
            list<BRNSHRK__Brainshark_Learning__c> bsLearningDetails = [Select BRNSHRK__User_Email__c, SFDC_Contact_ID__c, SFDC_Account_ID__c From BRNSHRK__Brainshark_Learning__c Where BRNSHRK__User_Email__c = :brainSharkUserEmail];
            
            list<Contact> lstMatchingContacts = [   Select Email, AccountId 
                                                    From Contact
                                                    Where Email = :brainSharkUserEmail];
            system.assert(bsLearningDetails.size() == numRecordsToTest);
            system.assert(bsLearningDetails[0].SFDC_Contact_ID__c == lstMatchingContacts[0].Id);
            system.assert(bsLearningDetails[0].SFDC_Account_ID__c == lstMatchingContacts[0].AccountId);
        test.stopTest();
    }
    
    static testMethod void testMultiBSLRecordInsertWithInternalUsers() {
        integer numRecordsToTest = 10;
        //get All Profiles
        list<string> lstProfNames = new list<string>{COMM_Constants.PROF_INT_PARTNER_ADMIN };
        map<string, Id> mapProfNameId = Test_COMM_Factory.getProfsByName(lstProfNames);
        
        //create internal users
        list<User> lstUsers = Test_COMM_Factory.createUsers(numRecordsToTest, mapProfNameId.get(COMM_Constants.PROF_INT_PARTNER_ADMIN));
        list<User> lstUsersQry = [Select Id, Email From User Where Id = :lstUsers];
        
        test.startTest();
            //create brainshark learning records
            set<string> setEmails = new set<string>();
            list<BRNSHRK__Brainshark_Learning__c> lstBSLearnings = new list<BRNSHRK__Brainshark_Learning__c>();
            for (integer i = 0; i < numRecordsToTest; i++){
                lstBSLearnings.add (new BRNSHRK__Brainshark_Learning__c(BRNSHRK__Course_Title__c = 'Title' + i, BRNSHRK__User_Email__c = lstUsersQry[i].Email));
                setEmails.add(lstUsersQry[i].Email);
            }
            insert lstBSLearnings;
            
            list<BRNSHRK__Brainshark_Learning__c> lstBSLearning = [Select BRNSHRK__User_Email__c, BRNSHRK__SFDC_ID__c, SFDC_Contact_ID__c, SFDC_Account_ID__c From BRNSHRK__Brainshark_Learning__c Where BRNSHRK__User_Email__c = :setEmails];
            for (BRNSHRK__Brainshark_Learning__c bsLearning : lstBSLearning){
                system.debug('***' + bsLearning.BRNSHRK__SFDC_ID__c + '----' + bsLearning.BRNSHRK__User_Email__c);
                system.assert(bsLearning.BRNSHRK__SFDC_ID__c != null);
            }
            
        test.stopTest();
    }
   
}