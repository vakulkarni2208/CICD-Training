global class NPN_SuRF_Batch_PL implements Database.batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Account_ID__c
                                         ,Competency__c
                                         ,Contact_Name__c
                                         ,Login_Time__c
                                         ,Month__c
                                         ,Year__c
                                         FROM SuRF_Portal_Login__c
                                         WHERE isDeleted = false]);
    }
    global void execute(Database.BatchableContext BC, List<SuRF_Portal_Login__c> scope) {
        List<SuRF_Portal_Login_Trans__c> lst = new List<SuRF_Portal_Login_Trans__c>();
        for(SuRF_Portal_Login__c obj : scope) {
            SuRF_Portal_Login_Trans__c transObj = new SuRF_Portal_Login_Trans__c();
            transObj.Account_ID__c = obj.Account_ID__c;
            transObj.Competency__c = obj.Competency__c;
            transObj.Contact_Name__c = obj.Contact_Name__c;
            transObj.Login_Time__c = obj.Login_Time__c;
            lst.add(transObj);
        }
        insert lst;
    }
    global void finish(Database.BatchableContext BC) {
    }
}