/*
	Date Created: 2016.09.08
	Author: Paresh Jena
	
	Schedulable Apex Class to sync Opportunity record's Primary Customer Contact and Primary Contact Role from Primary Opportunity Contact Role related list (only if there is a mismatch)
	
	Commad to schedule the apex through Developer Console
	------------------------------------------------------
	CRM_OCR_Sync_Scheduler p = new CRM_OCR_Sync_Scheduler();
	DateTime currDT = DateTime.now().addMinutes(2);
	integer sec = currDT.second();
	integer min = currDT.minute();
	String sch = sec + ' ' + min + ' ' + '* ? * *'; //0 5 * * * ?
	system.debug('sch: ' + sch);
	system.schedule('Exec of CRM_OCR_Sync_Scheduler', sch, p);
	
	Change Lists:
	
*/


public class CRM_OCR_Sync_Scheduler implements Schedulable{
	
    public void execute(SchedulableContext sc) {
    	//Lookback Time in Minutes
		dateTime dtJobLookBackTime;
		integer iJobExecFrequency;
		integer iJobBatchSize;
		boolean isJobScheduleEnabled;
		
		try{
			decimal dJobLookbackDuration  = OCR_Settings__c.getOrgDefaults().Job_Lookback_Duration__c ; //in minutes
			system.debug('***dJobLookbackDuration in minutes: ' + dJobLookbackDuration);
			decimal dJobExecFrequency  = OCR_Settings__c.getOrgDefaults().Job_Exec_Frequency__c ;
			decimal dJobBatchSize = OCR_Settings__c.getOrgDefaults().Job_Batch_Size__c ;
			isJobScheduleEnabled = OCR_Settings__c.getOrgDefaults().Job_Schedule_Enabled__c;
			
			dtJobLookBackTime = DateTime.now().addMinutes(integer.valueOf(-dJobLookbackDuration));
			iJobExecFrequency = integer.valueOf(dJobExecFrequency);
			iJobBatchSize = integer.valueOf(dJobBatchSize);
		} catch(Exception ex){
			system.debug('***Value could not be fetched from CRM : OCR : Settings for Job_Lookback_Duration__c/Job_Exec_Frequency OR It could be running in TEST context');
			system.debug('***Exception: ' + ex);
			
			//set the default lookback to 24 hours and recurrence to every 5 miutes
			dtJobLookBackTime = DateTime.now().addHours(-24);
			iJobExecFrequency = 5; //5 minutes
			iJobBatchSize = 10;//batch size is 10
			isJobScheduleEnabled = true; //always on for test execution
		}
		
		//configuratuion parameters
		system.debug('***Job CRM_OCR_Sync_Scheduler***');
		system.debug('***dtJobLookBackTime: ' + dtJobLookBackTime);
		system.debug('***iJobExecFrequency: ' + iJobExecFrequency);
		system.debug('***iJobBatchSize: ' + iJobBatchSize);
		system.debug('***isJobScheduleEnabled: ' + isJobScheduleEnabled);

		
		if (isJobScheduleEnabled){
			//Get All Primary Opportunity Contact Roles withing the configured timeframe
			list<OpportunityContactRole> lstOCRs = [ 	Select OpportunityId, ContactId, Role 
														From OpportunityContactRole
														Where IsPrimary = true 
															And LastModifiedDate >= :dtJobLookBackTime LIMIT :iJobBatchSize]; //putting a limit of 100 for being safe so that it does not hit the governor limits
			//build a map of Opportunty Id and OCR from the list of OCRs
			map<Id, OpportunityContactRole> mapOppIdOCRs = new map<Id, OpportunityContactRole>();
			for (OpportunityContactRole ocr : lstOCRs){
				mapOppIdOCRs.put(ocr.OpportunityId, ocr);
			}
			
			//Get sub set of pportunities with unmatching Primary Contact and Role as that of OCR
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
			
			//------------------Re-Schedule Job and abort the existing one----------------------------------------------------------------
			DateTime nextScheduleTime = system.now().addMinutes(iJobExecFrequency);
	      	string minute = string.valueof(nextScheduleTime.minute());
	      	string second = string.valueof(nextScheduleTime.second ());
	      	string cronValue = second + ' ' + minute + ' * * * ?' ;
	      	string jobName = 'CRM_OCR_Sync_Scheduler - ' + nextScheduleTime.format('hh:mm');
	 
	    	CRM_OCR_Sync_Scheduler oSchCls = new CRM_OCR_Sync_Scheduler();
	    	system.schedule(jobName, cronValue , oSchCls);
	 
	    	// this section of code will abort the current schedule job
	    	system.abortJob(sc.getTriggerId());
	    	//------------------End: Re-Schedule Job--------------------------------------------------------------
			
		} else{ //otherwise Abort the job
			//---------------------Abort the Job. Need to restart the job manually--------------------------------------
			system.debug('***Abrorting the Job as the Flag OCR_Settings__c.getOrgDefaults().Job_Schedule_Enabled__c is set to Off');
			system.debug('***Admin has to set this flag to true in custom settings and run the following script in developer console');
			system.debug('CRM_OCR_Sync_Scheduler p = new CRM_OCR_Sync_Scheduler()');
			system.debug('system.schedule(\'Exec of CRM_OCR_Sync_Scheduler\', \'0 2 * ? * *\' , p)');
			
			system.abortJob(sc.getTriggerId());
			//---------------------End: Abort the Job. Need to schdeule the job manually--------------------------------------
		}
    }
}