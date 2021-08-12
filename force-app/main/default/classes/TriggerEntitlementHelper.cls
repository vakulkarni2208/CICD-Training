/**************************************************************************************************
* Name       : TriggerEntitlementHelper
* Purpose    : Helper class for TriggerEntitlement Trigger 
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 12/13/2017      | Initial Draft
*Perficient         | 1.0        | 12/25/2017      | Final Draft
*Perficient         | 1.1        | 07/03/2018      | Added two methods AddAnnouncement and getAnnoucementsToAddByAccount
*Akhilesh Gupta     | 2.0        | 12/12/2019      | Updated code to implement Trigger Handler
| Add Logic to update Entitlement Name  
| Remove code responsible to assign Knowledge Category Permissions
*Akhilesh Gupta     | 2.0        | 02/26/2020      | SDS-2064 - Updated "UpdateEntitlement" function to use support level from Product 
- User new Constants framework, use ESP_Utility functions instead of ServiceCloudUtils.
* Nilesh Adkar      2.1        12/01/2020        SDS-2020 ESPContactNVIDIARenewalsButton
* Nilesh Adkar      2.2        01/01/2021        SDS-2432 : Service: Registration Reminder for Support Portal. Method Added checkSupportPortalRegistration
* Akhilesh Gupta    | 3.0        | 02/15/2021      |SDS-2901: Updated logic for 24x7 Business Critical.
**************************************************************************************************/
public class TriggerEntitlementHelper extends NV_TriggerHandler {
    public list<Entitlement> oldRecords;
    private static list<Entitlement> newRecords;
    private static map<Id, Entitlement> oldRecordsMap;
    private static map<Id, Entitlement> newRecordsMap;
    public static boolean DISABLE_TRIGGER = FALSE;
    public override void init() {
        OBJECT_NAME = 'Entitlement';
        oldRecords = trigger.old;
        newRecords = trigger.New;
        if(oldRecords != null)
            oldRecordsMap = new map<Id, Entitlement>(oldRecords);
        if(newRecords != null && Trigger.isUpdate)
            newRecordsMap = new map<Id, Entitlement>(newRecords);
        System.debug('Old Records' + oldRecords + '1');
        System.debug('New Records' + trigger.New + '1'); 
    }
    public override void beforeInsert() {
        //SDS-2901 
        //TriggerEntitlementHelper.UpdateEntilementProcess();
        //TriggerEntitlementHelper.updateAccountSupportLevel();        
        TriggerEntitlementHelper.UpdateName();
        TriggerEntitlementHelper.updateAssetId();
        //TriggerEntitlementHelper.LinkwithOriginalEntitlement();
    }
    public override void beforeUpdate() {
        //SDS-2901 
        //TriggerEntitlementHelper.updateAccountSupportLevel();
        TriggerEntitlementHelper.UpdateName();
        TriggerEntitlementHelper.updateAssetId();
        //TriggerEntitlementHelper.LinkwithOriginalEntitlement();
    }
    public override void afterInsert() {
        //SDS-2901 
        //TriggerEntitlementHelper.UpdateEntilementProcess();
        ESP_EntitlementUtils.checkForProductUpgrade(newRecords); //SDS-2908
        TriggerEntitlementHelper.AddAnnouncement(oldRecordsMap,newRecords);
    }
    public override void afterUpdate() {
        //SDS-2901 
        //TriggerEntitlementHelper.UpdateEntilementProcess();
        ESP_EntitlementUtils.checkForProductUpgrade(newRecords); //SDS-2908
        //TriggerEntitlementHelper.RemoveUpdatePermissionSet(trigger.oldMap,trigger.New);
        TriggerEntitlementHelper.AddAnnouncement(oldRecordsMap,newRecords);
    }
    
   /* public static void LinkwithOriginalEntitlement(){
        //set<String> PAKIDset = new set<String>();
        map<String, Entitlement> entbyRenewedPAKIDMap = new map<String, Entitlement>();
        for(Entitlement ent : newRecords){
            if(!string.IsBlank(ent.Renewed_PAK_ID__c)) {
                entbyRenewedPAKIDMap.put(ent.Renewed_PAK_ID__c, ent);
            } //else {
                //ent.Renewed_Entitlement__c = NULL;
            //}
            
            //Get Old Renewed PAKID's to delink entitlements.
            if(trigger.isUpdate) {
                Entitlement oldRecord = oldRecordsMap.get(ent.Id);
                if(!string.IsBlank(oldRecord.Renewed_PAK_ID__c) && ent.Renewed_PAK_ID__c != oldRecord.Renewed_PAK_ID__c) {
                    entbyRenewedPAKIDMap.put(oldRecord.Renewed_PAK_ID__c, ent);
                }
            }
        }
        
        if(entbyRenewedPAKIDMap.isEmpty())
            return;
        
        //Find ExistingEntitlement where NewEntitlement.RenewedPAKID = ExistingEntitlement.PAKID
        list<Entitlement> originalEntitlements = [select Id, Renewed_PAK_ID__c, PAK_ID__c, AssetId from Entitlement where PAK_ID__c in: entbyRenewedPAKIDMap.keySet()];
        
        list<Entitlement> entitlementsToUpdate = new list<Entitlement>();
        //IF found, Populate ExistingEntitlement.RenewedEntitlement = NewEntitlement
        for(Entitlement originalEnt : originalEntitlements) {
            //if(originalEnt.PAK_ID__c != originalEnt.Renewed_PAK_ID__c) {
                if(entbyRenewedPAKIDMap.containsKey(originalEnt.PAK_ID__c)) {
                    Entitlement renewedEntitlement = entbyRenewedPAKIDMap.get(originalEnt.PAK_ID__c);
                    if(originalEnt.PAK_ID__c == renewedEntitlement.Renewed_PAK_ID__c) {
                        if(originalEnt.Id != renewedEntitlement.Id) {
                            renewedEntitlement.AssetId = originalEnt.AssetId;
                            originalEnt.Renewed_Entitlement__c = renewedEntitlement.Id;
                        }
                    } else {
                        renewedEntitlement.AssetId = NULL;
                        originalEnt.Renewed_Entitlement__c = NULL;
                    }
                    if(renewedEntitlement.Id != originalEnt.Id)
                        entitlementsToUpdate.add(originalEnt);
                }
            //}
        }
        
        //bkpif(!entitlementsToUpdate.isEmpty())
        //bkp    update entitlementsToUpdate;
        ////update originalEntitlements;
    }
    
    */
    public static void updateAccountSupportLevel() {
        /*//set<Id> accountIdsToProcess = new set<Id>();
        List<Account> accList = new list<Account>();
        for(Entitlement ent: newRecords) {
            if(
                //acc != null && 
                //acc.Support_Level__c == ESP_Utility.ESPConstants.SLA_24X7SUPPORT && 
                trigger.isInsert && ent.Support_level__c == ESP_Utility.ESPConstants.SLA_24X7SUPPORT 
                || (
                    trigger.isUpdate && 
                    (oldRecordsMap.get(ent.Id).SlaProcessId != ent.SlaProcessId || oldRecordsMap.get(ent.Id).Support_level__c != ent.Support_level__c)
                )
            ){
                    System.debug('ent.SlaProcessId = ' + ent.SlaProcessId);
                    //ent.SlaProcessId = slaProcessId; //SDS-2901
                    //accountIdsToProcess.add(ent.AccountId);
                    accList.add(new Account(Id=ent.AccountId, Support_Level__c=ESP_Utility.ESPConstants.SLA_24X7SUPPORT));
                }
        }
        
        //System.debug('accountIdsToProcess = ' + accountIdsToProcess);
        //SDS-2901
        //if(!accountIdsToProcess.isEmpty()) {
        //    updateAccountSupportLevel(accountIdsToProcess);
        //}
        
        system.debug('accList: '+ accList);
        if(!accList.isEmpty()) {
            Account_tgr_cls.UPDATE_ALL_ENTITLEMENTS = TRUE;
            update accList;
			Account_tgr_cls.UPDATE_ALL_ENTITLEMENTS = FALSE;
        } */
    }
    /*
This function auto populates Entitlement Process Name for Business Critical Accounts
*/
    /*public static boolean UPDATE_ENT_PROCESS = TRUE;
    public static void UpdateEntilementProcess(){
        
        if(UPDATE_ENT_PROCESS) {
            UPDATE_ENT_PROCESS = FALSE;*/
            //set<Id> SlaProcessIdSet = new set<Id>();
          /*Set<Id> acctIdSet = new Set<Id>();
            for(Entitlement ent : newRecords){
                acctIdSet.add(ent.AccountId);
            }
            if(acctIdSet.isEmpty())// || EntProcessList.isEmpty()) 
                return;
            Map<Id,Account> acctMap = new Map<Id, Account>([SELECT Id, Support_Level__c FROM account WHERE Id IN :acctIdSet]);
            */
            
            /*SLA_Settings__mdt slaSetting = ESP_Utility.getSLASetting(ESP_Utility.ESPConstants.SLA_24X7SUPPORT);
            List<SlaProcess> EntProcessList;
            if(slaSetting != NULL)
                EntProcessList = [SELECT Id, Name FROM SlaProcess WHERE name =: slaSetting.Entitlement_Process_Name__c];
            
            Id slaProcessId = (EntProcessList.isEmpty()) ? NULL : EntProcessList[0].Id;
			*/
           /* set<Id> accountIdsToProcess = new set<Id>();
            for(Entitlement ent: newRecords) {
                //Account acc = acctMap.get(ent.AccountId); //SDS-2901
                //system.debug('1242019: '+ acc + 'ent: '+ ent); //SDS-2901
                if(
                    //acc != null && 
                    //acc.Support_Level__c == ESP_Utility.ESPConstants.SLA_24X7SUPPORT && 
                    (ent.Support_level__c == ESP_Utility.ESPConstants.SLA_24X7SUPPORT && ent.SlaProcessId == null) 
                    || (oldRecordsMap != null && !oldRecordsMap.isEmpty() && oldRecordsMap.get(ent.Id).SlaProcessId != ent.SlaProcessId)){
                        System.debug('ent.SlaProcessId = ' + ent.SlaProcessId);
                       //ent.SlaProcessId = slaProcessId; //SDS-2901
                       accountIdsToProcess.add(ent.AccountId);
                   }
            }
            
            System.debug('accountIdsToProcess = ' + accountIdsToProcess);
            	
            //SDS-2901
            if(!accountIdsToProcess.isEmpty()) {
                updateAccountSupportLevel(accountIdsToProcess);
				//if(System.IsFuture() || system.isBatch())
                //	return;
                //System.debug('accountIdsToProcess = ' + accountIdsToProcess);
                //Account_tgr_cls.managePlaceholderEntitlements(accountIdsToProcess, slaProcessId);
                //reEvaluateEntitlementProcess(accountIdsToProcess);
            }
        }
    } */
    
    //@future
    /*public static void updateAccountSupportLevel(set<Id> accountIdsToProcess) {
        List<Account> accList = new list<Account>();
        for(Id accId : accountIdsToProcess) {
            accList.add(new Account(Id=accId, Support_Level__c=ESP_Utility.ESPConstants.SLA_24X7SUPPORT));
        }
        system.debug('accList: '+ accList);
        if(!accList.isEmpty()) {
            //Account_tgr_cls.UPDATE_ALL_ENTITLEMENTS = TRUE;
            update accList;
			//Account_tgr_cls.UPDATE_ALL_ENTITLEMENTS = FALSE;
        }
    }*/
        /*
    @future
    @InvocableMethod
    public static void reEvaluateEntitlementProcess(List<Id> accIdsToUpdate) {
    	UPDATE_ENT_PROCESS = FALSE;
        //TriggerEntitlementHelper.DISABLE_TRIGGER = TRUE;
        //Query All the Entitlements to process
        map<Id, Entitlement> entitlementsToProcess 
             		= new map<Id, Entitlement>(
                        [SELECT Id, Name, AccountId, Hardware_Serial_Number__c, Account.Support_Level__c, SlaProcessId, Service_Product__r.Product_Line__c, Service_Product__r.Support_level__c, Service_Product__r.SLA_Scope__c  
                         FROM Entitlement 
                         WHERE AccountId IN :accIdsToUpdate
                         and Entitlement_Status__c != 'Expired' and Entitlement_Status__c != 'Inactive']
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
        
        for(Entitlement ent: entitlementsToProcess.values()) {
            if(
                //ent.Account.Support_Level__c == ESP_Utility.ESPConstants.SLA_24X7SUPPORT && 
               Ent.Service_Product__r != NULL && 
               Ent.Service_Product__r.Support_level__c == ESP_Utility.ESPConstants.SLA_24X7SUPPORT && 
               Ent.Name != ESP_Utility.ESPConstants.ServiceCloudSettings.Placeholder_Entitlement_Name__c
              )
            {
                system.debug('Ent.Service_Product__r.SLA_Scope__c: '+ Ent.Service_Product__r.SLA_Scope__c);
                system.debug('ESP_Utility.ESPConstants.SLA_Settings.SLA_By_SN_Label__c: '+ ESP_Utility.ESPConstants.SLA_Settings.SLA_By_SN_Label__c);
                system.debug('ent.Service_Product__r.Product_Line__c: '+ ent.Service_Product__r.Product_Line__c);
                
                //Get SN List to Update
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
        
        system.debug('entitlementsToProcess: '+ entitlementsToProcess);
        system.debug('slaProcessId: '+ slaProcessId);
        system.debug('SNSet: '+ SNSet);
        system.debug('ProdLineSet: '+ ProdLineSet);
        map<Id, Entitlement> entMapToUpdate = new map<Id, Entitlement>();
        
        for(Entitlement ent: entitlementsToProcess.values()) {
            system.debug('SN: '+ ent.Hardware_Serial_Number__c);
            system.debug('Product Line: '+ ent.Service_Product__r.Product_Line__c);
            if(SNSet.contains(ent.Hardware_Serial_Number__c)) { //Update Entitlement based on Serial Number
                if(ent.SlaProcessId != slaProcessId) {
                    Ent.SlaProcessId = slaProcessId;
                    entMapToUpdate.put(ent.Id, ent);
                    system.debug('Match by SN');
                }
            } else if(ProdLineSet.contains(ent.Service_Product__r.Product_Line__c)) { //Update Entitlement based on Product Line
                if(ent.SlaProcessId != slaProcessId) {
                    Ent.SlaProcessId = slaProcessId;
                    entMapToUpdate.put(ent.Id, ent);
                    system.debug('Match by Product Line');
                }
            } else if(ent.SlaProcessId != NULL) {
                Ent.SlaProcessId = NULL;
                entMapToUpdate.put(ent.Id, ent);
                system.debug('No Match');
            }
        }
        
        system.debug('entMapToUpdate: '+ entMapToUpdate);
        if(!entMapToUpdate.isEmpty()){
            TriggerEntitlementHelper.UPDATE_ENT_PROCESS  = False;
            update entMapToUpdate.values();
            TriggerEntitlementHelper.UPDATE_ENT_PROCESS  = True;            
        }
	}
    */
    
    
    
    Public static void updateAssetId(){
        set<String> serialNumberSet = new set<String>();
        set<String> deliveryNumberSet = new set<String>();
        set<String> PAKIdNumberSet = new set<String>();
        for(Entitlement ent : newRecords){
            Entitlement oldEnt = (trigger.isUpdate) ? oldRecordsMap.get(ent.Id) : NULL;
            System.debug('Old Ent->'+oldEnt);
            if ( ( ent.Hardware_Serial_Number__c != null && ent.Hardware_Serial_Number__c != '')  
                    && (ent.Link_Asset__c == true || (oldEnt != NULL && oldEnt.Hardware_Serial_Number__c != ent.Hardware_Serial_Number__c) )
               ) {
                serialNumberSet.add(ent.Hardware_Serial_Number__c);
                //ent.AssetId = NULL;
            }else if((ent.SAP_Delivery_Number__c != null && ent.SAP_Delivery_Number__c != '' )
                    && (ent.Link_Asset__c == true || (oldEnt != NULL && oldEnt.SAP_Delivery_Number__c != ent.SAP_Delivery_Number__c) )
                    ){
                deliveryNumberSet.add(ent.SAP_Delivery_Number__c);
                //ent.AssetId = NULL;
            }/* Change: 25Oct2020: This code is commented due as we do not want to link based on PAK ID
              * else if((ent.PAK_ID__c != null && ent.PAK_ID__c != '') 
                     && (ent.Link_Asset__c == true || (oldEnt != NULL && oldEnt.PAK_ID__c != ent.PAK_ID__c) )
                    ){
                PAKIdNumberSet.add(ent.PAK_ID__c);
                //ent.AssetId = NULL;
            } */
            ent.Link_Asset__c = false;
        }
        System.debug('Assets Check point 1');
        if(serialNumberSet.isEmpty() && deliveryNumberSet.isEmpty()) // && PAKIdNumberSet.isEmpty() ) Change: 25Oct2020: This code is commented due as we do not want to link based on PAK ID
            return;
        System.debug('Assets Check point 2');
        // Change: 25Oct2020: This code is commented due as we do not want to link based on PAK ID
        List<Asset> AssetLst = [Select Id, Name, SerialNumber, SAP_Delivery_Number__c, PAKID__c from Asset where SerialNumber in: serialNumberSet OR SAP_Delivery_Number__c in: deliveryNumberSet];// OR PAKID__c in: PAKIdNumberSet]; 
        
        if(AssetLst.isEmpty())
            return;
        System.debug('Assets>>>'+AssetLst);
        Map <String, Asset> SNtoAssetMap = New Map<String, Asset>();
        for(Asset ast: AssetLst){
            if(ast.SerialNumber != null && ast.SerialNumber != ''){
                SNtoAssetMap.put(ast.SerialNumber, ast);
            }
            /* Change: 25Oct2020: This code is commented due as we do not want to link based on PAK ID
            if(ast.PAKID__c != null && ast.PAKID__c != ''){
                SNtoAssetMap.put(ast.PAKID__c, ast);
            } */
            if(ast.SAP_Delivery_Number__c != null && ast.SAP_Delivery_Number__c != ''){
                SNtoAssetMap.put(ast.SAP_Delivery_Number__c, ast);
            }
        }
        System.debug('SNtoAssetMap>>>'+SNtoAssetMap);
        for(Entitlement ent: newRecords) {
            if(SNtoAssetMap.containsKey(ent.Hardware_Serial_Number__c)){
                ent.AssetID = SNtoAssetMap.get(ent.Hardware_Serial_Number__c).id;
                System.debug('<<<AssetsId Update>>>');
            } /* Change: 25Oct2020: This code is commented due as we do not want to link based on PAK ID
            else if(SNtoAssetMap.containsKey(ent.PAK_ID__c)){
                ent.AssetID = SNtoAssetMap.get(ent.PAK_ID__c).id; 
                System.debug('<<<AssetsId Update>>>');
            } */ else if(SNtoAssetMap.containsKey(ent.SAP_Delivery_Number__c)){
                ent.AssetID = SNtoAssetMap.get(ent.SAP_Delivery_Number__c).id; 
                System.debug('<<<AssetsId Update>>>');
            }
        }
    }
    
    /* Update EntitlementName everytime either PAKID, Hardware Serial Number or Product Description changes.*/
    public static void UpdateName() {
        for(Entitlement ent : newRecords) {
            String description = string.IsBlank(ent.Product_Description__c) ? '' : '-' + ent.Product_Description__c;
            String entName = string.IsBlank(ent.Hardware_Serial_Number__c) ? ent.PAK_ID__c  +  description : ent.Hardware_Serial_Number__c + description;
            if(entName.left(80) != ent.Name)
                ent.Name = entName.left(80);
        }
    }
    
    /*
*   This method is invoked by the Entitlement Trigger
*   It is invoked/fired based on the After insert/update trigger event on the Entitlement
*   Following criteria is used to determine what entitlements will be processed for permission set removal
*   -   Only work on active record types of account NPN Account Registry or New Customer Account?
*   -   If an update, only apply product family changed and is the right status.
*   If any of the above is true, then we will look for associated announcements and construct 
*   CustomerAnnouncements based on them 
*/    
    public static void AddAnnouncement(Map<Id,Entitlement> triggerOldMap, List<Entitlement> triggerNewList){
        List<Entitlement> listToAdd = new List<Entitlement>();
        Id npnAccountRegistryRTId = null;
        Id newCustomerAccountRTId = null;
        // we only add to npn and new accounts
        Schema.RecordTypeInfo npnAccount = Schema.SObjectType.Account.RecordTypeInfosByName.get('NPN Account Registry');
        Schema.RecordTypeInfo newCustomer = Schema.SObjectType.Account.RecordTypeInfosByName.get('New Customer Account');
        
        if (npnAccount != null) {
            npnAccountRegistryRTId = npnAccount.RecordTypeId;
        }
        if (newCustomer != null) {
            newCustomerAccountRTId = newCustomer.RecordTypeId;
        }        
        //Changes Part of Version 1.1
        //Get Account Recordtype for related accounts in trigger.New
        List<Id> accountIdList = new List<Id>();
        for(Entitlement entitlelist:triggerNewList){
            accountIdList.add(entitlelist.AccountId);
        }
        
        //system.debug('123450 accountIdList: '+ accountIdList);
        Map<Id,Account> acctRecordIdMap = new Map<Id,Account>([Select Id,RecordTypeId From Account where Id IN :accountIdList]);
        
        for(Entitlement entList : triggerNewList){
            if(((acctRecordIdMap.get(entList.AccountId)).RecordTypeId == npnAccountRegistryRTId ||
                (acctRecordIdMap.get(entList.AccountId)).RecordTypeId == newCustomerAccountRTId) && 
               entList.Status == 'Active') {
                   //system.debug('123451 Inside for loop: ');
                   // for insert we want any active entitlements with the right account record types
                   if (trigger.isAfter && trigger.isInsert){
                       listToAdd.add(entList);
                       //system.debug('123452 Insert: ');
                   } else if(trigger.isAfter && trigger.isUpdate)
                   {
                       //system.debug('123452 Update: ');
                       
                       String oldStatus = triggerOldMap.get(entList.Id).Status;
                       String oldProduct = triggerOldMap.get(entList.Id).Product__c;
                       
                       // for update, we only want different product or status change to active
                       if ((!String.isBlank(oldProduct) && oldProduct != entList.Product__c) ||
                           (oldStatus == 'Removed' || oldStatus == 'Inactive' || oldStatus == 'Expired')) { 
                               //system.debug('123452 Update2: ');
                               listToAdd.add(entList);
                           }
                   }
               }
        }
        
        //system.debug('123453 Entitlements to process: '+ listToAdd);
        if(!listToAdd.isEmpty()){
            List<CustomerAnnouncement__c> toAdd = getAnnoucementsToAddByAccount(listToAdd);
            System.debug('Customer Announcements to create:');
            String debugBeforeInsert = '';
            for (CustomerAnnouncement__c ca : toAdd) debugBeforeInsert += '\n' + ca;
            System.debug(debugBeforeInsert);        
            insert toAdd;
        }
    }    
    
    /*
*   This method is invoked by the Entitlement Trigger via AddAnnouncement()
*   It takes in a list of entitlements and searches for the corresponding announcements to each
*   product on the entitlement.  It then constructs a customer announcement object based on the
*   account and announcement.  It returns a list of these customer announcements.
*/ 
    /**
* Changes on 29-June-2018
* Added logic to check for duplicate customer announcement creation
* */    
    public static List<CustomerAnnouncement__c> getAnnoucementsToAddByAccount(List<Entitlement> toCheck) {
        List<CustomerAnnouncement__c> toReturn = new List<CustomerAnnouncement__c>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<String> productToAccount =new Set<String>();
        Map<Id,List<Id>> productToAnnouncementMap = new Map<Id,List<Id>>();
        Set<Id> CustAnnouncementSet = new Set<Id>();
        String accProdId;
        
        for(Entitlement enti : toCheck)
        {
            if(enti.Product__c != null && enti.AccountId != null){
                accountIds.add(enti.AccountId);
                productIds.add(enti.Product__c);
                accProdId=enti.Product__c+'-'+enti.AccountId;
                //Set of ProductId-AccountId; used to get announcement and create customer announcements 
                productToAccount.add(accProdId);
            }
        }
        //system.debug('123454 Product-Account KeyList: '+ accProdId);
        for(CustomerAnnouncement__c custAnnounce:[Select Id, Account__c,Announcement__c,Announcement__r.Product__c 
                                                  From CustomerAnnouncement__c Where Account__c IN :accountIds 
                                                  AND Announcement__r.Product__c IN:productIds])
        {
            // set of Existing Customer Announcement for that account
            // Used to check if there are any customer annoucements already created
            CustAnnouncementSet.add(custAnnounce.Announcement__c);
        }
        
        //system.debug('123455 Customer Announcements: '+ CustAnnouncementSet);
        for(Announcement__c listAnnouncement : [SELECT Id, Access_Level__c, Product__c 
                                                FROM Announcement__c WHERE Access_Level__c != 'Archived' 
                                                AND Product__c IN : productIds])
        {
            //Map of Product Id as key and List of Accountment id as value built based on annoucement for the list of products
            //and access level is not Archived
            //Used to get Accountment Id for that Product
            
            if(productToAnnouncementMap.containsKey(listAnnouncement.Product__c)) {
                List<Id> announceId = productToAnnouncementMap.get(listAnnouncement.Product__c);
                announceId.add(listAnnouncement.Id);
                productToAnnouncementMap.put(listAnnouncement.Product__c, announceId);
            } else {
                productToAnnouncementMap.put(listAnnouncement.Product__c, new List<Id> { listAnnouncement.Id });
            }
        }
        
        for(String prodToAcckey : productToAccount)
        {
            //system.debug('123457 product-Account key: '+ prodToAcckey);
            // validate if customer annoucement is already created
            if(!productToAnnouncementMap.isEmpty() && productToAnnouncementMap.containsKey((Id)prodToAcckey.substringBefore('-'))){
                //system.debug('123458 found key in map: ');
                For(Id announcementId:productToAnnouncementMap.get(prodToAcckey.substringBefore('-'))){
                    //system.debug('123459 announcementId: '+ announcementId);
                    if(!CustAnnouncementSet.contains(announcementId)){
                        //system.debug('1234510 : '+ announcementId);
                        CustomerAnnouncement__c toAdd = new CustomerAnnouncement__c();
                        toAdd.Account__c = prodToAcckey.substringAfter('-');
                        toAdd.Announcement__c = announcementId;
                        toReturn.add(toAdd);
                    }
                }
            }
        }
        return toReturn;
    }
    
@auraenabled
    public static string ESPContactNVIDIARenewalsButton(string strSubject, string strDescription){
        List<User> lstUser = [select name,Account.name,AccountId,ContactId,contact.name,email from User where id= :UserInfo.getUserId()];
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        List<string> lstEmailIds = new List<string>();
        //lstEmailIds.add('gbrar@nvidia.com');
        lstEmailIds.add(label.Service_Cloud_ESP_Entitlement_Renewal_Team_email);
        message.setToAddresses(lstEmailIds);
        message.subject = '[' + lstUser.get(0).name + '] [Account- ' + lstUser.get(0).Account.name + '][' + strSubject + ']';
        message.plainTextBody = 'Account Name : ' + lstUser.get(0).Account.name +'\n' + 'Account Link : ' + URL.getSalesforceBaseUrl().toExternalForm() + '\\' + lstUser.get(0).AccountId + '\n Contact Name : ' + lstUser.get(0).contact.name + '\n Contact Link : ' + URL.getSalesforceBaseUrl().toExternalForm() +'\\'+ lstUser.get(0).ContactId + '\n Description : ' + strDescription;
        Messaging.SingleEmailMessage[] messages = 
        new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
            return 'Success';
        } else {
            System.debug('The email failed to send: '
                  + results[0].errors[0].message);
            return 'Failed';      
        }
        
    } 
       
// SDS-2432 Added method
@InvocableMethod
    public static void checkSupportPortalRegistration(List<Entitlement> lstCurrentEntitlement){
        List<Contact> lstContact = [select id from Contact where Community_User_Type__c = 'ESP' and Community_User_Active__c=true and AccountId=:lstCurrentEntitlement.get(0).AccountId];
        if(lstContact.isEmpty()){
             List<Entitlement> lstEnt = [select Customer_Contact__c from Entitlement where AccountId = :lstCurrentEntitlement.get(0).accountId];
             if(!lstEnt.isEmpty()){
                 List<Id> lstContactIds = new List<Id>();
                EmailTemplate templateId = [Select DeveloperName,Id,subject from EmailTemplate where DeveloperName= 'Service_Cloud_Community_Registration_Reminder_to_Customer' limit 1];
                OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where Address='no_reply@nvidia.com' limit 1];
                List<Messaging.SingleEmailMessage> lstMessages= new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail ;
                List<string> lstToAddresses = new List<string>();
                for(Entitlement tmp : lstEnt){
                     if(tmp.Customer_Contact__c !=null){                         
                         mail = new Messaging.SingleEmailMessage();
                         mail.setOrgWideEmailAddressId(owa.id);
                         mail.setTemplateID(templateId.Id); 
                         mail.setTargetObjectId(tmp.Customer_Contact__c);
                         mail.setSaveAsActivity(false);
                         mail.setTreatTargetObjectAsRecipient(true);
                         mail.setWhatId(tmp.Id);
                        //mail.setSubject(templateId.subject);
                         lstMessages.add(mail); 
                     }                   
                 }
                if(!lstMessages.isEmpty()){          
                     Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMessages,false);
                    if (results[0].success) {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send: '
                              + results[0].errors[0].message);
                    }                    
                }
             }
        }
    }    
}