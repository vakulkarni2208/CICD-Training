public with sharing class ESP_SyncSAPOrderToEntitlement_BAT_SCH implements Schedulable{
	
	public integer BATCH_SIZE;
	public DateTime LookBackFromDt;
	/*
	private DateTime LookBackFromDt;
    private DateTime LookBackToDt;
    public ESP_SyncSAPOrderToEntitlement_BAT_SCH() {
    	system.debug('20191213 1.1');
        LookBackFromDt = DateTime.Now().addDays(-1);
        LookBackToDt   = DateTime.Now();
    }
    public ESP_SyncSAPOrderToEntitlement_BAT_SCH(DateTime fromDate, DateTime toDate) {
    	system.debug('20191213 1.3');
        LookBackToDt   = (toDate != null) ? toDate : DateTime.Now();
        LookBackFromDt = (fromDate != null) ? fromDate : LookBackToDt.addDays(-1);
    }*/
    
	public void execute(SchedulableContext SC) {
		ESP_SyncSAPOrderToEntitlement_BAT bat = new ESP_SyncSAPOrderToEntitlement_BAT();
		bat.LookBackFromDt = LookBackFromDt;
		system.debug('LookBackFromDt: '+ LookBackFromDt);
		Id batchJobId = Database.executeBatch(bat,BATCH_SIZE);
		
		///system.debug('LookBackFromDt: '+ LookBackFromDt + ' LookBackToDt: '+LookBackToDt);
		///Id batchJobId = Database.executeBatch(new ESP_SyncSAPOrderToEntitlement_BAT(LookBackFromDt, LookBackToDt));
		/*String Query = 'SELECT Name,SFDC_Account__c, Start_Date__c,End_Date__c,Product__r.Description,Quantity__c,Hardware_Serial_Number__c,SAP_PAK_ID__c,Product__c,Renewed_PAK_ID__c,SAP_Sales_Order_Number__c,ID, Sold_To_Partner_Lookup__c, Order_Type__c, (Select Id From Entitlements__r)'
		        			+ ' FROM SAP_Order__c'
		        			+ ' where Order_Type__c in  (\'ZOR\', \'ZSO\', \'ZDO\', \'ZMRS\' )'
		        			;
		Id batchJobId = Database.executeBatch(new ESP_SyncSAPOrderToEntitlement_BAT(Query),10);
		*/
		
		system.debug('batchJobId: '+ batchJobId);
		system.debug('Aborting the Job, Job ID: '+ sc.getTriggerId());
		system.abortJob(sc.getTriggerId());
	}
}