/*
	2019.08.14 - test class for  from NVIDIASFDCOrgInstanceInitializer_batch
		- Upates all email addresses of external User and Contact records 
*/

@isTest(SeeAllData=false)
private class NVIDIASFDCOrgInstanceInitializ_bat_test {

    static testMethod void testCreateExternalUserAndUpdateTheirEmailAddress() {
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
        
        system.runAs(currUser){
	        //Create Portal Permission Sets object record
			oPPS = new Portal_Permission_Sets__c (Name = PP_COMM_LITE, Portal_Groups__c = PPG_COMMUNITY);
			database.SaveResult lstDSRPPS = Database.insert(oPPS, false); 
			
			//Create Portal Public Groups object record
			 oPPG= new Portal_Public_Groups__c (Name = PPG_COMMUNITY, Portal_Public_Group__c = PPS_COMM_CONTENT);
			database.SaveResult lstDSRPPG = Database.insert(oPPG, false); 
			
	        
	        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
	        partnerAccount = Test_COMM_Factory.createAccount('Test PP Account1', mapPP_PartnerProgramAccount_RT.get(COMM_Constants.ACCOUNT_RT_PARTNER_ACCOUNT), true, false);
	        /*
	        long lRandom = Math.roundToLong(Math.random() * 9999);
			long  uniqueVal = System.currentTimeMillis();
			string uniqueNameExt = lRandom + '' + uniqueVal;
	        partnerAccount.SAP_customer_Number__c = uniqueNameExt.right(4)+uniqueNameExt.right(6);
	        update partnerAccount;
	       */
	        //Check if the Account is a partner account 
	        system.assertEquals(partnerAccount.IsPartner, true);
	        //---------------------------------------------
         
        
        
	        //Create a Partner Contact 
	        //---------------------------------------------
	        //Contact partnerContact = Test_COMM_Factory.createContact('Test', 'test1@nv.com', partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.CON_DEFAULT_CONTENT_TYPE_NPN);
	        
	        //Create N number of Partner Contacts
	        //---------------------------------------------
	        //createContacts(Id accountId, string recordTypeId, string strPortalGroups, integer iNumOfUsers){
	        lstPartnerContact = Test_COMM_Factory.createContacts(partnerAccount.Id, mapPP_PartnerContact_RT.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), PPG_COMMUNITY, 10);
	        
        }
        //Create the Portal User for those N Partner Contacts
        //---------------------------------------------
        list<User> lstPartnerUser = Test_COMM_Factory.createUsers(lstPartnerContact, mapPP_TPP_Generic_Prof.get(COMM_Constants.PROF_PP_TPP_GENERIC)); 
        
        //---------------------------------------------
        
		
		Test.startTest();

     		NVIDIASFDCOrgInstanceInitializer_batch oBC = new NVIDIASFDCOrgInstanceInitializer_batch();
     		Database.executeBatch(oBC, 100);

   		Test.stopTest();
        
    }
}