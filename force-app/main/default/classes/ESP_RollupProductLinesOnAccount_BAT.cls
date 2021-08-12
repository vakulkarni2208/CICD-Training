/*
Service Cloud : Update Product Lines on Account
The Batch is responsible to rollup "Product Lines" from Entitlement to Account.

* Akhilesh: 07/24/2019: Created.
Pending Action Items: Use Common Log function
*/
public class ESP_RollupProductLinesOnAccount_BAT implements Database.Batchable<sObject>{
    
    private DateTime LookBackFromDt;
    private DateTime LookBackToDt;
    private String query;
    
    public ESP_RollupProductLinesOnAccount_BAT() {
        LookBackFromDt = DateTime.Now().addDays(-1);
        LookBackToDt   = DateTime.Now();
    }
    public ESP_RollupProductLinesOnAccount_BAT(String strQuery) {
        query = strQuery;
    }
    public ESP_RollupProductLinesOnAccount_BAT(DateTime sDate, DateTime eDate) {
        LookBackToDt   = (eDate != null) ? eDate : DateTime.Now();
        LookBackFromDt = (sDate != null) ? sDate : LookBackToDt.addDays(-1);
    }
    
    //lastmodifieddate > yesterday
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //String LookBackFromDate = LookBackFromDt.year()+'/'+LookBackFromDt.month()+'/'+LookBackFromDt.day();
        //Date LookBackToDate = date.newinstance(LookBackToDt.year(), LookBackToDt.month(), LookBackToDt.day());
        
        if(query == null || query == '')
            query = 'select Id from Account'
            +' where Id in (select AccountId from Entitlement'
            +' where (EndDate >= '+ LookBackFromDt.format('yyyy-MM-dd') + ' AND EndDate <= '+ LookBackToDt.format('yyyy-MM-dd') +') '
            +'OR (lastmodifieddate >= ' +LookBackFromDt.format('yyyy-MM-dd HH:mm:ss.SSSZ').replaceAll(' ', 'T') + ' AND lastmodifieddate <= '+LookBackToDt.format('yyyy-MM-dd HH:mm:ss.SSSZ').replaceAll(' ', 'T')+')'
            +' ) '
            ;
        system.debug('query: '+ query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        try{
            system.debug('execute BC: '+ BC);
            List<Account> accList = scope;
            system.debug('execute accList: '+ accList);
            if(!accList.isEmpty()) {
                for(Account acc : accList) {
                    set<String> prodLineSet = ESP_Utility.FindProductLinesForCustomer(acc.Id);
                    
                    Service_Cloud_Error_Log__c sl = new Service_Cloud_Error_Log__c();
                    sl.Record_URL__c = ''+accList;
                    sl.Functionality_Name__c = 'Batch_UpdateProductLinesOnAccount';
                    sl.Error_Type__c = 'Success';
                    sl.Error_Description__c = 'AccountID: '+ acc.Id + 'ProductLines: '+ prodLineSet;
                    insert sl;
                    
                    acc.Product_Lines__c = string.join(new list<string>(prodLineSet), ';');
                    system.debug('ProductLines: '+ acc.Product_Lines__c);
                }
            }
            update accList;
            
        }catch (Exception ex) {
            Service_Cloud_Error_Log__c sl = new Service_Cloud_Error_Log__c();
            sl.Record_URL__c = ''+scope;
            sl.Functionality_Name__c = 'ESP_RollupProductLinesOnAccount_BAT';
            sl.Error_Type__c = 'Failure';
            sl.Error_Code__c = 'ESP_RollupProductLinesOnAccount_BAT';
            sl.Error_Description__c = 'ESP_RollupProductLinesOnAccount_BAT : ' + ex.getMessage() + 'Stack Trace: ' + ex.getStackTraceString();
            insert sl;
            //system.debug('Exception: '+ ex.getMessage());
            //ESP_Utility.LogErrors('ESP_RollupProductLinesOnAccount_BAT : ' + ex.getMessage(), ex.getStackTraceString());
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        system.debug('finish BC: '+ BC);
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, ExtendedStatus, MethodName, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                                FROM AsyncApexJob
                                WHERE Id = :bc.getJobId()];
                                
        ESP_Utility.LogErrors('ESP_RollupProductLinesOnAccount_BAT', job.Id + ' ' +job.Status + 'BatchJobMethodName: '+job.MethodName +' NumberOfErrors : ' + job.NumberOfErrors + ' Error Details: '+ job.ExtendedStatus);
    }
}