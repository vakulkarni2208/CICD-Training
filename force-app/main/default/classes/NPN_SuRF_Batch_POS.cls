global class NPN_SuRF_Batch_POS implements Database.batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Account_ID__c
                                         ,Competency__c
                                         ,Fiscal_Year_Quarter__c
                                         ,Partner_POS_Revenue__c
                                         ,Partner_Program__c
                                         ,Partner_Unit_Price__c
                                         ,POS_Quantity__c
                                         ,POS_Revenue__c
                                         ,Product_Code__c
                                         ,Target__c
                                         ,Target_Achieved__c
                                         ,Unit_Price__c
                                         ,Partner_SubProgram__c
                                          FROM SuRF_POS__c
                                         WHERE isDeleted = false]);
    }
    global void execute(Database.BatchableContext BC, List<SuRF_POS__c> scope) {
        List<SuRF_POS_Trans__c> lst = new List<SuRF_POS_Trans__c>();
        for(SuRF_POS__c obj : scope) {
            SuRF_POS_Trans__c transObj = new SuRF_POS_Trans__c();
            transObj.Account_ID__c = obj.Account_ID__c;
            transObj.Competency__c = obj.Competency__c;
            transObj.Fiscal_Year_Quarter__c = obj.Fiscal_Year_Quarter__c;
            transObj.Partner_POS_Revenue__c = obj.Partner_POS_Revenue__c;
            transObj.Partner_Program__c = obj.Partner_Program__c;
            transObj.Partner_Unit_Price__c = obj.Partner_Unit_Price__c;
            transObj.POS_Quantity__c = obj.POS_Quantity__c;
            transObj.POS_Revenue__c = obj.POS_Revenue__c;
            transObj.Product_Code__c = obj.Product_Code__c;
            transObj.Target__c = obj.Target__c;
            transObj.Target_Achieved__c = obj.Target_Achieved__c;
            transObj.Unit_Price__c = obj.Unit_Price__c;
            transObj.Partner_SubProgram__c = obj.Partner_SubProgram__c;
            lst.add(transObj);
        }
        insert lst;
    }
    global void finish(Database.BatchableContext BC) {
    }
}