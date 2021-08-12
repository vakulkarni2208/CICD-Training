/*
 *  This is a batch job that removes corresponding permission set(s) when an entitlement on the account has expired
 *  Following Entitlement records are eligible for removal
 *  - Product Family attribute on the Entitlement record is valid
 *  - Current date is past the End Date on the Entitlement record
 *  This batch job may be instantied in a couple of ways
 *  - a single argument constuctor with a specific Entitlement record Id
 *  - a first execution boolean parameter Note: This input parameter is currently not used 
 */ 
global class IDM_UpdatePermissionSet implements Database.Batchable<sObject> {
    
    String query;
    
    global IDM_UpdatePermissionSet() {
        Date twentyFourHoursAgo = System.Today()-1;
        String twentyFourHoursAgoStr = String.valueOf(twentyFourHoursAgo);
        twentyFourHoursAgoStr.replace(' ', 'T');
        query ='SELECT Id,Product_Family__c,AccountId FROM Entitlement Where EndDate = '+twentyFourHoursAgoStr+' and Product_Family__c != null';
    }
    // Testing
        global IDM_UpdatePermissionSet(String entId){
        query = PRFT_DomainLayer.buildQueryFields('Entitlement',' Where Id = \''+entId+'\'','Select ');
            System.debug('Checking query constructor--'+query);
      }

    global IDM_UpdatePermissionSet(Boolean firstExecution) {
        Date twentyFourHoursAgo = System.Today()-1;
        String twentyFourHoursAgoStr = String.valueOf(twentyFourHoursAgo);
        twentyFourHoursAgoStr.replace(' ', 'T');
        query ='SELECT Id,Product_Family__c,AccountId FROM Entitlement Where EndDate <= '+twentyFourHoursAgoStr+' and Product_Family__c != null';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('checking query---'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Entitlement> scope) {
        Map<String,String> entitlementVsProduct = new Map<String,String>();
        Map<String,String> entitlementVsAccount = new Map<String,String>();
        List<Id> entitlementPermissionTobeAdded = new List<Id>();
        for(Entitlement entList : scope){
            if(!entitlementVsAccount.containsKey(entList.AccountId)){
                    entitlementVsAccount.put(entList.AccountId,'');
                }
                String tempEntId = entitlementVsAccount.get(entList.AccountId);
                tempEntId = tempEntId +entList.Id+'-';
                entitlementVsAccount.put(entList.AccountId,tempEntId);
                 entitlementVsProduct.put(entList.Id,entList.Product_Family__c);
                System.debug('checking entitlement vs Product List--'+entitlementVsAccount);

        }

        // Removal Logic
        /*if(!entitlementVsProduct.isEmpty()){
            System.debug('checking removal logic--'+entitlementVsProduct);
            TriggerEntitlementHelper.removePermissionSet(entitlementVsProduct,entitlementVsAccount);
        }*/
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}