/* 12/12/2019: Akhilesh: 	Created. This class/batch job is responsible to link Subscriptions
				to Entitlements. 
   12/21/2019: Akhilesh: 	Updated logic to search based on PAK ID instead of Hardware Serial Number	
   01/10/2020: Akhilesh:	Added logic to filter Perpetual Entitlements.	
*/
public with sharing class ESP_LinkSubToEntitlements_BAT implements database.Batchable<sObject>, Database.RaisesPlatformEvents {
    
    private string query = 'select Id, SAP_Order__c from Entitlement '
    						+'where SAP_Order__c != Null and Subscription__c = NULL '
    							+'and SAP_Order__r.Entitlement_Type__c != \'PL\'';
    
    public ESP_LinkSubToEntitlements_BAT() {}
    public ESP_LinkSubToEntitlements_BAT(String strQuery) {
        system.debug('20191213 1');
        query = strQuery;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('20191213 2' + query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, list<sObject> scope) {
        system.debug(scope);
        system.debug('20191213 3');
        updateSubscriptionOnEntitlements(scope);
    }
    
    public void finish(Database.batchableContext bc) {
        system.debug('20191213 5');
    }
    
    public void updateSubscriptionOnEntitlements(list<sObject> scope) {
        system.debug('20191213 4');
        map<Id, Entitlement> entsToUpdate = new map<Id,Entitlement>();
        set<string> setOfSAPOrderToSearch = new set<string>();
        for(Entitlement ent : (list<Entitlement>)scope) {
            system.debug('20191213 4.1');
            if(ent.SAP_Order__c != NULL)
                setOfSAPOrderToSearch.add(ent.SAP_Order__c);
        }
        
        if(!setOfSAPOrderToSearch.isEmpty()) {
            system.debug('20191213 4.2');
            //Find SAP_Order by sNos.
            list<SBQQ__Subscription__c> subsList = [Select Id, SAP_Order__c from SBQQ__Subscription__c where SAP_Order__c in: setOfSAPOrderToSearch];
            
            if(!subsList.isEmpty()) {
                system.debug('20191213 4.2.1');
                for(Entitlement ent : (list<Entitlement>)scope) {
                	for(SBQQ__Subscription__c sub : subsList) {
                        system.debug('20191213 4.2.2');
                        if(sub.SAP_Order__c == ent.SAP_Order__c) {
                            ent.Subscription__c = sub.Id;
                            entsToUpdate.put(ent.Id, ent);
                        }
                    }
                }
                
                if(!entsToUpdate.isEmpty())
                	update entsToUpdate.values();
            }
        }
    }
}