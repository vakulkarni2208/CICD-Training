/*
 * Schedulable Batch Class for the 'Certification' object
 * Author: Manideep
 * Created Date: 12/01/2020
 * JIRA # SDS-2793
 * Description: This Schedulable Batch Class is being scheduled to run everyday in the night. 
                * This is created as for the project 'DLI/DMS 2.0: Display Certified instructor Active/Inactive at Contact & Certification level'.
                * This Batch class query's the Certification object records and will invoke the helper class 'CRM_Certification_Update_BAT_Helper.cls'                       
*/
public Class CRM_Certification_Update_BAT_SCH implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
  public final String Query;
  list<String> oppStagesToExcludeList = new list<String>();
  
  // Constructor
  public CRM_Certification_Update_BAT_SCH() {
    Query = runQuery();
  }
  
  // method to form Dynamic SOQL query.
  public string runQuery() {
    
    String queryString;
    
    queryString = 'SELECT Id, isCertification_Active__c, is_Certification_Active_Formula__c ' 
                   + 'FROM Certifications__c '
                   + 'WHERE (isCertification_Active__c = TRUE AND is_Certification_Active_Formula__c = FALSE) '
                   + 'OR (isCertification_Active__c = FALSE AND is_Certification_Active_Formula__c = TRUE)';                                                
    system.debug('queryString---->'+queryString); 
      
    return queryString;
  } 
   
  public Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(Query); 
  } 
  
  public void execute(Database.BatchableContext BC, List<Certifications__c> certificationScopeList) {
    // invoke the helper class to process all Certifications
    CRM_Certification_Update_BAT_Helper.executeBatch_Helper(certificationScopeList);    
  } 
  
  public void finish(Database.BatchableContext BC) {}
    
  // execute method of Schedule Class
  public void execute(SchedulableContext SC) {
    //invoke Batch Class
    CRM_Certification_Update_BAT_SCH certificationUpdateBatch = new CRM_Certification_Update_BAT_SCH();
    Id batchinstanceid = database.executeBatch(certificationUpdateBatch, 20);
  } 
   
}