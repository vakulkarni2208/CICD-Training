/*
	Trigger Class for trigger Partner_Attribute_tgr 
	
	Functionality:
	- After Insert, After Update : Insert NPN Revenue Target record if there is none for the current FY
	
	2016.09.24 - After insert, after update, after delete events - set Account field "NPN Active Program - Competency"
	
	2017.11.08 - Level Change Date - update existing NPN Revenue Target for Current Fiscal Year
	
	2021.01.31 	Rajat	SDS-2724 Added Sub Program in the logic.
*/

public class Partner_Attribute_tgr_cls {

	//after insert, update of Parter Attribute record; if there is no NPN Revenue Target for the current Year, add one.
	public static void createNPNRevenueTarget(list<Partner_Attribute__c> newPAsInTgr){
		
		//get the current fiscal year
		Date currentDate = System.Today();
		string strCurrentFY = CRM_NPN_Revenue_Target_Common.getFiscalYear(currentDate);
			
		//find out Parter Attributes for which there is no NPN Revenue Target records for the current Fiscal Year
		list<Partner_Attribute__c> lstPAWithNoRevenueTrgt = [	Select Id, Partner_Program_Name__c, Partner_Sub_Program__c, Partner_Competency__c, Program_Level__c, Account_Name__r.BillingCountry 
																From Partner_Attribute__c 
																Where Id = :newPAsInTgr
																	And Id Not in (Select Partner_Attribute__c From NPN_Revenue_Targets__c Where  Year__c = :strCurrentFY And Partner_Attribute__c = :newPAsInTgr)];
		
		if (lstPAWithNoRevenueTrgt != null && !lstPAWithNoRevenueTrgt.isEmpty()){
			
			//List for holding extened Partner Attribute fields including Account Billing Country
			list<CRM_NPN_Revenue_Target_Common.PartnerAttributeExt> lstPartnerAttributeExt = new list<CRM_NPN_Revenue_Target_Common.PartnerAttributeExt>();
			
			for (Partner_Attribute__c pa : lstPAWithNoRevenueTrgt){
				// Added Sub_Program__c for SDS-2724
				lstPartnerAttributeExt.add(new CRM_NPN_Revenue_Target_Common.PartnerAttributeExt(pa.Id, pa.Partner_Program_Name__c, pa.Partner_Sub_Program__c, pa.Partner_Competency__c, pa.Program_Level__c, pa.Account_Name__r.BillingCountry));
			}
			
			//Calll the createRevenueTargets with the list of Partner Attributes having no Revenue Targets
			system.debug('***Calls CRM_NPN_Revenue_Target_Common.createRevenueTargets() with lstPartnerAttributeExt = ' + lstPartnerAttributeExt + ' Fiscal Year = ' + strCurrentFY);
			CRM_NPN_Revenue_Target_Common.createRevenueTargets(lstPartnerAttributeExt, strCurrentFY);
		}
		
	}
	
	//2017.11.08 - Level Change Date - update existing NPN Revenue Target for Current Fiscal Year
	public static void updateExistingNPNRevenueTargetOnLevelChange(map<id, Partner_Attribute__c> oldMapPA, map<id, Partner_Attribute__c> newMapPA){
		//list<Id> lstPAIdsWithLevelChanged = new list<Id>();
		list<Partner_Attribute__c> lstPAWithLevelChanged = new list<Partner_Attribute__c>();
		for(Id id : newMapPA.keySet()){
			if (newMapPA.get(id).Program_Level__c != oldMapPA.get(Id).Program_Level__c){
				//lstPAIdsWithLevelChanged.add(pa.Id);
				lstPAWithLevelChanged.add(newMapPA.get(id));
			}
		}
		
		system.debug('***lstPAWithLevelChanged: ' + lstPAWithLevelChanged);
		
		if (!lstPAWithLevelChanged.isEmpty()){
			//get the current fiscal year
			Date currentDate = System.Today();
			string strCurrentFY = CRM_NPN_Revenue_Target_Common.getFiscalYear(currentDate);
			
			//delete the current FY's NPN Revenue Targets
			list<NPN_Revenue_Targets__c> lstNPNRevTrgtsForCurrFY = [Select Id From NPN_Revenue_Targets__c Where  Year__c = :strCurrentFY And Partner_Attribute__c = :lstPAWithLevelChanged];
			system.debug('***lstNPNRevTrgtsForCurrFY: ' + lstNPNRevTrgtsForCurrFY);
			
			system.debug('***Begin: deletes the NPN Revenue Targets: ' + lstNPNRevTrgtsForCurrFY);
			database.delete(lstNPNRevTrgtsForCurrFY);
			system.debug('***End: deletes the NPN Revenue Targets');
			
			//add the current FY's NPN Revenue Targets
			system.debug('***Begin: createNPNRevenueTarget for PAs: ' + lstPAWithLevelChanged);
			createNPNRevenueTarget(lstPAWithLevelChanged);
			system.debug('***Begin: createNPNRevenueTarget');
			
		}
		
	}
	
	//2016.09.24 - After insert, after update, after delete events - set Account field "NPN Active Program - Competency"
	public static void setAccountNPNActiveProgramCompetency(list<Partner_Attribute__c> lstPA){
		set<Id> setAccountIdsInPA = new set<Id>();
		for (Partner_Attribute__c pa : lstPA){
			if(pa.Account_Name__c != null){
				setAccountIdsInPA.add(pa.Account_Name__c);
			}
		}
		
		if(!setAccountIdsInPA.isEmpty() && setAccountIdsInPA.size() > 0){
			setAccountNPNActiveProgramCompetency(setAccountIdsInPA);
		}
	}
	

	private static void setAccountNPNActiveProgramCompetency(set<Id> setAccIds){
		//fetch all the partner attribute records related tot he accounts
		list<Account> lstAccount = [Select NPN_Active_Program_Competency__c, 
										(	Select Id,  Partner_Program_Name__c, Partner_Competency__c, Program_Level__c 
											From Account_Attributes__r Where Date_Competency_Terminated__c = null) 
									From Account
									Where Id = :setAccIds];
		
		list<Account> lstAccWithUpdatedInfo = new list<Account>();
		for (Account acc : lstAccount){
			list<Partner_Attribute__c> lstPA = acc.Account_Attributes__r;
			if (lstPA != null && !lstPA.isEmpty()){
				set<string> setNPNProgramInfo = new set<string>();
				string strAllNPNProgramInfo = ''; 
				for (Partner_Attribute__c pa : lstPA){
					setNPNProgramInfo.add(pa.Partner_Program_Name__c + ':' + pa.Partner_Competency__c + ':' + pa.Program_Level__c);
				}
				if (!setNPNProgramInfo.isEmpty()){
					//convert from set to list
					list<string> lstNPNProgramInfo = new list<string>();
					lstNPNProgramInfo.addAll(setNPNProgramInfo);
					
					//collect all unique comibnation of Program Name, Competency, Level from List to string separated by '::'
					for (string strNPNProgramInfo : lstNPNProgramInfo){
						if (strAllNPNProgramInfo != '')  strAllNPNProgramInfo += '::';
						strAllNPNProgramInfo += strNPNProgramInfo;
					}
				}
				lstAccWithUpdatedInfo.add(new Account(Id = acc.Id, NPN_Active_Program_Competency__c = strAllNPNProgramInfo));		 
			} else{
				lstAccWithUpdatedInfo.add(new Account(Id = acc.Id, NPN_Active_Program_Competency__c = ''));
			}
			
		}
		
		//update the Accounts with NPN_Active_Program_Competency__c
		if (!lstAccWithUpdatedInfo.isEmpty()){
			Database.saveResult[] lstDSR = database.update(lstAccWithUpdatedInfo, false);
			//Debugging of failure and successes
			for (integer i = 0; i < lstAccWithUpdatedInfo.size(); i++){
				Database.SaveResult dsr = lstDSR[i];
				Account acc = lstAccWithUpdatedInfo[i];
					
				if (!dsr.isSuccess()){
					system.debug('***Failed Update: Account Record Id : ' + acc.Id);
					System.debug('***Error Message:' + dsr.getErrors()[0].getStatusCode() + ': ' + dsr.getErrors()[0].getMessage());
				} else{
					system.debug('***Sucessful Update: Account Record Id : ' + acc.Id);
				}
			}
		}

	}
}