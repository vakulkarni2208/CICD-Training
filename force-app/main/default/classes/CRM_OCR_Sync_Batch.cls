/*
	Batchable and Schedulable Apex
	
	The job needs to sync all Opportunity record's Primary Contact and Primary Customer Contact Role from Primary Opportunity Contact Role related list (only if there is a mismatch)
	
	It is configurable to only consider the records from a specific date (e.g., the Primary OCRs whose last modified date is 1/1/2010) and the batc size
	
	It is intended to run only once at the begining to sync all OCRs but can be used when the adhoc job (CRM_OCR_Sync_Scheduler) that runs every 2-5 minutes could not pick up certain records or stopped working for any reason
	Note: After each execution you need to delete the next scheduled job instance
	
	It can be scheduled from UI or if granular schedule is needed then you can do it through developer console
	Commad to schedule the apex through Developer Console which schdules it to run every 1 hours
	----------------------------------------------------------------------------------------
	CRM_OCR_Sync_Batch p = new CRM_OCR_Sync_Batch();
	DateTime currDT = DateTime.now().addMinutes(60);
	integer sec = currDT.second();
	integer min = currDT.minute();
	String sch = sec + ' ' + min + ' ' + '* ? * *'; //0 5 * * * ?
	system.debug('sch: ' + sch);
	system.schedule('Exec of CRM_OCR_Sync_Batch', sch, p);
	
	Change Lists:
	
*/

public class CRM_OCR_Sync_Batch implements Database.Batchable<SObject>, Database.Stateful, System.Schedulable{
	
	public datetime dtBatchJobLookbackDateTime;
	integer iJobBatchSize;
	
	//constructor
	public CRM_OCR_Sync_Batch(){
		system.debug('---------Entering Batch Apex Constructor-------------------');
		
		//get the value form custom settings CRM : OCR : Settings
		dtBatchJobLookbackDateTime = OCR_Settings__c.getOrgDefaults().Batch_Job_Lookback_Date__c;
		iJobBatchSize = integer.valueOf(OCR_Settings__c.getOrgDefaults().Job_Batch_Size__c);
		system.debug('***dtBatchJobLookbackDateTime: ' + dtBatchJobLookbackDateTime);
		system.debug('***iJobBatchSize: ' + iJobBatchSize);
		
		system.debug('---------Exiting Batch Apex Constructor-------------------');
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC){
		system.debug('---------Entering Batch Job start method-------------------');
		
		//get all the Opportunity Contact Roles whose last modified date >= the configured
		return Database.getQueryLocator([	Select OpportunityId, ContactId, Role 
											From OpportunityContactRole
											Where IsPrimary = true 
												And LastModifiedDate >= :dtBatchJobLookbackDateTime
										]);
	}
	
	public void execute(Database.BatchableContext BC, List<sObject> scope){
		system.debug('---------Entering Batch Job execute method-------------------');
		
		//update the Opportunities with mismatched Primary Contact and Role
		if (scope != null && !scope.isEmpty()){
			
			//get hold of list of OCRs from the scope object
			list<OpportunityContactRole> lstOCRs = (List<OpportunityContactRole>) scope;
			
			//build a map of Opportunty Id and OCR from the list of OCRs
			map<Id, OpportunityContactRole> mapOppIdOCRs = new map<Id, OpportunityContactRole>();
			for (OpportunityContactRole ocr : lstOCRs){
				mapOppIdOCRs.put(ocr.OpportunityId, ocr);
			}
			
			//Get sub set of pportunities with unmatching Primary Customer Contact and Role as that of OCR
			list<Opportunity> lstOpps = [	Select DR_Customer_Contact__c, Primary_Contact_Role__c
											From Opportunity
											Where Id = :mapOppIdOCRs.keyset()];
			
			list<Opportunity> lstOppsToSync = new list<Opportunity>();
			for (Opportunity opp : lstOpps){
				if (opp.DR_Customer_Contact__c != mapOppIdOCRs.get(opp.Id).ContactId || opp.Primary_Contact_Role__c != mapOppIdOCRs.get(opp.Id).Role){
					lstOppsToSync.add(opp);
				}
			} 
			
			system.debug('***Total Opportunties with mismatched Contact Role in this schedule run: ' + lstOppsToSync.size());
			
			//if there are disconnected oppty records then update it with value from OCR
			if (!lstOppsToSync.isEmpty()){
				//list<Opportunity> lstOppsToUpdateFromOCR = new list<Opportunity>();
				for (Opportunity opp : lstOppsToSync){
					opp.DR_Customer_Contact__c = mapOppIdOCRs.get(opp.Id).ContactId;
					opp.Primary_Contact_Role__c =  mapOppIdOCRs.get(opp.Id).Role;
				}
				
				list<Database.SaveResult> lstDSR = database.update(lstOppsToSync, false);
				
				//Debugging of failure and successes
				for (integer i = 0; i < lstOppsToSync.size(); i++){
					Database.SaveResult dsr = lstDSR[i];
					Opportunity opp = lstOppsToSync[i];
					
					if (!dsr.isSuccess()){
						system.debug('***Failed Update: Opprtunity Record Id : ' + opp.Id + ' with Primary Customer Contact Id = ' + opp.DR_Customer_Contact__c + ', and Role = ' + opp.Primary_Contact_Role__c);
						System.debug('***Error Message:' + dsr.getErrors()[0].getStatusCode() + ': ' + dsr.getErrors()[0].getMessage());
					} else{
						system.debug('***Sucessful Update: Opprtunity Record Id : ' + opp.Id + ' with Primary Customer Contact Id = ' + opp.DR_Customer_Contact__c + ', and Role = ' + opp.Primary_Contact_Role__c);
					}
				}
			}
			
		}
		system.debug('---------Exiting Batch Job execute method-------------------');
	}
	
	public void finish(Database.BatchableContext BC){
		system.debug('---------Entering Batch Job finish method-------------------');
		system.debug('---------Exiting Batch Job finish method-------------------');
	}
	
	
	//Schedulable interface method implementation. 
	//When you schedule the class CRM_OCR_Sync_Batch to run at a specific interval, it will run the this execute method which in turn will call the batch apex methods
	public void execute(SchedulableContext SC){
		system.debug('---------Scheduler module for Batch Job Starts-------------------');

		system.debug('---------Scheduled Batch Job Starts-------------------');

		CRM_OCR_Sync_Batch CRMOCRSyncBatch = new CRM_OCR_Sync_Batch();
		database.executeBatch(CRMOCRSyncBatch, iJobBatchSize);
		system.debug('---------Scheduled Batch Job Ends-------------------');
		
		system.debug('---------Scheduler module for Batch Job Ends-------------------');
		
	}
	
	
	
    
}