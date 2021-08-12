global class NPN_SuRF_Batch_C implements Database.batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Account_ID__c
                                         ,Contact_Name__c
                                         ,Email__c
                                         ,Phone_Number__c
                                         ,Role__c
                                         FROM SuRF_Contacts__c
                                         WHERE isDeleted = false]);
    }
    global void execute(Database.BatchableContext BC, List<SuRF_Contacts__c> scope) {
        List<SuRF_Contacts_Trans__c> lst = new List<SuRF_Contacts_Trans__c>();
        for(SuRF_Contacts__c obj : scope) {
            SuRF_Contacts_Trans__c transObj = new SuRF_Contacts_Trans__c();
            transObj.Account_ID__c = obj.Account_ID__c;
            transObj.Contact_Name__c = obj.Contact_Name__c;
            transObj.Email__c = obj.Email__c;
            transObj.Phone_Number__c = obj.Phone_Number__c;
            transObj.Role__c = obj.Role__c;
            lst.add(transObj);
        }
        insert lst;
    }
    global void finish(Database.BatchableContext BC) {
    }
}