/*
    Trigger class for User Trigger User_tgr
    
    - 2017.01.23 - PJENA
    1. WORKDAY user sync
    [
        - New User : Create an inactive user with generic profile, timezone, language 
        - Existing User : Set users inactive if their HRActive__c is false.
                        : do not activate when HR_Active__c is true as it is intended to be done manually
    ]
    
    2017.07.18 - PJENA - Country/State picklist rollout changes
    
    2018.06.14 - PJENA - Scedulable batch class to Sync Community User Data to its Community Contact Record
    					 Copy ContactId value to custom Community_ContactId__c during the onboarding.
    					 
    2018.06.14 - PJENA - Set the Activation and Deactivation Date for Users (move from Process Builder to Trigger)

    2020.11.04 - PJENA - SDS-2776 - Set ManagerId from ManagerGUID__c field - Only for update use case. It is supposed to be set from Workday with the Manager Process Node

    2020.12.09 - PJENA - Bugfix - Brainshark Activation/Deactivation Date not getting set for new inserts - UserType comes blank for Before Insert triggers, alternatively use EmployeeGuid to determine internal users
*/

public class User_tgr_cls {
    private string currentLoggedOnUserName;
    private string sfdcIntegrationUsers;
    private string sfdcInstanceName;
    private string defaultSFDCUserProfileId;
    private string defaultSFDCUserRoleId;
    private string defaultTimeZoneSidKey;
    private string defaultLocaleSidKey;
    private string defaultEmailEncodingKey;
    private string defaultLanguageLocaleKey;
    private list<User> lstInternalUsersInTgr = new list<User>();
    private set<string> lstAllCountries = new set<string>();
    private set<string> lstAllMngrGUIDs = new set<string>();
    
    public User_tgr_cls (list<User> lstNewUserVals, list<User> lstOldUserVals, Map<Id, User> oldMap){
        
        //============================WORKDAY User Sync process===============================================================
        system.debug('***Begin: User_tgr_cls(): ');
        currentLoggedOnUserName     = UserInfo.getUserName();
        system.debug('***currentLoggedOnUserName: ' + currentLoggedOnUserName);
        sfdcIntegrationUsers        = WorkdayUserSync_Settings__c.getOrgDefaults().Integration_Users__c;
        
        //run only if sfdcIntegrationUsers is not blank - test case safe (what if the test classes creating users are set with SeeAllData=false)
        if (string.isNotBlank(sfdcIntegrationUsers)){
            system.debug('***sfdcIntegrationUsers set the custom settings: ' + sfdcIntegrationUsers);
            
            //run the code if only for the integration users: records coming from Workday PI Dataloader or during deployment
            if (sfdcIntegrationUsers.contains(currentLoggedOnUserName)){
                system.debug('***Begin: User_tgr_cls code executes');
                sfdcInstanceName            = WorkdayUserSync_Settings__c.getOrgDefaults().Sandbox_Instance_Name__c;
                defaultSFDCUserProfileId    = WorkdayUserSync_Settings__c.getOrgDefaults().Generic_Profile_Id__c;
                defaultSFDCUserRoleId       = WorkdayUserSync_Settings__c.getOrgDefaults().Generic_Role_Id__c;
                defaultTimeZoneSidKey       = WorkdayUserSync_Settings__c.getOrgDefaults().Time_Zone_Sid_Key__c;
                defaultLocaleSidKey         = WorkdayUserSync_Settings__c.getOrgDefaults().Locale_Sid_Key__c;
                defaultEmailEncodingKey     = WorkdayUserSync_Settings__c.getOrgDefaults().Email_Encoding_Key__c;
                defaultLanguageLocaleKey    = WorkdayUserSync_Settings__c.getOrgDefaults().Language_Locale_Key__c;
                
                //collect all the internal users as they would be getting synced only
                boolean bContainsRecordsWithGUID = false;
                for (User oUser : lstNewUserVals){
                    if (string.isNotBlank(oUser.EMPLOYEEGUID__c)){
                        lstInternalUsersInTgr.add(oUser);
                        if (!bContainsRecordsWithGUID) {
                            bContainsRecordsWithGUID = true;
                        }
                        lstAllCountries.add(oUser.CountryCode);
                        
                        //SDS-2776: Collect all User's Manager GUID in case of update process
                        if (system.trigger.isupdate && string.isNotBlank(oUser.ManagerGUID__c)){
                            lstAllMngrGUIDs.add(oUser.ManagerGUID__c);
                        }
                    }
                    
                }
                
                system.debug('***bContainsRecordsWithGUID: ' + bContainsRecordsWithGUID);
                //system.debug('***lstInternalUsersInTgr: ' + lstInternalUsersInTgr);
                
                list<Country_List__c> lstCountryList = new list<Country_List__c>();

                list<User> lstManagerUsers = new list<User>();
                
                //run only if there are GUIDs: avoid one SOQL
                if (bContainsRecordsWithGUID){
                
                    //collect all the country info from Country_List where ISO 3 letter code matches
                    //------------------------------------------------------------------------------
                    lstCountryList = [Select Name, ISO_Code__c, Region__c From Country_List__c Where ISO_Code__c in :lstAllCountries];
                    
                    //build a map of 3-letter ISO Code and their Country Name from Country List
                    map<string, string> mapCountryList = new map<string, string>();
                    map<string, string> mapCountryRegionList = new map<string, string>();
                    
                    for (Country_List__c country : lstCountryList){
                        mapCountryList.put(country.ISO_Code__c, country.Name);
                        mapCountryRegionList.put(country.ISO_Code__c, country.Region__c);
                    }
                    //------------------------------------------------------------------------------

                    //SDS-2776: Collect all Manager User Ids from Manager GUIDs
                    //------------------------------------------------------------------------------
                    map<string, string> mapMngrUserData = new map<string, string>();
                    if (system.trigger.isupdate){
                        lstManagerUsers = [Select Id, EMPLOYEEGUID__c From User Where EMPLOYEEGUID__c in :lstAllMngrGUIDs];
                        for (User mngrUser : lstManagerUsers){
                            mapMngrUserData.put(mngrUser.EMPLOYEEGUID__c, mngrUser.Id);
                        }
                    }
                    //------------------------------------------------------------------------------

                    

                    system.debug('***sfdcInstanceName (For Prod it should be blank)= ' + sfdcInstanceName);
                    
                    //process internal users
                    for (User oUser : lstInternalUsersInTgr){
                        
                        //before update trigger case: if HRActive__c flag is false the disable the user
                        if (system.trigger.isupdate){
                            //system.debug('***Begin: User_tgr_cls Before Update Code');
                            //No change to the username, email, profile, role, timezone, language
                            oUser.Username          = oldMap.get(oUser.Id).Username;
                            oUser.Email             = oldMap.get(oUser.Id).Email;
                            oUser.ProfileId         = oldMap.get(oUser.Id).ProfileId;
                            oUser.UserRoleId        = oldMap.get(oUser.Id).UserRoleId;
                            oUser.TimeZoneSidKey    = oldMap.get(oUser.Id).TimeZoneSidKey;
                            oUser.LocaleSidKey      = oldMap.get(oUser.Id).LocaleSidKey;
                            oUser.EmailEncodingKey  = oldMap.get(oUser.Id).EmailEncodingKey;
                            oUser.LanguageLocaleKey = oldMap.get(oUser.Id).LanguageLocaleKey;
                            
                            
                            //oUser.Region__c = string.isBlank(mapCountryRegionList.get(oUser.CountryCode)) == true ? oldMap.get(oUser.Id).Region__c :  mapCountryRegionList.get(oUser.CountryCode); //mapCountryRegionList.get(oUser.Country);
                            oUser.Region__c = string.isBlank(mapCountryRegionList.get(oUser.CountryCode)) == true ? null :  mapCountryRegionList.get(oUser.CountryCode);
                            
                            //system.debug('***mapCountryList.get(oUser.Country): ' + mapCountryList.get(oUser.Country));
                            //update the country from Country List; if the map contains value, then set it to the mapped value otherwise stick to old value
                            //2017.07.18 - PJENA- Country/State picklist rollout changes. No need to set the Country from Country_List as the CountryCode will set directly from Workday
                            //oUser.Country = string.isBlank(mapCountryList.get(oUser.Country)) == true ? oldMap.get(oUser.Id).Country :  mapCountryList.get(oUser.Country);
                            
                            //SDS-2776: Set the User's Manager from Manager GUID
                            //----------------------------------------------------
                            if (string.isNotBlank(oUser.ManagerGUID__c) && string.isNotBlank(mapMngrUserData.get(oUser.ManagerGUID__c))){
                                oUser.ManagerId = mapMngrUserData.get(oUser.ManagerGUID__c);
                            }
                            //----------------------------------------------------

                            //disable the user if the HR_Active__c is false
                            if (oUser.HRActive__c == false){
                                oUser.IsActive  = false;
                            }
                            
                            //system.debug('***End: User_tgr_cls Before Update Code');
                        } else if (system.trigger.isinsert){
                            //before insert trigger case: add the users as inactive users
                            //system.debug('***Begin: User_tgr_cls Before Insert Code');
                            
                            oUser.ProfileId         = defaultSFDCUserProfileId;
                            oUser.UserRoleId        = defaultSFDCUserRoleId;
                            oUser.TimeZoneSidKey    = defaultTimeZoneSidKey;
                            oUser.LocaleSidKey      = defaultLocaleSidKey;
                            oUser.EmailEncodingKey  = defaultEmailEncodingKey;
                            oUser.LanguageLocaleKey = defaultLanguageLocaleKey;
                            
                            //No Content specific access by default
                            oUser.UserPermissionsSFContentUser = false;
                            oUser.UserPreferencesContentNoEmail = true;
                            oUser.UserPreferencesContentEmailAsAndWhen = true;
                            
                            //all new users need to created as inactive
                            oUser.IsActive          = false;
                            
                            oUser.Region__c = string.isBlank(mapCountryRegionList.get(oUser.CountryCode)) == true ? null :  mapCountryRegionList.get(oUser.CountryCode);
                            
                            //update the country from Country List; if the map contains value, then set it to the mapped value otherwise stick to whatever comes from the csv
                            //2017.07.18 - PJENA- Country/State picklist rollout changes. No need to set the Country from Country_List as the CountryCode will set directly from Workday
                            //oUser.Country = string.isBlank(mapCountryList.get(oUser.Country)) == true ? oUser.Country :  mapCountryList.get(oUser.Country);
                            
                            //for sandbox, change their email to make it invalid so they do not get automated emails
                            oUser.Email             = string.isBlank(sfdcInstanceName) == true ? oUser.Email : oUser.Email + '.' + sfdcInstanceName;
                            //for sandbox, set username to email appeneded with the sandbox instance name 
                            oUser.Username          = oUser.Email;
                            oUser.FederationIdentifier  = oUser.EMPLOYEEGUID__c;
                            //system.debug('***End: User_tgr_cls Before Insert Code');
                        }
                    }
                
                }//end: run only if there are GUIDs
                
                system.debug('***End: User_tgr_cls code executes');
            }
            system.debug('***End: User_tgr_cls(): ');
        } //end: run only if sfdcIntegrationUsers is not blank
        //============================End: WORKDAY User Sync process===============================================================
        
        
        
        //============================Copy ContactId value to custom Community_ContactId__c during the onboarding.================
        //2018.06.14 - PJENA - Scedulable batch class to Sync Community User Data to its Community Contact Record (Insert : For external users only - Set Activation Date)

        if (trigger.isBefore && trigger.isInsert){
	        for(User oUser : lstNewUserVals) {
				
                //Copy Community Contact Id only for external users only
                //2020.12.09 - PJENA - Bugfix - Brainshark Activation/Deactivation Date not getting set for new inserts - UserType comes blank for Before Insert triggers, alternatively use EmployeeGuid to determine internal users
	            if(string.isBlank(oUser.EMPLOYEEGUID__c)) {
	                //copy Community_ContactId__c from ContactId
	                oUser.Community_ContactId__c = oUser.ContactId;
	            }
				
				//Set activation date for both Internal/External Users
				if (oUser.IsActive == true){
					oUser.ActivatedDate__c = Date.today();
					oUser.ActivatedByUserId__c = UserInfo.getUserId();
				}
                
                //2020.11.04 - PJENA - SDS-2776 - Set Brainshark Activation/Deactivate Date for Internal Users
                //2020.12.09 - PJENA - Bugfix - Brainshark Activation/Deactivation Date not getting set for new inserts - UserType comes blank for Before Insert triggers, alternatively use EmployeeGuid to determine internal users
                if (string.isNotBlank(oUser.EMPLOYEEGUID__c) && oUser.HRActive__c == true){
                    oUser.Brainshark_HR_Activation_Date__c = DateTime.now();
                }else if (string.isNotBlank(oUser.EMPLOYEEGUID__c) && oUser.HRActive__c == false){
                    oUser.Brainshark_HR_Deactivation_Date__c = DateTime.now();
                }
                //End: SDS-2776 - Set Brainshark Activation/Deactivate Date for Internal Users
	            
	        }
        }
        //============================End: Copy ContactId value to custom Community_ContactId__c during the onboarding.================
        

        //2018.06.14 - PJENA - Set the Activation and Deactivation Date for Users (Update : for Internal and Externa Users)
        //===========================Set the Activation and Deactivation Date for Users ===============================================
		if (trigger.isBefore && trigger.isUpdate){
			for(User oUser : lstNewUserVals) {

				//Update : for Internal Users
				if (oUser.UserType == 'Standard' && oUser.IsActive <> oldMap.get(oUser.Id).IsActive){
					if (oUser.IsActive == true){
						oUser.ActivatedDate__c = Date.today();
	                	oUser.ActivatedByUserId__c = UserInfo.getUserId();
					}else{
						oUser.DeactivatedDate__c = Date.today();
	                	oUser.DeactivatedByUserId__c = UserInfo.getUserId();
					}
				
				}
                //End: Update : for Internal Users

                //2020.11.04 - PJENA - SDS-2776 - for Internal Users - Set Brainshark Activation/Deactivate Date 
                if (oUser.UserType == 'Standard' && oUser.HRActive__c <> oldMap.get(oUser.Id).HRActive__c && oUser.HRActive__c == true){
                    oUser.Brainshark_HR_Activation_Date__c = DateTime.now();
                }else if (oUser.UserType == 'Standard' && oUser.HRActive__c <> oldMap.get(oUser.Id).HRActive__c && oUser.HRActive__c == false){
                    oUser.Brainshark_HR_Deactivation_Date__c = DateTime.now();
                }
                //End: SDS-2776 - for Internal Users - Set Brainshark Activation/Deactivate Date 
                
				//Update : for External Users
				if (oUser.UserType <> 'Standard' && oUser.IsPortalEnabled <> oldMap.get(oUser.Id).IsPortalEnabled){
					if (oUser.IsPortalEnabled == true){
						oUser.ActivatedDate__c = Date.today();
	                	oUser.ActivatedByUserId__c = UserInfo.getUserId();
					}else{
						oUser.DeactivatedDate__c = Date.today();
	                	oUser.DeactivatedByUserId__c = UserInfo.getUserId();
					}
					
				}
				//End: Update : for External Users
			}
		}
		//===========================End: Set the Activation and Deactivation Date for Users ===========================================
		
    }
}