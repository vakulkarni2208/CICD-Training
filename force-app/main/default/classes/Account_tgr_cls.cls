/*
    Apex Class for Account_tgr.trigger
    Changelist:
    2018.08.09 - PJENA          - SDS-757 - Move Account/Contact Region, Sub-Region, Territory setup from Future method to direct synchronous process
    2018.12.04 - Akhilesh Gupta - SDS-1037: Update Entitlement Process on Entitlements.
    2020.02.01 - Akhilesh Gupta - SDS-1944: Added function updateCases.
                                - Use common TriggerHandler 
    2020.02.20 - Akhilesh Gupta - SDS-1039 - Added "managePlaceholderEntitlements" to create PlaceholderEntitlements 
    2020.02.26 - Akhilesh Gupta - SDS-2064 - Updated "UpdateEntitlement" function to use support level from Product 
                                - User new Constants framework, use ESP_Utility functions instead of ServiceCloudUtils.
    2020.02.01 - Akhilesh Gupta - SDS-2055: Update function updateCases.
    2020.08.28 - Extending SAP Integration
    2021.02.15 - Akhilesh Gupta - SDS-2901: Updated logic for 24x7 Business Critical.
									Updated Function: updateEntiltments
									- Remove logic to update all Entitlements from Account Trigger and only kept logic for Placeholder Entitlement.
									Introduced new static variable "UPDATE_ALL_ENTITLEMENTS" to bypass PEC logic.
									
*/

public class Account_tgr_cls extends NV_TriggerHandler {
    public static final string CONST_BEFOREINSERT  = 'beforeinsert';
    public static final string CONST_SAPR3ACCOUNTS = 'SAP R3';
    public static final string CONST_ERROR_MESSAGE = 'Customers cannot be inserted from SAP R3. Please add the Customer through SFDC UI with SAP Customer Number';
    public static boolean skipCaseUpdate = false;
    
    public list<Account> oldRecords;
    private static list<Account> newRecords;
    private static map<Id, Account> oldRecordsMap;
    public override void init() { 
        OBJECT_NAME = 'Account';
        oldRecords = trigger.old;
        newRecords = trigger.New;
        if(oldRecords != null)
            oldRecordsMap = new map<Id, Account>(oldRecords);
        System.debug('Old Records' + oldRecords + '1');
        System.debug('New Records' + trigger.New + '1'); 
    }
    public override void beforeInsert() {
        Account_tgr_cls.Account_tgr_cls1(newRecords, Account_tgr_cls.CONST_BEFOREINSERT);
        Account_tgr_cls.setAccountRegionSubRegionTerritory(newRecords);
    }
    public override void beforeUpdate() {
        Account_tgr_cls.setAccountRegionSubRegionTerritory(newRecords);
    }
    public override void afterInsert() {
        NVService.isValidPECAccountService(newRecords);
    }
    
    public override void afterUpdate() {
        if(Account_tgr_cls.UPDATE_ALL_ENTITLEMENTS == FALSE) {
            NVService.isValidPECAccountService(newRecords);
            NVService.isValidPartnerAccountService(newRecords);
        }
        //Account_tgr_cls.managePlaceholderEntitlements(); //SDS-2901: Moved code to Entitlement Trigger.
        Account_tgr_cls.updateEntiltments();
        
        //SDS-2055: Populate TAM and RTAM for all Open Cases.
        if(!Account_tgr_cls.skipCaseUpdate) {
           Account_tgr_cls.updateCases();
           Account_tgr_cls.skipCaseUpdate = true;
        }
    }
    
    //Check - Customers cannot be inserted from SAP R3
    public static void Account_tgr_cls1(list<Account> newAccountsList, string triggerType) {
        if (triggerType == CONST_BEFOREINSERT){
             for (Account newAcc: newAccountsList){
                if (newAcc.AccountSource == CONST_SAPR3ACCOUNTS && newAcc.SAP_Customer_Number__c != null){
                    newAcc.addError(CONST_ERROR_MESSAGE);
                }
            }
        }
    }//End: Check - Customers cannot be inserted from SAP R3
    
    //Date: 2015.09.02
    //Set Account Billig and Shipping Region, Sub-Region and Territory fields in Before Insert and Before Update triggers
    //2018.08.09 - PJENA - SDS-757 - Move Account/Contact Region, Sub-Region, Territory setup from Future method to direct synchronous process
    public static void setAccountRegionSubRegionTerritory(list<Account> newAccountsInTgr){
        set<string> setAllCountryNamesInAccountTgr = new set<string>();
        
        for (Account acc : newAccountsInTgr){
            setAllCountryNamesInAccountTgr.add(acc.BillingCountryCode);
            setAllCountryNamesInAccountTgr.add(acc.BillingCountry);
            setAllCountryNamesInAccountTgr.add(acc.ShippingCountryCode);
            setAllCountryNamesInAccountTgr.add(acc.ShippingCountry);
        }
        
        //query the Region, Sub-Region and Territory details for the Countries in the Triggered Account and create a map
        //-----------------------------------------------------------------------------------------------------------------
        List<Country_List__c> lstCountryList = [Select name, ISO_Code__c, Region__c, Sub_Region__c, Territory__c 
                                                From Country_List__c 
                                                Where ISO_Code__c = :setAllCountryNamesInAccountTgr
                                                    Or Name = :setAllCountryNamesInAccountTgr];
            
        //creat a map of Country and its details from the Country List
        map<string, Country_List__c> mapCountryList = new map<string, Country_List__c>();
        for(Country_List__c countryListRec : lstCountryList){
            if(mapCountryList.get(countryListRec.name) == null){
                mapCountryList.put(countryListRec.name, countryListRec);
            }
            if(mapCountryList.get(countryListRec.ISO_Code__c) == null){
                mapCountryList.put(countryListRec.ISO_Code__c, countryListRec);
            }
        }
        system.debug('***mapCountryList: ' + mapCountryList);
        //-----------------------------------------------------------------------------------------------------------------
        //Assign the Region, Sub-Region, Territory
        
        //Set Region/Sub-Region/Territory
        //-----------------------------------------------------------------------------------------------------------------
        for (Account accInTgr : newAccountsInTgr){
            
            if (accInTgr.BillingCountryCode != null && mapCountryList.get(accInTgr.BillingCountryCode) != null){
                accInTgr.Billing_Region__c = mapCountryList.get(accInTgr.BillingCountryCode).Region__c;
                accInTgr.Billing_Sub_Region__c = mapCountryList.get(accInTgr.BillingCountryCode).Sub_Region__c;
                accInTgr.Billing_Territory__c  = mapCountryList.get(accInTgr.BillingCountryCode).Territory__c;
            }else if (accInTgr.BillingCountry != null && mapCountryList.get(accInTgr.BillingCountry) != null){
                accInTgr.Billing_Region__c = mapCountryList.get(accInTgr.BillingCountry).Region__c;
                accInTgr.Billing_Sub_Region__c = mapCountryList.get(accInTgr.BillingCountry).Sub_Region__c;
                accInTgr.Billing_Territory__c  = mapCountryList.get(accInTgr.BillingCountry).Territory__c;
            }else{
                accInTgr.Billing_Region__c = '';
                accInTgr.Billing_Sub_Region__c = '';
                accInTgr.Billing_Territory__c  = '';
            }
                
            if (accInTgr.ShippingCountryCode != null && mapCountryList.get(accInTgr.ShippingCountryCode) != null){
                accInTgr.Shipping_Region__c = mapCountryList.get(accInTgr.ShippingCountryCode).Region__c;
                accInTgr.Shipping_Sub_Region__c = mapCountryList.get(accInTgr.ShippingCountryCode).Sub_Region__c;
                accInTgr.Shipping_Territory__c  = mapCountryList.get(accInTgr.ShippingCountryCode).Territory__c;
            }else if (accInTgr.ShippingCountry != null && mapCountryList.get(accInTgr.ShippingCountry) != null){
                accInTgr.Shipping_Region__c = mapCountryList.get(accInTgr.ShippingCountry).Region__c;
                accInTgr.Shipping_Sub_Region__c = mapCountryList.get(accInTgr.ShippingCountry).Sub_Region__c;
                accInTgr.Shipping_Territory__c  = mapCountryList.get(accInTgr.ShippingCountry).Territory__c;
            }else{
                accInTgr.Shipping_Region__c = '';
                accInTgr.Shipping_Region__c = '';
                accInTgr.Shipping_Region__c  = '';
            }
        }
        //Set Region/Sub-Region/Territory
        //----------------------------------------------------------------------------------------------------------------- 
    
    }
    //End: Set Account Billig and Shipping Region, Sub-Region and Territory fields in Before Insert and Before Update triggers
    
    /* 
        12/4/2018: Akhilesh Gupta: This method is responsible to set Entitlement Process on Entitlements.
    */
    public static boolean UPDATE_ALL_ENTITLEMENTS = FALSE;
    public static void updateEntiltments(){
        system.debug('InsideUpdateEntitlement');        
        map<Id, Account> accMapToUpdate = new map<Id, Account>(); 
        for(Account accNew : newRecords) {
            if(accNew.Support_Level__c != oldRecordsMap.get(accNew.Id).Support_Level__c){// || UPDATE_ALL_ENTITLEMENTS){
                accMapToUpdate.put(accNew.Id, accNew);
            }
        }
        system.debug('AccountToUpdate: '+ accMapToUpdate);
        if(accMapToUpdate.isEmpty()) 
            return;
        
        SLA_Settings__mdt slaSetting = ESP_Utility.getSLASetting(ESP_Utility.ESPConstants.SLA_24X7SUPPORT);
        list<SlaProcess> EntProcessList;
        if(slaSetting != NULL)
            EntProcessList = [SELECT Id, Name FROM SlaProcess WHERE name =: slaSetting.Entitlement_Process_Name__c];
        Id slaProcessId = (EntProcessList.isEmpty()) ? NULL : EntProcessList[0].Id;
        
        //This function is responsible to update All the Entitlements with correct SLA Process.
        //Account_tgr_cls.setEntitlementProcessForAllEntitlements(accMapToUpdate.keySet(), slaProcessId);
        
        //This function is responsible to create/delete Placeholder Entitlements.
        Account_tgr_cls.managePlaceholderEntitlements(accMapToUpdate.keySet(), slaProcessId);
    }
    
    public static void managePlaceholderEntitlements(set<Id> accIdsToUpdate, Id slaProcessId) {
        
        system.debug('2192020 serviceCloudSetting: '+ ESP_Utility.ESPConstants.ServiceCloudSettings);
        
        list<Account> accountsToProcess = [select Id, Support_Level__c,
                                            (select Id,Name, SlaProcessId from Entitlements 
                                                where Name =: ESP_Utility.ESPConstants.ServiceCloudSettings.Placeholder_Entitlement_Name__c
                                            ) from Account where Id IN :accIdsToUpdate];
        system.debug('2192020 accountsToProcess: '+ accountsToProcess);
        system.debug('2192020 slaProcessId: '+ slaProcessId);
        
        //set<Id> accIdsForDelEntitlements = new set<Id>();
        list<Entitlement> placeHolderEntitlements = new list<Entitlement>();
        for(Account acc : accountsToProcess) {
            list<Entitlement> entList = acc.Entitlements;
            system.debug('2192020 acc.Support_Level__c: '+ acc.Support_Level__c);
            
            if (entList.isEmpty()){
                if(acc.Support_Level__c == ESP_Utility.ESPConstants.SLA_24X7SUPPORT) {
                    if(ESP_Utility.ESPConstants.ServiceCloudSettings != NULL) {
                        Entitlement ent = new Entitlement();
                        ent.Name        = ESP_Utility.ESPConstants.ServiceCloudSettings.Placeholder_Entitlement_Name__c;
                        ent.AccountId   = acc.Id;
                        ent.SlaProcessId= slaProcessId;
                        ent.PAK_ID__c   = ESP_Utility.ESPConstants.ServiceCloudSettings.Placeholder_Entitlement_Name__c;
                        //ent.Hardware_Serial_Number__c = ESP_Utility.ESPConstants.ServiceCloudSettings.Placeholder_Entitlement_Name__c;
                        placeHolderEntitlements.add(ent);
                    }
                    //placeHolderEntitlements.add(getPlaceholderEntitlement(acc));
                } //else {
                    //accIdsForDelEntitlements.add(acc.Id);
                //}
            } else {
                system.debug('2192020 entList: '+ entList);
                for (Entitlement existingEnt : entList){
                    if(acc.Support_Level__c == ESP_Utility.ESPConstants.SLA_24X7SUPPORT) {
                        existingEnt.SlaProcessId = slaProcessId;
                    } else {
                        existingEnt.SlaProcessId = NULL;
                    }
                    placeHolderEntitlements.add(existingEnt);
                }
            }
        }
        
        system.debug('2192020 placeHolderEntitlements: '+ placeHolderEntitlements);
        if(!placeHolderEntitlements.isEmpty()) {
            TriggerEntitlementHelper.DISABLE_TRIGGER = TRUE;
            upsert placeHolderEntitlements;
            TriggerEntitlementHelper.DISABLE_TRIGGER = FALSE;
        }
    }
    
    /*public static void getPlaceholderEntitlement(Account acc, Entitlement ent){
        //SLA_Settings__mdt slaSetting = ServiceCloudUtils.getSLASetting(acc.Support_Level__c);
        //list<SlaProcess> EntProcessList;
        //if(slaSetting != NULL)
        //   EntProcessList = [SELECT Id, Name FROM SlaProcess WHERE name =: slaSetting.Entitlement_Process_Name__c];
                
        if(ESP_Utility.ESPConstants.ServiceCloudSettings != NULL) {
            ent.Name = ESP_Utility.ESPConstants.ServiceCloudSettings.Placeholder_Entitlement_Name__c;
            ent.AccountId = accountId;
        }
        return ent;
    } */
    
    /* 
        01/20/2020: Akhilesh Gupta: This method is responsible to update Cases with TAM information.
    */
    public static void updateCases(){
        system.debug('InsideUpdateEntitlement');
        map<Id,Account> accMapToUpdate = new map<Id, Account>(); 
        for(Account accNew : newRecords) {
            if(accNew.Technical_Account_Manager_TAM__c != oldRecordsMap.get(accNew.Id).Technical_Account_Manager_TAM__c
                || accNew.Regional_TAM__c != oldRecordsMap.get(accNew.Id).Regional_TAM__c
            ){
                accMapToUpdate.put(accNew.Id, accNew);
            }
        }
        system.debug('AccountToUpdte: '+ accMapToUpdate);
        if(accMapToUpdate.isEmpty()) 
            return;
        map<Id,Case> caseMapToUpdate = new map<Id, Case>(
                                                    [SELECT Id, AccountId, Account_Manager__c, Regional_TAM__c 
                                                            FROM Case 
                                                            WHERE AccountId IN :accMapToUpdate.keySet()
                                                                    and isClosed = false and Owner.Name != 'ESP : Invalid Case Queue']
                                                );
        
        //SLA_Settings__mdt slaSetting = ServiceCloudUtils.getSLASetting(ServiceCloudUtils.CONST_24X7SUPPORT);
        //list<SlaProcess> EntProcessList;
        //if(slaSetting != NULL)
        //    EntProcessList = [SELECT Id, Name FROM SlaProcess WHERE name =: slaSetting.Entitlement_Process_Name__c];
        
        if(caseMapToUpdate.isEmpty())
            return;
        
        //Id slaProcessId = (EntProcessList.isEmpty()) ? NULL : EntProcessList[0].Id;
        system.debug('caseMapToUpdate: '+ caseMapToUpdate);
        //system.debug('slaProcessId: '+ slaProcessId);
        list<Case> caseListToUpdate = new list<Case>();
        for(Case c: caseMapToUpdate.values()) {
            Account acc = accMapToUpdate.get(c.AccountId);
            boolean bUpdate = false;
            if(c.Account_Manager__c == NULL && c.Account_Manager__c != acc.Technical_Account_Manager_TAM__c) {
                c.Account_Manager__c = acc.Technical_Account_Manager_TAM__c;
                bUpdate = true;
            }
            if(c.Regional_TAM__c == NULL && c.Regional_TAM__c != acc.Regional_TAM__c) {
                c.Regional_TAM__c = acc.Regional_TAM__c;
                bUpdate = true;
            }
            
            if(bUpdate)
                caseListToUpdate.add(c);
            /*if(caseMapToUpdate.get(Ent.AccountId).Support_Level__c == ServiceCloudUtils.CONST_24X7SUPPORT 
                && Ent.SlaProcessId != slaProcessId)
            {
                Ent.SlaProcessId = slaProcessId;
                entListToUpdate.add(Ent);
            } else if((accMapToUpdate.get(Ent.AccountId).Support_Level__c == NULL 
                        || accMapToUpdate.get(Ent.AccountId).Support_Level__c == '') 
                    && Ent.SlaProcessId != NULL) 
            {
                Ent.SlaProcessId = NULL;
                entListToUpdate.add(Ent);
            }*/
        }
        
        if(!caseListToUpdate.isEmpty()) {
            //update caseListToUpdate;
            //system.debug('Cases to Update'
            //Savepoint sp = Database.setSavepoint();
            Database.SaveResult [] updateResult = Database.update(caseListToUpdate, false);
            boolean bError = false;
            String recordIds = '';
            String errMessages = '';
            Integer icount = 0;
            for (Database.SaveResult r : updateResult) {
                //system.debug()
                if (!r.isSuccess()) {
                    bError = true;
                    for (Database.Error e : r.getErrors()) {
                        errMessages += e.getMessage() + ';'; 
                    }
                    recordIds += caseListToUpdate[icount].Id;//r.getId() + ';';
                }
                //recordIds += r.getId() + ';';
                icount++;
            }
            //Database.rollback(sp);
            if(bError) {
                //Database.rollback(sp);
                NV_Log__c nvlog = new NV_Log__c(Component_Name__c   = 'Account_tgr_cls',Error_Description__c    = ''+errMessages,
                                                Functionality_Name__c   = 'TAM Update on Account',
                                                Log_Type__c         = 'Error: Trigger',             Method_Name__c          = 'updateCases',
                                                Record_ID__c        = ''+recordIds,     Status__c               = 'Error'
                                    );
                insert nvlog;
            }
        }
    }
}