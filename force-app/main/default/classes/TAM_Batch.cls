/*
 * Author: Manideep
 * CreatedDate: 2/17/2017
 * Description: This is a Batch class to update TAM's for all qualified Accounts by utilizing 'TAM_Utility_Class'.                 
*/

public class TAM_Batch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
  
  public final String Query;
  
  // Constructor
  public TAM_Batch() {
  	Query = runquery();
  }
  
  // method to form Dynamic SOQL query.
  public string runquery() {
  	// RecordType Id of Account Record Type 'New Customer Account'
    Id NewAccRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER).getRecordTypeId();
    String queryString;
    
  	queryString = 'Select Id, Name, RecordTypeId, OwnerId, Billing_Region__c, BillingCountry, BillingState, BillingCity, Industry from Account '
  	               + 'where Billing_Region__c != null and BillingCountry != null and RecordTypeId = \''+ NewAccRTId + '\'';
    system.debug('queryString---->'+queryString); 
      
  	return queryString;
  } 
  
   
  public Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(Query);	
  } 
  
  public void execute(Database.BatchableContext BC, List<Account> accScope) {
  	
  	List<Account> acctsAllFieldsList = new List<Account>();
  	List<Account> updateAccList = new List<Account>();
        
    Map<Id, Account_Tag__c> accountTagMap = new Map<Id, Account_Tag__c>();
    for(Account_Tag__c acctag: [Select Id, Name, AccountID__c, Tag__c from Account_Tag__c where Tag__c =:COMM_Constants.Account_TAG_1]) {
        accountTagMap.put(acctag.AccountID__c, acctag);
    }
    for(Account_Tag__c acctag: [Select Id, Name, AccountID__c, Tag__c from Account_Tag__c where Tag__c =:COMM_Constants.Account_TAG_2]) {
       	if(!accountTagMap.isEmpty() && accountTagMap.containsKey(acctag.AccountID__c))
       	   accountTagMap.remove(acctag.AccountID__c);
    }
        
    for(Account acc: accScope) {
        if(!accountTagMap.isEmpty() && accountTagMap.containsKey(acc.Id) && String.isNotBlank(String.valueOf(acc.Billing_Region__c))) {
           acctsAllFieldsList.add(acc); 
        }   
    }    
       
    // All Accounts
    if(!acctsAllFieldsList.isEmpty()) {
       List<TAMSObjectRecTemplate> listAllTSRT = new List<TAMSObjectRecTemplate>();
       for(Account acc: acctsAllFieldsList) {
           TAMSObjectRecTemplate TSRT = new TAMSObjectRecTemplate();
           TSRT.Id = acc.Id; 
           TSRT.Region = acc.Billing_Region__c;
           TSRT.Country = acc.BillingCountry;
           TSRT.State = acc.BillingState;
           TSRT.City = acc.BillingCity;
           TSRT.Industry = acc.Industry;
           listAllTSRT.add(TSRT);
       }
       system.debug('listTSRT-bulkBatch-1--->'+listAllTSRT);
       
       // invoke the TAM Service to find the appropriate TAM for each Account
       listAllTSRT = CRM_TAM_Utility.getTAMs(listAllTSRT);
       system.debug('listTSRT-bulkBatch-2--->'+listAllTSRT);
       
       for(Account acc: acctsAllFieldsList) {
           for(TAMSObjectRecTemplate tsrt: listAllTSRT) {
               if((String.valueOf(acc.Id).equalsIgnoreCase(String.valueOf(tsrt.Id))) && (String.isNotBlank(String.valueOf(tsrt.TAMId)))
                                         && (String.isBlank(tsrt.errMsg)) && (String.valueOf(acc.OwnerId) != String.valueOf(tsrt.TAMId))) { 
                   acc.OwnerId = tsrt.TAMId;                                                        
                   updateAccList.add(acc); 
               }            
           } 
       }
        
    } 
    
    // update All Acounts or Direct Accounts
    if(!updateAccList.isEmpty()) {
       update updateAccList;
    }      
               
  } // end of execute()
  
  public void finish(Database.BatchableContext BC) {}
  
  // execute method of Schedule class
  public void execute(SchedulableContext sc) {
  	 //invoke Batch class
     TAM_Batch tambatch = new TAM_Batch();
     Id batchinstanceid = database.executeBatch(tambatch);
  }
    
}