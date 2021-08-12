public class ESP_LinkAssets_BAT implements database.Batchable<sObject>, Database.RaisesPlatformEvents, Database.Stateful {
    
    public DateTime LookBackFromDt;
    public DateTime LookBackToDt;
    private string query;
    public boolean LINK_ALL_ASSETS = ESP_Utility.ESPConstants.ServiceCloudSettings.Link_All_Assets__c; 

    public ESP_LinkAssets_BAT() {
        LookBackFromDt = DateTime.Now().addDays(-1);
        LookBackToDt   = DateTime.Now();
    }
    public ESP_LinkAssets_BAT(String strQuery) {
        query = strQuery;
    }
    public ESP_LinkAssets_BAT(DateTime sDate, DateTime eDate) {
        LookBackToDt   = (eDate != null) ? eDate : DateTime.Now();
        LookBackFromDt = (sDate != null) ? sDate : LookBackToDt.addDays(-1);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('Test Bat 2');
        //query =+ ' where Link_Entitlements__c = true OR Link_Components__c = true';
        
        if(query == null || query == '')
            query = 'select Id, SAP_Delivery_Number__c, SerialNumber, PAKID__c, Link_Entitlements__c, Link_Components__c '
            + ' from Asset where (Link_Entitlements__c = true OR Link_Components__c = true OR ContactId = \''+ ESP_Utility.ESPConstants.ServiceCloudSettings.Default_Asset_Contact_ID__c+'\')'
            + ' AND (lastmodifieddate >= ' +LookBackFromDt.format('yyyy-MM-dd HH:mm:ss.SSSZ').replaceAll(' ', 'T') 
            + ' AND lastmodifieddate <= '+LookBackToDt.format('yyyy-MM-dd HH:mm:ss.SSSZ').replaceAll(' ', 'T')
            + ')';
        system.debug('Query' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, list<sObject> scope) {
        system.debug('In Side Execute Function 11');
        Asset_tgr_cls.LINK_ALL_ASSETS = LINK_ALL_ASSETS;
        Asset_tgr_cls.linkEntitlements(scope);
        system.debug('In Side Execute Function 22');
        Asset_tgr_cls.linkComponents(scope);
        update scope;
    }
    
    public void finish(Database.batchableContext bc) {
        system.debug('finish BC: '+ BC);
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, ExtendedStatus, MethodName, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        
        ESP_Utility.LogErrors('ESP_LinkAssets_BAT', job.Id + ' ' +job.Status + 'BatchJobMethodName: '+job.MethodName +' NumberOfErrors : ' + job.NumberOfErrors + ' Error Details: '+ job.ExtendedStatus);
    }
}