/*
	2018.11.25 - pjena - Batch class to Add PBMs to Opportunity Team
	
	It needs to be scheduled manually from Dev Console for the first time and afterwards it will run from the configuration present in Custom Settings named CRM_AddPBMsAsOpptyTeamMember_Settings__c
	PBMsAsOpptyTeamMember_Settings__c.BATCHJOB_LKBK_TIME__c - Defines the lookback time in minutes. 
					All Users that got created or modified from this lookback time till current time are processed by this job
	PBMsAsOpptyTeamMember_Settings__c.BATCHJOB_RECUR__c - Defines recurring frequency in minutes. 
					The job repeats execution based on this time gap.
	PBMsAsOpptyTeamMember_Settings__c.BATCHJOB_ENABLE_SCHDULED_JOB__c - Flag to enable or disable the job.
					This is an automatic way to abort the scheduled job. Once it is aborted the job needs to be sc manually thru the Dev Console.
	PBMsAsOpptyTeamMember_Settings__c.BATCHJOB_BATCH_SIZE__c - Number of records processed in each batch.
					If the callout takes more time then reduce the batch size.
					
	Commad to schedule the apex through Developer Console
	
	CRM_AddPBMsAsOpptyTeamMember_Batch p = new CRM_AddPBMsAsOpptyTeamMember_Batch();
	DateTime currDT = DateTime.now().addMinutes(2);
	integer sec = currDT.second();
	integer min = currDT.minute();
	String sch = sec + ' ' + min + ' ' + '* ? * *'; //0 5 * * * ?
	system.debug('sch: ' + sch);
	system.schedule('Exec of CRM_AddPBMsAsOpptyTeamMember_Batch', sch, p);
*/
public class CRM_AddPBMsAsOpptyTeamMember_Batch implements Database.Batchable<SObject>, System.Schedulable{
	//Lookback Time and recurrig time in Minutes
    private decimal dRecurTime;
    private decimal dLookBackTime;
    private decimal dBatchSize;
    private boolean isJobEnabled = true;
    
    private integer iRecurTime;
	private DateTime dtLookBackTime;
	private integer iBatchSize;
	private string strTeamRole;

	
	private static final string OPP_TYPE = 'Deal Registration';
	
	//Constructor accepting next execution time in minutes and the lookback time
    public CRM_AddPBMsAsOpptyTeamMember_Batch(){
    	system.debug('********Begin: Constructor: CRM_AddPBMsAsOpptyTeamMember_Batch()**************');
    	try{
    		dRecurTime  = CRM_AddPBMsAsOpptyTeamMember_Settings__c.getOrgDefaults().RECUR__c ; //in minutes
			dLookBackTime  = CRM_AddPBMsAsOpptyTeamMember_Settings__c.getOrgDefaults().LKBK_TIME__c ; //in minutes
			dBatchSize = CRM_AddPBMsAsOpptyTeamMember_Settings__c.getOrgDefaults().BATCH_SIZE__c;
			isJobEnabled = CRM_AddPBMsAsOpptyTeamMember_Settings__c.getOrgDefaults().ENABLE_SCHDULED_JOB__c;
			strTeamRole = CRM_AddPBMsAsOpptyTeamMember_Settings__c.getOrgDefaults().Team_Role__c;

			//set the global variable
			iRecurTime = integer.valueOf(dRecurTime);
			dtLookBackTime = DateTime.now().addMinutes(integer.valueOf(-dLookBackTime));
			iBatchSize = integer.valueOf(dBatchSize);
		} catch(Exception ex){
			system.debug('***Value could not be set from parameters, so setting the default lookback to 1 hour and recurrence to every 60 minutes');
			system.debug('***Exception: ' + ex);
			
			//set the default lookback to 1 hour and recurrence to every 30 minutes
			iRecurTime = 30; //30 minutes
			dtLookBackTime = DateTime.now().addHours(-1);
			iBatchSize = 25;
			isJobEnabled = true; //always on for test execution
			strTeamRole = 'Channel Manager (PBM)';
		}
		
		system.debug('***Value from Settings: dRecurTime (RECUR__c) = ' + dRecurTime);
		system.debug('***Value from Settings: dLookBackTime (LKBK_TIME__c) = ' + dLookBackTime);
		system.debug('***Value from Settings: dBatchSize (BATCH_SIZE__c) = ' + iBatchSize);
		system.debug('***Value from Settings: isJobEnabled (ENABLE_SCHDULED_JOB__c) = ' + isJobEnabled);
		system.debug('***Value from Settings: isJobEnabled (Team_Role__c) = ' + strTeamRole);
		
		system.debug('***Value set to iRecurTime = ' + iRecurTime);
		system.debug('***Value set to dtLookBackTime = ' + dtLookBackTime);
		system.debug('***Value set to iBatchSize = ' + iBatchSize);
		system.debug('********End: Constructor: CRM_AddPBMsAsOpptyTeamMember_Batch()**************');
    }
    
    //Schedulable interface method implementation. 
	//When you schedule the class DR_OPPREG_SAP_SYNC_Batch to run at a specific interval, it will run the this execute method which in turn will call the batch apex methods
	public void execute(SchedulableContext sc){
		
		//Run the code if the Job is enabled else abort the job
		//--------------------------------------------------------------------------------------------
		if (isJobEnabled){
			system.debug('---------Start: Execute method of the scheduled class; it fires the executeBatch method to invoke the batch job and reschdules the scheduled class to run at the set interval ------------------');
			//Invoke the batch job
			CRM_AddPBMsAsOpptyTeamMember_Batch oCRM_AddPBMsAsOpptyTeamMember_Batch = new CRM_AddPBMsAsOpptyTeamMember_Batch();
			database.executeBatch(oCRM_AddPBMsAsOpptyTeamMember_Batch, iBatchSize);
			system.debug('---------End: Execute method of the scheduled class; it fires the executeBatch method to invoke the batch job and reschdules the scheduled class to run at the set interval ------------------');
		
			//------------------Re-Schedules Job and aborts the old job that already fired the executeBatch method----------------------------------------------
			system.debug('------------------Start: Re-Schedules Job and aborts the old job that already fired the executeBatch method---------------------------');
			DateTime nextScheduleTime = system.now().addMinutes(iRecurTime);
	      	string minute = string.valueof(nextScheduleTime.minute());
	      	string second = string.valueof(nextScheduleTime.second ());
	      	string cronValue = second + ' ' + minute + ' * * * ?' ;
	      	string jobName = 'CRM_AddPBMsAsOpptyTeamMember_Batch - ' + nextScheduleTime.format('hh:mm');
	 
	    	CRM_AddPBMsAsOpptyTeamMember_Batch oSchCls = new CRM_AddPBMsAsOpptyTeamMember_Batch();
	    	system.schedule(jobName, cronValue , oSchCls);
	 
	 		system.debug('------------------End: Re-Schedules Job and aborts the old job that already fired the executeBatch method---------------------------');
	 		
	    	// this section of code will abort the current schedule job
	    	system.abortJob(sc.getTriggerId());
	    	//------------------End: Re-Schedules Job and aborts the old job that already fired the executeBatch method----------------------------------------------
			
		}else{
			//---------------------Abort the Job. Need to restart the job manually--------------------------------------
			system.debug('***Abrorting the Job as the Flag DR_SAP_SYNC_Settings__c.getOrgDefaults().BATCHJOB_ENABLE_SCHDULED_JOB__c is set to Off');
			system.debug('***Admin has to set this flag to true in custom settings and run the following script in developer console');
			system.debug('CRM_AddPBMsAsOpptyTeamMember_Batch p = new CRM_AddPBMsAsOpptyTeamMember_Batch()');
			system.debug('system.schedule(\'Exec of CRM_AddPBMsAsOpptyTeamMember_Batch\', \'0 2 * ? * *\' , p)');
			
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
		return Database.getQueryLocator([	Select id, NPN_Solution_Provider_VAR__r.OwnerId, (Select Id, Name, OpportunityId, UserId, TeamMemberRole From OpportunityTeamMembers)
											From Opportunity
											Where IsClosed = false
											And NPN_Solution_Provider_VAR__c <> null
											And (LastModifiedDate >= :dtLookBackTime OR NPN_Solution_Provider_VAR__r.LastModifiedDate >= :dtLookBackTime)
										]);
	}

	
	public void execute(Database.BatchableContext BC, List<sObject> scope){
		system.debug('---------Entering Batch Job execute method-------------------');
		if (scope != null && !scope.isEmpty()){
			try{
				list<Opportunity> lstOpps = (List<Opportunity>) scope;
				system.debug('***lstOpps > ' + lstOpps);
				list<OpportunityTeamMember> listOTMsToInsert = new list<OpportunityTeamMember>();			
				for (Opportunity opp : lstOpps){
					set<string> sExistingTeamMembers = new set<string>();
					list<OpportunityTeamMember> listExistingOTM = new list<OpportunityTeamMember>();
					listExistingOTM = opp.OpportunityTeamMembers;
					if (!listExistingOTM.isEmpty()){
						for (OpportunityTeamMember otm : listExistingOTM){
							sExistingTeamMembers.add(otm.UserId);
						}
					}
					
					if (!sExistingTeamMembers.contains(opp.NPN_Solution_Provider_VAR__r.OwnerId)){
						listOTMsToInsert.add(new OpportunityTeamMember(OpportunityId = opp.Id, UserId = opp.NPN_Solution_Provider_VAR__r.OwnerId, TeamMemberRole = strTeamRole, OpportunityAccessLevel = 'Edit'));
					}
				}
				system.debug('***listOTMsToInsert : ' + listOTMsToInsert);
				Database.SaveResult[] lstSR = database.insert(listOTMsToInsert, false);
				system.debug('***lstSR : ' + lstSR);

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