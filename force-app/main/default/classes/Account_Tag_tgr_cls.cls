/*
	Trigger Class for trigger Account_Tag_tgr 
	
	Functionality:
	2017.04.17 - After insert, after update, after delete events - set Account field "Account_Tags__c"
	
*/

public with sharing class Account_Tag_tgr_cls {
    
    //2017.04.17 - After insert, after update, after delete events - set Account field "Account_Tags__c"
    public static void setAccountTags(list<Account_Tag__c> lstAT){
    	system.debug('***Enters Account_Tag_tgr_cls.setAccountTags() method');
		set<Id> setAccountIdsInAT = new set<Id>();
		for (Account_Tag__c oAT : lstAT){
			if(oAT.AccountID__c != null){
				setAccountIdsInAT.add(oAT.AccountID__c);
			}
		}
		
		if(!setAccountIdsInAT.isEmpty() && setAccountIdsInAT.size() > 0){
			system.debug('***Begin Call setAccountTagsOnAccountRec helper method');
			setAccountTagsOnAccountRec(setAccountIdsInAT);
			system.debug('***End Call setAccountTagsOnAccountRec helper method');
		}
		system.debug('***Exits Account_Tag_tgr_cls.setAccountTags() method');
	}
	
	
	//helper class called from setAccountTags method
	private static void setAccountTagsOnAccountRec(set<Id> setAccIds){
		system.debug('***Enters Account_Tag_tgr_cls.setAccountTags() > setAccountTagsOnAccountRec helper method');
		//fetch all the account tag records related to the accounts
		list<Account> lstAccount = [Select AccountTags__c, 
										(	Select Id,  AccountID__c, Tag__c 
											From Account_Tags__r ) 
									From Account
									Where Id = :setAccIds];
		list<Account> lstAccWithUpdatedInfo = new list<Account>();
		for (Account acc : lstAccount){
			list<Account_Tag__c> lstAT = acc.Account_Tags__r;
			if (lstAT != null && !lstAT.isEmpty()){
				string strAccountTags = '';
				set<string> setAccountTags = new set<string>(); //used for duplicate prevention
				integer numAccountTags = lstAT.size();
				for (integer i = 0; i < numAccountTags; i++){
					if (string.isNotBlank(lstAT[i].Tag__c) && setAccountTags.add(lstAT[i].Tag__c)) {
						if (i != numAccountTags - 1){
							strAccountTags = strAccountTags + lstAT[i].Tag__c + ';';
						}else{
							strAccountTags = strAccountTags + lstAT[i].Tag__c;
						}
					}
				}
				//if there is no change of Account Tags, then do not update the Account again
				if (acc.AccountTags__c != strAccountTags) {
					lstAccWithUpdatedInfo.add(new Account(Id = acc.Id, AccountTags__c = strAccountTags));
				}		 
			} else{
				lstAccWithUpdatedInfo.add(new Account(Id = acc.Id, AccountTags__c = null));
			}
		}
		
		//update the Accounts with AccountTags__c
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
		
		system.debug('***Exits Account_Tag_tgr_cls.setAccountTags() > setAccountTagsOnAccountRec helper method');
	}
    
}