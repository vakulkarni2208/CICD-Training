global class NPN_SuRF_Batch_LM implements Database.batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Account_ID__c
                                         ,Lead_Status__c
                                         ,Region__c
                                         FROM SuRF_Lead_Management__c]);
    }
    global void execute(Database.BatchableContext BC, List<SuRF_Lead_Management__c> scope) {
        List<SuRF_Lead_Management_Trans__c> lst = new List<SuRF_Lead_Management_Trans__c>();
        for(SuRF_Lead_Management__c obj : scope) {
            SuRF_Lead_Management_Trans__c transObj = new SuRF_Lead_Management_Trans__c();
            transObj.Account_ID__c = obj.Account_ID__c;
            transObj.Lead_Status__c = obj.Lead_Status__c;
            transObj.Region__c = obj.Region__c;
            lst.add(transObj);
        }
        insert lst;
    }
    global void finish(Database.BatchableContext BC) {
    }
}