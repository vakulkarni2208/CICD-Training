/*
	NPN IDM
	2017.09.12 - pjena - Batch class to manage IDM user creation/SOCRMAccessRole management
	It needs to be scheduled manually from Dev Console for the first time and afterwards it will run from the configuration present in Custom Settings named Community_Settings__c
	IDM_Settings__c.BATCHJOB_LKBK_TIME__c - Defines the lookback time in minutes. 
					All Users that got created or modified from this lookback time till current time are processed by this job
	IDM_Settings__c.BATCHJOB_RECUR__c - Defines recurring frequency in minutes. 
					The job repeats execution based on this time gap.
	IDM_Settings__c.BATCHJOB_ENABLE_SCHDULED_JOB__c - Flag to enable or disable the job.
					This is an automatic way to abort the scheduled job. Once it is aborted the job needs to be sc manually thru the Dev Console.
	IDM_Settings__c.BATCHJOB_BATCH_SIZE__c - Number of records processed in each batch.
					If the callout takes more time then reduce the batch size.
					
	Commad to schedule the apex through Developer Console
	
	SOCRM_IDM_UserMgmt_Batch p = new SOCRM_IDM_UserMgmt_Batch();
	DateTime currDT = DateTime.now().addMinutes(2);
	integer sec = currDT.second();
	integer min = currDT.minute();
	String sch = sec + ' ' + min + ' ' + '* ? * *'; //0 5 * * * ?
	system.debug('sch: ' + sch);
	system.schedule('Exec of SOCRM_IDM_UserMgmt_Batch', sch, p);
	
	2018.03.29 - pjena 	- Changes related to Service Cloud -	Do not invoke IDM API calls if you find there is any active Service Cloud users
						- Used CDATA section in the company name for escaping XML special characters
						- Used the IDM_API_Call_Failure__c = false, so if the failure happens for whatever reason the IDM API call will not happen for that user again
	2019.09.04 - pjena - LICENSING-186 (SDS-1663) - Update NPN Partner onboarding API to pass Country code to IDM. Ex: CN, US, DE..

*/

public class SOCRM_IDM_UserMgmt_Batch implements Database.Batchable<SObject>, Database.Stateful, System.Schedulable, Database.AllowsCallouts{
	
    //Lookback Time and recurrig time in Minutes
    private decimal dRecurTime;
    private decimal dLookBackTime;
    private decimal dBatchSize;
    private boolean isJobEnabled = true;
    
    private integer iRecurTime;
	private DateTime dtLookBackTime;
	private integer iBatchSize;
	
	
	//Constructor accepting next execution time in minutes and the lookback time
    public SOCRM_IDM_UserMgmt_Batch(){
    	system.debug('********Begin: Constructor: SOCRM_IDM_UserMgmt_Batch()**************');
    	try{
    		dRecurTime  = IDM_Settings__c.getOrgDefaults().BATCHJOB_RECUR__c ; //in minutes
			dLookBackTime  = IDM_Settings__c.getOrgDefaults().BATCHJOB_LKBK_TIME__c ; //in minutes
			dBatchSize = IDM_Settings__c.getOrgDefaults().BATCHJOB_BATCH_SIZE__c;
			isJobEnabled = IDM_Settings__c.getOrgDefaults().BATCHJOB_ENABLE_SCHDULED_JOB__c;
			
			//set the global variable
			iRecurTime = integer.valueOf(dRecurTime);
			dtLookBackTime = DateTime.now().addMinutes(integer.valueOf(-dLookBackTime));
			iBatchSize = integer.valueOf(dBatchSize);
			
			
		} catch(Exception ex){
			system.debug('***Value could not be set from parameters, so setting the default lookback to 1 hour and recurrence to every 60 minutes');
			system.debug('***Exception: ' + ex);
			
			//set the default lookback to 1 hour and recurrence to every 30 minutes
			iRecurTime = 60; //60 minutes
			dtLookBackTime = DateTime.now().addHours(-1);
			iBatchSize = 25;
			isJobEnabled = true; //always on for test execution
		}
		
		system.debug('***Value from Settings: dRecurTime (BATCHJOB__RECUR__c) = ' + dRecurTime);
		system.debug('***Value from Settings: dLookBackTime (BATCHJOB_LKBK_TIME__c) = ' + dLookBackTime);
		system.debug('***Value from Settings: dBatchSize (BATCHJOB_BATCH_SIZE__c) = ' + iBatchSize);
		system.debug('***Value from Settings: isJobEnabled (BATCHJOB_ENABLE_SCHDULED_JOB__c) = ' + isJobEnabled);
		
		system.debug('***Value set to iRecurTime = ' + iRecurTime);
		system.debug('***Value set to dtLookBackTime = ' + dtLookBackTime);
		system.debug('***Value set to iBatchSize = ' + iBatchSize);
		system.debug('********End: Constructor: SOCRM_IDM_UserMgmt_Batch()**************');
    }
    
    //Schedulable interface method implementation. 
	//When you schedule the class SOCRM_IDM_UserMgmt_Batch to run at a specific interval, it will run the this execute method which in turn will call the batch apex methods
	public void execute(SchedulableContext sc){
		
		//Run the code if the Job is enabled else abort the job
		//--------------------------------------------------------------------------------------------
		if (isJobEnabled){
			system.debug('---------Start: Execute method of the scheduled class; it fires the executeBatch method to invoke the batch job and reschdules the scheduled class to run at the set interval ------------------');
			//Invoke the batch job
			SOCRM_IDM_UserMgmt_Batch oSOCRM_IDM_UserMgmt_Batch = new SOCRM_IDM_UserMgmt_Batch();
			database.executeBatch(oSOCRM_IDM_UserMgmt_Batch, iBatchSize);
			system.debug('---------End: Execute method of the scheduled class; it fires the executeBatch method to invoke the batch job and reschdules the scheduled class to run at the set interval ------------------');
		
			//------------------Re-Schedules Job and aborts the old job that already fired the executeBatch method----------------------------------------------
			system.debug('------------------Start: Re-Schedules Job and aborts the old job that already fired the executeBatch method---------------------------');
			DateTime nextScheduleTime = system.now().addMinutes(iRecurTime);
	      	string minute = string.valueof(nextScheduleTime.minute());
	      	string second = string.valueof(nextScheduleTime.second ());
	      	string cronValue = second + ' ' + minute + ' * * * ?' ;
	      	string jobName = 'SOCRM_IDM_UserMgmt_Batch - ' + nextScheduleTime.format('hh:mm');
	 
	    	SOCRM_IDM_UserMgmt_Batch oSchCls = new SOCRM_IDM_UserMgmt_Batch();
	    	system.schedule(jobName, cronValue , oSchCls);
	 
	 		system.debug('------------------End: Re-Schedules Job and aborts the old job that already fired the executeBatch method---------------------------');
	 		
	    	// this section of code will abort the current schedule job
	    	system.abortJob(sc.getTriggerId());
	    	//------------------End: Re-Schedules Job and aborts the old job that already fired the executeBatch method----------------------------------------------
			
		}else{
			//---------------------Abort the Job. Need to restart the job manually--------------------------------------
			system.debug('***Abrorting the Job as the Flag IDM_Settings__c.getOrgDefaults().PS_PG_ENABLE_SCHDULED_JOB__c is set to Off');
			system.debug('***Admin has to set this flag to true in custom settings and run the following script in developer console');
			system.debug('SOCRM_IDM_UserMgmt_Batch p = new SOCRM_IDM_UserMgmt_Batch()');
			system.debug('system.schedule(\'Exec of SOCRM_IDM_UserMgmt_Batch\', \'0 2 * ? * *\' , p)');
			
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
		string SOCRM_SFDC_Profiles = IDM_Settings__c.getOrgDefaults().SOCRM_SFDC_Profiles__c;
		system.debug('***SOCRM_SFDC_Profiles: ' + SOCRM_SFDC_Profiles);
		list<string> lstAllowedNPNProfiles = SOCRM_SFDC_Profiles.split(';');
		list<string> lstAllowedNPNProfilesAfterTrim = new list<string>();
		for (string s : lstAllowedNPNProfiles){
			string strProfName = s.trim();
			lstAllowedNPNProfilesAfterTrim.add(strProfName);
		}
		system.debug('***lstAllowedNPNProfiles: ' + lstAllowedNPNProfiles);
				
		return Database.getQueryLocator([	Select Id, email, firstName, lastName, companyName, LanguageLocaleKey, 
												IsActive, IDM_SOCRM_Role_Assigned__c, IDM_Assign_SOCRM_Role_Call_Initiated__c, IDM_Assign_SOCRM_Role_Call_Success__c, IDM_Assign_SOCRM_Role_Call_Response__c, 
												IDM_SOCRM_Role_Revoked__c, IDM_Revoke_SOCRM_Role_Call_Initiated__c, IDM_Revoke_SOCRM_Role_Call_Success__c, IDM_Revoke_SOCRM_Role_Call_Response__c,
												Contact.Account.Name, Contact.MailingCountryCode, CountryCode
											From User
											Where Profile.Name in :lstAllowedNPNProfilesAfterTrim
												And (
														(IsActive = true AND IDM_SOCRM_Role_Assigned__c = false)
														Or (IsActive = false And IDM_SOCRM_Role_Revoked__c = false)
													)
												And LastModifiedDate >= :dtLookBackTime 
												And IDM_API_Call_Failure__c = false
										]);
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope){
		system.debug('---------Entering Batch Job execute method-------------------');
		list<User> lstCommunityUsers = new list<user>();
		list<User> lstNPNOnlyUsers = new list<user>(); //exclude ESP users
		map<Id, User> mapCommunityUsers = new map<Id, User>();
		list<SOCRM_IDM_Wrapper.IdmResponse> lstIDMResponses = new list<SOCRM_IDM_Wrapper.IdmResponse>();
		list<IDM_IntegrationError__c> lstIDMIntegrationErrors = new  list<IDM_IntegrationError__c>();
		if (scope != null && !scope.isEmpty()){
			try{
				lstCommunityUsers = (List<User>) scope;
				
				//2018.03.29 - pjena - Changes related to Service Cloud -	Do not invoke IDM API calls if you find there is any active Service Cloud users
				//Find all Email addresses in scope
				set<string> commUserEmailsInScope = new set<string>();
				for (User oCommunityUser : lstCommunityUsers){
					commUserEmailsInScope.add(oCommunityUser.email);
				}
				
				//Find all active ESP Users with FederationId matching with the emails in the scope; we need to exclude those users
				system.debug('***ESP_SFDC_Profile__c in IDM Settings: ' + IDM_Settings__c.getOrgDefaults().ESP_SFDC_Profile__c);
				system.debug('***commUserEmailsInScope: ' + commUserEmailsInScope);
				list<User> lstESPUsers = [Select Email, FederationIdentifier From User Where FederationIdentifier in :commUserEmailsInScope and Profile.Name  = :IDM_Settings__c.getOrgDefaults().ESP_SFDC_Profile__c];
				map<string, string> mapESPUsers = new map<string, string>();
				for (User espUser : lstESPUsers){
					mapESPUsers.put(espUser.email, espUser.FederationIdentifier);
				}
				system.debug('***All ESP Users in this scope : ' + mapESPUsers);
				
				//Get only NPN Community Users
				for (User oCommunityUser : lstCommunityUsers){
					if ( mapESPUsers.get(oCommunityUser.email) == null){
						lstNPNOnlyUsers.add(oCommunityUser);
					}
				}
				
				//End: 2018.03.29 - pjena - Changes related to Service Cloud -	Do not invoke IDM API calls if you find there is any active Service Cloud users
				
				//mapCommunityUsers.putAll(lstCommunityUsers);
				mapCommunityUsers.putAll(lstNPNOnlyUsers);
				lstIDMResponses = new list<SOCRM_IDM_Wrapper.IdmResponse>();
				
				string SOCRM_Email_Template_Category = IDM_Settings__c.getOrgDefaults().SOCRM_Email_Template_Category__c; //e.g., SOCRMAccessRole
				string SOCRM_IDM_Role = IDM_Settings__c.getOrgDefaults().SOCRM_IDM_Role__c; //e.g., SOCRM
				
				//system.debug('***Users in this batch: ' + lstCommunityUsers);
				system.debug('***NPN only Users in this batch: ' + lstNPNOnlyUsers);
				//----------------------Begin: Call IDM API------------------------------------------------
				//for (User commUser : lstCommunityUsers){
				for (User commUser : lstNPNOnlyUsers){
					SOCRM_IDM_Wrapper.IdmRequest oIdmReq = new SOCRM_IDM_Wrapper.IdmRequest();
					oIdmReq.sfdcUserId = commUser.Id;
					oIdmReq.emailAddress = commUser.email;
					oIdmReq.firstName = commUser.FirstName;
					oIdmReq.lastName = commUser.LastName;
					oIdmReq.company = commUser.isActive? commUser.Contact.Account.Name : commUser.CompanyName; //commUser.CompanyName;
					oIdmReq.industry = 'NA';
					oIdmReq.jobRole = 'NA';
					oIdmReq.street1 = 'NA';
					oIdmReq.street2 = 'NA';
					oIdmReq.state = 'NA';
					oIdmReq.postalCode = 'NA';
					oIdmReq.country = commUser.isActive? commUser.Contact.MailingCountryCode : commUser.CountryCode;
					oIdmReq.langCode =  commUser.LanguageLocaleKey.replace('_', '-'); //commUser.LanguageLocaleKey.substring(0,2);
					oIdmReq.idmRole = SOCRM_IDM_Role;
					oIdmReq.emailTemplateCategory = SOCRM_Email_Template_Category;
					oIdmReq.phone = 'NA';
					oIdmReq.userName = commUser.email;
					oIdmReq.city = 'NA';
					oIdmReq.isActive = commUser.isActive?'1':'0';
					
					SOCRM_IDM_Wrapper.IdmResponse oIdmResponse = SOCRM_IDM_Wrapper.callout_CreateSOCRMIDMUser(oIdmReq);	
					lstIDMResponses.add(oIdmResponse);
				}
				//----------------------End: Call IDM APIs-------------------------
			} catch(Exception ex){
				system.debug('***exception: ' + ex);
				string exceptionDetails = 'Apex Exception::[getCause=' + ex.getCause()  + '], [ExceptionType=  ' + ex.getTypeName() +'], [message=  ' + ex.getMessage()  +'],  [StackTraceString ='+ ex.getStackTraceString();
				IDM_IntegrationError__c intErr = new IDM_IntegrationError__c(Error_Source__c = 'SOCRM_IDM_UserMgmt_Batch', Error_Description__c = exceptionDetails);
				database.insert(intErr, false);
			}
			
		}
		
		//Process IDM Responses and Update the status in the User custom fields
		system.debug('---------Begin: Process IDM Responses------------------------------');
		if (!lstIDMResponses.isEmpty()){
			list<User> lstUsersToUpdate = new list<User>();
			for (SOCRM_IDM_Wrapper.IdmResponse response : lstIDMResponses){
				
				system.debug('***SOCRM_IDM_UserMgmt_Batch.response : ' + response);
				
				if (response != null){
					if (response.x_isApexException != 1){
					
						if (response.x_isAPICallSucceeded == 1 && mapCommunityUsers.get(response.x_sfdcUserId).IsActive && mapCommunityUsers.get(response.x_sfdcUserId).IDM_SOCRM_Role_Assigned__c == false ){
							//if IsActive = true, IDM_SOCRM_Role_Assigned__c = false, API call succeeded => IDM_SOCRM_Role_Assigned__c = true, FederationIdentifier = email
							User usr = new User(Id = response.x_sfdcUserId, FederationIdentifier = mapCommunityUsers.get(response.x_sfdcUserId).email,
											IDM_API_Call_Failure__c = false, IDM_API_Call_Failure_Exception__c = null,
											IDM_SOCRM_Role_Assigned__c = true, IDM_Assign_SOCRM_Role_Call_Initiated__c = true, IDM_Assign_SOCRM_Role_Call_Success__c = true, 
											IDM_Assign_SOCRM_Role_Date__c = DateTime.now(), IDM_Last_Attempted_Date_via_API__c = DateTime.now(), 
											IDM_Assign_SOCRM_Role_Call_Response__c = response.x_transactionId);
							lstUsersToUpdate.add(usr);
											
						}else if (response.x_isAPICallSucceeded == 0 && mapCommunityUsers.get(response.x_sfdcUserId).IsActive && mapCommunityUsers.get(response.x_sfdcUserId).IDM_SOCRM_Role_Assigned__c == false ){
							//if IsActive = true, IDM_SOCRM_Role_Assigned__c = false, API call failed => update the API response flags to capture the error
							User usr = new User(Id = response.x_sfdcUserId, 
											IDM_API_Call_Failure__c = false, IDM_API_Call_Failure_Exception__c = null,
											IDM_Assign_SOCRM_Role_Call_Initiated__c = true, IDM_Assign_SOCRM_Role_Call_Success__c = false, 
											IDM_Last_Attempted_Date_via_API__c = DateTime.now(),
											IDM_Assign_SOCRM_Role_Call_Response__c = response.x_transaction + '-' + response.x_faultCode + '-' + response.x_code + '-' + response.x_faultString);
							lstUsersToUpdate.add(usr);
									
						}else if (response.x_isAPICallSucceeded == 1 && mapCommunityUsers.get(response.x_sfdcUserId).IsActive == false && mapCommunityUsers.get(response.x_sfdcUserId).IDM_SOCRM_Role_Revoked__c == false ){
							//if IsActive = false, IDM_SOCRM_Role_Revoked__c = false, API call succeeded => IDM_SOCRM_Role_Revoked__c = true, FederationIdentifier = null
							User usr = new User(Id = response.x_sfdcUserId, FederationIdentifier = null,
											IDM_API_Call_Failure__c = false, IDM_API_Call_Failure_Exception__c = null,
											IDM_SOCRM_Role_Revoked__c = true, IDM_Revoke_SOCRM_Role_Call_Initiated__c = true, IDM_Revoke_SOCRM_Role_Call_Success__c = true, 
											IDM_Revoke_SOCRM_Role_Date__c = DateTime.now(), IDM_Last_Attempted_Date_via_API__c = DateTime.now(),
											IDM_Revoke_SOCRM_Role_Call_Response__c = response.x_transactionId);
							lstUsersToUpdate.add(usr);
						}else if (response.x_isAPICallSucceeded == 0 && mapCommunityUsers.get(response.x_sfdcUserId).IsActive == false && mapCommunityUsers.get(response.x_sfdcUserId).IDM_SOCRM_Role_Revoked__c == false ){
							//if IsActive = false, IDM_SOCRM_Role_Revoked__c = false, API call failed => update the API response flags to capture the error
							User usr = new User(Id = response.x_sfdcUserId, 
											IDM_API_Call_Failure__c = false, IDM_API_Call_Failure_Exception__c = null,
											IDM_Revoke_SOCRM_Role_Call_Initiated__c = true, IDM_Revoke_SOCRM_Role_Call_Success__c = false, 
											IDM_Last_Attempted_Date_via_API__c = DateTime.now(),
											IDM_Revoke_SOCRM_Role_Call_Response__c = response.x_transaction + '-' + response.x_faultCode + '-' + response.x_code + '-' + response.x_faultString);
							lstUsersToUpdate.add(usr);
						}
					
					}else{
						//Apex Exception
						User usr = new User(Id = response.x_sfdcUserId, IDM_Last_Attempted_Date_via_API__c = DateTime.now(),
											IDM_API_Call_Failure__c = true, IDM_API_Call_Failure_Exception__c = string.isNotBlank(response.x_ApexException) ? response.x_ApexException.substring(0,254) : response.x_ApexException);
						lstUsersToUpdate.add(usr);
						IDM_IntegrationError__c intErr = new IDM_IntegrationError__c(UserId__c =  response.x_sfdcUserId, Error_Source__c = 'SOCRM_IDM_UserMgmt_Batch', Error_Description__c = response.x_ApexException);
						lstIDMIntegrationErrors.add(intErr);
					}
				}
			}
			
			if (!lstUsersToUpdate.isEmpty()){
				Database.SaveResult[] lstSR = Database.update(lstUsersToUpdate, false);
				//list<IDM_IntegrationError__c> lstIDMIntegrationErrors = new  list<IDM_IntegrationError__c>();
				
				for (integer i = 0; i < lstUsersToUpdate.size(); i++){
					Database.SaveResult sr = lstSR[i];
					if (!sr.isSuccess()){
						// Operation failed, so get all errors 
						system.debug('The following error has occurred.');
						string errorDetails = 'User Id erred = ' + lstUsersToUpdate[i].Id + ' |err.getFields() =' + sr.getErrors()[0].getFields() + ' | err.getStatusCode() = ' + sr.getErrors()[0].getStatusCode() + ' | err.getMessage() = ' +sr.getErrors()[0].getMessage();
						system.debug('***errorDetails: ' + errorDetails);
						IDM_IntegrationError__c intErr = new IDM_IntegrationError__c(UserId__c =  lstUsersToUpdate[i].Id, Error_Source__c = 'SOCRM_IDM_UserMgmt_Batch', Error_Description__c = errorDetails);
						lstIDMIntegrationErrors.add(intErr);
					}else{
						// Operation was successful, so get the ID of the record that was processed
						system.debug('Successfully Updated User with User.Id: ' + sr.getId());
					}
				}
										
				if (!lstIDMIntegrationErrors.isEmpty()){
					database.insert(lstIDMIntegrationErrors, false);
				}
			}
		}
		
		system.debug('---------End: Process IDM Responses------------------------------');
		
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