/*
	Service Cloud : Create/Update Entitlements from Subscription
	It was done to decouple the process builders on CPQ Subcription object
	The intent is to create Entitlement record for each Subscription and sync the Subscription information to Entitlements (for subscriptions updated either today or in last 2 days).
	
	Assumption: Subscriptions created by svcDeploy (with profile=System Administrator) OR svcDataWriter (Profile=SVC SAP Integration) are only accounted.
	Automatic subscriptions are created from SAP PO uses svcDataWriter (when orders are fulfilled)
	Manual subscriptions are created by IT CPQ team using svcDeploy user
	
	
	It needs to be scheduled manually from Dev Console for the first time and afterwards it will run from the configuration present in Custom Settings named ESP_CreateEntFromSubscr_Settings__c
	ESP_CreateEntFromSubscr_Settings__c.LKBK_TIME__c - Defines the lookback time in minutes. 
					All Users that got created or modified from this lookback time till current time are processed by this job
	ESP_CreateEntFromSubscr_Settings__c.RECUR__c - Defines recurring frequency in minutes. 
					The job repeats execution based on this time gap.
	ESP_CreateEntFromSubscr_Settings__c.ENABLE_SCHDULED_JOB__c - Flag to enable or disable the job.
					This is an automatic way to abort the scheduled job. Once it is aborted the job needs to be sc manually thru the Dev Console.
	ESP_CreateEntFromSubscr_Settings__c.BATCH_SIZE__c - Number of records processed in each batch.
					If the callout takes more time then reduce the batch size.
					
	Commad to schedule the apex through Developer Console
	
	ESP_CreateEntFromSubscr_Sch p = new ESP_CreateEntFromSubscr_Sch();
	DateTime currDT = DateTime.now().addMinutes(2);
	integer sec = currDT.second();
	integer min = currDT.minute();
	String sch = sec + ' ' + min + ' ' + '* ? * *'; //0 5 * * * ?
	system.debug('sch: ' + sch);
	system.schedule('Create/Update Entitlements from Subscription', sch, p);
	
	Improvements Note : Batch could have been ideal but there is a future funtion on the Entitlement trigger which prevents a batch to update the entitlements. When that restrictions is removed, we can rewrite it as a batch apex.
* Akhilesh: 07/24/2019: Added logic to populate "Service Product".
* Akhilesh: 09/04/2019: Added logic to Truncate Entitlement Name.
*/
public with sharing class ESP_CreateEntFromSubscr_Sch implements System.Schedulable {
	
	//Lookback Time and recurrig time in Minutes
    private decimal dRecurTime;
    private decimal dLookBackTime;
    private decimal dBatchSize;
    private boolean isJobEnabled = true;
    
    private integer iRecurTime;
	private DateTime dtLookBackTime;
	private integer iBatchSize;
    
    //Constructor accepting next execution time in minutes and the lookback time
    public ESP_CreateEntFromSubscr_Sch(){
        system.debug('********Begin: Constructor: ESP_CreateEntFromSubscr_Sch()**************');

    	dRecurTime  	= ESP_CreateEntFromSubscr_Settings__c.getOrgDefaults().RECUR__c ; //in minutes
		dLookBackTime  	= ESP_CreateEntFromSubscr_Settings__c.getOrgDefaults().LKBK_TIME__c ; //in minutes
		dBatchSize 		= ESP_CreateEntFromSubscr_Settings__c.getOrgDefaults().BATCH_SIZE__c;
		isJobEnabled 	= ESP_CreateEntFromSubscr_Settings__c.getOrgDefaults().ENABLE_SCHDULED_JOB__c;
			
		//set the global variable
		iRecurTime 		= integer.valueOf(dRecurTime);
		dtLookBackTime 	= DateTime.now().addMinutes(integer.valueOf(-dLookBackTime));
		iBatchSize 		= integer.valueOf(dBatchSize);
		
		system.debug('***iRecurTime = ' + iRecurTime);
		system.debug('***Current Time is = ' + Datetime.now());
		system.debug('***dtLookBackTime = ' + dtLookBackTime);
		system.debug('***iBatchSize = ' + iBatchSize);
		
        system.debug('********End: Constructor: ESP_CreateEntFromSubscr_Sch()**************');
    }
    
    
	public void execute(SchedulableContext sc){
		//Run the code if the Job is enabled else abort the job
		//--------------------------------------------------------------------------------------------
		if (isJobEnabled){
			system.debug('---------Start: Execute method of the scheduled class; it fires the executeBatch method to invoke the batch job and reschdules the scheduled class to run at the set interval ------------------');
			//Invoke the batch job
			processSubscriptions();
			system.debug('---------End: Execute method of the scheduled class; it fires the executeBatch method to invoke the batch job and reschdules the scheduled class to run at the set interval ------------------');
		
			//------------------Re-Schedules Job and aborts the old job that already fired the executeBatch method----------------------------------------------
			system.debug('------------------Start: Re-Schedules Job and aborts the old job that already fired the executeBatch method---------------------------');
			DateTime nextScheduleTime = system.now().addMinutes(iRecurTime);
	      	string minute = string.valueof(nextScheduleTime.minute());
	      	string second = string.valueof(nextScheduleTime.second ());
	      	string cronValue = second + ' ' + minute + ' * * * ?' ;
	      	string jobName = 'ESP_CreateEntFromSubscr_Sch - ' + nextScheduleTime.format('hh:mm');
	 
	    	ESP_CreateEntFromSubscr_Sch oSchCls = new ESP_CreateEntFromSubscr_Sch();
	    	system.schedule(jobName, cronValue , oSchCls);
	 
	 		system.debug('------------------End: Re-Schedules Job and aborts the old job that already fired the executeBatch method---------------------------');
	 		
	    	// this section of code will abort the current schedule job
	    	system.abortJob(sc.getTriggerId());
	    	//------------------End: Re-Schedules Job and aborts the old job that already fired the executeBatch method----------------------------------------------
		}else{
			//---------------------Abort the Job. Need to restart the job manually--------------------------------------
			system.debug('***Abrorting the Job as the Flag SP_CreateEntFromSubscr_Settings__c.getOrgDefaults().ENABLE_SCHDULED_JOB__c is set to Off');
			system.debug('***Admin has to set this flag to true in custom settings and run the following script in developer console');
			system.debug('ESP_CreateEntFromSubscr_Sch p = new ESP_CreateEntFromSubscr_Sch()');
			system.debug('system.schedule(\'Exec of SOCRM_IDM_UserMgmt_Batch\', \'0 2 * ? * *\' , p)');
			
			system.abortJob(sc.getTriggerId());
			//---------------------End: Abort the Job. Need to schdeule the job manually--------------------------------------
		}
	}
    
    public void processSubscriptions(){
    	system.debug('---------Entering processSubscriptions() method-------------------');
    	
    	list<SBQQ__Subscription__c> lstSub = new list<SBQQ__Subscription__c>();
    	list<Entitlement> lstEntToInsertUpd = new list<Entitlement>();
    	
    	//set the global variable again
    	dRecurTime  	= ESP_CreateEntFromSubscr_Settings__c.getOrgDefaults().RECUR__c ; //in minutes
		dLookBackTime  	= ESP_CreateEntFromSubscr_Settings__c.getOrgDefaults().LKBK_TIME__c ; //in minutes
		dBatchSize 		= ESP_CreateEntFromSubscr_Settings__c.getOrgDefaults().BATCH_SIZE__c;
		isJobEnabled 	= ESP_CreateEntFromSubscr_Settings__c.getOrgDefaults().ENABLE_SCHDULED_JOB__c;
		
		iRecurTime 		= integer.valueOf(dRecurTime);
		dtLookBackTime 	= DateTime.now().addMinutes(integer.valueOf(-dLookBackTime));
		iBatchSize 		= integer.valueOf(dBatchSize);
		system.debug('***iRecurTime = ' + iRecurTime);
		system.debug('***Current Time is = ' + Datetime.now());
		system.debug('***dtLookBackTime used in the query = ' + dtLookBackTime);
		system.debug('***iBatchSize = ' + iBatchSize);
        //end: set the global variables
        
		lstSub =  [	SELECT s.Name, s.SBQQ__StartDate__c, s.SBQQ__RenewedDate__c, s.SBQQ__RenewalQuantity__c, s.SBQQ__RenewalPrice__c, s.SBQQ__RegularPrice__c, 
						s.SBQQ__Product__c, SBQQ__Product__r.Description, s.SBQQ__EndDate__c, s.SBQQ__Contract__r.EndDate, s.SBQQ__Account__c, s.Renewed_PAK_ID__c, s.Renewed_Entitlement_ID__c, 
						s.PAK_ID__c, s.Id, s.Hardware_Serial_Number__c, s.Entitlement_ID__c, s.ESP_Contract_End_Date__c, s.CreatedDate, (Select Id From Entitlements__r ) 
			      	FROM SBQQ__Subscription__c s 
			      	WHERE s.LastModifiedDate > :dtLookBackTime AND (s.CreatedBy.Profile.Name = 'System Administrator' OR s.CreatedBy.Profile.Name = 'SVC SAP Integration')];
				      
        if (lstSub != null && !lstSub.isEmpty()){
        	try{
				For (SBQQ__Subscription__c sub : lstSub){
					list<Entitlement> lstEnt = new list<Entitlement>();
					lstEnt = sub.Entitlements__r;
                    String entName = string.IsBlank(sub.Hardware_Serial_Number__c) ? sub.PAK_ID__c  + '-' + sub.SBQQ__Product__r.Description : sub.Hardware_Serial_Number__c + '-' + sub.SBQQ__Product__r.Description;
					if (lstEnt.isEmpty()){
						Entitlement ent 	= new Entitlement();
						ent.Subscription__c = sub.Id;
						ent.AccountId 		= sub.SBQQ__Account__c;
						ent.Name 			= entName.left(80);//substring(0,80);//string.IsBlank(sub.Hardware_Serial_Number__c) ? sub.PAK_ID__c  + '-' + sub.SBQQ__Product__r.Description : sub.Hardware_Serial_Number__c + '-' + sub.SBQQ__Product__r.Description;
						ent.StartDate 		= sub.SBQQ__StartDate__c;
						ent.EndDate 		= sub.SBQQ__Contract__r.EndDate;
						ent.PAK_ID__c 		= sub.PAK_ID__c;
						ent.Product__c 		= sub.SBQQ__Product__c;
						ent.Regular_Price__c= sub.SBQQ__RegularPrice__c;
						ent.Renewal_Price__c= sub.SBQQ__RenewalPrice__c;
						ent.Renewed_Date__c = sub.SBQQ__RenewedDate__c;
						ent.Renewed_PAK_ID__c 		= sub.Renewed_PAK_ID__c;
						ent.Renewal_Quantity__c		= sub.SBQQ__RenewalQuantity__c;
						ent.Service_Product__c 		= sub.SBQQ__Product__c;
						ent.Entitlement_ID_SAP__c	= sub.Entitlement_ID__c;
						ent.Renewed_Entitlement_ID__c = sub.Renewed_Entitlement_ID__c;
						ent.Hardware_Serial_Number__c = sub.Hardware_Serial_Number__c;
						lstEntToInsertUpd.add(ent);
					} else {
						for (Entitlement existingEnt : lstEnt){
							existingEnt.Name 		= entName.left(80);//string.IsBlank(sub.Hardware_Serial_Number__c) ? sub.PAK_ID__c  + '-' + sub.SBQQ__Product__r.Description : sub.Hardware_Serial_Number__c + '-' + sub.SBQQ__Product__r.Description;
							existingEnt.StartDate 	= sub.SBQQ__StartDate__c;
							existingEnt.EndDate 	= sub.SBQQ__Contract__r.EndDate;
							existingEnt.PAK_ID__c 	= sub.PAK_ID__c;
							existingEnt.Regular_Price__c 	= sub.SBQQ__RegularPrice__c;
							existingEnt.Renewal_Price__c 	= sub.SBQQ__RenewalPrice__c;
							existingEnt.Renewal_Quantity__c = sub.SBQQ__RenewalQuantity__c;
							existingEnt.Renewed_Date__c 	= sub.SBQQ__RenewedDate__c;
							existingEnt.Renewed_PAK_ID__c 	= sub.Renewed_PAK_ID__c;
							existingEnt.Hardware_Serial_Number__c = sub.Hardware_Serial_Number__c;
							existingEnt.Renewed_Entitlement_ID__c = sub.Renewed_Entitlement_ID__c;
							lstEntToInsertUpd.add(existingEnt);
						}
					}
				}
			
				system.debug('***lstEntToInsertUpd: ' + lstEntToInsertUpd.size());
			
				if (!lstEntToInsertUpd.isEmpty()){
					Database.UpsertResult[] lstSR = database.upsert(lstEntToInsertUpd, false);
					
					list<Service_Cloud_Error_Log__c> lstEntCRUDStatus = new list<Service_Cloud_Error_Log__c>();
					for (integer i = 0; i < lstSR.size(); i++){
						Database.UpsertResult sr = lstSR[i];
						Service_Cloud_Error_Log__c entCRUDError = new Service_Cloud_Error_Log__c();
						entCRUDError.Functionality_Name__c = 'ESP_CreateEntFromSubscr_Sch';
						if (!sr.isSuccess()){
							// Operation failed, so get all errors 
							system.debug('The following error has occurred.');
							entCRUDError.Error_Type__c = 'EntitlementSync Failure';	
							string errorDetails = 'Id erred = ' + lstEntToInsertUpd[i].Id +  ' |err.StatusCode = ' + sr.getErrors()[0].getStatusCode() + ' |err.getFields() =' + sr.getErrors()[0].getFields() + ' | err.getStatusCode() = ' + sr.getErrors()[0].getStatusCode() + ' | err.getMessage() = ' +sr.getErrors()[0].getMessage();
							entCRUDError.Error_Description__c = errorDetails;
							system.debug('***errorDetails: ' + errorDetails);
						}else{
							// Operation was successful, so get the ID of the record that was processed
							system.debug('Successfully Created/Edited Entitlement.Id: ' + sr.getId());
							entCRUDError.Error_Type__c = 'EntitlementSync Success';
							entCRUDError.Error_Description__c = 'Successfully Created/Edited Entitlement.Id: ' + sr.getId();
						}
						lstEntCRUDStatus.add(entCRUDError);
					}
					
					//insert the stauts to Service_Cloud_Error_Log__c object
					if (!lstEntCRUDStatus.isEmpty()){
						Database.insert(lstEntCRUDStatus, false);
					}
				}
        	}  catch(Exception ex){
				system.debug('***exception: ' + ex);
				Service_Cloud_Error_Log__c entCRUDError = new Service_Cloud_Error_Log__c();
				entCRUDError.Functionality_Name__c = 'ESP_CreateEntFromSubscr_Sch';
				entCRUDError.Error_Type__c = 'EntitlementSync Failure';	
				string errorDetails = 'Apex Exception::[getCause=' + ex.getCause()  + '], [ExceptionType=  ' + ex.getTypeName() +'], [message=  ' + ex.getMessage()  +'],  [StackTraceString ='+ ex.getStackTraceString();
				entCRUDError.Error_Description__c = errorDetails;
				system.debug('***errorDetails: ' + errorDetails);
        	}
        }
        system.debug('---------Exiting processSubscriptions() method-------------------');
    }
}