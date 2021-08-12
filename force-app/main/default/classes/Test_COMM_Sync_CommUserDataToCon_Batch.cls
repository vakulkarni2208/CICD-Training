/*
	2018.06.02 - Test Class for Schdulable batch class COMM_Sync_CommUserDataToContactRec_Batch
	
 */
 
@isTest(SeeAllData=false)
private class Test_COMM_Sync_CommUserDataToCon_Batch {

    static testMethod void test_ActvCommUsers() {
		
		string PPG_COMMUNITY = 'Community';
		
		
		
		//create Partner Portal Account
        //---------------------------------------------
        map<String, Id> mapNewCustomerAccount_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_ACCOUNT, COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER);
        map<String, Id> mapCustomerContact_RT = COMM_Utility.getRTsByName(COMM_Constants.SOBJECT_CONTACT, COMM_Constants.CONTACT_RT_SALES_CONTACT);
        map<string, Id> mapCommLite_Prof = COMM_Utility.getProfsByName(COMM_Constants.PROF_CP_QPP_GENERIC);
        
       
        Account customerAccount;
        list<Contact> lstSalesContact;
        User currUser = [Select Id From User where Id = :UserInfo.getUserId()];
        
        system.runAs(currUser){
			
			//Set Community Settings custom settings
			Test_COMM_Factory.set_CommunitySettings();
		
	        //(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal)
	        customerAccount = Test_COMM_Factory.createAccount('Test Customer Account1', mapNewCustomerAccount_RT.get(COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER), false, false);
	       
	        //Check if the Account is a partner account 
	        //system.assertEquals(customerAccount.IsCustomer, true);
	        //---------------------------------------------
         
    
	        //Create N number of Partner Contacts
	        //---------------------------------------------
	        //createContacts(Id accountId, string recordTypeId, string strPortalGroups, integer iNumOfUsers){
	        lstSalesContact = Test_COMM_Factory.createContacts(customerAccount.Id, mapCustomerContact_RT.get(COMM_Constants.CONTACT_RT_SALES_CONTACT), null, 10);
	        
        }
        //Create the Portal User for those N Customer Contacts
        //---------------------------------------------
        list<User> lstCustomerUser = Test_COMM_Factory.createUsers(lstSalesContact, mapCommLite_Prof.get(COMM_Constants.PROF_CP_QPP_GENERIC)); 
        
        //---------------------------------------------
        
		
		Test.startTest();

     		string CRON_EXP = '0 5 * ? * *';
     	 	
     	 	// Schedule the test job
      		String jobId = System.schedule('Test_COMM_Sync_CommUserDataToContactRec_Batch',  CRON_EXP ,  new COMM_Sync_CommUserDataToContactRec_Batch());

     	 	// Get the information from the CronTrigger API object
      		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

      		// Verify the expressions are the same
      		System.assertEquals(CRON_EXP, ct.CronExpression);

      		// Verify the job has not run
      		System.assertEquals(0, ct.TimesTriggered);

   		Test.stopTest();

    }
}