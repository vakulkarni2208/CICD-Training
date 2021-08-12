/*
  * @Author: Moon (Perficient)
  * @Created Date: Jan 28, 2018
  * @Desc:  Purpose is to associate the announcements to the new customer accounts on the Customer Announcement junction object.
  *         Please find below the criteria for eligible account(s) to be processed 
  *         - Record type 'New Customer Account'
  *         - Must have entitlements belonging to product family DGX or Grid
  *         This batch job is invoked by the Announcement Trigger 
  *         Currently, the Announcement Trigger invokes this job for 'Generic' announcements only
*/
global class Batch_InsertAnncAccount implements Database.Batchable<sObject> {
    Set<Id> anncIdSet;
    string strAccessLevel;
    String query;
    
    global Batch_InsertAnncAccount(Set<Id> tmpAnncIdSet, string strAccessLevel) {
        anncIdSet = tmpAnncIdSet;
        if(strAccessLevel=='Generic') 
            query = 'SELECT Id FROM Account WHERE RecordType.DeveloperName = \'New_Customer_Account\' and Id IN (SELECT AccountId FROM Entitlement WHERE Product_Family__c != null AND (Product_Family__c like \'%DGX%\' OR Product_Family__c like \'%Grid%\'))';
        else if(strAccessLevel=='Product Specific')
            query = 'SELECT Id FROM Account WHERE RecordType.DeveloperName = \'New_Customer_Account\' and Id IN (SELECT AccountId FROM Entitlement WHERE Product_Family__c != null AND status = \'Active\')';           
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<CustomerAnnouncement__c> juncList = new List<CustomerAnnouncement__c>();
        List<Account> acctList = scope;
        for(Account acct : acctList){
            for(Id anncId : anncIdSet){
                CustomerAnnouncement__c junc = new CustomerAnnouncement__c();
                junc.Announcement__c = anncId;
                junc.Account__c = acct.Id;
                juncList.add(junc);
            }
        }
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.allowFieldTruncation = true;
        try{
            insert juncList;
        }catch(Exception e){            
            Service_Cloud_Error_Log__c iError = new Service_Cloud_Error_Log__c(Functionality_Name__c = 'Customer Announcement Batch Insert', Error_Type__c = 'SALESFORCE BATCH', Error_Description__c = 'Soql query: ' + query + '\n Error: ' + e.getMessage());
            iError.setOptions(dml);
            insert iError;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}