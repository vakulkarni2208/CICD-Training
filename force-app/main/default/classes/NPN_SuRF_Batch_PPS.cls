global class NPN_SuRF_Batch_PPS implements Database.batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Account_ID__c
                                         ,Account_Name__c
                                         ,Category__c
                                         ,Competency__c
                                         ,Competency_Signed_Date__c
                                         ,Flag__c
                                         ,Level__c
                                         ,Order__c
                                         ,Partner_Program__c
                                         ,PBM__c
                                         ,Program_Signed_Date__c
                                         ,Region__c
                                         ,Partner_SubProgram__c
                                          FROM SuRF_Partner_Performance_Scorecard__c
                                         WHERE isDeleted = false]);
    }
    global void execute(Database.BatchableContext BC, List<SuRF_Partner_Performance_Scorecard__c> scope) {
        List<SuRF_Partner_Performance_Scorecard_Trans__c> lst = new List<SuRF_Partner_Performance_Scorecard_Trans__c>();
        for(SuRF_Partner_Performance_Scorecard__c obj : scope) {
            SuRF_Partner_Performance_Scorecard_Trans__c transObj = new SuRF_Partner_Performance_Scorecard_Trans__c();
            transObj.Account_ID__c = obj.Account_ID__c;
            transObj.Account_Name__c = obj.Account_Name__c;
            transObj.Category__c = obj.Category__c;
            transObj.Competency__c = obj.Competency__c;
            transObj.Competency_Signed_Date__c = obj.Competency_Signed_Date__c;
            transObj.Flag__c = obj.Flag__c;
            transObj.Level__c = obj.Level__c;
            transObj.Order__c = obj.Order__c;
            transObj.Partner_Program__c = obj.Partner_Program__c;
            transObj.PBM__c = obj.PBM__c;
            transObj.Program_Signed_Date__c = obj.Program_Signed_Date__c;
            transObj.Region__c = obj.Region__c;
            transObj.Partner_SubProgram__c = obj.Partner_SubProgram__c;
            lst.add(transObj);
        }
        insert lst;
    }
    global void finish(Database.BatchableContext BC) {
    }
}