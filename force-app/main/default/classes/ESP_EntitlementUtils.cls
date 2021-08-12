/**
 * This is utility class for all reusable functions related to Entitlements.
 * Created: 02/10/2021 - Akhilesh Gupta 
 * 2021.10.02 - Akhilesh Gupta 	- Added reEvaluateEntitlementProcess to update Entitlement process on all the Entitlements associated with Account Ids provided.
 */

public class ESP_EntitlementUtils {
	
    public static void checkForProductUpgrade(list<Entitlement> entList) {
        map<String, Entitlement> EntMapBySN = new map<String, Entitlement>();
        for(Entitlement ent : entList) {
            system.debug('Upgrade Ent: '+ ent);
            if(ent.Product_Upgrade_Entitlement__c && ent.Hardware_Serial_Number__c != NULL && ent.Hardware_Serial_Number__c != '')
                EntMapBySN.put(ent.Hardware_Serial_Number__c, ent);
        }
        
        system.debug('EntMapBySN: '+ EntMapBySN);
        //Find All Entitlements matiching with SNs, AccountID, Active and Upgraded For equals ent.Service Prod
        list<Entitlement> entToProcess = [select Id, Name, AccountId, Subscription__c, Hardware_Serial_Number__c,
                                          	Service_Product__c, Service_Product__r.ProductCode, Service_Product__r.Upgrade_Product__c
                                         	, AssetId, Asset.SerialNumber, Asset.Product2.Upgrade_Product__c, Asset.Product2.Upgrade_Product__r.Description
                                          From Entitlement
                                         	Where Hardware_Serial_Number__c in: EntMapBySN.keySet() 
                                          		and EndDate >=: Date.today()
                                          		and Service_Product__r.Upgrade_Product__c != NULL
                                         ]; 
        
        system.debug('entToProcess: '+ entToProcess);
        
        if(entToProcess.isEmpty())
           return;
        
        list<Entitlement> EntitlementsToUpdate = new list<Entitlement>();
        list<Asset> AssetsToUpdate = new list<Asset>();
        list<SBQQ__Subscription__c> SubscriptionsToUpdate = new list<SBQQ__Subscription__c>();
        
        for(Entitlement oldEnt: entToProcess) {
            Entitlement upgradeEnt = EntMapBySN.get(oldEnt.Hardware_Serial_Number__c);
            system.debug('oldEnt: '+ oldEnt);
            if(oldEnt.AccountId == upgradeEnt.AccountId
              	//&& oldEnt.Service_Product__r.Upgrade_Product__c == upgradeEnt.Service_Product__c 
              ) {
        		oldEnt.Service_Product__c = oldEnt.Service_Product__r.Upgrade_Product__c;
                EntitlementsToUpdate.add(oldEnt);
                
                if(oldEnt.Subscription__c != null)
                    SubscriptionsToUpdate.add(new SBQQ__Subscription__c(Id=oldEnt.Subscription__c, 
                                                   SBQQ__Product__c=oldEnt.Service_Product__r.Upgrade_Product__c
                                                  ));
               	if(oldEnt.AssetId != Null && oldEnt.Asset.Product2 != NULL && oldEnt.Asset.Product2.Upgrade_Product__c != NULL) {
                	Asset ast = new Asset();
                    ast.Id = oldEnt.AssetId;
                    ast.Product2Id = oldEnt.Asset.Product2.Upgrade_Product__c;
                    ast.Name = oldEnt.Asset.SerialNumber + '-' + oldEnt.Asset.Product2.Upgrade_Product__r.Description;
                    AssetsToUpdate.add(ast);
                }
            }
        }
        
        system.debug('EntitlementsToUpdate: '+ EntitlementsToUpdate);
        system.debug('AssetsToUpdateldEnt: '+ AssetsToUpdate);
        system.debug('SubscriptionsToUpdate: '+ SubscriptionsToUpdate);
        
        if(!EntitlementsToUpdate.isEmpty()) 
            update EntitlementsToUpdate;
        if(!AssetsToUpdate.isEmpty()) {
            update AssetsToUpdate;
            //update AssetsToUpdate;
        }
        if(!SubscriptionsToUpdate.isEmpty()) 
            update SubscriptionsToUpdate;
    }
    
    public static void reEvaluateEntitlementProcess(set<Id> accIdsToUpdate) {
        //Query All the Entitlements to process
        map<Id, Entitlement> entitlementsToProcess 
             		= new map<Id, Entitlement>(
                        [SELECT Id, Name, AccountId, EndDate, Hardware_Serial_Number__c, Account.Support_Level__c, SlaProcessId, Entitlement_Status__c
                         	, Service_Product__r.Product_Line__c, Service_Product__r.Support_level__c, Service_Product__r.SLA_Scope__c  
                         FROM Entitlement 
                         WHERE AccountId IN :accIdsToUpdate 
                         and Name !=: ESP_Utility.ESPConstants.ServiceCloudSettings.Placeholder_Entitlement_Name__c
                         //and Entitlement_Status__c != 'Expired' and Entitlement_Status__c != 'Inactive'
                        ]
                    );
        
        if(entitlementsToProcess.isEmpty()) 
            return;
        
        SLA_Settings__mdt slaSetting = ESP_Utility.getSLASetting(ESP_Utility.ESPConstants.SLA_24X7SUPPORT);
        List<SlaProcess> EntProcessList;
        if(slaSetting != NULL)
            EntProcessList = [SELECT Id, Name FROM SlaProcess WHERE name =: slaSetting.Entitlement_Process_Name__c];
        
        Id slaProcessId = (EntProcessList.isEmpty()) ? NULL : EntProcessList[0].Id;
        
        //Create Dataset to Process
        set<String> SNSet 		= new set<String>();
        set<String> ProdLineSet = new set<String>();
        //map<Id, Integer> accTo24x7Count = map<Id, Integer>();
        
        for(Entitlement ent: entitlementsToProcess.values()) {
            if(
                //ent.Account.Support_Level__c == ESP_Utility.ESPConstants.SLA_24X7SUPPORT && 
               ent.Service_Product__r != NULL && 
               ent.Service_Product__r.Support_level__c == ESP_Utility.ESPConstants.SLA_24X7SUPPORT && 
               ent.Name != ESP_Utility.ESPConstants.ServiceCloudSettings.Placeholder_Entitlement_Name__c
               && ent.Entitlement_Status__c != 'Expired' && ent.Entitlement_Status__c != 'Inactive'
              )
            {
                system.debug('ent.Service_Product__r.SLA_Scope__c: '+ ent.Service_Product__r.SLA_Scope__c);
                system.debug('ESP_Utility.ESPConstants.SLA_Settings.SLA_By_SN_Label__c: '+ ESP_Utility.ESPConstants.SLA_Settings.SLA_By_SN_Label__c);
                system.debug('ent.Service_Product__r.Product_Line__c: '+ ent.Service_Product__r.Product_Line__c);
                
                //Get SN List to Update // and 
                if(ent.EndDate >= Date.today()) {
                    if(Ent.Service_Product__r.SLA_Scope__c == ESP_Utility.ESPConstants.SLA_Settings.SLA_By_SN_Label__c 
                        && !string.isBlank(ent.Hardware_Serial_Number__c)
                      ) 
                        SNSet.add(ent.Hardware_Serial_Number__c);
                    
                    //Get Product Line list to update
                    if(Ent.Service_Product__r.SLA_Scope__c == ESP_Utility.ESPConstants.SLA_Settings.SLA_By_Product_Line_Label__c 
                        && !string.isBlank(ent.Service_Product__r.Product_Line__c)
                      )
                        ProdLineSet.add(ent.Service_Product__r.Product_Line__c);
                }
            }
        }
        
        system.debug('entitlementsToProcess: '+ entitlementsToProcess);
        system.debug('slaProcessId: '+ slaProcessId);
        system.debug('SNSet: '+ SNSet);
        system.debug('ProdLineSet: '+ ProdLineSet);
        map<Id, Entitlement> entMapToUpdate = new map<Id, Entitlement>();
        
        for(Entitlement ent: entitlementsToProcess.values()) {
            system.debug('SN: '+ ent.Hardware_Serial_Number__c);
            system.debug('Product Line: '+ ent.Service_Product__r.Product_Line__c);
            if(ent.Name != ESP_Utility.ESPConstants.ServiceCloudSettings.Placeholder_Entitlement_Name__c) {
                if(Ent.EndDate < Date.today()) { //When an Entitlement is Exprired, remove SLA Process
                    if(ent.SlaProcessId != NULL) {
                        Ent.SlaProcessId = NULL;
                        entMapToUpdate.put(ent.Id, ent);
                    }
                    system.debug('Entitlement Expired');
                } else if(SNSet.contains(ent.Hardware_Serial_Number__c)) { //Update Entitlement based on Serial Number
                    if(ent.SlaProcessId != slaProcessId) { //Only update if Entitlement process not populated. Reduce number of records to be updated
                        Ent.SlaProcessId = slaProcessId;
                        entMapToUpdate.put(ent.Id, ent);
                        system.debug('Match by SN');
                    }
                } else if(ProdLineSet.contains(ent.Service_Product__r.Product_Line__c)) { //Update Entitlement based on Product Line
                    if(ent.SlaProcessId != slaProcessId) {//Only update if Entitlement process not populated. Reduce number of records to be updated
                        Ent.SlaProcessId = slaProcessId;
                        entMapToUpdate.put(ent.Id, ent);
                        system.debug('Match by Product Line');
                    }
                } else if(ent.SlaProcessId != NULL) { //Remove SLA Process when it is not fitting based on SLA Scope (SN/Product Line)
                    Ent.SlaProcessId = NULL;
                    entMapToUpdate.put(ent.Id, ent);
                    system.debug('No Match');
                }
            }
        }
        
        system.debug('entMapToUpdate: '+ entMapToUpdate);
        if(!entMapToUpdate.isEmpty()){
            TriggerEntitlementHelper.DISABLE_TRIGGER = TRUE;
            //TriggerEntitlementHelper.UPDATE_ENT_PROCESS  = False;
            update entMapToUpdate.values();
            updateAccountSupportLevel(accIdsToUpdate, slaProcessId);
            TriggerEntitlementHelper.DISABLE_TRIGGER = FALSE;
            //TriggerEntitlementHelper.UPDATE_ENT_PROCESS  = True;            
        }
	}
    
    public static void updateAccountSupportLevel(set<Id> accIdsToUpdate, Id slaProcessId) {
        list<Account> accountsToProcess = [select Id, Support_Level__c,
                                            (select Id, Name, SlaProcessId from Entitlements 
                                                where slaProcessId != NULL 
                                                  and Name !=: ESP_Utility.ESPConstants.ServiceCloudSettings.Placeholder_Entitlement_Name__c
                                            ) 
                                           from Account where Id IN :accIdsToUpdate];
        
        system.debug('accountsToProcess: '+ accountsToProcess);
        
        List<Account> accList = new list<Account>();
        for(Account acc : accountsToProcess) {
            system.debug('acc.Entitlements: '+ acc.Entitlements);
            system.debug('acc.Support_Level__c: '+ acc.Support_Level__c);
            if(acc.Entitlements != NULL && acc.entitlements.size() > 0) {
                if(acc.Support_Level__c != ESP_Utility.ESPConstants.SLA_24X7SUPPORT) 
                	accList.add(new Account(Id=acc.Id, Support_Level__c = ESP_Utility.ESPConstants.SLA_24X7SUPPORT));
            } else if(acc.Support_Level__c != '') {
                accList.add(new Account(Id=acc.Id, Support_Level__c=''));
            }
        }
        
        system.debug('accList: '+ accList);
        if(!accList.isEmpty()) {
            Account_tgr_cls.UPDATE_ALL_ENTITLEMENTS = TRUE;
            update accList;
			Account_tgr_cls.UPDATE_ALL_ENTITLEMENTS = FALSE;
        }
    }
}