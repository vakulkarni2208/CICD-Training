/*
	2018.06.02 - PJENA - Scedulable batch class to Sync Community User Data to its Community Contact Record
	
	/COMM_Sync_CommUserDataToContactRec_Batch p = new COMM_Sync_CommUserDataToContactRec_Batch();
	//Run every 60 minutes and look back 60 minitues and batch size = 25
	COMM_Sync_CommUserDataToContactRec_Batch p = new COMM_Sync_CommUserDataToContactRec_Batch();
	DateTime currDT = DateTime.now().addMinutes(2);
	integer sec = currDT.second();
	integer min = currDT.minute();
	String sch = sec + ' ' + min + ' ' + '* ? * *'; //0 5 * * * ?
	system.debug('sch: ' + sch);
	system.schedule('Exec of COMM_Sync_CommUserDataToContactRec_Batch', sch, p);
	
	2018.06.19 - PJENA - Bug fix - inclusion of contact reonboarding case
	
*/

public class COMM_Sync_CommUserDataToContactRec_Batch implements Database.Batchable<SObject>, Database.Stateful, System.Schedulable{
	
    //Lookback Time and recurrig time in Minutes
    private decimal dRecurTime;
    private decimal dLookBackTime;
    private decimal dBatchSize;
    private boolean isJobEnabled = true;
    
    private integer iRecurTime;
	private DateTime dtLookBackTime;
	private integer iBatchSize;
	
	
	//Constructor accepting next execution time in minutes and the lookback time
    public COMM_Sync_CommUserDataToContactRec_Batch(){
    	system.debug('********Begin: Constructor: COMM_Sync_CommUserDataToContactRec_Batch()**************');
    	try{
    		dRecurTime  = Community_Settings__c.getOrgDefaults().BATCHJOB_U2CSync_RECUR__c ; //in minutes
			dLookBackTime  = Community_Settings__c.getOrgDefaults().BATCHJOB_U2CSync_LKBK_TIME__c ; //in minutes
			dBatchSize = Community_Settings__c.getOrgDefaults().BATCHJOB_U2CSync_BATCH_SIZE__c;
			isJobEnabled = Community_Settings__c.getOrgDefaults().BATCHJOB_U2CSync_ENABLE_SCHDULED_JOB__c;
			
			//set the global variable
			iRecurTime = integer.valueOf(dRecurTime);
			dtLookBackTime = DateTime.now().addMinutes(integer.valueOf(-dLookBackTime));
			iBatchSize = integer.valueOf(dBatchSize);
			
			
		} catch(Exception ex){
			system.debug('***Value could not be set from parameters, so setting the default lookback to 1 hour and recurrence to every 60 minutes');
			system.debug('***Exception: ' + ex);
			
			//set the default lookback to 1 hour and recurrence to every 60 minutes
			iRecurTime = 60; //60 minutes
			dtLookBackTime = DateTime.now().addHours(-1);
			iBatchSize = 25;
			isJobEnabled = true; //always on for test execution
		}
		
		system.debug('***Value from Settings: dRecurTime (BATCHJOB_U2CSync_RECUR__c) = ' + dRecurTime);
		system.debug('***Value from Settings: dLookBackTime (BATCHJOB_U2CSync_LKBK_TIME__c) = ' + dLookBackTime);
		system.debug('***Value from Settings: dBatchSize (BATCHJOB_U2CSync_BATCH_SIZE__c) = ' + iBatchSize);
		system.debug('***Value from Settings: isJobEnabled (BATCHJOB_U2CSync_ENABLE_SCHDULED_JOB__c) = ' + isJobEnabled);
		
		system.debug('***Value set to iRecurTime = ' + iRecurTime);
		system.debug('***Value set to dtLookBackTime = ' + dtLookBackTime);
		system.debug('***Value set to iBatchSize = ' + iBatchSize);
		system.debug('********End: Constructor: COMM_Sync_CommUserDataToContactRec_Batch()**************');
    }
    
    //Schedulable interface method implementation. 
	//When you schedule the class COMM_Sync_CommUserDataToContactRec_Batch to run at a specific interval, it will run the this execute method which in turn will call the batch apex methods
	public void execute(SchedulableContext sc){
		
		//Run the code if the Job is enabled else abort the job
		//--------------------------------------------------------------------------------------------
		if (isJobEnabled){
			system.debug('---------Start: Execute method of the scheduled class; it fires the executeBatch method to invoke the batch job and reschdules the scheduled class to run at the set interval ------------------');
			//Invoke the batch job
			COMM_Sync_CommUserDataToContactRec_Batch oCOMMSyncU2CBatch = new COMM_Sync_CommUserDataToContactRec_Batch();
			database.executeBatch(oCOMMSyncU2CBatch, iBatchSize);
			system.debug('---------End: Execute method of the scheduled class; it fires the executeBatch method to invoke the batch job and reschdules the scheduled class to run at the set interval ------------------');
		
			//------------------Re-Schedules Job and aborts the old job that already fired the executeBatch method----------------------------------------------
			system.debug('------------------Start: Re-Schedules Job and aborts the old job that already fired the executeBatch method---------------------------');
			DateTime nextScheduleTime = system.now().addMinutes(iRecurTime);
	      	string minute = string.valueof(nextScheduleTime.minute());
	      	string second = string.valueof(nextScheduleTime.second ());
	      	string cronValue = second + ' ' + minute + ' * * * ?' ;
	      	string jobName = 'COMM_Sync_CommUserDataToContactRec_Batch - ' + nextScheduleTime.format('hh:mm');
	 
	    	COMM_Sync_CommUserDataToContactRec_Batch oSchCls = new COMM_Sync_CommUserDataToContactRec_Batch();
	    	system.schedule(jobName, cronValue , oSchCls);
	 
	 		system.debug('------------------End: Re-Schedules Job and aborts the old job that already fired the executeBatch method---------------------------');
	 		
	    	// this section of code will abort the current schedule job
	    	system.abortJob(sc.getTriggerId());
	    	//------------------End: Re-Schedules Job and aborts the old job that already fired the executeBatch method----------------------------------------------
			
		}else{
			//---------------------Abort the Job. Need to restart the job manually--------------------------------------
			system.debug('***Abrorting the Job as the Flag Community_Settings__c.getOrgDefaults().BATCHJOB_U2CSync_ENABLE_SCHDULED_JOB__c is set to Off');
			system.debug('***Admin has to set this flag to true in custom settings and run the following script in developer console');
			system.debug('COMM_Sync_CommUserDataToContactRec_Batch p = new COMM_Sync_CommUserDataToContactRec_Batch()');
			system.debug('system.schedule(\'Exec of COMM_Sync_CommUserDataToContactRec_Batch\', \'0 2 * ? * *\' , p)');
			
			system.abortJob(sc.getTriggerId());
			//---------------------End: Abort the Job. Need to schdeule the job manually--------------------------------------
		}
		
	}
	

	//*************************************************************************************************************************
	//	BATCH METHODs
	//*************************************************************************************************************************
	public Database.QueryLocator start(Database.BatchableContext BC){
		system.debug('*******Enters Batch Start Method');
		system.debug('***dtLookBackTime: ' + dtLookBackTime);
		return Database.getQueryLocator([	Select Id, ContactId, Community_ContactId__c
											From User 
											Where UserType <> 'Standard'
											And LastModifiedDate >= :dtLookBackTime
										]);
	}

	
	public void execute(Database.BatchableContext BC, List<sObject> scope){
		system.debug('---------Entering Batch Job execute method-------------------');
		if (scope != null && !scope.isEmpty()){
			try{
				list<User> lstCommunityUsers = (List<User>) scope;
				
				system.debug('***Users in this batch: ' + lstCommunityUsers);
				set<Id> setContactIdsInBatch = new set <Id>();
				map<Id, Id> mapContactIdUserId = new map<id, Id>();
		        for(User usr : lstCommunityUsers) {
					if (usr.ContactId != null){
						 setContactIdsInBatch.add(usr.ContactId);
						 mapContactIdUserId.put(usr.ContactId, usr.Id);
					}
					if (usr.Community_ContactId__c != null) setContactIdsInBatch.add(usr.Community_ContactId__c);
		        }
				
				//Query All Contacts
		        map<Id, Contact> mapCommunityContacts = new map<Id, Contact>([Select Id, Community_User__c From Contact where Id =  :setContactIdsInBatch]);
		        
		        list<Contact> communityContactsToUpdate = new list<Contact>();
		        
		        for(Contact con : mapCommunityContacts.values()) {
		        	//if contact.Community_User__c = blank but usr.ContactId != blank; then insert case so set the Contact.Community_User__c
		        	////2018.06.19 - PJENA - Bug fix - inclusion of contact reonboarding case - if contact.Community_User__c != blank and usr.ContactId != blank; and the Contact is reonboarded with another user before the sync job ran; update the Contact with the newly onborded user
		        	//if contact.Community_User__c != blank but usr.ContactId = blank; then disable case so blank out the Contact.Community_User__c
		        	
		        	if ( (con.Community_User__c == null && mapContactIdUserId.get(con.Id) != null)  || 
		        		 (con.Community_User__c != null && mapContactIdUserId.get(con.Id) != null && con.Community_User__c != mapContactIdUserId.get(con.Id)) ){
		        		 	
						communityContactsToUpdate.add(new Contact(id = con.Id, Community_User__c = mapContactIdUserId.get(con.Id)));
		        	} else if (con.Community_User__c != null && mapContactIdUserId.get(con.Id) == null){
		        		communityContactsToUpdate.add(new Contact(id = con.Id, Community_User__c = null));
		        	}
		        }
		
		        if(!communityContactsToUpdate.isEmpty()){
		        	Database.SaveResult[] lstSR = Database.update(communityContactsToUpdate, false);
					for (Database.SaveResult sr : lstSR) {
					    if (sr.isSuccess()) {
					        // Operation was successful, so get the ID of the record that was processed
					        System.debug('***Successfully Updated Contact: ' + sr.getId());
					    }
					    else {
					        // Operation failed, so get all errors                
					        for(Database.Error err : sr.getErrors()) {
					            System.debug('***The following error has occurred.');                    
					            System.debug(err.getStatusCode() + ': ' + err.getMessage());
					            System.debug('***Contact fields that affected this error: ' + err.getFields());
					        }
					    }
					}
		        }

			} catch(Exception ex){
				system.debug('***exception: ' + ex);
			}
			
		}
		system.debug('---------Exiting Batch Job execute method-------------------');
	}
	
	public void finish(Database.BatchableContext BC){
		system.debug('---------Entering Batch Job finish method-------------------');
		
		system.debug('---------Exiting Batch Job finish method-------------------');
	}
	
	//*************************************************************************************************************************
	//	End: BATCH METHODs
	//*************************************************************************************************************************
}