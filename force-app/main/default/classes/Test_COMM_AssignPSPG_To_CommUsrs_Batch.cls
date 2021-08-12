/**
	2017.03.11 - Test Class for Schdulable batch class COMM_AssignPSPG_To_CommunityUsers_Batch
	10/3/2019 - SDS-1762 - EAR (Export Administration Regulations) list (PUB: Huawei, Dawning/Sugon Updates) - Do not add certain PS and public groups
	 
 */
 
@isTest(SeeAllData=false)
private class Test_COMM_AssignPSPG_To_CommUsrs_Batch {

     static testMethod void testPSPGAssignment() {
		
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
        Account EARRestrictedPartnerAccount;
        list<Contact> lstPartnerContact;
        list<Contact> lstEARPartnerContact;
        User currUser = [Select Id From User where Id = :UserInfo.getUserId()];
        
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
         
			EARRestrictedPartnerAccount = Test_COMM_Factory.createAccount('TestEARRestrictedPartnerAccount', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_PARTNER_ACCOUNT), true, false);
			EARRestrictedPartnerAccount.EAR_Restricted__c = true;
			database.update(EARRestrictedPartnerAccount);
        
	        //Create a Partner Contact 
	        //---------------------------------------------
	        //Contact partnerContact = Test_COMM_Factory.createContact('Test', 'test1@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_DEFAULT_CONTENT_TYPE_NPN);
	        
	        //Create N number of Partner Contacts
	        //---------------------------------------------
	        //createContacts(Id accountId, string recordTypeId, string strPortalGroups, integer iNumOfUsers){
	        lstPartnerContact = Test_COMM_Factory.createContacts(partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), PPG_COMMUNITY, 5);
	        lstEARPartnerContact = Test_COMM_Factory.createContacts(EARRestrictedPartnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), PPG_COMMUNITY, 5);
	        
	        
        }
        //Create the Portal User for those N Partner Contacts
        //---------------------------------------------
        list<User> lstPartnerUser = Test_COMM_Factory.createUsers(lstPartnerContact, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC)); 
        
        list<User> lstEARPartnerUser = Test_COMM_Factory.createUsers(lstEARPartnerContact, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC)); 
        
        //---------------------------------------------
        
		
		Test.startTest();

     		string CRON_EXP = '0 5 * ? * *';
     	 	
     	 	// Schedule the test job
      		String jobId = System.schedule('Test_COMM_AssignPSPG_To_PortalUsers',  CRON_EXP ,  new COMM_AssignPSPG_To_CommunityUsers_Batch());

     	 	// Get the information from the CronTrigger API object
      		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

      		// Verify the expressions are the same
      		System.assertEquals(CRON_EXP, ct.CronExpression);

      		// Verify the job has not run
      		System.assertEquals(0, ct.TimesTriggered);

   		Test.stopTest();

    }
}