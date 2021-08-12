/*
 * Test class for the Batch/Schedulable/Helper Class 
 * Author: Manideep
 * Created Date: 12/01/2020
 * JIRA # SDS-2793
 * Description: This Test Class covers the code coverage of the classes below
                - CRM_Certification_Update_BAT_SCH.cls
                - CRM_Certification_Update_BAT_Helper.cls
 */

@isTest
public class CRM_Certification_Update_BAT_SCH_Test {
  
  /*
   * This method covers code coverage for "CRM_Certification_Update_BAT_SCH"
     and for its helper class "CRM_Certification_Update_BAT_Helper".
   */
  private static testMethod void insertActiveCertificationsandTSCsForBatch() {
      
     Account acc = new Account();
      acc.Name = 'Test Account' + 'CRM_Certification_Update_BAT_SCH_Test';
      acc.Industry = 'Other';
     insert acc;
     
     Contact ctc = new Contact();
      ctc.FirstName = 'Test Ctc';
      ctc.LastName = 'CRM_Certification_Update_BAT_SCH_Test' + 1;
      ctc.accountId = acc.Id;
      ctc.Email = 'testCRM_Certification_Update_BAT_SCH_Test@test.com';
     insert ctc;
     
     Training_Service_Catalog__c tsc = new Training_Service_Catalog__c();
      tsc.Name = 'undamentals of Deep Learning for Test Class';
      tsc.Industry_Segment__c = 'Fundamentals';
      tsc.Active__c = 'Active';
     insert tsc;
     
     Certifications__c certf = new Certifications__c();
      certf.Contact__c = ctc.Id;
      certf.Language__c = 'English';
      certf.Training_Service_Catalog__c = tsc.Id;
      certf.Certification_Date__c = Date.Today();
      certf.Certification_Status__c = 'Certified';
      certf.Expiration_Date__c = Date.Today() + 2;
      certf.isCertification_Active__c = True;
     insert certf;
          
     // Update the Trainning Service Catalog as 'inActive'
     tsc.Active__c = 'inActive';
     update tsc;
     
     Certifications__c certfQry1 = [SELECT Id, isCertification_Active__c, is_Certification_Active_Formula__c
                                    FROM Certifications__c 
                                    WHERE Id =:certf.Id];
     system.debug('certfQry1.is_Certification_Active_Formula__c----->'+certfQry1.is_Certification_Active_Formula__c);
     system.debug('certfQry1.isCertification_Active__c------->'+certfQry1.isCertification_Active__c);
     system.AssertEquals(certfQry1.is_Certification_Active_Formula__c, FALSE);
     system.AssertEquals(certfQry1.isCertification_Active__c, TRUE);
     
     // invoke the batch class
     Test.StartTest();
     CRM_Certification_Update_BAT_SCH schCertBatch1 = new CRM_Certification_Update_BAT_SCH();
     String schTime1 = '0 0 23 * * ?';
     system.schedule('Test check1', schTime1, schCertBatch1);
     Test.stopTest(); 
    
  } // end of insertActiveCertificationsandTSCsForBatch()
  
  /*
   * This method covers code coverage for "CRM_Certification_Update_BAT_SCH"
     and for its helper class "CRM_Certification_Update_BAT_Helper".
   * Scenario to fail the Certification Update process, so that the Database.error logic will execute.
   * In oder to pass this Test method, update the field 'Training_Service_Catalog__c' on Certification lookup filter from Optional to Required. 
     And rollback that to Optional again after running.
  */
  private static testMethod void failCertificationUpdateforBatch() {
      
     Account acc = new Account();
      acc.Name = 'Test Account' + 'CRM_Certification_Update_BAT_SCH_Test';
      acc.Industry = 'Other';
     insert acc;
     
     Contact ctc = new Contact();
      ctc.FirstName = 'Test Ctc';
      ctc.LastName = 'CRM_Certification_Update_BAT_SCH_Test' + 1;
      ctc.accountId = acc.Id;
      ctc.Email = 'testCRM_Certification_Update_BAT_SCH_Test@test.com';
     insert ctc;
     
     Training_Service_Catalog__c tsc = new Training_Service_Catalog__c();
      tsc.Name = 'undamentals of Deep Learning for Test Class';
      tsc.Industry_Segment__c = 'Fundamentals';
      tsc.Active__c = 'Active';
     insert tsc;
     
     Certifications__c certf = new Certifications__c();
      certf.Contact__c = ctc.Id;
      certf.Language__c = 'English';
      certf.Training_Service_Catalog__c = tsc.Id;
      certf.Certification_Date__c = Date.Today();
      certf.Certification_Status__c = 'Certified';
      certf.Expiration_Date__c = Date.Today() + 2;
      certf.isCertification_Active__c = True;
     insert certf;
         
     // Deactivate previously used Training Service Catalog
     Training_Service_Catalog__c tsc2 = [Select Id, Active__c from Training_Service_Catalog__c WHERE Id =:tsc.Id];
     tsc2.Active__c = 'Inactive';
     update tsc2;
     
     Certifications__c certfQry2 = [SELECT Id, isCertification_Active__c, is_Certification_Active_Formula__c
                                    FROM Certifications__c 
                                    WHERE Id =:certf.Id];
     system.debug('certfQry2.is_Certification_Active_Formula__c----->'+certfQry2.is_Certification_Active_Formula__c);
     system.debug('certfQry2.isCertification_Active__c------->'+certfQry2.isCertification_Active__c);
     system.AssertEquals(certfQry2.is_Certification_Active_Formula__c, FALSE);
     system.AssertEquals(certfQry2.isCertification_Active__c, TRUE);
     
     // invoke the batch class
     Test.StartTest();
     CRM_Certification_Update_BAT_SCH schCertBatch2 = new CRM_Certification_Update_BAT_SCH();
     String schTime2 = '0 0 23 * * ?';
     system.schedule('Test check2', schTime2, schCertBatch2);
     Test.stopTest(); 
     
     
  } // end of insertActiveCertificationsandTSCsForBatch()
  
  /*
   * This method covers code coverage for "CRM_Certification_Update_BAT_SCH"
     and for its helper class "CRM_Certification_Update_BAT_Helper".
  */
  /*
  private static testMethod void insertActiveCertificationsandTSCsForBatch2() {
  
     Account acc = new Account();
      acc.Name = 'Test Account' + 'CRM_Certification_Update_BAT_SCH_Test';
      acc.Industry = 'Other';
     insert acc;
     
     Contact ctc = new Contact();
      ctc.FirstName = 'Test Ctc';
      ctc.LastName = 'CRM_Certification_Update_BAT_SCH_Test' + 1;
      ctc.accountId = acc.Id;
      ctc.Email = 'testCRM_Certification_Update_BAT_SCH_Test@test.com';
     insert ctc;
     
     Training_Service_Catalog__c tsc = new Training_Service_Catalog__c();
      tsc.Name = 'undamentals of Deep Learning for Test Class';
      tsc.Industry_Segment__c = 'Fundamentals';
      tsc.Active__c = 'Active';
     insert tsc;
     
     Certifications__c certf = new Certifications__c();
      certf.Contact__c = ctc.Id;
      certf.Language__c = 'English';
      certf.Training_Service_Catalog__c = tsc.Id;
      certf.Certification_Date__c = Date.Today();
      certf.Expiration_Date__c = Date.Today() + 2;
     insert certf;
     
     Certifications__c certfQry1 = [SELECT Id, isCertification_Active__c, is_Certification_Active_Formula__c, Expiration_Date__c  
                                    FROM Certifications__c 
                                    WHERE Id =:certf.Id];
     system.debug('certfQry1.is_Certification_Active_Formula__c----->'+certfQry1.is_Certification_Active_Formula__c);
     system.debug('certfQry1.isCertification_Active__c------->'+certfQry1.isCertification_Active__c);
     
     system.AssertEquals(certfQry1.is_Certification_Active_Formula__c, TRUE);
     system.AssertEquals(certfQry1.isCertification_Active__c, FALSE);
     
     // invoke the batch class
     Test.StartTest();
     CRM_Certification_Update_BAT_SCH schCertBatch = new CRM_Certification_Update_BAT_SCH();
     String schTime = '0 0 23 * * ?';
     system.schedule('Test check', schTime, schCertBatch);
     Test.stopTest();
     
     // Pass the yesterdays date in the Expiration Date
     certfQry1.Expiration_Date__c = Date.Today() - 1;
     certfQry1.isCertification_Active__c =  True;
     update certfQry1;
     
     Certifications__c certfQry2 = [SELECT Id, isCertification_Active__c, is_Certification_Active_Formula__c
                                    FROM Certifications__c 
                                    WHERE Id =:certf.Id];
     certfQry2.Expiration_Date__c = Date.Today() - 1;
     update certfQry2;
  
     system.debug('certfQry2.is_Certification_Active_Formula__c----->'+certfQry2.is_Certification_Active_Formula__c);
     system.debug('certfQry2.isCertification_Active__c------->'+certfQry2.isCertification_Active__c);

     system.AssertEquals(certfQry2.is_Certification_Active_Formula__c, FALSE);
     system.AssertEquals(certfQry2.isCertification_Active__c, TRUE);
     
     // invoke the batch class
     Test.StartTest();
     CRM_Certification_Update_BAT_SCH schCertBatch2 = new CRM_Certification_Update_BAT_SCH();
     String schTime2 = '0 0 23 * * ?';
     system.schedule('Test check2', schTime2, schCertBatch2);
     Test.stopTest();
    
  } // end of insertActiveCertificationsandTSCsForBatch2()
  */  

}