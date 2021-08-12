/*
  * @Author: Moon (Perficient)
  * @Created Date: Jan 28, 2018
  * @Desc:	Purpose is to withdraw the announcements for all customer accounts.
  *			- This batch job is invoked by the Announcement Trigger
  *			- The Announcement Trigger invokes this job for 'Archived' announcements only
  *			- Customer Announcement junction object records that reference the archived announcements are deleted by this job 
*/
global class Batch_DeleteAnncAccount implements Database.Batchable<sObject> {
	Set<Id> anncIdSet = new Set<Id>();
	String query;
	
	global Batch_DeleteAnncAccount(Set<Id> tempAnncIdSet) {
		if(tempAnncIdSet != null && !tempAnncIdSet.isEmpty()){
			anncIdSet = tempAnncIdSet;
		}
		query = 'SELECT ID FROM CustomerAnnouncement__c WHERE Announcement__c IN (';
		for(Id anncId : anncIdSet){
			query += '\''+anncId + '\' ,';
		}
		query = query.removeEnd(' ,');
		query += ')';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<CustomerAnnouncement__c> juncList = scope;
		Database.DMLOptions dml = new Database.DMLOptions();
		dml.allowFieldTruncation = true;
		try{
			delete juncList;
		}catch(Exception e){			
			Service_Cloud_Error_Log__c dError = new Service_Cloud_Error_Log__c(Functionality_Name__c = 'Customer Announcement Batch Delete', Error_Type__c = 'SALESFORCE BATCH', Error_Description__c = 'Soql query: ' + query + '\n Error: ' + e.getMessage());
			dError.setOptions(dml);
			insert dError;
		}		
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}