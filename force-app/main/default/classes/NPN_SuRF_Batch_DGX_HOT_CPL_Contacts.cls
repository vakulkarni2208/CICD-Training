//SuRF_DGX_HOT_CPL_Contacts
global class NPN_SuRF_Batch_DGX_HOT_CPL_Contacts implements Database.batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Account_ID__c,Account_Name__c,Competency__c,Contact_Name__c
                                            ,Curriculum_Course_Title__c,Curriculum_Title__c,Due_Date__c,Email__c
                                            ,Partner_Program__c,Partner_SubProgram__c,Partner_Training_Compliance__c
                                            ,Partner_Training_Required__c,Phone_Number__c,ProductType__c,Role__c
                                            ,Training_Compliance_Status__c,Training_Record_Type__c,Type__c 
                                            FROM SuRF_DGX_HOT_CPL_Contacts__c WHERE isDeleted = false]);
    }
    global void execute(Database.BatchableContext BC, List<SuRF_DGX_HOT_CPL_Contacts__c > scope) {
        List<SuRF_DGX_HOT_CPL_Contacts_Trans__c> lst = new List<SuRF_DGX_HOT_CPL_Contacts_Trans__c>();
        for(SuRF_DGX_HOT_CPL_Contacts__c obj : scope) {
            SuRF_DGX_HOT_CPL_Contacts_Trans__c transObj = new SuRF_DGX_HOT_CPL_Contacts_Trans__c();
            transObj.Account_ID__c  =   obj.Account_ID__c;
            transObj.Account_Name__c    =   obj.Account_Name__c;
            transObj.Competency__c  =   obj.Competency__c;
            transObj.Contact_Name__c    =   obj.Contact_Name__c;
            transObj.Curriculum_Course_Title__c =   obj.Curriculum_Course_Title__c;
            transObj.Curriculum_Title__c    =   obj.Curriculum_Title__c;
            transObj.Due_Date__c    =   obj.Due_Date__c;
            transObj.Email__c   =   obj.Email__c;
            transObj.Partner_Program__c =   obj.Partner_Program__c;
            transObj.Partner_SubProgram__c  =   obj.Partner_SubProgram__c;
            transObj.Partner_Training_Compliance__c =   obj.Partner_Training_Compliance__c;
            transObj.Partner_Training_Required__c   =   obj.Partner_Training_Required__c;
            transObj.Phone_Number__c    =   obj.Phone_Number__c;
            transObj.ProductType__c =   obj.ProductType__c;
            transObj.Role__c    =   obj.Role__c;
            transObj.Training_Compliance_Status__c  =   obj.Training_Compliance_Status__c;
            transObj.Training_Record_Type__c    =   obj.Training_Record_Type__c;
            transObj.Type__c    =   obj.Type__c;
            lst.add(transObj);
        }
        insert lst;
    }
    global void finish(Database.BatchableContext BC) {
    }
}