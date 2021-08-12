/*
	Test class for Partner Attribute trigger class Partner_Attribute_tgr_cls.cls
	
	2016.09.24 - After insert, after update, after delete events - set Account field "NPN Active Program - Competency"
	
	2017.11.08 - Level Change Date - update existing NPN Revenue Target for Current Fiscal Year
 */
 
@isTest(SeeAllData=false)
private class Test_Partner_Attribute_tgr_cls {

    static testMethod void testCreateNPNRevenueTarget() {
		string BILLING_COUNTRY_US = 'United States'; 
		decimal THRESHOLD_COMMIT = 100;
		decimal THRESHOLD_COMMIT_PREF = 50;
		
		map<string, Id> mapRTNameId = new map<string, Id>();
		list<RecordType> lstRecTypes = [Select Name From RecordType Where SobjectType = 'Account' And Name = :COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY];
		for (RecordType rt : lstRecTypes){
			mapRTNameId.put(rt.Name, rt.Id);
		}
		

        //Create a NPN Account Registry type of Account
        Account accNPNReg = new Account(name = 'NPNAccountRegistry1', RecordTypeId = mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY), BillingStreet = COMM_Constants.ADDRESS_STREET, BillingCity = COMM_Constants.ADDRESS_CITY, BillingState = COMM_Constants.ADDRESS_STATE, BillingCountry = BILLING_COUNTRY_US, BillingPostalCode = COMM_Constants.ADDRESS_ZIP, NPN_Program_Signed_Date__c = system.today() );
		insert accNPNReg;
		
		
		//Create Country_List__c
		list<Country_List__c> lstCountry = new list<Country_List__c>();
		Country_List__c countryUS = new Country_List__c(name = BILLING_COUNTRY_US, ISO_Code__c = 'US', Region__c = 'NALA', Sub_Region__c = 'LA', Territory__c = 'LA'); 
		lstCountry.add(countryUS);
		insert lstCountry;
		
		//Create NPN_Revenue_Commitment_Master__c
		list<NPN_Revenue_Commitment_Master__c> lstRevCommitMstr = new list<NPN_Revenue_Commitment_Master__c>();
		NPN_Revenue_Commitment_Master__c RevCommitMstr = new NPN_Revenue_Commitment_Master__c(Program__c = COMM_Constants.PA_PROGRAM_SP, Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_AC, Level__c = COMM_Constants.PA_LEVEL_ELITE, Country__c = lstCountry[0].Id, Threshold__c = THRESHOLD_COMMIT);
		NPN_Revenue_Commitment_Master__c RevCommitMstrPref = new NPN_Revenue_Commitment_Master__c(Program__c = COMM_Constants.PA_PROGRAM_SP, Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_AC, Level__c = COMM_Constants.PA_LEVEL_PREF, Country__c = lstCountry[0].Id, Threshold__c = THRESHOLD_COMMIT_PREF);
		lstRevCommitMstr.add(RevCommitMstr);
		lstRevCommitMstr.add(RevCommitMstrPref);
		insert lstRevCommitMstr;
		
		//Create a Partner Attribute record
		list<Partner_Attribute__c> lstPA = new list<Partner_Attribute__c>();
		//Select p.Program_Level__c, p.Partner_Program_Name__c, p.Partner_Competency__c, p.Account_Name__c From Partner_Attribute__c p
		Partner_Attribute__c pa1 = new Partner_Attribute__c(Account_Name__c = accNPNReg.Id, Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP, Partner_Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_AC, Program_Level__c = COMM_Constants.PA_LEVEL_ELITE );
		lstPA.add(pa1);
		insert lstPA;
		
		//Create custom settings data
		NPN_Revenue_Target_Automation_Settings__c csNPNSettings = new NPN_Revenue_Target_Automation_Settings__c();
		csNPNSettings.No_Match_No_Revenue_Target__c = true;
		insert csNPNSettings;
		
		test.startTest();
			list<NPN_Revenue_Targets__c> lstRevTargets = [Select Year__c, Minimum_Annual_Sales_Commitment__c From NPN_Revenue_Targets__c Where Partner_Attribute__c = :lstPA];
			system.debug('***lstRevTargets: ' + lstRevTargets);	
			system.assert(lstRevTargets[0].Year__c == CRM_NPN_Revenue_Target_Common.getFiscalYear(system.Today()));
			system.assert(lstRevTargets[0].Minimum_Annual_Sales_Commitment__c == THRESHOLD_COMMIT);
			
			//2016.09.24 - After insert, after update, after delete events - set Account field "NPN Active Program - Competency"
			Account  accNPNRegRet = [Select NPN_Active_Program_Competency__c From Account Where Id = :accNPNReg.Id];
			string accNPNRegCompetency = accNPNRegRet.NPN_Active_Program_Competency__c;
			boolean bProgramType_SP = false;
			if (accNPNRegCompetency != null){
				bProgramType_SP = accNPNRegCompetency.contains(COMM_Constants.PA_PROGRAM_SP);
			}
			system.assert(bProgramType_SP == true);
			
			//test update the level
			pa1.Program_Level__c = COMM_Constants.PA_LEVEL_PREF;
			update pa1;
			list<NPN_Revenue_Targets__c> lstRevTargetsRevised = [Select Year__c, Minimum_Annual_Sales_Commitment__c From NPN_Revenue_Targets__c Where Partner_Attribute__c = :pa1.Id];
			system.assert(lstRevTargetsRevised[0].Minimum_Annual_Sales_Commitment__c == THRESHOLD_COMMIT_PREF);
			
		test.stopTest();
    }

    //2016.09.24 - After insert, after update, after delete events - set Account field "NPN Active Program - Competency"
    static testMethod void testAccountNPNActiveProgramCompetency() {
		string BILLING_COUNTRY_US = 'United States'; 
		decimal THRESHOLD_COMMIT = 100;
		
		map<string, Id> mapRTNameId = new map<string, Id>();
		list<RecordType> lstRecTypes = [Select Name From RecordType Where SobjectType = 'Account' And Name = :COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY];
		for (RecordType rt : lstRecTypes){
			mapRTNameId.put(rt.Name, rt.Id);
		}
		

        //Create a NPN Account Registry type of Account
        Account accNPNReg = new Account(name = 'NPNAccountRegistry1', RecordTypeId = mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY), BillingStreet = COMM_Constants.ADDRESS_STREET, BillingCity = COMM_Constants.ADDRESS_CITY, BillingState = COMM_Constants.ADDRESS_STATE, BillingCountry = BILLING_COUNTRY_US, BillingPostalCode = COMM_Constants.ADDRESS_ZIP, NPN_Program_Signed_Date__c = system.today() );
		insert accNPNReg;
		
		
		//Create Country_List__c
		list<Country_List__c> lstCountry = new list<Country_List__c>();
		Country_List__c countryUS = new Country_List__c(name = BILLING_COUNTRY_US, ISO_Code__c = 'US', Region__c = 'NALA', Sub_Region__c = 'LA', Territory__c = 'LA'); 
		lstCountry.add(countryUS);
		insert lstCountry;
		
		//Create NPN_Revenue_Commitment_Master__c
		list<NPN_Revenue_Commitment_Master__c> lstRevCommitMstr = new list<NPN_Revenue_Commitment_Master__c>();
		NPN_Revenue_Commitment_Master__c RevCommitMstr = new NPN_Revenue_Commitment_Master__c(Program__c = COMM_Constants.PA_PROGRAM_SP, Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_AC, Level__c = COMM_Constants.PA_LEVEL_ELITE, Country__c = lstCountry[0].Id, Threshold__c = THRESHOLD_COMMIT);
		lstRevCommitMstr.add(RevCommitMstr);
		insert lstRevCommitMstr;
		
		//Create a Partner Attribute record
		list<Partner_Attribute__c> lstPA = new list<Partner_Attribute__c>();
		//Select p.Program_Level__c, p.Partner_Program_Name__c, p.Partner_Competency__c, p.Account_Name__c From Partner_Attribute__c p
		Partner_Attribute__c pa1 = new Partner_Attribute__c(Account_Name__c = accNPNReg.Id, Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP, Partner_Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_AC, Program_Level__c = COMM_Constants.PA_LEVEL_ELITE );
		lstPA.add(pa1);
		insert lstPA;
		
		//Create custom settings data
		NPN_Revenue_Target_Automation_Settings__c csNPNSettings = new NPN_Revenue_Target_Automation_Settings__c();
		csNPNSettings.No_Match_No_Revenue_Target__c = true;
		insert csNPNSettings;
		
		test.startTest();
			list<Partner_Attribute__c> lstPARet = [Select Id from Partner_Attribute__c Where Id = :pa1.Id];
			delete lstPARet;
			Account  accNPNRegRet = [Select NPN_Active_Program_Competency__c From Account Where Id = :accNPNReg.Id];
			string accNPNRegCompetency = accNPNRegRet.NPN_Active_Program_Competency__c;
			boolean bProgramType_SP = false;
			if (accNPNRegCompetency != null){
				bProgramType_SP = accNPNRegCompetency.contains(COMM_Constants.PA_PROGRAM_SP);
			}
			system.assert(bProgramType_SP == false);
		test.stopTest();
    }
}