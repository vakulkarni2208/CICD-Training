/* 12/12/2019: Akhilesh: 	Created. This class/batch job is responsible to link SAP Order
				to Entitlements.	
   01/10/2020: Akhilesh:	Added logic to filter Perpetual Entitlements.	
*/
public with sharing class ESP_LinkSAPOrderToEntitlements_BAT implements database.Batchable<sObject>, Database.RaisesPlatformEvents {
    
    private string query = 'select Id, MRS_No_Subscription__c, Subscription__c, Subscription__r.SAP_Order__c'
    						+ ', Hardware_Serial_Number__c, PAK_ID__c, Subscription__r.SAP_Order__r.SAP_Sales_Order_Number__c'
    						+ ', Subscription__r.SAP_Order__r.Sold_To_Partner_Lookup__c, Subscription__r.SAP_Order__r.Order_Type__c'
    						+ ' from Entitlement where SAP_Order__c = Null';
    
    public ESP_LinkSAPOrderToEntitlements_BAT() {}
    public ESP_LinkSAPOrderToEntitlements_BAT(String strQuery) {
        system.debug('20191213 1');
        query = strQuery;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('20191213 2');
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, list<sObject> scope) {
        system.debug(scope);
        system.debug('20191213 3');
        updateSAPOrderOnEntitlements(scope);
    }
    
    public void finish(Database.batchableContext bc) {
        system.debug('20191213 5');
    }
    
    public void updateSAPOrderOnEntitlements(list<sObject> scope) {
        //try {
            system.debug('20191213 4');
            list<Entitlement> entToUpdate = new list<Entitlement>();
            list<Entitlement> mrsEntsToUpdate = new list<Entitlement>();
            //set<string> sNosToSearch = new set<string>();
            set<string> PAKIDsToSearch = new set<string>();
            for(Entitlement ent : (list<Entitlement>)scope) {
                system.debug('20191213 4.1');
                if(ent.Subscription__c != null && ent.Subscription__r.SAP_Order__c != null) {
                    system.debug('20191213 4.1.1');
                    ent.SAP_Order__c 			= ent.Subscription__r.SAP_Order__c;
                    ent.NVIDIA_Sales_Order__c	= ent.Subscription__r.SAP_Order__r.SAP_Sales_Order_Number__c;
                    ent.Partner__c  			= ent.Subscription__r.SAP_Order__r.Sold_To_Partner_Lookup__c;
                    //if(ent.MRS_No_Subscription__c)
                    //	ent.Order_Type__c 		= 'ZMRS';
                    //else
                    	ent.Order_Type__c		= ent.Subscription__r.SAP_Order__r.Order_Type__c;
                    entToUpdate.add(ent);
                } else {
                    system.debug('20191213 4.1.2');
                    /*if(!string.isEmpty(ent.Hardware_Serial_Number__c)) {
                        system.debug('20191213 4.1.2.1');
                        sNosToSearch.add(ent.Hardware_Serial_Number__c);
                        mrsEntsToUpdate.add(ent);
                    }*/
                    if(!string.isEmpty(ent.PAK_ID__c)) {
                        system.debug('20191213 4.1.2.1');
                        PAKIDsToSearch.add(ent.PAK_ID__c);
                        mrsEntsToUpdate.add(ent);
                    }
                }
            }
            
            if(!mrsEntsToUpdate.isEmpty()) {
                system.debug('20191213 4.2');
                //Find SAP_Order by sNos.
                list<SAP_Order__c> sapOrdersList = [select Id, Hardware_Serial_Number__c, SAP_PAK_ID__c, SAP_Sales_Order_Number__c, Sold_To_Partner_Lookup__c, Order_Type__c 
                									from SAP_Order__c 
                									//where Hardware_Serial_Number__c in: sNosToSearch 
                									where SAP_PAK_ID__c in: PAKIDsToSearch
                										and Entitlement_Type__c != 'PL'
                									];
                
                //Update MRS Entitlements with SAP_Order_ID
                if(!sapOrdersList.isEmpty()) {
                    system.debug('20191213 4.2.1');
                    for(Entitlement ent : mrsEntsToUpdate) {
                        for(SAP_Order__c sapOrder : sapOrdersList) {
                            system.debug('20191213 4.2.2');
                            if(sapOrder.SAP_PAK_ID__c == ent.PAK_ID__c) {
                                ent.SAP_Order__c 			= sapOrder.Id;
                                ent.NVIDIA_Sales_Order__c	= sapOrder.SAP_Sales_Order_Number__c;
                                ent.Partner__c  			= sapOrder.Sold_To_Partner_Lookup__c;
                                if(ent.MRS_No_Subscription__c)
                                	ent.Order_Type__c = 'ZMRS';
                                else
                                	ent.Order_Type__c			= sapOrder.Order_Type__c;
                            }
                        }
                    }
                    
                    update mrsEntsToUpdate;
                }
            }
            
            system.debug('20191213 4.3');
            if(!entToUpdate.isEmpty()) 
                update entToUpdate;
                
            //Integer i = 1/0;
        /*} catch (Exception ex) {
            system.debug('20191213 6');
            //for(Entitlement ent : (list<Entitlement>)scope) {
            map<Id, Entitlement> entitlementsMap = new map<Id, Entitlement>();
            entitlementsMap.putAll((list<Entitlement>)scope);
            NV_Log__c nvlog = new NV_Log__c(
                                    //Account__c='',
                                    Component_Name__c       = 'ESP_LinkSAPOrderToEntitlements_BAT',
                                    Error_Description__c    = ''+ex.getStackTraceString(),
                                    Error_Message__c        = ''+ex.getMessage(),
                                    Functionality_Name__c   = 'Link SAP Order to Entitlement Job',
                                    Log_Type__c             = 'Error: Batch',
                                    Method_Name__c          = 'LinkSAPOrderOnEntitlements',
                                    Record_ID__c            = ''+entitlementsMap.keySet(),
                                    Status__c               = 'Exception'
                                );                                      
            insert nvlog;
            //}
        } */
    }
}