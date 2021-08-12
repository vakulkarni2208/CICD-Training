//SuRF_DGX_HOT_Compliance
global class NPN_SuRF_Batch_DGX_HOT_Compliance implements Database.batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Account_Id__c,Account_Name__c,BillingCountry__c
                                                ,Billing_Sub_Region__c,Category__c,Competency__c
                                                ,Flag__c,Order__c,Partner_Program_Name__c,Partner_Sub_Program__c
                                                FROM SuRF_DGX_HOT_Compliance__c WHERE isDeleted = false]);
    }
    global void execute(Database.BatchableContext BC, List<SuRF_DGX_HOT_Compliance__c> scope) {
        List<SuRF_DGX_HOT_Compliance_Trans__c> lst = new List<SuRF_DGX_HOT_Compliance_Trans__c>();
        for(SuRF_DGX_HOT_Compliance__c obj : scope) { 
            SuRF_DGX_HOT_Compliance_Trans__c transObj = new SuRF_DGX_HOT_Compliance_Trans__c();
            transObj.Account_Id__c  =   obj.Account_Id__c;
            transObj.Account_Name__c    =   obj.Account_Name__c;
            transObj.BillingCountry__c  =   obj.BillingCountry__c;
            transObj.Billing_Sub_Region__c  =   obj.Billing_Sub_Region__c;
            transObj.Category__c    =   obj.Category__c;
            transObj.Competency__c  =   obj.Competency__c;
            transObj.Flag__c    =   obj.Flag__c;
            transObj.Order__c   =   obj.Order__c;
            transObj.Partner_Program_Name__c    =   obj.Partner_Program_Name__c;
            transObj.Partner_Sub_Program__c =   obj.Partner_Sub_Program__c;
            lst.add(transObj);
        }
        insert lst;
    }
    global void finish(Database.BatchableContext BC) {
    }
}