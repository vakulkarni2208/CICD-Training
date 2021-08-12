/*
	2017.09.12 - pjena -Test class for IDM batch class SOCRM_IDM_UserMgmt_Batch
	
 */
 
@isTest(SeeAllData=false)
private class Test_SOCRM_IDM_UserMgmt_Batch {
	
	//Active Partner Users, Sync Success through Mock Response
	static testMethod void testActiveUserIDMSyncSuccess() {
		string PPG_COMMUNITY = 'Community';
		string PPS_COMM_CONTENT = 'Community Content';
		string PP_COMM_LITE = 'PP_COMM_LITE_HOME_TAB';
		
		//Set Community Settings custom settings
		Test_COMM_Factory.set_CommunitySettings();
		
		//create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_PARTNER_ACCOUNT);
        map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC);
        
        Portal_Permission_Sets__c oPPS;
        Portal_Public_Groups__c oPPG;
        Account partnerAccount;
        list<Contact> lstPartnerContact;
        User currUser = [Select Id From User where Id = :UserInfo.getUserId()];
        
        //set IDM : Settings
        //-------------------------------------------------------------------------------------
		IDM_Settings__c csIDMSettings = setIDMSettings();
		//End: set IDM : Settings
        //-------------------------------------------------------------------------------------
        
        system.runAs(currUser){
	        //Create Portal Permission Sets object record
			oPPS = new Portal_Permission_Sets__c (Name = PP_COMM_LITE, Portal_Groups__c = PPG_COMMUNITY);
			database.SaveResult lstDSRPPS = Database.insert(oPPS, false); 
			
			//Create Portal Public Groups object record
			 oPPG= new Portal_Public_Groups__c (Name = PPG_COMMUNITY, Portal_Public_Group__c = PPS_COMM_CONTENT);
			database.SaveResult lstDSRPPG = Database.insert(oPPG, false); 
			
	        
	        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
	        partnerAccount = Test_COMM_Factory.createAccount('Test PP Account1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_PARTNER_ACCOUNT), true, false);
	       
	        //Check if the Account is a partner account 
	        system.assertEquals(partnerAccount.IsPartner, true);
	        //---------------------------------------------
	        
	        //Create N number of Partner Contacts
	        //---------------------------------------------
	        //createContacts(Id accountId, string recordTypeId, string strPortalGroups, integer iNumOfUsers){
	        lstPartnerContact = Test_COMM_Factory.createContacts(partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), PPG_COMMUNITY, 2);
	        
        }
        //Create the Portal User for those N Partner Contacts
        //---------------------------------------------
        list<User> lstPartnerUser = Test_COMM_Factory.createUsers(lstPartnerContact, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC)); 
        //---------------------------------------------
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('SOCRMIDMSuccessResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
		
		//run as to avoid MIXED DML
		system.runAs(currUser){
			Test.startTest();
				Test.setMock(HttpCalloutMock.class, mock);
	      		Database.BatchableContext     bc;
				SOCRM_IDM_UserMgmt_Batch bClass = new SOCRM_IDM_UserMgmt_Batch();
	  			Database.QueryLocator ql = bClass.start(bc);
	  			bClass.execute(bc, lstPartnerUser);
	  			bClass.finish(bc);
	  
				lstPartnerUser = [Select Id, IsActive, IDM_Assign_SOCRM_Role_Call_Success__c, IDM_SOCRM_Role_Assigned__c From User Where Id = :lstPartnerUser];
				system.debug('***lstPartnerUser: ' + lstPartnerUser);
				for (User u : lstPartnerUser){
					system.assert(u.IDM_Assign_SOCRM_Role_Call_Success__c == true);
					system.assert(u.IDM_SOCRM_Role_Assigned__c == true);
				}
	   		Test.stopTest();
		}
    }
    
    //Active Partner Users, Sync Failure though Mock Failure Response
    static testMethod void testActiveUserIDMSyncFailure() {
		string PPG_COMMUNITY = 'Community';
		string PPS_COMM_CONTENT = 'Community Content';
		string PP_COMM_LITE = 'PP_COMM_LITE_HOME_TAB';
		
		//Set Community Settings custom settings
		Test_COMM_Factory.set_CommunitySettings();
		
		//create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_PARTNER_ACCOUNT);
        map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC);
        
        Portal_Permission_Sets__c oPPS;
        Portal_Public_Groups__c oPPG;
        Account partnerAccount;
        list<Contact> lstPartnerContact;
        User currUser = [Select Id From User where Id = :UserInfo.getUserId()];
        
        //set IDM : Settings
        //-------------------------------------------------------------------------------------
		IDM_Settings__c csIDMSettings = setIDMSettings();
		//End: set IDM : Settings
        //-------------------------------------------------------------------------------------
        
        system.runAs(currUser){
	        //Create Portal Permission Sets object record
			oPPS = new Portal_Permission_Sets__c (Name = PP_COMM_LITE, Portal_Groups__c = PPG_COMMUNITY);
			database.SaveResult lstDSRPPS = Database.insert(oPPS, false); 
			
			//Create Portal Public Groups object record
			 oPPG= new Portal_Public_Groups__c (Name = PPG_COMMUNITY, Portal_Public_Group__c = PPS_COMM_CONTENT);
			database.SaveResult lstDSRPPG = Database.insert(oPPG, false); 
			
	        
	        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
	        partnerAccount = Test_COMM_Factory.createAccount('Test PP Account1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_PARTNER_ACCOUNT), true, false);
	       
	        //Check if the Account is a partner account 
	        system.assertEquals(partnerAccount.IsPartner, true);
	        //---------------------------------------------
			
	        //Create N number of Partner Contacts
	        //---------------------------------------------
	        //createContacts(Id accountId, string recordTypeId, string strPortalGroups, integer iNumOfUsers){
	        lstPartnerContact = Test_COMM_Factory.createContacts(partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), PPG_COMMUNITY, 2);
	        
        }
        //Create the Portal User for those N Partner Contacts
        //---------------------------------------------
        list<User> lstPartnerUser = Test_COMM_Factory.createUsers(lstPartnerContact, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC)); 
        
        //---------------------------------------------
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('SOCRMIDMFailureResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
		
		//run as to avoid MIXED DML
		system.runAs(currUser){
			Test.startTest();
				Test.setMock(HttpCalloutMock.class, mock);
      			Database.BatchableContext     bc;
				SOCRM_IDM_UserMgmt_Batch bClass = new SOCRM_IDM_UserMgmt_Batch();
  				Database.QueryLocator ql = bClass.start(bc);
  				bClass.execute(bc, lstPartnerUser);
  				bClass.finish(bc);
  				
  				lstPartnerUser = [Select Id, IsActive, IDM_Assign_SOCRM_Role_Call_Success__c, IDM_SOCRM_Role_Assigned__c From User Where Id = :lstPartnerUser];
				system.debug('***lstPartnerUser: ' + lstPartnerUser);
				for (User u : lstPartnerUser){
					system.assert(u.IDM_Assign_SOCRM_Role_Call_Success__c == false);
					system.assert(u.IDM_SOCRM_Role_Assigned__c == false);
				}
   			Test.stopTest();
		}
    }
    
    //Inactive Partner Users, Sync Success through Mock Response
    static testMethod void testInActiveUserIDMSyncSuccess() {
		string PPG_COMMUNITY = 'Community';
		string PPS_COMM_CONTENT = 'Community Content';
		string PP_COMM_LITE = 'PP_COMM_LITE_HOME_TAB';
		
		//Set Community Settings custom settings
		Test_COMM_Factory.set_CommunitySettings();
		
		//create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_PARTNER_ACCOUNT);
        map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC);
        
        Portal_Permission_Sets__c oPPS;
        Portal_Public_Groups__c oPPG;
        Account partnerAccount;
        list<Contact> lstPartnerContact;
        User currUser = [Select Id From User where Id = :UserInfo.getUserId()];
        
        //set IDM : Settings
        //-------------------------------------------------------------------------------------
		IDM_Settings__c csIDMSettings = setIDMSettings();
		//End: set IDM : Settings
        //-------------------------------------------------------------------------------------
        
        system.runAs(currUser){
	        //Create Portal Permission Sets object record
			oPPS = new Portal_Permission_Sets__c (Name = PP_COMM_LITE, Portal_Groups__c = PPG_COMMUNITY);
			database.SaveResult lstDSRPPS = Database.insert(oPPS, false); 
			
			//Create Portal Public Groups object record
			 oPPG= new Portal_Public_Groups__c (Name = PPG_COMMUNITY, Portal_Public_Group__c = PPS_COMM_CONTENT);
			database.SaveResult lstDSRPPG = Database.insert(oPPG, false); 
			
	        
	        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
	        partnerAccount = Test_COMM_Factory.createAccount('Test PP Account1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_PARTNER_ACCOUNT), true, false);
	       
	        //Check if the Account is a partner account 
	        system.assertEquals(partnerAccount.IsPartner, true);
	        //---------------------------------------------
 			
	        //Create N number of Partner Contacts
	        //---------------------------------------------
	        //createContacts(Id accountId, string recordTypeId, string strPortalGroups, integer iNumOfUsers){
	        lstPartnerContact = Test_COMM_Factory.createContacts(partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), PPG_COMMUNITY, 2);
	        
        }
        
        //Create the Portal User for those N Partner Contacts
        //---------------------------------------------
        list<User> lstPartnerUser = createInactiveUsersToRevokSOCRMAccess(lstPartnerContact, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC));
        //---------------------------------------------
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('SOCRMIDMSuccessResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
		
		//run as to avoid MIXED DML
		system.runAs(currUser){
			Test.startTest();
				Test.setMock(HttpCalloutMock.class, mock);
      			Database.BatchableContext     bc;
				SOCRM_IDM_UserMgmt_Batch bClass = new SOCRM_IDM_UserMgmt_Batch();
  				Database.QueryLocator ql = bClass.start(bc);
  				bClass.execute(bc, lstPartnerUser);
  				bClass.finish(bc);
  				
  				lstPartnerUser = [Select Id, IsActive, IDM_Revoke_SOCRM_Role_Call_Success__c, IDM_SOCRM_Role_Revoked__c From User Where Id = :lstPartnerUser];
				system.debug('***lstPartnerUser: ' + lstPartnerUser);
				for (User u : lstPartnerUser){
					system.assert(u.IDM_Revoke_SOCRM_Role_Call_Success__c == true);
					system.assert(u.IDM_SOCRM_Role_Revoked__c == true);
				}
   			Test.stopTest();
		}
        
    }
    
    
    //Inactive Partner Users, Sync Failure through Mock Response
    static testMethod void testInActiveUserIDMSyncFailure() {
		string PPG_COMMUNITY = 'Community';
		string PPS_COMM_CONTENT = 'Community Content';
		string PP_COMM_LITE = 'PP_COMM_LITE_HOME_TAB';
		
		//Set Community Settings custom settings
		Test_COMM_Factory.set_CommunitySettings();
		
		//create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_PARTNER_ACCOUNT);
        map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC);
        
        Portal_Permission_Sets__c oPPS;
        Portal_Public_Groups__c oPPG;
        Account partnerAccount;
        list<Contact> lstPartnerContact;
        User currUser = [Select Id From User where Id = :UserInfo.getUserId()];
        
        //set IDM : Settings
        //-------------------------------------------------------------------------------------
		IDM_Settings__c csIDMSettings = setIDMSettings();
		//End: set IDM : Settings
        //-------------------------------------------------------------------------------------
        
        system.runAs(currUser){
	        //Create Portal Permission Sets object record
			oPPS = new Portal_Permission_Sets__c (Name = PP_COMM_LITE, Portal_Groups__c = PPG_COMMUNITY);
			database.SaveResult lstDSRPPS = Database.insert(oPPS, false); 
			
			//Create Portal Public Groups object record
			 oPPG= new Portal_Public_Groups__c (Name = PPG_COMMUNITY, Portal_Public_Group__c = PPS_COMM_CONTENT);
			database.SaveResult lstDSRPPG = Database.insert(oPPG, false); 
			
	        
	        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
	        partnerAccount = Test_COMM_Factory.createAccount('Test PP Account1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_PARTNER_ACCOUNT), true, false);
	       
	        //Check if the Account is a partner account 
	        system.assertEquals(partnerAccount.IsPartner, true);
	        //---------------------------------------------

	        //Create N number of Partner Contacts
	        //---------------------------------------------
	        //createContacts(Id accountId, string recordTypeId, string strPortalGroups, integer iNumOfUsers){
	        lstPartnerContact = Test_COMM_Factory.createContacts(partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), PPG_COMMUNITY, 2);
	        
        }
        //Create the Portal User for those N Partner Contacts
        //---------------------------------------------
		list<User> lstPartnerUser = createInactiveUsersToRevokSOCRMAccess(lstPartnerContact, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC));
		//---------------------------------------------
		
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('SOCRMIDMFailureResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
		
		//run as to avoid MIXED DML
		system.runAs(currUser){
			Test.startTest();
				Test.setMock(HttpCalloutMock.class, mock);
      			Database.BatchableContext     bc;
				SOCRM_IDM_UserMgmt_Batch bClass = new SOCRM_IDM_UserMgmt_Batch();
  				Database.QueryLocator ql = bClass.start(bc);
  				bClass.execute(bc, lstPartnerUser);
  				bClass.finish(bc);
  				
  				lstPartnerUser = [Select Id, IsActive, IDM_Revoke_SOCRM_Role_Call_Success__c, IDM_SOCRM_Role_Revoked__c From User Where Id = :lstPartnerUser];
				system.debug('***lstPartnerUser: ' + lstPartnerUser);
				for (User u : lstPartnerUser){
					system.assert(u.IDM_Revoke_SOCRM_Role_Call_Success__c == false);
					system.assert(u.IDM_SOCRM_Role_Revoked__c == false);
				}
   			Test.stopTest();
		}
        
    }
    
    //Active Partner Users, Exception case (with the help of no mock configuration)
	static testMethod void testFailureCaseWithoutMockResponse() {
		string PPG_COMMUNITY = 'Community';
		string PPS_COMM_CONTENT = 'Community Content';
		string PP_COMM_LITE = 'PP_COMM_LITE_HOME_TAB';
		
		//Set Community Settings custom settings
		Test_COMM_Factory.set_CommunitySettings();
		
		//create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapPP_PartnerProgramAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_PARTNER_ACCOUNT);
        map<String, Id> mapPP_PartnerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_PARTNER_CONTACT);
        map<string, Id> mapPP_TPP_Generic_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_PP_TPP_GENERIC);
        
        Portal_Permission_Sets__c oPPS;
        Portal_Public_Groups__c oPPG;
        Account partnerAccount;
        list<Contact> lstPartnerContact;
        User currUser = [Select Id From User where Id = :UserInfo.getUserId()];
        
        //set IDM : Settings
        //-------------------------------------------------------------------------------------
		IDM_Settings__c csIDMSettings = setIDMSettings();
		//End: set IDM : Settings
        //-------------------------------------------------------------------------------------
        
        system.runAs(currUser){
	        //Create Portal Permission Sets object record
			oPPS = new Portal_Permission_Sets__c (Name = PP_COMM_LITE, Portal_Groups__c = PPG_COMMUNITY);
			database.SaveResult lstDSRPPS = Database.insert(oPPS, false); 
			
			//Create Portal Public Groups object record
			 oPPG= new Portal_Public_Groups__c (Name = PPG_COMMUNITY, Portal_Public_Group__c = PPS_COMM_CONTENT);
			database.SaveResult lstDSRPPG = Database.insert(oPPG, false); 
			
	        
	        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
	        partnerAccount = Test_COMM_Factory.createAccount('Test PP Account1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_PARTNER_ACCOUNT), true, false);
	       
	        //Check if the Account is a partner account 
	        system.assertEquals(partnerAccount.IsPartner, true);
	        //---------------------------------------------

	        //Create N number of Partner Contacts
	        //---------------------------------------------
	        //createContacts(Id accountId, string recordTypeId, string strPortalGroups, integer iNumOfUsers){
	        lstPartnerContact = Test_COMM_Factory.createContacts(partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), PPG_COMMUNITY, 2);
	        
        }
        //Create the Portal User for those N Partner Contacts
        //---------------------------------------------
		list<User> lstPartnerUser = Test_COMM_Factory.createUsers(lstPartnerContact, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC)); 
		//---------------------------------------------
		
		/*
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('SOCRMIDMFailureResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/xml');
		*/
		//run as to avoid MIXED DML
		system.runAs(currUser){
			Test.startTest();
				/*
				Test.setMock(HttpCalloutMock.class, mock);
				*/
	      		Database.BatchableContext     bc;
				SOCRM_IDM_UserMgmt_Batch bClass = new SOCRM_IDM_UserMgmt_Batch();
	  			Database.QueryLocator ql = bClass.start(bc);
	  			bClass.execute(bc, lstPartnerUser);
	  			bClass.finish(bc);
	  			
	  			lstPartnerUser = [Select Id, IsActive, IDM_API_Call_Failure__c, IDM_SOCRM_Role_Assigned__c From User Where Id = :lstPartnerUser];
				system.debug('***lstPartnerUser: ' + lstPartnerUser);
				for (User u : lstPartnerUser){
					system.assert(u.IDM_API_Call_Failure__c == true);
					system.assert(u.IDM_SOCRM_Role_Assigned__c == false);
				}
	   		Test.stopTest();
		}
        
    }
    
    //-------------------------------------
    //HELPER Methods
    //-------------------------------------
    private static IDM_Settings__c setIDMSettings(){
    	//-------------------------------------------------------------------------------------
		IDM_Settings__c csIDMSettings = new IDM_Settings__c();
		csIDMSettings.Name = 'IDM Settings';
		csIDMSettings.API_endpoint__c = 'anything';
		csIDMSettings.API_HTTPReq_timeout__c = 60000;
		csIDMSettings.BATCHJOB_BATCH_SIZE__c = 25;
		csIDMSettings.BATCHJOB_ENABLE_SCHDULED_JOB__c = true;
		csIDMSettings.BATCHJOB_LKBK_TIME__c = 5;
		csIDMSettings.BATCHJOB_RECUR__c	 = 2;
		csIDMSettings.SOCRM_Email_Template_Category__c = 'SOCRM';
		csIDMSettings.SOCRM_IDM_Role__c = 'SOCRMAccessRole';
		csIDMSettings.SOCRM_SFDC_Profiles__c = 'NPN Partner Community(LOGIN); NPN Partner Community(NAMED); Marketing Customer Community; Community Lite Profile';
		if (Test.isRunningTest()){
			insert csIDMSettings;
		}
		return csIDMSettings;
    }
    
    //Create inactive users with SOCRMRole to be revoked
    private static list<User> createInactiveUsersToRevokSOCRMAccess(list<Contact> lstPartnerContacts, string profileId){
        Long lRandom, uniqueVal;
        list<User> lstUser = new list<User>();
        for (integer i = 0; i < lstPartnerContacts.size(); i++){
        	
        	lRandom = Math.roundToLong(Math.random() * 999);
			uniqueVal = System.currentTimeMillis();  //Current Time will always return different instantaneous value
	                
	        User usr = new User(alias = 't' + lRandom,                                             
								email = 't' + lRandom + uniqueVal + 's' + i  + '@nvidia.com',                                             
								lastname='test',                                                                                         
								CommunityNickname = 't' + lRandom + uniqueVal + 's' + i + '@nv.com',                                                                                       
								ProfileId = profileId,                                     
								username='t' + lRandom + uniqueVal + 's' + i + '@nv.com',  
								ContactId =  lstPartnerContacts[i].Id,                                  
								EmailEncodingKey  = COMM_Constants.USER_EMAILENCODEKEY,
								LanguageLocaleKey = COMM_Constants.USER_LANGLOCALEKEY,
								LocaleSidKey = COMM_Constants.USER_LOCALESIDKEY,
								TimeZoneSidKey = COMM_Constants.USER_TZSIDKEY,
								IsActive = false,
								IDM_SOCRM_Role_Assigned__c = true,
								IDM_SOCRM_Role_Revoked__c = false );
			lstUser.add(usr);
        }
		                                          
		if (Test.isRunningTest()){
			insert lstUser;
		}
		return lstUser;
    }
    
    //End: HELPER Methods
    //--------------------------------------
}