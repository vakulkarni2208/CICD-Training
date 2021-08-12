/*
Schedulable Batch Apex Class - replacing the schedulable class COMM_AssignPSPG_To_PortalUsers
	The existing scheduled calss COMM_AssignPSPG_To_PortalUsers.cls was failing too often due to "Apex CPU time limit exceeded" error whenever more records were updated

---------------------------------------------------------------------------------------------------
1 - Assigns Permission Sets to the Contact User from Portal Permission Sets object records and Contact's Permission Set Groups field value
2 - Assigns Public Groups to the Contact User from Portal Public Groups object records and Contact's Permission Set Groups field value 
3 - Resets Contact Users attributes as 
	Salesforce1 User = True, 
	Salesforce CRM Content User = True, 
	Chatter Answers User = false, 
	Receive Salesforce CRM Content Email Alerts = false, 
	Receive Salesforce CRM Content Alerts as Daily Digest = false

It needs to be scheduled manually from Dev Console for the first time and afterwards it will run from the configuration present in Custom Settings named Community_Settings__c
Community_Settings__c.PS_PG_ASSIGN_LKBK_TIME__c - Defines the lookback time in minutes. 
				All the Contacts/Users that got created or modified from this lookback time till current time are processed by this job
Community_Settings__c.PS_PG_ASSIGN_RECUR__c - Defines recurring frequency in minutes. 
				The job repeats execution based on this time gap.
Community_Settings__c.PS_PG_ENABLE_SCHDULED_JOB__c - Flag to enable or disable the job.
				This is an automatic way to abort the scheduled job. Once it is aborted the job needs to be sc manually thru the Dev Console.
				
Commad to schedule the apex through Developer Console

//COMM_AssignPSPG_To_CommunityUsers_Batch p = new COMM_AssignPSPG_To_CommunityUsers_Batch();
//Run every 60 minutes and look back 60 minitues and batch size = 25
COMM_AssignPSPG_To_CommunityUsers_Batch p = new COMM_AssignPSPG_To_CommunityUsers_Batch();
DateTime currDT = DateTime.now().addMinutes(2);
integer sec = currDT.second();
integer min = currDT.minute();
String sch = sec + ' ' + min + ' ' + '* ? * *'; //0 5 * * * ?
system.debug('sch: ' + sch);
system.schedule('Exec of COMM_AssignPSPG_To_CommunityUsers_Batch', sch, p);

Change list:
3/31/2015 - Raj - Do not remove any public groups. 
3/31/2015 - Tracy - When Users are modified, make sure the checkbox also gets set/unset (previously it was only set/unset during new user creation).
3/31/2015 - Paresh - Removed references to COMM_Constants.cls and COMM_Utility.cls. 
		Added the utility methods and Constants native to this class so it can stay independent.
4/22/2015 - Paresh - Dedupe of PermissionSetAssignment list and GroupMember list. 
		If a contact was having two Portal Public Groups, then associated Permission Sets were added the list as duplicates and none of the duplicates were getting inserted because of SFDC governance.
7/7/2015 - If it is a CP user then set userPermissionsSFContentUser = false, otherwise it is true
		Resets Contact Users attributes as 
			Salesforce1 User = False, 
			Salesforce CRM Content User = True (Only for Partner Portal Users), 
			Chatter Answers User = false, 
			Receive Salesforce CRM Content Email Alerts = false, 
			Receive Salesforce CRM Content Alerts as Daily Digest = false

9/10/2015 - Add the MDFv3 permission set as part of MDF related permission set
4/8/2016 - 	Unsubscribing users from Public Groups - Raj, Tracy, Brenda
			If portal contacts are removed from any Permissions & Group Assignments, they need to be removed from the respective Public Groups 
			(on 3/31/2015 this functionality was blocked by Raj)

3/9/2017 - New batch class relpacement for COMM_AssignPSPG_To_PortalUsers

9/15/2017 - AIC Portal Users (they are lite portal users now as they moved from Gold Partner) need to be excluded from content specific user attribute disablement

10/3/2019 - SDS-1762 - EAR (Export Administration Regulations) list (PUB: Huawei, Dawning/Sugon Updates) - Do not add certain PS and public groups

*/

public class COMM_AssignPSPG_To_CommunityUsers_Batch implements Database.Batchable<SObject>, Database.Stateful, System.Schedulable{
	
    private static final string PS_MKTG_MDF_PORTAL_READ_CHANNEL = 'MKTG_MDF_Portal_READ_CHANNEL';
    private static final string PS_MKTG_MDF_PORTAL_UPDATE = 'MKTG_MDF_Portal_UPDATE';
    private static final string PS_MKTG_MDFV3_VIEWER = 'MKTG_MDFV3_VIEWER';
    private static final string USERLICENSE_CP_OCPMC = 'Overage Customer Portal Manager Custom';
    
    //Lookback Time and recurrig time in Minutes
    private decimal dRecurTime;
    private decimal dLookBackTime;
    private decimal dBatchSize;
    private boolean isJobEnabled = true;
    
    private integer iRecurTime;
	private DateTime dtLookBackTime;
	private integer iBatchSize;
	
	
	//Constructor accepting next execution time in minutes and the lookback time
    public COMM_AssignPSPG_To_CommunityUsers_Batch(){
    	system.debug('********Begin: Constructor: COMM_AssignPSPG_To_CommunityUsers_Batch()**************');
    	try{
    		dRecurTime  = Community_Settings__c.getOrgDefaults().BATCHJOB_PS_PG_ASSIGN_RECUR__c ; //in minutes
			dLookBackTime  = Community_Settings__c.getOrgDefaults().BATCHJOB_PS_PG_ASSIGN_LKBK_TIME__c ; //in minutes
			dBatchSize = Community_Settings__c.getOrgDefaults().BATCHJOB_PS_PG_BATCH_SIZE__c;
			isJobEnabled = Community_Settings__c.getOrgDefaults().BATCHJOB_PS_PG_ENABLE_SCHDULED_JOB__c;
			
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
		
		system.debug('***Value from Settings: dRecurTime (BATCHJOB_PS_PG_ASSIGN_RECUR__c) = ' + dRecurTime);
		system.debug('***Value from Settings: dLookBackTime (BATCHJOB_PS_PG_ASSIGN_LKBK_TIME__c) = ' + dLookBackTime);
		system.debug('***Value from Settings: dBatchSize (BATCHJOB_PS_PG_BATCH_SIZE__c) = ' + iBatchSize);
		system.debug('***Value from Settings: isJobEnabled (BATCHJOB_PS_PG_ENABLE_SCHDULED_JOB__c) = ' + isJobEnabled);
		
		system.debug('***Value set to iRecurTime = ' + iRecurTime);
		system.debug('***Value set to dtLookBackTime = ' + dtLookBackTime);
		system.debug('***Value set to iBatchSize = ' + iBatchSize);
		system.debug('********End: Constructor: COMM_AssignPSPG_To_CommunityUsers_Batch()**************');
    }
    
    //Schedulable interface method implementation. 
	//When you schedule the class COMM_AssignPSPG_To_CommunityUsers_Batch to run at a specific interval, it will run the this execute method which in turn will call the batch apex methods
	public void execute(SchedulableContext sc){
		
		//Run the code if the Job is enabled else abort the job
		//--------------------------------------------------------------------------------------------
		if (isJobEnabled){
			system.debug('---------Start: Execute method of the scheduled class; it fires the executeBatch method to invoke the batch job and reschdules the scheduled class to run at the set interval ------------------');
			//Invoke the batch job
			COMM_AssignPSPG_To_CommunityUsers_Batch oCOMMAssignPSPGBatch = new COMM_AssignPSPG_To_CommunityUsers_Batch();
			database.executeBatch(oCOMMAssignPSPGBatch, iBatchSize);
			system.debug('---------End: Execute method of the scheduled class; it fires the executeBatch method to invoke the batch job and reschdules the scheduled class to run at the set interval ------------------');
		
			//------------------Re-Schedules Job and aborts the old job that already fired the executeBatch method----------------------------------------------
			system.debug('------------------Start: Re-Schedules Job and aborts the old job that already fired the executeBatch method---------------------------');
			DateTime nextScheduleTime = system.now().addMinutes(iRecurTime);
	      	string minute = string.valueof(nextScheduleTime.minute());
	      	string second = string.valueof(nextScheduleTime.second ());
	      	string cronValue = second + ' ' + minute + ' * * * ?' ;
	      	string jobName = 'COMM_AssignPSPG_To_CommunityUsers_Batch - ' + nextScheduleTime.format('hh:mm');
	 
	    	COMM_AssignPSPG_To_CommunityUsers_Batch oSchCls = new COMM_AssignPSPG_To_CommunityUsers_Batch();
	    	system.schedule(jobName, cronValue , oSchCls);
	 
	 		system.debug('------------------End: Re-Schedules Job and aborts the old job that already fired the executeBatch method---------------------------');
	 		
	    	// this section of code will abort the current schedule job
	    	system.abortJob(sc.getTriggerId());
	    	//------------------End: Re-Schedules Job and aborts the old job that already fired the executeBatch method----------------------------------------------
			
		}else{
			//---------------------Abort the Job. Need to restart the job manually--------------------------------------
			system.debug('***Abrorting the Job as the Flag Community_Settings__c.getOrgDefaults().PS_PG_ENABLE_SCHDULED_JOB__c is set to Off');
			system.debug('***Admin has to set this flag to true in custom settings and run the following script in developer console');
			system.debug('COMM_AssignPSPG_To_CommunityUsers_Batch p = new COMM_AssignPSPG_To_CommunityUsers_Batch()');
			system.debug('system.schedule(\'Exec of COMM_AssignPSPG_To_CommunityUsers_Batch\', \'0 2 * ? * *\' , p)');
			
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
		return Database.getQueryLocator([	Select  Contact.Portal_Groups__c, ContactId, Contact.EAR_Restricted__c  
											From User 
											Where IsActive = true 
												And ContactId != null 
												And Contact.Portal_Groups__c != null
												And (Contact.LastModifiedDate >= :dtLookBackTime OR LastModifiedDate >= :dtLookBackTime  OR CreatedDate >= :dtLookBackTime)
										]);
	}

	
	public void execute(Database.BatchableContext BC, List<sObject> scope){
		system.debug('---------Entering Batch Job execute method-------------------');
		if (scope != null && !scope.isEmpty()){
			try{
				list<User> lstActivePortalUsers = (List<User>) scope;
				
				system.debug('***Users in this batch: ' + lstActivePortalUsers);
				
				//----------------------Assign Permission Sets and Public Groups------------------------------------------------
				if (!lstActivePortalUsers.isEmpty()){
					
					//build map of userId, list of Portal Groups (Permission Sets Groups)
					map<Id, list<string>> mapUserIdListOFPSGrpNames = new map<Id, list<string>>();
					
					//EAR Restricted Users
					list<User> lstEARRestrictedUsers = new list<User>();
					
					for (User portalUser : lstActivePortalUsers){
						list<string> lstPSNames;
						if (mapUserIdListOFPSGrpNames.get(portalUser.Id) == null){
							 lstPSNames = new list<string>();
							 mapUserIdListOFPSGrpNames.put(portalUser.Id, lstPSNames);
						} else{
							lstPSNames = mapUserIdListOFPSGrpNames.get(portalUser.Id);
						}
							
						if (portalUser.Contact.Portal_Groups__c != null){
							lstPSNames.addAll(portalUser.Contact.Portal_Groups__c.split(';'));
						}
						
						//SDS-1762 - EAR (Export Administration Regulations) list
						//Collect all the EAR Restrcited Users
						if (portalUser.Contact.EAR_Restricted__c){
							lstEARRestrictedUsers.add(portalUser);
						}
						//End: SDS-1762 - EAR (Export Administration Regulations) list
							
					}
						
					//get all the Permission Sets Groups from the mapUserIdListOFPSNames
					set<string> setAllPSGrpNames = new set<string>();
					for (list<string> lstPSGrpNames : mapUserIdListOFPSGrpNames.values()){
						setAllPSGrpNames.addAll(lstPSGrpNames);
					}
					
					system.debug('***setAllPSGrpNames: ' + setAllPSGrpNames);
					system.debug('***mapUserIdListOFPSGrpNames: ' + mapUserIdListOFPSGrpNames);
						
					if (!setAllPSGrpNames.isEmpty()){
						//PERMISSION SET Assignment
						assignPortalPermissionSets(setAllPSGrpNames, mapUserIdListOFPSGrpNames);
						
						//PUBLIC Group Assignment
						assignPortalPublicGroups(setAllPSGrpNames, mapUserIdListOFPSGrpNames);
					}
					
					//SDS-1762 - EAR (Export Administration Regulations) list
					//Remove the Restricted Permission Sets and Public Groups from these set of users. Needs to be at the end of the PermissionSet, Public Group Assignments as there are very specific SFDC PS/PG that needs to be removed
					if (!lstEARRestrictedUsers.isEmpty()){
						system.debug('***Begin Call: removeEARRestrictedPSPGsFromUser for ' + lstEARRestrictedUsers);
						removeEARRestrictedPSPGsFromUser(lstEARRestrictedUsers);
						system.debug('***End Call: removeEARRestrictedPSPGsFromUser');
					}
					//End: SDS-1762 - EAR (Export Administration Regulations) list
					
					//Begin: Do not set "Salesforce CRM Content User" for Customer Portal Users
					//-------------------------------------------------------------------------
					//9/15/2017 - AIC Portal Users (they are lite portal users now as they moved from Gold Partner) need to be excluded from content specific user attribute disablement
					string strESCAPE_USER_SETTINGS_PROF = Community_Settings__c.getOrgDefaults().BATCHJOB_PS_PG_ESCAPE_USER_SETTINGS_PROF__c;
					list<string> lstProfileNames = new list<string>();
					if (string.isNotBlank(strESCAPE_USER_SETTINGS_PROF)){
						lstProfileNames = strESCAPE_USER_SETTINGS_PROF.split('[\\s]*;[\\s]*');
					}
					
					set<Id> setPortalUserIds = mapUserIdListOFPSGrpNames.keySet();
					map<Id, User> mapCPUsers = new map<Id, user> ([	Select Id, Name 
																	From User 
																	Where IsActive = true 
																		And Id in :setPortalUserIds 
																		And Profile.Name Not in :lstProfileNames
																		And ( 	userPreferencesContentNoEmail = false
																			Or userPreferencesContentEmailAsAndWhen = false
																			Or UserPermissionsChatterAnswersUser = true
																			Or UserPreferencesHideS1BrowserUI = false 
																		)
																 	]);
					
					if (!mapCPUsers.isEmpty()){
					 	//Call the method to update the users with options: 
					 	list<Id> lstPortalUserIds = new list<Id>();
					 	lstPortalUserIds.addAll(mapCPUsers.keySet());
					 	assignPortalUserOptionsFuture(lstPortalUserIds);
					}
					
					//End: Do not set "Salesforce CRM Content User" for Customer Portal Users
					//-------------------------------------------------------------------------
				
				}
				//----------------------End: Assign Permission Sets and Public Groups-------------------------
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
    
    //********************************************************************************************************
    //PERMISSION SET Assignments 
    //********************************************************************************************************
	private static void assignPortalPermissionSets(set<string> setAllPSGrpNames, map<Id, list<string>> mapUserIdListOFPSGrpNames){
				
		map<string, list<string>> mapPPSGrpLstPSNames = getMapPPSGrpLstPSNames(setAllPSGrpNames);
		system.debug('***mapPPSGrpLstPSNames: ' + mapPPSGrpLstPSNames);
		
		//get a map PS Name and PS Id for the all the PS Names 
		set<string> setPSNames = new set<string>();
		list<string> lstPSNames = new list<string>();
		for (list<string> lstPSNamesFromGrp : mapPPSGrpLstPSNames.values()){
			setPSNames.addAll(lstPSNamesFromGrp); //this removes duplicate PS Names
		}
		lstPSNames.addAll(setPSNames);
		system.debug('***lstPSNames: ' + lstPSNames);
		//map<string, Id> mapPSNamesId = COMM_Utility.getPSsByName(lstPSNames);
		map<string, Id> mapPSNamesId = getPSsByName(lstPSNames);
		
		//For each user find the grp names, get the list of PS list from Portal Permission Sets and then find its corresponding PS Id to build the PersmissionSetAssignment objects
		list<Id> lstUserIds = new list<Id>();
		list<Id> lstPSIds = new list<Id>();
		set<PermissionSetAssignment> setPSA = new set<PermissionSetAssignment>();
		for (Id portalUserId : mapUserIdListOFPSGrpNames.keyset()){ //for each portal user
			list<string> lstPSGrpNamesFromContact = mapUserIdListOFPSGrpNames.get(portalUserId); //get the contact's PS Groups
			for (string strPSGrpFromContact : lstPSGrpNamesFromContact){ //for each PS Group of the Contact
				if (mapPPSGrpLstPSNames.get(strPSGrpFromContact) != null){
					for (string strPS : mapPPSGrpLstPSNames.get(strPSGrpFromContact)){ //get the list of Permission Set names for the PS Group and buid the Permission Set Assignment objects
						PermissionSetAssignment psa = new PermissionSetAssignment();
						psa.AssigneeId = portalUserId;
						psa.PermissionSetId = mapPSNamesId.get(strPS);
						if (mapPSNamesId.get(strPS) != null){
							lstUserIds.add(portalUserId);
							lstPSIds.add(mapPSNamesId.get(strPS));
							setPSA.add(psa);
						}
					}
				}
				
			}
		}
			
		//Delete all the existing Permission Sets related the Portal User 
		//(Note/Assumption: Portal Permission Sets starts with PP_ and 2 MDF related permission sets)
		//----------------------------------------------------------------------------------
		list<PermissionSetAssignment> lstExistingPSA = [Select AssigneeId, PermissionSetId 
														From PermissionSetAssignment
														Where AssigneeId = :mapUserIdListOFPSGrpNames.keySet()
															And ( PermissionSet.Name like 'PP_%' 
																	Or	PermissionSet.Name in (:PS_MKTG_MDF_PORTAL_READ_CHANNEL, :PS_MKTG_MDF_PORTAL_UPDATE, :PS_MKTG_MDFV3_VIEWER) )];
		
		//find the PSA Ids from the existing PSAs which are not present in the set of PSAs to be inserted; only delete those
		list<Id> existingPSAIdsToBeDeleted = new list<Id>();
		
		for (PermissionSetAssignment existingPSA : lstExistingPSA){
			boolean bPSAMatchFound = false;
			for (PermissionSetAssignment newPSA : setPSA){
				if (existingPSA.AssigneeId == newPSA.AssigneeId && existingPSA.PermissionSetId == newPSA.PermissionSetId){
					bPSAMatchFound = true;
					break;
				}
			}
			if (!bPSAMatchFound) existingPSAIdsToBeDeleted.add(existingPSA.Id);
		}
		//----------------------------------------------------------------------------------
		
		//Call future method to insert Permission Sets
		//----------------------------------------------------------------------------------
		assignPortalPermissionSetsFuture(lstUserIds, lstPSIds, existingPSAIdsToBeDeleted);
		//----------------------------------------------------------------------------------
		
	}
	//*******End: assignPortalPermissionSets***********************************************************************
	
	
	
	//***************************************************************************************************
	//Future methods to delete and insert Permission Sets called from assignPortalPermissionSets method
	//***************************************************************************************************
	private static void assignPortalPermissionSetsFuture(list<Id> lstUserIds, list<Id> lstPSIds, list<Id> existingPSAIdsToBeDeleted){
		//Delete the existing PermissionSetAssignments
		//----------------------------------------------------------------------------------
		if (!existingPSAIdsToBeDeleted.isEmpty()){
			
			list<PermissionSetAssignment> lstPSAToBeDeleted = new list<PermissionSetAssignment>();
			for (Id psaId : existingPSAIdsToBeDeleted){
				lstPSAToBeDeleted.add(new PermissionSetAssignment(Id = psaId));
			}
			
			if (!lstPSAToBeDeleted.isEmpty()){
				Database.DeleteResult[] lstDR = Database.delete(lstPSAToBeDeleted, false);

				// Iterate through each returned result
				for(Database.DeleteResult dr : lstDR) {
					if (dr.isSuccess()) {
			        	// Operation was successful, so get the ID of the record that was processed
			        	System.debug('Successfully Deleted PSA. PSA ID: ' + dr.getId());
				    }
				    else {
				        // Operation failed, so get all errors                
				        for(Database.Error err : dr.getErrors()) {
				            System.debug('The following error has occurred during deletion.');                    
				            System.debug(err.getStatusCode() + ': ' + err.getMessage());
				            System.debug('PSA fields that affected this error: ' + err.getFields());
				        }
				    }
				}
			}
		}
		//----------------------------------------------------------------------------------
		
		//Insert PSA Records. 
		//----------------------------------------------------------------------------------
		
		//Remove the duplicates entries. A Portal PS can be configured for more than one Portal PS Groups and these Portal PS Group might be assigned to a single Contact
		// As such the list will have duplicates and no one from the duplicate will get inserted. To prevent this dedupe the source.
		set<string> setAssigneeIdPSId = new set<string>();
		list<PermissionSetAssignment> lstPSA = new list<PermissionSetAssignment>();
		for (integer i = 0; i < lstUserIds.size(); i++){
			string strAssigneeIdPSId = lstUserIds[i] + '-' + lstPSIds[i];
			if (!setAssigneeIdPSId.contains(strAssigneeIdPSId)){
				PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = lstUserIds[i], PermissionSetId = lstPSIds[i]);
				lstPSA.add(psa);
				setAssigneeIdPSId.add(strAssigneeIdPSId); //add the set which holds uniques
				
			}
		}
		if (!lstPSA.isEmpty()){
			Database.SaveResult[] lstSR = Database.insert(lstPSA, false);
			for (Database.SaveResult sr : lstSR) {
			    if (sr.isSuccess()) {
			        // Operation was successful, so get the ID of the record that was processed
			        System.debug('Successfully inserted PSA. PSA ID: ' + sr.getId());
			    }
			    else {
			        // Operation failed, so get all errors                
			        for(Database.Error err : sr.getErrors()) {
			            System.debug('The following error has occurred during insert.');                    
			            System.debug(err.getStatusCode() + ': ' + err.getMessage());
			            System.debug('PSA fields that affected this error: ' + err.getFields());
			        }
			    }
			}
		}
		//End: Insert PSA Records
		//----------------------------------------------------------------------------------
		
	}
	//*********End: assignPortalPermissionSetsFuture*****************************************************************
	
	
	
	//*************************************************************************************************************
	//PUBLIC Group Assignment
	//*************************************************************************************************************
	private static void assignPortalPublicGroups(set<string> setAllPSGrpNames, map<Id, list<string>> mapUserIdListOFPSGrpNames){
		
		//get map of Contact's PPS Grp to list of PPG Names
		map<string, list<string>> mapContactPPGrpLstPPGNames = getMapPPGrpLstPPGNames(setAllPSGrpNames);
		
		system.debug('***mapContactPPGrpLstPPGNames' + mapContactPPGrpLstPPGNames);
		
		//get map of PG Name and PG Id for the all the PG Names in PPG
		set<string> setPGNames = new set<string>();
		list<string> lstPGNames = new list<string>();
		for (list<string> lstPGNamesFromGrp : mapContactPPGrpLstPPGNames.values()){
			setPGNames.addAll(lstPGNamesFromGrp); //this removes duplicate PS Names
		}
		//get a list of uniqe PG Names from PPG object
		lstPGNames.addAll(setPGNames);
		//map<string, Id> mapPGNamesId = COMM_Utility.getPGsByName(lstPGNames);
		map<string, Id> mapPGNamesId = getPGsByName(lstPGNames);
		
		system.debug('***mapPGNamesId: ' + mapPGNamesId);
		
		//For each user find the grp names, get the list of PGs list from Portal Permission Groups and then find its corresponding PG Id to build the Group Member objects
		list<Id> lstUserIds = new list<Id>();
		list<Id> lstPGIds = new list<Id>();
		Set<GroupMember> setGMs = new Set<GroupMember>();
		for (Id portalUserId : mapUserIdListOFPSGrpNames.keyset()){ //for each portal user
			list<string> lstPGGrpNamesFromContact = mapUserIdListOFPSGrpNames.get(portalUserId); //get the Contact's list of Portal Groups
			for (string strPGGrpNamesFromContact : lstPGGrpNamesFromContact){ //for each PS Group of the Contact
				if (mapContactPPGrpLstPPGNames.get(strPGGrpNamesFromContact) != null){
					for (string strPG : mapContactPPGrpLstPPGNames.get(strPGGrpNamesFromContact)){ //get the list of PG names for the PP Group
						GroupMember oGroupMember = new GroupMember();
						oGroupMember.UserOrGroupId = portalUserId;
                        oGroupMember.GroupId = mapPGNamesId.get(strPG);
                        if (mapPGNamesId.get(strPG) != null){
                        	lstUserIds.add(portalUserId);
                        	lstPGIds.add(mapPGNamesId.get(strPG));
                        	setGMs.add(oGroupMember);
                        }
					}
				}
			}
		}
		
		//Get all the existing GroupMember records for the portal users and related to the Public Groups associated with the context
		//Assumed that all the Public Groups present in all the records of Portal Public Group is the super set to consider
		//----------------------------------------------------------------------------------
		list<GroupMember> lstExistingGMs = [Select UserOrGroupId, GroupId 
											From GroupMember 
											Where Group.Name in :getListAllPGsFromPPG()
												And UserOrGroupId in :mapUserIdListOFPSGrpNames.keySet()];
		
		//find the PSA Ids from the existing PSAs which are not present in the set of PSAs to be inserted; only delete those
		list<Id> existingGMIdsToBeDeleted = new list<Id>();
		
		for (GroupMember existingGM : lstExistingGMs){
			boolean bGMMatchFound = false;
			for (GroupMember newGM : setGMs){
				if (existingGM.UserOrGroupId == newGM.UserOrGroupId && existingGM.GroupId == newGM.GroupId){
					bGMMatchFound = true;
					break;
				}
			}
			if (!bGMMatchFound) existingGMIdsToBeDeleted.add(existingGM.Id);
		}
		//----------------------------------------------------------------------------------
		
		//Call future method to update Public Groups
		//----------------------------------------------------------------------------------
		
		//Note: 2015.03.31 - Raj - Do not delete any existing group assignments
		//So, clearing all the emlements of the list existingGMIdsToBeDeleted
		
		//Note: 4/8/2016 - 	Unsubscribing users from Public Groups - Raj, Tracy, Brenda
		//existingGMIdsToBeDeleted.clear();
		//End: Note 4/8/2016
		
		//End: Note 2015.03.31 - Raj
		
		assignPublicGroupsFuture(lstUserIds, lstPGIds, existingGMIdsToBeDeleted);
		//----------------------------------------------------------------------------------
		
	}
	//********End: assignPortalPublicGroups***************************************************************************
	
	
	
	//****************************************************************************************
	//Future methods to insert Public Groups called from assignPortalPublicGroups() method
	//****************************************************************************************

	private static void assignPublicGroupsFuture(list<Id> lstUserIds, list<Id> lstPGIds, list<Id> existingGMIdsToBeDeleted){
		system.debug('***assignPublicGroupsFuture > lstUserIds: ' + lstUserIds);
		system.debug('***assignPublicGroupsFuture > lstPGIds: ' + lstPGIds);
		system.debug('***existingGMIdsToBeDeleted > existingGMIdsToBeDeleted: ' + existingGMIdsToBeDeleted);
		
		//Delete the existing Group Membes
		//----------------------------------------------------------------------------------
		if (!existingGMIdsToBeDeleted.isEmpty()){
			
			list<GroupMember> lstPGsToBeDeleted = new list<GroupMember>();
			for (Id pgId : existingGMIdsToBeDeleted){
				lstPGsToBeDeleted.add(new GroupMember(Id = pgId));
			}
			
			if (!lstPGsToBeDeleted.isEmpty()){
				Database.DeleteResult[] lstDR = Database.delete(lstPGsToBeDeleted, false);

				// Iterate through each returned result
				for(Database.DeleteResult dr : lstDR) {
					if (dr.isSuccess()) {
			        	// Operation was successful, so get the ID of the record that was processed
			        	System.debug('Successfully inserted GM. GM ID: ' + dr.getId());
				    }
				    else {
				        // Operation failed, so get all errors                
				        for(Database.Error err : dr.getErrors()) {
				            System.debug('The following error has occurred.');                    
				            System.debug(err.getStatusCode() + ': ' + err.getMessage());
				            System.debug('GM fields that affected this error: ' + err.getFields());
				        }
				    }
				}
			}
		}
		//----------------------------------------------------------------------------------
		
		
		//Insert GM Records
		//----------------------------------------------------------------------------------
		
		//Remove the duplicates entries. A Portal PS can be configured for more than one Portal PS Groups and these Portal PS Group might be assigned to a single Contact
		// As such the list will have duplicates and no one from the duplicate will get inserted. To prevent this dedupe the source.
		set<string> setAssigneeIdPGId = new set<string>();
		list<GroupMember> lstGM = new list<GroupMember>();
		for (integer i = 0; i < lstUserIds.size(); i++){
			string strAssigneeIdPGId = lstUserIds[i] + '-' + lstPGIds[i];
			if (!setAssigneeIdPGId.contains(strAssigneeIdPGId)){
				GroupMember oGM = new GroupMember(UserOrGroupId = lstUserIds[i], GroupId = lstPGIds[i]);
				lstGM.add(oGM);
				setAssigneeIdPGId.add(strAssigneeIdPGId);
			}
		}
		if (!lstGM.isEmpty()){
			Database.SaveResult[] lstSR = Database.insert(lstGM, false);
			for (Database.SaveResult sr : lstSR) {
			    if (sr.isSuccess()) {
			        // Operation was successful, so get the ID of the record that was processed
			        System.debug('Successfully inserted GM. GM ID: ' + sr.getId());
			    }
			    else {
			        // Operation failed, so get all errors                
			        for(Database.Error err : sr.getErrors()) {
			            System.debug('The following error has occurred.');                    
			            System.debug(err.getStatusCode() + ': ' + err.getMessage());
			            System.debug('GM fields that affected this error: ' + err.getFields());
			        }
			    }
			}
		}
		//End: Insert GM Records
		//----------------------------------------------------------------------------------
	}
	//*********End: assignPublicGroupsFuture***************************************************
	
	
	
	
	//***************************************************************************************************************
	// EARRestrictedPSPGsFromUser
	//***************************************************************************************************************
	private static void removeEARRestrictedPSPGsFromUser(list<User> lstEARRestrictedUserIds){
		//Collect all the EAR Restricted PS and PG Names from Custom Metadata Types
        list<NPN_EAR_Restricted_List__mdt> lstEAR = [	SELECT  Restricted_Permission_Sets__c, Restricted_Public_Groups__c 
        											FROM NPN_EAR_Restricted_List__mdt 
        											WHERE DeveloperName = 'NPN_EAR_Restricted_List'];
		string EARPS = lstEAR[0].Restricted_Permission_Sets__c;
		string EARPG = lstEAR[0].Restricted_Public_Groups__c;
		
		//create list of PS Names
		list<string> lstEARPSNames = new list<string>();
		lstEARPSNames = EARPS.split('[\\s]*;[\\s]*');
		
		//create list PG Names
		list<string> lstEARPGNames = new list<string>();
		lstEARPGNames = EARPG.split('[\\s]*;[\\s]*');
		
		list<PermissionSetAssignment> lstPSA = new list<PermissionSetAssignment>();
		lstPSA = [	Select Id 
					From PermissionSetAssignment 
					Where AssigneeId = :lstEARRestrictedUserIds 
						And PermissionSet.Name = :lstEARPSNames];
		
		
		
		if (!lstPSA.isEmpty()){
			Database.DeleteResult[] lstDR = Database.delete(lstPSA, false);

			// Iterate through each returned result
			for(Database.DeleteResult dr : lstDR) {
				if (dr.isSuccess()) {
			        // Operation was successful, so get the ID of the record that was processed
			        System.debug('Successfully inserted GM. GM ID: ' + dr.getId());
				} else {
					// Operation failed, so get all errors                
					for(Database.Error err : dr.getErrors()) {
						system.debug('The following error has occurred.');                    
						system.debug(err.getStatusCode() + ': ' + err.getMessage());
						system.debug('GM fields that affected this error: ' + err.getFields());
					}
				}
			}
		}
		
		//get the PS and PG Id, Names
		map<string, Id> mapPGNamesId = getPGsByName(lstEARPGNames);
		list<GroupMember> lstGM= new list<GroupMember>();
		lstGM = [	Select Id 
					From GroupMember 
					Where UserOrGroupId = :lstEARRestrictedUserIds 
						And GroupId = :mapPGNamesId.values()];
		
		if (!lstGM.isEmpty()){
			Database.DeleteResult[] lstDR = Database.delete(lstGM, false);

			// Iterate through each returned result
			for(Database.DeleteResult dr : lstDR) {
				if (dr.isSuccess()) {
			        // Operation was successful, so get the ID of the record that was processed
			        System.debug('Successfully inserted GM. GM ID: ' + dr.getId());
				} else {
					// Operation failed, so get all errors                
					for(Database.Error err : dr.getErrors()) {
						system.debug('The following error has occurred.');                    
						system.debug(err.getStatusCode() + ': ' + err.getMessage());
						system.debug('GM fields that affected this error: ' + err.getFields());
					}
				}
			}
		}
		
	}
	//End: EARRestrictedPSPGsFromUser
	//***************************************************************************************************************
	
	
	
	
	
	//**********************************************************************
	//Future methods to set User options to Portal Users
	//**********************************************************************
	private static void assignPortalUserOptionsFuture(list<Id> lstPortaUserIds){
		
		map<Id, User> mapCPUsers = new map<Id, user>( [	Select Id, Name 
														From User 
														Where Id = :lstPortaUserIds 
														And ProfileId in (SELECT Id FROM Profile Where UserLicense.name = :USERLICENSE_CP_OCPMC)]);

		list<User> lstPortalUsers = new list<User>();
		if (!lstPortaUserIds.isEmpty()){
			for (Id portalUserId : lstPortaUserIds){
				User portalUser;
				//If it is a CP user then set userPermissionsSFContentUser = false, otherwise it is true
				if (!mapCPUsers.isEmpty() && mapCPUsers.get(portalUserId) != null ){
					portalUser = new User( Id = portalUserId, userPreferencesContentNoEmail = true, userPreferencesContentEmailAsAndWhen = true, 
											userPermissionsSFContentUser = false, UserPermissionsChatterAnswersUser = false, UserPreferencesHideS1BrowserUI = true);
				} else{
					portalUser = new User( Id = portalUserId, userPreferencesContentNoEmail = true, userPreferencesContentEmailAsAndWhen = true, 
											userPermissionsSFContentUser = true, UserPermissionsChatterAnswersUser = false, UserPreferencesHideS1BrowserUI = true);
				}
				lstPortalUsers.add(portalUser);
			}

			if (!lstPortalUsers.isEmpty()){
				Database.SaveResult[] lstSR = Database.update(lstPortalUsers, false);
				for (Database.SaveResult sr : lstSR) {
				    if (sr.isSuccess()) {
				        // Operation was successful, so get the ID of the record that was processed
				        System.debug('Successfully Updated User wit User.Id: ' + sr.getId());
				    }
				    else {
				        // Operation failed, so get all errors                
				        for(Database.Error err : sr.getErrors()) {
				            System.debug('The following error has occurred.');                    
				            System.debug(err.getStatusCode() + ': ' + err.getMessage());
				            System.debug('User fields that affected this error: ' + err.getFields());
				        }
				    }
				}
			}
		}
	}
	//********End: assignPortalUserOptionsFuture*******************************
	
	
	//**********************************************************************************
	// Utility Methods
	//**********************************************************************************
	
	//returns all Permission Sets by Name, Id pair
	//-------------------------------------------------------------------------------------------------------
	private static map<string, Id> getPSsByName(list<string> lstPSName){
		map<string, Id> allPSsByName = new map<string, Id>();
		
		list<PermissionSet> lstPS = new list<PermissionSet>();
		
		if (lstPSName == null || lstPSName.isEmpty()){
			lstPS = [Select Name From PermissionSet];
		} else{
			lstPS = [Select Name From PermissionSet Where Name = :lstPSName];
		}
		
		for (PermissionSet ps : lstPS){
			allPSsByName.put(ps.Name, ps.Id);
		}
		return allPSsByName;
	}
	
	//returns all Public Groups by Name, Id pair
	//-------------------------------------------------------------------------------------------------------
	private static map<string, Id> getPGsByName(list<string> lstPGName){
		map<string, Id> allPGssByName = new map<string, Id>();
		
		list<Group> lstPGs = new list<Group>();
		
		if (lstPGName == null || lstPGName.isEmpty()){
			lstPGs = [Select Name From Group];
		} else{
			lstPGs = [Select Name From Group Where Name = :lstPGName];
		}
		
		for (Group grp : lstPGs){
			allPGssByName.put(grp.Name, grp.Id);
		}
		return allPGssByName;
	}
	
	
	// Helper method tha returns Map of Portal Permission Set Group to List of Permission Sets
	//-------------------------------------------------------------------------------------------------------
	private static map<string, list<string>> getMapPPSGrpLstPSNames(set<string> setPSGrpNames){
		map<string, list<string>> mapPPSGrpLstPSName = new map<string, list<string>>();
			
		if (!setPSGrpNames.isEmpty()){
			string strAllPSGrpNames = '';
			for (string strPSGrpName : setPSGrpNames){
				if (strPSGrpName != null && strPSGrpName.trim() != ''){
					strAllPSGrpNames += '\'' + strPSGrpName + '\'' + ', ';
				}
			}
			//remove the last comma
			if (strAllPSGrpNames.trim().length() != 0){
				strAllPSGrpNames = strAllPSGrpNames.substring(0, strAllPSGrpNames.lastIndexOf(','));
			}
			//Query the Portal Permission Set object build a map of Permission Set grp and list of Permission Set Names
			string strQuery = 'Select Name, Portal_Groups__c From Portal_Permission_Sets__c Where Portal_Groups__c Includes (' + strAllPSGrpNames + ')';
				
			list<Portal_Permission_Sets__c> lstPPS = Database.query(strQuery);
			
			//Build a map of PPSGrp to PS Names
			for (Portal_Permission_Sets__c oPPS : lstPPS){
				//take care of multi select values
				if (oPPS.Portal_Groups__c.contains(';')){
					list<string> multiValuedPG;
					multiValuedPG = oPPS.Portal_Groups__c.split(';');
					for (string strPGName : multiValuedPG){
						list<string> lstPSNames;
						if (mapPPSGrpLstPSName.get(strPGName) == null ){
							lstPSNames = new list<string>();
							mapPPSGrpLstPSName.put(strPGName, lstPSNames);
						} else{
							lstPSNames = mapPPSGrpLstPSName.get(strPGName);
						}
						lstPSNames.add(oPPS.Name);
					}
				} else{
					list<string> lstPSNames;
					if (mapPPSGrpLstPSName.get(oPPS.Portal_Groups__c) == null ){
						lstPSNames = new list<string>();
						mapPPSGrpLstPSName.put(oPPS.Portal_Groups__c, lstPSNames);
					} else{
						lstPSNames = mapPPSGrpLstPSName.get(oPPS.Portal_Groups__c);
					}
					lstPSNames.add(oPPS.Name);
				}
				
			}
			
		}
			
		//return the map of PS Group Name and list PS Names
		return mapPPSGrpLstPSName;
		
	}
	
	
	//Get all the Permission Set Group Names and its Public Group  from Portal Public Group object
	//-------------------------------------------------------------------------------------------------------
	private static map<string, list<string>> getMapPPGrpLstPPGNames(set<string> setPSGrpNames){
		map<string, list<string>> mapPPSGrpLstPPGName = new map<string, list<string>>();
		
		list<Portal_Public_Groups__c> lstPPGs = [	Select Name, Portal_Public_Group__c 
													From Portal_Public_Groups__c
													Where Name in :setPSGrpNames];
		
		for (Portal_Public_Groups__c oPPG : lstPPGs){
			if (oPPG.Portal_Public_Group__c != null){
				list<string> lstPGs = new list<string>();
				if (oPPG.Portal_Public_Group__c.contains(';')){ //for multi valued PPG
					lstPGs = oPPG.Portal_Public_Group__c.split(';');
				} else{
					lstPGs.add(oPPG.Portal_Public_Group__c);
				}
				mapPPSGrpLstPPGName.put(oPPG.Name, lstPGs);
			}
		}
		
		return mapPPSGrpLstPPGName;
	}
	//-------------------------------------------------------------------------------------------------------
	
	
	//Get all the Portal Public Group from Portal Public Group object
	//-------------------------------------------------------------------------------------------------------
	private static list<string> getListAllPGsFromPPG(){
		list<string> listAllPGsFromPPG = new list<string>();
		list<Portal_Public_Groups__c> lstPPGs = [	Select Portal_Public_Group__c 
													From Portal_Public_Groups__c
													Where Portal_Public_Group__c != null];
		
		for (Portal_Public_Groups__c oPPG : lstPPGs){
			list<string> lstPGs = new list<string>();
			if (oPPG.Portal_Public_Group__c.contains(';')){ //for multi valued PPG
				lstPGs = oPPG.Portal_Public_Group__c.split(';');
				for (string strPG : lstPGs){
					listAllPGsFromPPG.add(strPG);
				}
			} else{
				listAllPGsFromPPG.add(oPPG.Portal_Public_Group__c);
			}
		}
		return listAllPGsFromPPG;
	}
	//-------------------------------------------------------------------------------------------------------
	
    //************End: Utility Methods****************************************************
    
}