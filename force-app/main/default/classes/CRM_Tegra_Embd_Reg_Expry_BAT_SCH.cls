/*
 * Schedulable Batch Class for the 'Opportunity' object
 * Author: Manideep
 * Created Date: 02/14/2020
 * JIRA # SDS-1493
 * Description: This Schedulable Batch Class is being scheduled to run everyday in the night. 
                * This is created as for the project 'Tegra Embedded Partner Expirations'.
                * This Batch class query's the Opportunity object records and will invoke the helper class 'CRM_Tegra_Embd_Reg_Exp_BAT_Helper.cls'  
                * Exclude the Opportunities those that don't have the PBM/ChannelAdmin by checking the field 'DR_SalesOps_Approver__c' is not null which will get populated through Lead Conversion from the Lead
                  (or) from the custom setting 'Jetson DR : Channel Admins'.                     
*/
public Class CRM_Tegra_Embd_Reg_Expry_BAT_SCH implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
  public final String Query;
  list<String> oppStagesToExcludeList = new list<String>();
  
  // Constructor
  public CRM_Tegra_Embd_Reg_Expry_BAT_SCH() {
    Query = runQuery();
  }
  
  // method to form Dynamic SOQL query.
  public string runQuery() {
    // RecordType Id of Opportunity Record Type 'Tegra Embedded Partner Opportunity'
    Id OppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(COMM_Constants.OPPTY_RT_TEGRA_EMBEDDED_PARTNER_OPPTY).getRecordTypeId();
    String queryString;
    
    //Extract the data from the type 'Hierarchy' Custom Setting Organization level
    Tegra_Embedded_Registration_Expirations__c tegraEmbdRegExpCS = Tegra_Embedded_Registration_Expirations__c.getOrgDefaults();
    
    oppStagesToExcludeList = string.valueOf(tegraEmbdRegExpCS.Opportunity_Stages_to_Exclude__c).split(';');
    system.debug('oppStagesToExcludeList----->'+oppStagesToExcludeList);
                       
    queryString = 'SELECT Id, Name, RecordTypeId, OwnerId, Owner.Name, Owner.Email, AccountId, DR_Partner_Sales_Rep_Company__c, DR_SalesOps_Approver__c, DR_SalesOps_Approver__r.isActive, DR_SalesOps_Approver__r.Email, ' 
                   + 'Opportunity_Expired__c, Opportunity_Expiration_Date__c, LastModifiedDate_by_Partner__c '
                   + 'FROM Opportunity '
                   + 'WHERE Opportunity_Expired__c != TRUE AND LastModifiedDate_by_Partner__c != null AND DR_SalesOps_Approver__c != null AND RecordTypeId = \''+ OppRTId + '\' '
                   + 'AND StageName NOT IN:oppStagesToExcludeList';
                                                     
    system.debug('queryString---->'+queryString); 
      
    return queryString;
  } 
   
  public Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(Query); 
  } 
  
  public void execute(Database.BatchableContext BC, List<Opportunity> opptyScope) {
    // invoke the helper class to process all Opportunities
    CRM_Tegra_Embd_Reg_Expry_BAT_SCH_Helper.excuteBatch_Helper(opptyScope);    
  } 
  
  public void finish(Database.BatchableContext BC) {}
    
  // execute method of Schedule Class
  public void execute(SchedulableContext SC) {
    //invole Batch Class
    CRM_Tegra_Embd_Reg_Expry_BAT_SCH tegraOppExpBatch = new CRM_Tegra_Embd_Reg_Expry_BAT_SCH();
    Id batchinstanceid = database.executeBatch(tegraOppExpBatch, 100);
  } 
   
}