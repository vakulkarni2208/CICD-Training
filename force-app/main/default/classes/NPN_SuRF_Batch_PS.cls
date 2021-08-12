global class NPN_SuRF_Batch_PS implements Database.batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Account_ID__c
                                         ,Partner_Program__c
                                         ,Submission_Date__c
                                         ,Partner_SubProgram__c 
                                         FROM SuRF_POS_Submission__c
                                         WHERE isDeleted = false]);
    }
    global void execute(Database.BatchableContext BC, List<SuRF_POS_Submission__c> scope) {
        List<SuRF_POS_Submission_Trans__c> lst = new List<SuRF_POS_Submission_Trans__c>();
        for(SuRF_POS_Submission__c obj : scope) {
            SuRF_POS_Submission_Trans__c transObj = new SuRF_POS_Submission_Trans__c();
            transObj.Account_ID__c = obj.Account_ID__c;
            transObj.Partner_Program__c = obj.Partner_Program__c;
            transObj.Submission_Date__c = obj.Submission_Date__c;
            transObj.Partner_SubProgram__c = obj.Partner_SubProgram__c;
            lst.add(transObj);
        }
        insert lst;
    }
    global void finish(Database.BatchableContext BC) {
    }
}