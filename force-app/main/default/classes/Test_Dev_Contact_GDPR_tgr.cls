/*
 Author: Jasek Arent
 Comments:
    Test class for Dev_Contact_GDPR_tgr

*/
@isTest (SeeAllData=false)
public class Test_Dev_Contact_GDPR_tgr {
    
    @testSetup static void setUpDevContact() {
        
       Dev_Account__c devAccount = new Dev_Account__c();
       devAccount.Dev_Account_Name__c = 'TestDevAccount';
       insert devAccount;
        
       Dev_Contact__c devContact = new Dev_Contact__c();
       devContact.Dev_Account_Name__c = devAccount.Id;
       devContact.First_Name__c = 'TestFirstName';
       devContact.Last_Name__c = 'TestLastName';
       devContact.Email__c = 'testlastname20200414001@iamai.com';
       devContact.Email2__c = 'testlastname@iamai2.com';
       devContact.Source_User_ID__c = 'GDPR_TEST_1';
       devContact.Industry_Segment_Vertical__c = 'HPC';
       insert devContact;
        
       devContact = new Dev_Contact__c();
       devContact.Dev_Account_Name__c = devAccount.Id;
       devContact.First_Name__c = 'TestFirstName';
       devContact.Last_Name__c = 'TestLastName';
       devContact.Email__c = 'testIsAnonymized@iamai.com';
       devContact.Source_User_ID__c = 'GDPR_TEST_2';
       devContact.Industry_Segment_Vertical__c = 'HPC';
       insert devContact; 
        
       devContact = new Dev_Contact__c();
       devContact.Dev_Account_Name__c = devAccount.Id;
       devContact.First_Name__c = 'TestFirstName';
       devContact.Last_Name__c = 'TestLastName';
       devContact.Email__c = 'testlastname3@iamai.com';
       devContact.Source_User_ID__c = 'GDPR_TEST_3';
       devContact.Industry_Segment_Vertical__c = 'HPC';
       insert devContact;
    }
    
    @isTest
    static void Should_Anonymize_PII_Data() {
   
        Dev_Contact__c devContact = [SELECT ID, Anonymized__c FROM Dev_Contact__c WHERE Source_User_ID__c = 'GDPR_TEST_1'];
        System.assert(devContact != null);
        
        devContact.Anonymized__c = true;
        devContact.Anonymization_Reason__c = 'Privacy Data Delete Request';
        
        update devContact;        
        
        devContact = [SELECT ID, Email__c, Email2__c, Last_Name__c, First_Name__c, Anonymization_Reason__c FROM Dev_Contact__c WHERE Source_User_ID__c = 'GDPR_TEST_1'];
        
        System.assert(devContact.Email__c.contains('iamai.com'), 'Email domain must be preserved');
        System.assert(devContact.Email2__c.contains('iamai2.com'), 'Email domain must be preserved');
        
        System.debug(devContact.Last_Name__c);
        System.debug(devContact.First_Name__c);
        System.debug(devContact.Email__c);
        System.debug(devContact.Email2__c);
        System.debug(devContact.Anonymization_Reason__c);
    }
    
    @isTest
    static void Should_Not_Allow_For_Reverting_Anonymized() {
        Dev_Contact__c devContact = [SELECT ID, Anonymized__c FROM Dev_Contact__c WHERE Source_User_ID__c = 'GDPR_TEST_2'];
        System.assert(devContact != null);
        
        devContact.Anonymized__c = true;
        devContact.Anonymization_Reason__c = 'Privacy Data Delete Request';
        
        update devContact;
        
        devContact.Anonymized__c = false;
        
        try {
            update devContact;
            System.assert(false, 'Should fail update');
        } catch (Exception e) {
            System.debug('Expected error: ' + e);
        }
        
        devContact.Anonymized__c = true;
        
        try {
            update devContact;
            System.assert(false, 'Should fail update');
        } catch (Exception e) {
            System.debug('Expected error: ' + e);
        }
        
    }
    
    @isTest
    static void Should_Require_Anonymization_Reasone() {
   
        Dev_Contact__c devContact = [SELECT ID, Anonymized__c FROM Dev_Contact__c WHERE Source_User_ID__c = 'GDPR_TEST_3'];
        System.assert(devContact != null);
        
        devContact.Anonymized__c = true;
        
        try {
            update devContact;
            System.assert(false, 'Should fail update');
        } catch (Exception e) {
            System.debug('Expected error: ' + e);
        }    
    }
    
    @isTest
    static void Should_Fail_Insert_Anonymized() {
       Dev_Account__c devAccount = [SELECT ID FROM Dev_Account__c WHERE Dev_Account_Name__c = 'TestDevAccount'];
        
       Dev_Contact__c devContact = new Dev_Contact__c();
       devContact.Dev_Account_Name__c = devAccount.Id;
       devContact.First_Name__c = 'TestFirstName';
       devContact.Last_Name__c = 'TestLastName';
       devContact.Email__c = 'willfail@iamai.com';
       devContact.Source_User_ID__c = 'GDPR_TEST_FAIL';
       devContact.Industry_Segment_Vertical__c = 'HPC';
       devContact.Anonymized__c = true;
       
       try {
            insert devContact;
            System.assert(false, 'Should fail insert');
        } catch (Exception e) {
            System.debug('Expected error: ' + e);
        }    
    }

}