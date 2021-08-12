public with sharing class SAPOrder_tgr_cls extends NV_TriggerHandler  {
    public static boolean skipTriggerActions = false;
    
	//public list<SAP_Order__c> oldRecords;
    private static list<SAP_Order__c> newRecords;
    //private static map<Id, SAP_Order__c> oldRecordsMap;
    public override void init() { 
        OBJECT_NAME = 'SAP_Order__c';
        //oldRecords = trigger.old;
        newRecords = trigger.New;
        //if(oldRecords != null)
        //    oldRecordsMap = new map<Id, SAP_Order__c>(oldRecords);
        //System.debug('Old Records' + oldRecords + '1');
        System.debug('New Records' + trigger.New + '1'); 
    }
    
    //public override void beforeInsert() {
    //    SAPOrder_tgr_cls.updateEntitlementSyncFlag();
    //}
    
    public override void beforeUpdate() {
        SAPOrder_tgr_cls.updateEntitlementSyncFlag();
    }
    
    public static void updateEntitlementSyncFlag() {
    	for(SAP_Order__c sapOrder: newRecords) {
    		if(sapOrder.Synced_with_Entitlement__c)
    			sapOrder.Synced_with_Entitlement__c = false;
    	}
    }
}