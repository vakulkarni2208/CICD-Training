public without sharing class NPN_LWCQPBStatementsController{
    @AuraEnabled
    public static List<QPB_Statement__c> getQPBStatements() {
        return [SELECT Id, Name, Account_Name__c, Region__c, Fiscal_Year__c, Quarter__c, Type__c, Status__c, CreatedDate, Attachment_Uploaded__c  from QPB_Statement__c where Attachment_Uploaded__c = false order by CreatedDate  DESC];
    } 
}