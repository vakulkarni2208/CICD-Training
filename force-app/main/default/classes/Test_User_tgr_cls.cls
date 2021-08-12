/*
 	2017.01.23: Test class for User Trigger class User_tgr_cls
 	2017.07.18 - PJENA- Country/State picklist rollout changes
	2020.11.04 - PJENA - SDS-2776 - Set ManagerId from ManagerGUID__c field - Only for update use case. It is supposed to be set from Workday with the Manager Process Node
 */
 
 
@isTest (SeeAllData = false)
private class Test_User_tgr_cls {
	
	private static Profile profNVInternalCRMGeneric;
	private static string nvidiaDomain = '@nvidia.com';
	private static string instanceName = 'sb';
	private static string prodInstanceName = '';
	private static string countryCodeINDIA = 'IN';
	private static string countryNameINDIA = 'India';
	private static string regionNameEMEAI = 'EMEA';
	private static string countryCodeUS = 'US';
	private static string countryNameUS = 'United States';
	private static string regionNameNALA = 'NALA';
	private static string countryCodeCHINA = 'CN';
	private static string countryNameCHINA = 'China';
	private static string regionNameAPAC = 'APAC';
	
	
	/*
		Testing of user create/update in Sandbox scenario
	*/
    static testMethod void testWDSyncUserCreationInSandbox() {
        
        //create test data
        //-------------------------------------------------------------------------------
        createCustomSettingsData(instanceName);
        setCountryListData();
        //-------------------------------------------------------------------------------
        //End: create test data
       
        
        //Create New Users
        //-------------------------------------------------------------------------------
        list<User> lstNewUsers = new list<User>();
        long lRandom, uniqueVal;
        string email;
        
        //create an user1
        lRandom = Math.roundToLong(Math.random() * 999);
        uniqueVal = System.currentTimeMillis();
        email = 'f1' + lRandom + 'l1' + uniqueVal + nvidiaDomain;
        User user1 = new User(
        					FirstName = 'f1', 
        					LastName = 'l1', 
        					Department = 'Worldwide Field Ops', 
        					Email = email, 
        					CountryCode = countryCodeUS, 
        					ALIAS= 'f1l1', 
        					CommunityNickname = email,
        					CompanyName = 'NVIDIA',
        					HRActive__c = true,
        					IsActive = true,
							EMPLOYEEGUID__c = '2bce1504c61d4b7db7f894dcbwdtusr1'
        					);
		//create an user2
        lRandom = Math.roundToLong(Math.random() * 999);
        uniqueVal = System.currentTimeMillis();
        email = 'f2' + lRandom + 'l2' + uniqueVal + nvidiaDomain;
        User user2 = new User(
        					FirstName = 'l2', 
        					LastName = 'f2', 
        					Department = 'Worldwide Field Ops', 
        					Email = email, 
        					CountryCode = countryCodeINDIA, 
        					ALIAS='f2l2', 
        					CommunityNickname = email,
        					CompanyName = 'NVIDIA',
        					HRActive__c = true,
        					IsActive = true,
							EMPLOYEEGUID__c = '2bce1504c61d4b7db7f894dcbwdtusr2'
        					);
        
        lstNewUsers.add(user1);
        lstNewUsers.add(user2);
        
        insert lstNewUsers;
        //-------------------------------------------------------------------------------
        
        //Assert the values
        //-------------------------------------------------------------------------------
        Test.startTest();
	        list<User> lstQryUsers = [	Select Username, Email, EMPLOYEEGUID__c, FederationIdentifier, IsActive, HRActive__c, ProfileId, UserRoleId, Country, Region__c 
	        							From User 
	        							Where Id in :lstNewUsers];
	        for (integer i=0; i<lstQryUsers.size(); i++){
	        	//Assert the inactive state, profileId, RoleId; username and email should end with the sandbox instance name
	        	system.assert(lstQryUsers[i].isActive == false);
	        	system.assert(lstQryUsers[i].ProfileId == profNVInternalCRMGeneric.Id);
	        	system.assert(lstQryUsers[i].UserRoleId == null);
	        	system.assert(lstQryUsers[i].Username == lstQryUsers[i].Email);
	        	system.assert(lstQryUsers[i].FederationIdentifier == lstQryUsers[i].EMPLOYEEGUID__c);
	        	system.assert(lstQryUsers[i].Username.endsWith(instanceName));
	        	system.assert(lstQryUsers[i].Email.endsWith(instanceName));
	        	
	        	//Assert the country
	        	if (lstQryUsers[i].FederationIdentifier == '2bce1504c61d4b7db7f894dcbwdtusr1'){
	        		system.assert(lstQryUsers[i].Country == countryNameUS);
	        		system.assert(lstQryUsers[i].Region__c == regionNameNALA);
	        	}else if (lstQryUsers[i].FederationIdentifier == '2bce1504c61d4b7db7f894dcbwdtusr2'){
	        		system.assert(lstQryUsers[i].Country == countryNameINDIA);
	        		system.assert(lstQryUsers[i].Region__c == regionNameEMEAI);
	        		
	        	}
	        }
        Test.stopTest();
        //End: Assert the Values
        //-------------------------------------------------------------------------------
        
        
        //==============================================================================================
        //	UPDATE CASE : Activate
        //==============================================================================================
        
        //Update the user to make it active and change their email and username and country to an invalid value
        //-------------------------------------------------------------------------------
        string changedEmailSuffix = 'chngd';
        string invalidCountry = '';
        
        User self = [Select Id From User Where Id = :UserInfo.getUserId()];
        
        system.runAs(self){
	        //query the users again to update
	        lstQryUsers = [	Select Username, Email, EMPLOYEEGUID__c, FederationIdentifier, IsActive, HRActive__c, ProfileId, UserRoleId, Country, Region__c 
	        							From User 
	        							Where Id in :lstQryUsers];
	        for (integer i=0; i<lstQryUsers.size(); i++){
	        	lstQryUsers[i].IsActive = true;
	        	lstQryUsers[i].HRActive__c = true;
	        	lstQryUsers[i].Email = lstQryUsers[i].Email + changedEmailSuffix;
	        	lstQryUsers[i].Username = lstQryUsers[i].Username + changedEmailSuffix;
	        	lstQryUsers[i].CountryCode = invalidCountry;
	        }
	        update lstQryUsers;
	        //End: Update the user to make it active and change their email and username
	        //-------------------------------------------------------------------------------
	        
	        //Assert the values
	        //-------------------------------------------------------------------------------
	        lstQryUsers = [	Select Username, Email, EMPLOYEEGUID__c, FederationIdentifier, IsActive, HRActive__c, ProfileId, UserRoleId, Country, Region__c 
	        							From User 
	        							Where Id in :lstQryUsers];
	        							
			for (integer i=0; i<lstQryUsers.size(); i++){
	        	//Assert the inactive state, profileId, RoleId; username is unchanged, email is unchanged, Country is unchanged
	        	system.assert(lstQryUsers[i].isActive == true);
	        	system.assert(lstQryUsers[i].Username == lstQryUsers[i].Email);
	        	system.assert(lstQryUsers[i].Country == null);
	        	system.assert(lstQryUsers[i].Username.endsWith(instanceName));
	        	system.assert(lstQryUsers[i].Email.endsWith(instanceName));
	        	
	        	//Assert the country, it should be unchanged
	        	system.assert(lstQryUsers[i].Country == null);
	        	system.assert(lstQryUsers[i].Region__c == null);
	        }
        }
		//End: Assert the values
		//-------------------------------------------------------------------------------
        
        //End: UPDATE CASE : Activate
        //==============================================================================================
        
    }
    
    /*
		Testing of user create/update in prod scenario with GUID
	*/
    static testMethod void testWDSyncUserCreationInProd() {
        
        //create test data
        //-------------------------------------------------------------------------------
        createCustomSettingsData(prodInstanceName);
        setCountryListData();
        //-------------------------------------------------------------------------------
        //End: create test data
       
        
        //Create New Users
        //-------------------------------------------------------------------------------
        list<User> lstNewUsers = new list<User>();
        long lRandom, uniqueVal;
        string email;
        
        //create an user1
        lRandom = Math.roundToLong(Math.random() * 999);
        uniqueVal = System.currentTimeMillis();
        email = 'pf1' + lRandom + 'pl1' + uniqueVal + nvidiaDomain;
        User user1 = new User(
        					FirstName = 'pf1', 
        					LastName = 'pl1', 
        					Department = 'Worldwide Field Ops', 
        					Email = email, 
        					CountryCode = countryCodeUS, 
        					ALIAS= 'pf1pl1', 
        					CommunityNickname = email,
        					CompanyName = 'NVIDIA',
        					HRActive__c = true,
        					IsActive = true,
							EMPLOYEEGUID__c = '2bce1504c61d4b7db7f894dcbwdtusr3'
        					);
		//create an user2
        lRandom = Math.roundToLong(Math.random() * 999);
        uniqueVal = System.currentTimeMillis();
        email = 'pf2' + lRandom + 'pl2' + uniqueVal + nvidiaDomain;
        User user2 = new User(
        					FirstName = 'pl2', 
        					LastName = 'pf2', 
        					Department = 'Worldwide Field Ops', 
        					Email = email, 
        					CountryCode = countryCodeINDIA, 
        					ALIAS='pf2pl2', 
        					CommunityNickname = email,
        					CompanyName = 'NVIDIA',
        					HRActive__c = true,
        					IsActive = true,
							EMPLOYEEGUID__c = '2bce1504c61d4b7db7f894dcbwdtusr4'
        					);
        
        
        
        lstNewUsers.add(user1);
        lstNewUsers.add(user2);
        
        insert lstNewUsers;
        //-------------------------------------------------------------------------------
        
        
        //Assert the values
        //-------------------------------------------------------------------------------
        Test.startTest();
	        list<User> lstQryUsers = [	Select Username, Email, EMPLOYEEGUID__c, FederationIdentifier, IsActive, ProfileId, UserRoleId, Country 
	        							From User 
	        							Where Id in :lstNewUsers];
	        for (integer i=0; i<lstQryUsers.size(); i++){
	        	//Assert the inactive state, profileId, RoleId; username and email should end with nvidia.com for production instance
	        	system.assert(lstQryUsers[i].isActive == false);
	        	system.assert(lstQryUsers[i].ProfileId == profNVInternalCRMGeneric.Id);
	        	system.assert(lstQryUsers[i].UserRoleId == null);
	        	system.assert(lstQryUsers[i].Username == lstQryUsers[i].Email);
	        	system.assert(lstQryUsers[i].FederationIdentifier == lstQryUsers[i].EMPLOYEEGUID__c);
	        	system.assert(lstQryUsers[i].Username.endsWith(nvidiaDomain));
	        	system.assert(lstQryUsers[i].Email.endsWith(nvidiaDomain));
	        	
	        	//Assert the country
	        	if (lstQryUsers[i].FederationIdentifier == '2bce1504c61d4b7db7f894dcbwdtusr3'){
	        		system.assert(lstQryUsers[i].Country == countryNameUS);
	        	}else if (lstQryUsers[i].FederationIdentifier == '2bce1504c61d4b7db7f894dcbwdtusr4'){
	        		system.assert(lstQryUsers[i].Country == countryNameINDIA);
	        		
	        	}
	        }
        Test.stopTest();
        //End: Assert the Values
        //-------------------------------------------------------------------------------
        
       
        //==============================================================================================
        //	UPDATE CASE : Activate
        //==============================================================================================
        
        //Update the user to make it active and change their email and username and country to an invalid value
        //-------------------------------------------------------------------------------
        string changedEmailSuffix = 'chngd';
        string invalidCountry = '';
        
        User self = [Select Id From User Where Id = :UserInfo.getUserId()];
        
        system.runAs(self){
	        //query the users again to update
	        lstQryUsers = [	Select Username, Email, EMPLOYEEGUID__c, FederationIdentifier, IsActive, HRActive__c, ProfileId, UserRoleId, Country 
	        							From User 
	        							Where Id in :lstQryUsers];
	        for (integer i=0; i<lstQryUsers.size(); i++){
	        	lstQryUsers[i].IsActive = true;
	        	lstQryUsers[i].HRActive__c = true;
	        	lstQryUsers[i].Email = lstQryUsers[i].Email + changedEmailSuffix;
	        	lstQryUsers[i].Username = lstQryUsers[i].Username + changedEmailSuffix;
	        	lstQryUsers[i].CountryCode = invalidCountry;
	        }
	        update lstQryUsers;
	        //End: Update the user to make it active and change their email and username
	        //-------------------------------------------------------------------------------
	        
	        //Assert the values
	        //-------------------------------------------------------------------------------
	        lstQryUsers = [	Select Username, Email, EMPLOYEEGUID__c, FederationIdentifier, IsActive, HRActive__c, ProfileId, UserRoleId, Country 
	        							From User 
	        							Where Id in :lstQryUsers];
	        							
			for (integer i=0; i<lstQryUsers.size(); i++){
	        	//Assert the inactive state, profileId, RoleId; username is unchanged, email is changed, Country is unchanged
	        	system.assert(lstQryUsers[i].isActive == true);
	        	system.assert(lstQryUsers[i].Username == lstQryUsers[i].Email);
	        	system.assert(lstQryUsers[i].Country != invalidCountry);
	        	system.assert(lstQryUsers[i].Username.endsWith(nvidiaDomain));
	        	system.assert(lstQryUsers[i].Email.endsWith(nvidiaDomain));
	        	
	        	//Assert the country, it should be unchanged
	        	system.assert(lstQryUsers[i].Country == null);
	        	
	        }
	        //End: Assert the values
        }
		//-------------------------------------------------------------------------------
		
        
        //End: UPDATE CASE : Activate
        //==============================================================================================
        
    }
    
    
    /*
		Testing of user create/update in Prod scenario with GUID and disable users
	*/
    static testMethod void testWDSyncUserCreationInProdAndDisableUser() {
        
        //create test data
        //-------------------------------------------------------------------------------
        createCustomSettingsData(prodInstanceName);
        setCountryListData();
        //-------------------------------------------------------------------------------
        //End: create test data
       
        
        //Create New Users
        //-------------------------------------------------------------------------------
        list<User> lstNewUsers = new list<User>();
        long lRandom, uniqueVal;
        string email;
        
        //create an user1
        lRandom = Math.roundToLong(Math.random() * 999);
        uniqueVal = System.currentTimeMillis();
        email = 'pf3' + lRandom + 'pl3' + uniqueVal + nvidiaDomain;
        User user1 = new User(
        					FirstName = 'pf3', 
        					LastName = 'pl3', 
        					Department = 'Worldwide Field Ops', 
        					Email = email, 
        					CountryCode = countryCodeUS , 
        					ALIAS= 'pf3pl3', 
        					CommunityNickname = email,
        					CompanyName = 'NVIDIA',
        					HRActive__c = true,
        					IsActive = true,
        					EMPLOYEEGUID__c = '2bce1504c61d4b7db7f894dcbwdtusr5'
        					);
		//create an user2
        lRandom = Math.roundToLong(Math.random() * 999);
        uniqueVal = System.currentTimeMillis();
        email = 'pf4' + lRandom + 'pl4' + uniqueVal + nvidiaDomain;
        User user2 = new User(
        					FirstName = 'pl4', 
        					LastName = 'pf4', 
        					Department = 'Worldwide Field Ops', 
        					Email = email, 
        					CountryCode = countryCodeINDIA, 
        					ALIAS='pf4pl4', 
        					CommunityNickname = email,
        					CompanyName = 'NVIDIA',
        					HRActive__c = true,
        					IsActive = true,
        					EMPLOYEEGUID__c = '2bce1504c61d4b7db7f894dcbwdtusr6'
        					);
        
        
        
        lstNewUsers.add(user1);
        lstNewUsers.add(user2);
        
        insert lstNewUsers;
        //-------------------------------------------------------------------------------
        
        
        //Assert the values
        //-------------------------------------------------------------------------------
        Test.startTest();
	        list<User> lstQryUsers = [	Select Username, Email, EMPLOYEEGUID__c, FederationIdentifier, IsActive, ProfileId, UserRoleId, Country 
	        							From User 
	        							Where Id in :lstNewUsers];
	        for (integer i=0; i<lstQryUsers.size(); i++){
	        	//Assert the inactive state, profileId, RoleId; username and email should end with nvidia.com for production instance
	        	system.assert(lstQryUsers[i].isActive == false);
	        	system.assert(lstQryUsers[i].ProfileId == profNVInternalCRMGeneric.Id);
	        	system.assert(lstQryUsers[i].UserRoleId == null);
	        	system.assert(lstQryUsers[i].Username == lstQryUsers[i].Email);
	        	system.assert(lstQryUsers[i].FederationIdentifier == lstQryUsers[i].EMPLOYEEGUID__c);
	        	system.assert(lstQryUsers[i].Username.endsWith(nvidiaDomain));
	        	system.assert(lstQryUsers[i].Email.endsWith(nvidiaDomain));
	        	
	        	//Assert the country
	        	if (lstQryUsers[i].FederationIdentifier == '2bce1504c61d4b7db7f894dcbwdtusr5'){
	        		system.assert(lstQryUsers[i].Country == countryNameUS);
	        	}else if (lstQryUsers[i].FederationIdentifier == '2bce1504c61d4b7db7f894dcbwdtusr6'){
	        		system.assert(lstQryUsers[i].Country == countryNameINDIA);
	        		
	        	}
	        }
        Test.stopTest();
        //End: Assert the Values
        //-------------------------------------------------------------------------------
        
        //==============================================================================================
        //	UPDATE CASE : Activate
        //==============================================================================================
        
        //Update the user to make it active and change their email and username and country to an invalid value
        //-------------------------------------------------------------------------------
        string changedEmailSuffix = 'chngd';
        string invalidCountry = '';
        User userQry1, userQry2;
        User self = [Select Id From User Where Id = :UserInfo.getUserId()];
        
        system.runAs(self){
	        //query the users again to update
	        lstQryUsers = [	Select Username, Email, EMPLOYEEGUID__c, FederationIdentifier, IsActive, HRActive__c, ProfileId, UserRoleId, Country 
	        							From User 
	        							Where Id in :lstQryUsers];
	        for (integer i=0; i<lstQryUsers.size(); i++){
	        	if (lstQryUsers[i].FederationIdentifier == '2bce1504c61d4b7db7f894dcbwdtusr5'){
	        		userQry1 = lstQryUsers[i];
	        	} else if (lstQryUsers[i].FederationIdentifier == '2bce1504c61d4b7db7f894dcbwdtusr6'){
	        		userQry2 = lstQryUsers[i];
	        	}
	        }
	        
	        //activate the user1 (active; email, username = changed; country = CHN) 
	        userQry1.IsActive = true;
	        userQry1.HRActive__c = true;
	        userQry1.Email = userQry1.Email + changedEmailSuffix;
	        userQry1.Username = userQry1.Username + changedEmailSuffix;
	        userQry1.CountryCode = countryCodeCHINA;
	        
	        //deactivate  the user2 with HRActive=false (inactive; email, username = changed; country = invalid) 
	        userQry2.IsActive = true;
	        userQry2.HRActive__c = false;
	        userQry2.Email = userQry1.Email + changedEmailSuffix;
	        userQry2.Username = userQry1.Username + changedEmailSuffix;
	        userQry2.CountryCode = invalidCountry;
	        
	        update lstQryUsers;
	        //End: Update the user to make it active and change their email and username
	        //-------------------------------------------------------------------------------
	        
	        //Assert the values
	        //-------------------------------------------------------------------------------
	        lstQryUsers = [	Select Username, Email, EMPLOYEEGUID__c, FederationIdentifier, IsActive, HRActive__c, ProfileId, UserRoleId, Country 
	        							From User 
	        							Where Id in :lstQryUsers];
	        							
			for (integer i=0; i<lstQryUsers.size(); i++){
	        	system.assert(lstQryUsers[i].Username.endsWith(nvidiaDomain));
	        	system.assert(lstQryUsers[i].Email.endsWith(nvidiaDomain));
	        	
	        	//Assert the country
	        	if (lstQryUsers[i].FederationIdentifier == '2bce1504c61d4b7db7f894dcbwdtusr5'){
	        		system.assert(lstQryUsers[i].Country == countryNameCHINA);
	        		system.assert(lstQryUsers[i].IsActive == true);
	        	}else if (lstQryUsers[i].FederationIdentifier == '2bce1504c61d4b7db7f894dcbwdtusr6'){
	        		system.assert(lstQryUsers[i].Country == null);
	        		system.assert(lstQryUsers[i].IsActive == false);
	        	}
	        }
        }
		//End: Assert the values
		//-------------------------------------------------------------------------------
        
        //End: UPDATE CASE : Activate
        //==============================================================================================
        
    }
    
    
    /*
		Testing of user create/update in prod with no GUID
	*/
    static testMethod void testWDSyncUserCreationInProdNoGUID() {
        
        //create test data
        //-------------------------------------------------------------------------------
        createCustomSettingsData(prodInstanceName);
        setCountryListData();
        //-------------------------------------------------------------------------------
        //End: create test data
       
        
        //Create New Users
        //-------------------------------------------------------------------------------
        list<User> lstNewUsers = new list<User>();
        long lRandom, uniqueVal;
        string email;
        
        //create an user1
        lRandom = Math.roundToLong(Math.random() * 999);
        uniqueVal = System.currentTimeMillis();
        email = 'n5' + lRandom + 'l5' + uniqueVal + nvidiaDomain;
        User user1 = new User(
        					FirstName = 'n5', 
        					LastName = 'l5', 
        					Department = 'Worldwide Field Ops', 
        					Email = email,
        					Username = email,
        					CountryCode = countryCodeUS , 
        					ALIAS= 'png5', 
        					CommunityNickname = email,
        					CompanyName = 'NVIDIA',
        					HRActive__c = false,
        					IsActive = true,
        					ProfileId = profNVInternalCRMGeneric.Id,
        					EmailEncodingKey  = COMM_Constants.USER_EMAILENCODEKEY,
							LanguageLocaleKey = COMM_Constants.USER_LANGLOCALEKEY,
							LocaleSidKey = COMM_Constants.USER_LOCALESIDKEY,
							TimeZoneSidKey = COMM_Constants.USER_TZSIDKEY
        					);
		//create an user2
        lRandom = Math.roundToLong(Math.random() * 999);
        uniqueVal = System.currentTimeMillis();
        email = 'n6' + lRandom + 'l6' + uniqueVal + nvidiaDomain;
        User user2 = new User(
        					FirstName = 'n6', 
        					LastName = 'l6', 
        					Department = 'Worldwide Field Ops', 
        					Email = email,
        					Username = email,
        					CountryCode = countryCodeINDIA, 
        					ALIAS='png6', 
        					CommunityNickname = email,
        					CompanyName = 'NVIDIA',
        					HRActive__c = false,
        					IsActive = false,
        					ProfileId = profNVInternalCRMGeneric.Id,
        					EmailEncodingKey  = COMM_Constants.USER_EMAILENCODEKEY,
							LanguageLocaleKey = COMM_Constants.USER_LANGLOCALEKEY,
							LocaleSidKey = COMM_Constants.USER_LOCALESIDKEY,
							TimeZoneSidKey = COMM_Constants.USER_TZSIDKEY
        					);
        
        lstNewUsers.add(user1);
        lstNewUsers.add(user2);
        
        insert lstNewUsers;
        //-------------------------------------------------------------------------------
        
        
        //Assert the values
        //-------------------------------------------------------------------------------
        Test.startTest();
	        list<User> lstQryUsers = [	Select Username, Email, EMPLOYEEGUID__c, FederationIdentifier, IsActive, ProfileId, UserRoleId, Country 
	        							From User 
	        							Where Id in :lstNewUsers];
	        for (integer i=0; i<lstQryUsers.size(); i++){
	        	
	        	if (lstQryUsers[i].Id == user1.Id){
	        		system.assert(user1.IsActive == true);
	        	}else if (lstQryUsers[i].Id == user2.Id){
	        		system.assert(user2.IsActive == false);
	        	}
	        }
        Test.stopTest();
        //End: Assert the Values
        //-------------------------------------------------------------------------------

    }
    
    /*
    	create Profile and build the custom settings data
    */
    static void createCustomSettingsData(string strSFDCInstanceName){
    	//get the profile Id
    	profNVInternalCRMGeneric = [Select Name From Profile Where Name = :COMM_Constants.PROF_INT_NVINTERNALCRMGENERIC];
    	setWorkdayUserSyncSettings(strSFDCInstanceName);
    	
    }
    
    /*
    	creates WorkdayUserSync_Settings__c custom settings data
    */
    static void setWorkdayUserSyncSettings(string strSFDCInstanceName){
    	WorkdayUserSync_Settings__c csWDUserSettings = new WorkdayUserSync_Settings__c();
		csWDUserSettings.Name = 'WorkdayUserSync Settings';
		csWDUserSettings.Email_Encoding_Key__c = 'ISO-8859-1';
		csWDUserSettings.Generic_Profile_Id__c = profNVInternalCRMGeneric.Id;
		csWDUserSettings.Generic_Profile_Name__c = profNVInternalCRMGeneric.Name;
		csWDUserSettings.Generic_Role_Id__c = '';
		csWDUserSettings.Integration_Users__c = UserInfo.getUserName();
		csWDUserSettings.Language_Locale_Key__c = 'en_US';
		csWDUserSettings.Locale_Sid_Key__c = 'en_US';
		csWDUserSettings.Sandbox_Instance_Name__c = strSFDCInstanceName;
		csWDUserSettings.Time_Zone_Sid_Key__c = 'America/Los_Angeles';
		
		if (Test.isRunningTest()){
			insert csWDUserSettings;
		}
    }
    
    /*
    	creates Country_List__c records
    */
    static void setCountryListData(){
    	if (Test.isRunningTest()){
    		list<Country_List__c> lstCountryList = [Select Name, ISO_Code__c, ISO_Code_3__c, Region__c, Sub_Region__c, Territory__c From Country_List__c limit 2000];
    		delete lstCountryList;
    		
    		//build the test data
    		Country_List__c countryUSA = new Country_List__c(Name = countryNameUS, ISO_Code__c = countryCodeUS, Region__c = regionNameNALA, Sub_Region__c = '', Territory__c = 'NA');
    		Country_List__c countryIND = new Country_List__c(Name = countryNameINDIA, ISO_Code__c = countryCodeINDIA, Region__c = regionNameEMEAI, Sub_Region__c = '', Territory__c = 'SOUTH ASIA');
    		Country_List__c countryCHN = new Country_List__c(Name = countryNameCHINA, ISO_Code__c = countryCodeCHINA, Region__c = regionNameAPAC);
    		
    		lstCountryList = new list<Country_List__c>();
    		lstCountryList.add(countryUSA);
    		lstCountryList.add(countryIND);
    		lstCountryList.add(countryCHN);
    		
    		insert lstCountryList;
    	}
    }
    
    
}