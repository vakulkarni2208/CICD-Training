global class NPN_SuRF_Batch_O implements Database.batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Account_ID__c
                                         ,Amount__c
                                         ,Competency__c
                                         ,Level__c
                                         ,Opportunity_Name__c
                                         ,Partner_Program__c
                                         ,POS_Amount__c
                                         ,POS_Unit_Price__c
                                         ,Probability__c
                                         ,Product__c
                                         ,Quantity__c
                                         ,Stage__c
                                         ,Target__c
                                         ,Unit_Price__c
                                         FROM SuRF_Opportunity__c
                                         WHERE isDeleted = false]);
    }
    global void execute(Database.BatchableContext BC, List<SuRF_Opportunity__c> scope) {
        List<SuRF_Opportunity_Trans__c> lst = new List<SuRF_Opportunity_Trans__c>();
        for(SuRF_Opportunity__c obj : scope) {
            SuRF_Opportunity_Trans__c transObj = new SuRF_Opportunity_Trans__c();
            transObj.Account_ID__c = obj.Account_ID__c;
            transObj.Amount__c = obj.Amount__c;
            transObj.Competency__c = obj.Competency__c;
            transObj.Level__c = obj.Level__c;
            transObj.Opportunity_Name__c = obj.Opportunity_Name__c;
            transObj.Partner_Program__c = obj.Partner_Program__c;
            transObj.POS_Amount__c = obj.POS_Amount__c;
            transObj.POS_Unit_Price__c = obj.POS_Unit_Price__c;
            transObj.Probability__c = obj.Probability__c;
            transObj.Product__c = obj.Product__c;
            transObj.Quantity__c = obj.Quantity__c;
            transObj.Stage__c = obj.Stage__c;
            transObj.Target__c = obj.Target__c;
            transObj.Unit_Price__c = obj.Unit_Price__c;
            lst.add(transObj);
        }
        insert lst;
    }
    global void finish(Database.BatchableContext BC) {
    }
}