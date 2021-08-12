/**************************************************************************************************
* Name       : TriggerRMAHelper
* Purpose    : Helper class for TriggerRMA Trigger 
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 11/15/2017      | Initial Draft
*Perficient         | 1.0        | 1/15/2017       | Final Draft
*Perficient         | 2.0        | 2/19/2017       | As Elsie requests, only update subscription 
*                                                    when SN matched and also check a flag in Part objct.
*AkhileshGupta      | 3.0        | 8/03/2018       | Changes to Support SDMR Process: Multiple Subscription may exist for same Serial Number
                                                   | Code optimization
                                                   | Consider Saturn V process : Entitlments can exist without Subscription.
* Nilesh Adkar      | 3.1        | 08/02/2019      | SDS-1574 Send RMA tracking notification to Additional Recipients
                                                     Added sendEmail() and emailAdditionalAddressesTrackingNumberPopulated() methods  
* Akhilesh Gupta    ! 4.0        | 12/10/2019      | Updated code to implement Trigger Handler
                                                   | Add Logic to update MRS Entitlements
* Akhilesh Gupta    ! 4.0        | 01/20/2020      | SDS-1712: Updated logic to update Subscriptions without having link with Entitlements.
                                                   | Code Improvement areas: separate method for Subscription/Entitlement update, Populate AccountId on RMA, Remove comments, Part query in nv_utility class, NV_Log instead of Service_Cloud_Error_log                                                    
* Nilesh Adkar      | 4.1        | 06/10/2020      | Epic SDS-1686 CE Dispatch flow -> SDS-2230, SDS-2119, SDS-2231, SDS-2232, SDS-2233, SDS-2234 CE Dispatch
**************************************************************************************************/
public class TriggerRMAHelper extends NV_TriggerHandler {
    public list<RMA__c> oldRecords;
    private static list<RMA__c> newRecords;
    private static map<Id, RMA__c> oldRecordsMap;
    public override void init() { 
        OBJECT_NAME = 'RMA__c';
        oldRecords = trigger.old;
        newRecords = trigger.New;
        if(oldRecords != null)
            oldRecordsMap = new map<Id, RMA__c>(oldRecords);
        System.debug('Old Records' + oldRecords + '1');
        System.debug('New Records' + trigger.New + '1'); 
    }
    
    public override void afterInsert() {
        TriggerRMAHelper.updateCaseStatusNew();//newRecords);
    }
    public override void afterUpdate() {
        TriggerRMAHelper.updateOnFullSystemRMA();//newRecords, oldRecordsMap);
        TriggerRMAHelper.updateCaseStatus();//newRecords,oldRecordsMap);
        TriggerRMAHelper.sendEmail();//newRecords,oldRecordsMap); // SDS-1574
        createFANVBug();
    }
   
   /* THIS CODE IS COMMENTED TO USE NEW TRIGGER PATTERN AND TRIGGER HANDLER.
    *   This method is invoked/fired on After update trigger event on the RMA__c object
    *   It is responsible for the following 
    *   - Update of corresponding subscription, entitlement (Name), custom entitlement records
    *   - Update of Case incident status referred to on the RMA record
    *
    
    public static void AfterUpdate(List<RMA__c> oldRMA, Map<Id,RMA__c> oldMap,List<RMA__c> newRMA, Map<Id,RMA__c> newMap){
        updateSubscritption(oldMap, newMap);
        updateCaseStatus(newRMA,oldMap);
        sendEmail(newRMA,oldMap); // SDS-1574
    }*/
   /*
    *   This method is invoked/fired on After update trigger event on the RMA__c object
    *   
    *   Purpose of this method is to update the following for the eligible updated RMA records
    *   - Subscription records (SBQQ__Subscription__c)
    *       For Hardware_Serial_Number__c (Updated to RMA Replacement Serial Number)
    *   - Standard Entitlement records (Entitlement)
    *       For Name (updated to a string concatenation of RMA Replacement Serial Number and the product description)    
    *   - Custom Entitlement records (Entitlement__c)
    *       For Name (updated to a string concatenation of RMA Replacement Serial Number and the product description)
    *
    *   The following RMA records are eligible for further processing i.e subscription and entitlement name updates
    *       - Either the Replace Serial Number on the RMA record has changed
    *       - Or the Re-ship Part Number on the RMA record has changed
    *       Additional Criteria for processing
    *       - There must be a valid subscription on the entitlement associated with the input RMA record
    *       - The re-ship part number on the RMA is expected to be a full system part number (refer to Part_c custom record)
    *   
    *   Order of processing is as follows:
    *   Step 1 - Identify if the replacement serial number or the part number on the RMA has changed
    *   Step 2 - Collect the corresponding entitlement identifier (record id) found on the RMA record, into a List container
    *   Step 3 - Retrieve the Re-ship part numbers from the RMA records 
    *            and validate in a separate Collection if the Re-ship part numbers are flagged 
    *            as full system (check for full system flag on the corresponding Part Number record)
    *   Step 4 - For each RMA record, if criteria is met as explained above
    *           a) Update the subscription record for Hardware Serial number
    *           b) Update the corresponding standard Entitlement record as found on the RMA record, for Name attribute 
    *              using the RMA Replacement Serial Number
    *           c) Update the custom Entitlement record as well, for Name attribute using the RMA Replacement Serial Number
    * 08/03/2018: Code optimization by filtering records and checking wherever query/records processing can be avoided.
    */
    public static void updateOnFullSystemRMA(){//list<RMA__c> newMap, map<Id, RMA__c> oldMap){
        //Set<Id> EntitlementIds        = new Set<Id>();
        Set<String> partNumberSet       = new Set<String>();
        Set<String> SNsToUpdate         = new Set<String>();
        list<Entitlement> lstEntitlement= new list<Entitlement>();
        list<RMA__c> RMAtoProcess       = new list<RMA__c>();
        set<string> replacementSNset            = new Set<String>(); //SDS-2456
        //String SNsString = '';
        system.debug('Old map: 12345 '+ oldRecordsMap);
        system.debug('New RMA List: 12345 '+ newRecords);
        //SELECT AssetId,FromDate,Id,RelatedAssetId,RelationshipType FROM AssetRelationship
        //map<String, AssetRelationship> assetRelationshipMapBySN = new map<String, AssetRelationship>();
        //Identify the RMA's which needs SN# update at Subscription
        for(RMA__c newRMA : newRecords) {
            RMA__c oldRMA = oldRecordsMap.get(newRMA.Id);
            if((oldRMA.Replacement_Serial_Number__c != newRMA.Replacement_Serial_Number__c 
                    //|| oldRMA.Reship_Part_Number__c != newRMA.Reship_Part_Number__c
                )
                && String.isNotBlank(newRMA.Replacement_Serial_Number__c)
                && String.isNotBlank(newRMA.Reship_Part_Number__c)
                && String.isNotBlank(newRMA.Entitlement__c)
            ) {
                //EntitlementIds.add(newRMA.Entitlement__c);
                //Collect Current Serial Numbers to find Subscription/Entitlements
                if(String.isNotBlank(newRMA.Serial_Number__c)){
                    SNsToUpdate.add(newRMA.Serial_Number__c);
                    //SNsString = SNsString + ' \'' + newRMA.Serial_Number__c +'\'' + ',' ; //SDS-2456
                    //assetRelationshipMapBySN.put(newRMA.Serial_Number__c, new AssetRelationship()); //SDS-2456
                }
                
                //Collect PartNumbers to query Part table
                if(String.isNotBlank(newRMA.Reship_Part_Number__c))
                    partNumberSet.add(newRMA.Reship_Part_Number__c);
                    
                replacementSNset.add(newRMA.Replacement_Serial_Number__c); //SDS-2456
                //SNsString = SNsString + ' \'' +newRMA.Replacement_Serial_Number__c +'\'' + ',' ;
                RMAtoProcess.add(newRMA);
            }
            //System.debug('SNsString 111 ===' + SNsString);
            /*if(SNsString != null)
            SNsString = SNsString.subString(0,SNsString.length() - 1);*/
        }
        system.debug('SNsToUpdate: 12345 '+ SNsToUpdate);
        system.debug('partNumberSet: 12345 '+ partNumberSet);
        
        if(SNsToUpdate.isEmpty() || partNumberSet.isEmpty())
            return;
        
        //Set to store part records of type Full System Only
        Set<String> fsPartNumberSet = new Set<String>();
        if(!partNumberSet.isEmpty()){
            for(Part__c p : [SELECT Part_Number__c FROM Part__c WHERE Part_Number__c IN: partNumberSet AND Full_System__c = true]) {
                fsPartNumberSet.add(p.Part_Number__c);
            }
        }
        
        //Find all the Entitlements matching with Hardware Serial Numbers
        list<Entitlement__c> allEntitlements = [SELECT Id, Name, Entitlement__c
                                                , Entitlement__r.Id, Entitlement__r.AccountId, Entitlement__r.Name, Entitlement__r.Product_Description__c, Entitlement__r.Hardware_Serial_Number__c
                                                , Entitlement__r.Subscription__c, Entitlement__r.Subscription__r.Hardware_Serial_Number__c 
                                                FROM Entitlement__c 
                                                WHERE Entitlement__r.Hardware_Serial_Number__c IN :SNsToUpdate
                                            ];
        //SDS-2456
        //Find Assets matching with SN
        list<Asset> assetList = [SELECT Id, Name, AccountId, Product2Id,  Status, PAKID__c, 
                                     Quantity,SAP_Order__c, Product_Line__c,ProductDescription,
                                     ProductCode, ProductFamily, Material_Number__c,  InstallDate, Serial_Number__c, 
                                     ContactId, Street_1__c, Street_2__c, State__c, Country__c, Postal_Code__c, City__c,
                                     Hostname__c, Local_FSL_not_available__c, Description, Status_Notes__c, SAP_Account_Number__c, 
                                     SAP_Delivery_Number__c, VAR_SAP_Number__c, Sold_To_Partner_SAP_Number__c, SAP_PECC_Number__c, 
                                     PurchaseDate, VAR__c, Sold_To_Partner__c, Link_Entitlements__c,Link_Components__c,Asset_Processing_Status__c,
                                     Installation_Address_1__c, Installation_Address_2__c, Installation_City_Province__c, Installation_State__c, 
                                     Installation_Country__c, Installation_Zip_Postal_Code__c//,External_System_ID__c, Refurbished__c
                                 FROM Asset 
                                 WHERE Serial_Number__c IN :SNsToUpdate OR Serial_Number__c IN :replacementSNset
                                ];
        //In ('SN1', 'SN2')
        //list<Asset> assetList = (List<Asset>) PRFT_DomainLayer.queryObj('Asset','WHERE Serial_Number__c IN (' +  SNsString + ')');// OR Serial_Number__c IN : ' + replacementSNset);
        //list<Asset> asstList = (List<Asset>) queryObj('Asset','WHERE Id ='+'\''+assetId+'\'');
        System.debug('assetList = ' + assetList);
        
        //SDS-1712:
        //Query Subscriptions matching with HSNo
        list<SBQQ__Subscription__c> allSubscriptions = [SELECT Id, Name, Hardware_Serial_Number__c, SBQQ__Account__c 
                                                            FROM SBQQ__Subscription__c 
                                                            WHERE Hardware_Serial_Number__c IN :SNsToUpdate
                                                        ];
        
        //Old Query backup
        //Map<Id,Entitlement> entitlementMap = new Map<Id,Entitlement>()
        //    ([SELECT Id,Name,Product_Description__c,Subscription__c,Subscription__r.Hardware_Serial_Number__c FROM Entitlement WHERE Id IN :EntitlementIds]);
        system.debug('allEntitlements: 12345 '+ allEntitlements);
        system.debug('fsPartNumberSet: 12345 '+ fsPartNumberSet);
        
        if(allEntitlements.isEmpty() || fsPartNumberSet.isEmpty())
            return;
        
        //Group Entitlments by Serial Number
        //Assumption: There will always be a entitlement for each Subscription.
        //This map will hold multiple Entitlments for each Serial Number (SDML and CDR can have multiple entitlments/subscriptions for same serial number)
        map<String, list<Entitlement__c>> entitlementListBySN = new map<String, list<Entitlement__c>>();
        for(Entitlement__c ent : allEntitlements) {
            list<Entitlement__c> entList = new list<Entitlement__c>();
            if(entitlementListBySN.containsKey(ent.Entitlement__r.Hardware_Serial_Number__c))
                entList = entitlementListBySN.get(ent.Entitlement__r.Hardware_Serial_Number__c);
            
            entList.add(ent);
            entitlementListBySN.put(ent.Entitlement__r.Hardware_Serial_Number__c, entList);
        }
        
        map<String, list<SBQQ__Subscription__c>> subListBySN = new map<String, list<SBQQ__Subscription__c>>();
        for(SBQQ__Subscription__c sub : allSubscriptions) {
            list<SBQQ__Subscription__c> subList = new list<SBQQ__Subscription__c>();
            if(subListBySN.containsKey(sub.Hardware_Serial_Number__c))
                subList = subListBySN.get(sub.Hardware_Serial_Number__c);
            
            subList.add(sub);
            subListBySN.put(sub.Hardware_Serial_Number__c, subList);
        }
        system.debug('12345 : '+ entitlementListBySN);
        //SDS-2456
        //Create Assets map
        map<String, Asset> assetMapBySN = new map<String, Asset>();
        for(Asset asst : assetList) {
            assetMapBySN.put(asst.Serial_Number__c, asst);
        }
        System.debug('assetMapBySN == ' +assetMapBySN);
        //SDS-2456
        TriggerRMAHelper.updateAssets(RMAtoProcess, fsPartNumberSet, assetMapBySN);
        
        list<SBQQ__Subscription__c> subscriptionsToUpdate = new list<SBQQ__Subscription__c>();
        list<Entitlement> entiListTobeUpdated             = new list<Entitlement>();
        //-->By process builder //list<Entitlement__c> custEntiListTobeUpdated  = new list<Entitlement__c>();
        //Set<Id> subIdSet = new Set<Id>();
        
        //Updating subscription Hardware_Serial_Number__c with the new rma Replacement_Serial_Number__c
        for(RMA__c newRMA : RMAtoProcess){
            RMA__c oldRMA = oldRecordsMap.get(newRMA.Id);            
            system.debug('12345 : newRMA.Serial_Number__c '+ newRMA.Serial_Number__c);
            if(fsPartNumberSet.contains(newRMA.Reship_Part_Number__c)) {
                
                /* Update Entitlements */
                list<Entitlement__c> entListForSN = entitlementListBySN.get(newRMA.Serial_Number__c);
                if(!entListForSN.isEmpty()) {
                    for(Entitlement__c customerEntitlement : entListForSN) {
                        ////Id subId = customerEntitlement.Entitlement__r.Subscription__c; //SDS-1712
                        
                        ///if(subId != null) {///
                            //String existingSubSN = customerEntitlement.Entitlement__r.Subscription__r.Hardware_Serial_Number__c;
                            System.debug(LoggingLevel.ERROR,'--------existingSubSN-----------' + customerEntitlement.Entitlement__r.Hardware_Serial_Number__c);
                            System.debug(LoggingLevel.ERROR,'--------rmaSN-----------' + newRMA.Serial_Number__c);
                            System.debug(LoggingLevel.ERROR,'--------part number-----------' + newRMA.Reship_Part_Number__c);
                            //if(String.isNotBlank(existingSubSN)
                            //    && existingSubSN == newRMA.Serial_Number__c
                            //    && 
                            //if(fsPartNumberSet.contains(newRMA.Reship_Part_Number__c)) {
                                //if(!subIdSet.contains(subId)){
                                    //subIdSet.add(subId);
                                    //-->By process builder //customerEntitlement.Name              = newRMA.Replacement_Serial_Number__c + '-' +customerEntitlement.Entitlement__r.Product_Description__c;
                                    //-->By process builder //custEntiListTobeUpdated.add(customerEntitlement);
                                    
                                    ///if(customerEntitlement.Entitlement__c  != null) {
                                    Entitlement enti      = new Entitlement();
                                    enti.Id               = customerEntitlement.Entitlement__r.Id;
                                    enti.Name             = newRMA.Replacement_Serial_Number__c + '-' +customerEntitlement.Entitlement__r.Product_Description__c;
                                    enti.Hardware_Serial_Number__c = newRMA.Replacement_Serial_Number__c;
                                    entiListTobeUpdated.add(enti);
                                    ///}
                                    
                                    /*////if(subId != null) { //SDS-1712
                                        SBQQ__Subscription__c subscription  = new SBQQ__Subscription__c();
                                        subscription.Id                     = subId;
                                        subscription.Hardware_Serial_Number__c= newRMA.Replacement_Serial_Number__c;
                                        subscriptionsToUpdate.add(subscription);
                                    } */
                                //}
                            //}
                        ///}
                    }
                }
            
                //Update Subscriptions - SDS-1712 (separate logic from Entitlements)
                list<SBQQ__Subscription__c> subListForSN = subListBySN.get(newRMA.Serial_Number__c);
                if(subListForSN != null && !subListForSN.isEmpty()) {
                    for(SBQQ__Subscription__c sub : subListForSN) {
                        ///Id subId = customerEntitlement.Entitlement__r.Subscription__c;
                        
                        ///if(subId != null) {///
                            //String existingSubSN = customerEntitlement.Entitlement__r.Subscription__r.Hardware_Serial_Number__c;
                            //System.debug(LoggingLevel.ERROR,'--------existingSubSN-----------' + customerEntitlement.Entitlement__r.Hardware_Serial_Number__c);
                            //System.debug(LoggingLevel.ERROR,'--------rmaSN-----------' + newRMA.Serial_Number__c);
                            //System.debug(LoggingLevel.ERROR,'--------part number-----------' + newRMA.Reship_Part_Number__c);
                            //if(String.isNotBlank(existingSubSN)
                            //    && existingSubSN == newRMA.Serial_Number__c
                            //    && 
                            //if(fsPartNumberSet.contains(newRMA.Reship_Part_Number__c)) {
                                //if(!subIdSet.contains(subId)){
                                    //subIdSet.add(subId);
                                    //-->By process builder //customerEntitlement.Name              = newRMA.Replacement_Serial_Number__c + '-' +customerEntitlement.Entitlement__r.Product_Description__c;
                                    //-->By process builder //custEntiListTobeUpdated.add(customerEntitlement);
                                    
                                    ///if(customerEntitlement.Entitlement__c  != null) {
                                    /*Entitlement enti      = new Entitlement();
                                    enti.Id               = customerEntitlement.Entitlement__r.Id;
                                    enti.Name             = newRMA.Replacement_Serial_Number__c + '-' +customerEntitlement.Entitlement__r.Product_Description__c;
                                    enti.Hardware_Serial_Number__c = newRMA.Replacement_Serial_Number__c;
                                    entiListTobeUpdated.add(enti);*/
                                    ///}
                                    
                                    //if(subId != null) {
                                        SBQQ__Subscription__c subscription  = new SBQQ__Subscription__c();
                                        subscription.Id                     = sub.Id;
                                        subscription.Hardware_Serial_Number__c= newRMA.Replacement_Serial_Number__c;
                                        subscriptionsToUpdate.add(subscription);
                                    //}
                                //}
                            //}
                        ///}
                    }
                }
            }
        }
        
        //Update Subscriptions:
        if(!subscriptionsToUpdate.isEmpty()){
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.allowFieldTruncation= true;
            Savepoint savePoint     = Database.setSavepoint();
            try {
                update subscriptionsToUpdate;
                //update entiListTobeUpdated;
                //-->By process builder //update custEntiListTobeUpdated;                
            } catch (Exception e) {
                if(savePoint != null)
                    Database.rollback(savePoint); 
                
                Service_Cloud_Error_Log__c errorLog = new Service_Cloud_Error_Log__c(  Functionality_Name__c = 'TriggerRMAHelper', 
                                                        Error_Description__c = e.getMessage(), Error_Type__c = 'DML Exception');
                errorLog.setOptions(dml);
                insert errorLog;
            }
        }
        
        //Update Entitlements: 
        if(!entiListTobeUpdated.isEmpty()){
            //Map<Id,Entitlement> entiMap = new Map<Id,Entitlement>(entiListTobeUpdated);
            //List<Entitlement__c> custEntiListTobeUpdated= [SELECT Name, Entitlement__c 
            //                                               FROM Entitlement__c 
             //                                              WHERE Entitlement__c IN :entiListTobeUpdated];
            //for(Entitlement__c custEnti : custEntiListTobeUpdated){
            //    custEnti.Name = entiMap.get(custEnti.Entitlement__c).Name;
            //}                                               
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.allowFieldTruncation= true;
            Savepoint savePoint2     = Database.setSavepoint();
            try {
                //update subscriptionsToUpdate; 
                update entiListTobeUpdated;
                //-->By process builder //update custEntiListTobeUpdated;                
            } catch (Exception e) {
                if(savePoint2 != null)
                    Database.rollback(savePoint2); 
                
                Service_Cloud_Error_Log__c errorLog = new Service_Cloud_Error_Log__c(  Functionality_Name__c = 'TriggerRMAHelper', 
                                                        Error_Description__c = e.getMessage(), Error_Type__c = 'DML Exception');
                errorLog.setOptions(dml);
                insert errorLog;
            }
        }
    }
    
    //SDS-2456
    public static void updateAssets(list<RMA__c> RMAtoProcess, Set<String> fsPartNumberSet, map<String, Asset>assetMapBySN) {
        map<String, AssetRelationship> assetRelationshipMapBySN = new map<String, AssetRelationship>();
        //list<Asset> assetsToUpdate    = new list<Asset>();
        //list<Asset> newAssets         = new list<Asset>();
        map<String, Asset> newAssetsMap = new map<String, Asset>();
        list<Asset> existingAssets  = new list<Asset>();
        //1. Go through each RMA 
        for(RMA__c rma : RMAtoProcess){
            //Skip if No Asset linked to current Entitlement/RMA
            if(!assetMapBySN.containsKey(rma.Serial_Number__c))
                continue;
            Asset originalAsset = assetMapBySN.get(rma.Serial_Number__c);
            Asset clonedAsset = null;
            System.debug('originalAsset == '+ originalAsset);
            //Create AssetRelationship record
            AssetRelationship assetRel = new AssetRelationship();
            assetRel.AssetId = originalAsset.Id;
            assetRel.RelationshipType = 'Replacement';
            assetRel.FromDate = date.today();
            assetRel.RelatedAssetId = NULL; //assetMapBySN.get(rma.Replacement_Serial_Number__c); //This value can be null if new Asset is not in SFDC.
            assetRelationshipMapBySN.put(rma.Replacement_Serial_Number__c, assetRel);
            //2. Create/Update New Asset: (NEW)
            //2.1. Find Asset with new SN (find based on RMA.Replacement_Serial_Number__c )
            //2.1.1 If New Asset already exist : Do not create, query Asset details and go to step#3
            if(assetMapBySN.containsKey(rma.Replacement_Serial_Number__c)) {
                Asset existingAsst = assetMapBySN.get(rma.Replacement_Serial_Number__c);
                clonedAsset = TriggerRMAHelper.getClonedAsset(originalAsset);
                //clonedAsset.Serial_Number__c = rma.Replacement_Serial_Number__c;
                clonedAsset.Id              = existingAsst.Id;
                //clonedAsset.Refurbished__c  = true;
                assetRel.RelatedAssetId = existingAsst.Id;
                // Update the Refurbished count: ++1
            } else { //2.1.2 If doesn't exist: Clone from original Asset ()
                clonedAsset = TriggerRMAHelper.getClonedAsset(originalAsset);
                //Change SN
                /*        c. Copy All the details related to customer: 
                i. AccountID
                ii. Address Information
                iii. VAR, Product etc.
                d. Set Asset Status = "Installed/Active"
                e. Set "Link entitlement" and "Link Component" to true */
                //clonedAsset.Serial_Number__c = rma.Replacement_Serial_Number__c;
                clonedAsset.Status = 'Installed/Active';
            }
            clonedAsset.AccountId           = originalAsset.AccountId;
            clonedAsset.Link_Components__c  = true;
            clonedAsset.Link_Entitlements__c= true;
            clonedAsset.Product2Id          = originalAsset.Product2Id;
            clonedAsset.Serial_Number__c    = rma.Replacement_Serial_Number__c;
            clonedAsset.SerialNumber        = rma.Replacement_Serial_Number__c;
            clonedAsset.Material_Number__c  = rma.Reship_Part_Number__c;
            clonedAsset.Quantity            = 1;
            clonedAsset.Asset_created_from_RMA__c = rma.Id;
            clonedAsset.SAP_Delivery_Number__c = rma.Delivery_Number__c;
            
            //newAssets.add(clonedAsset);
            newAssetsMap.put(rma.Replacement_Serial_Number__c, clonedAsset);
            //assetsToUpdate.add(clonedAsset);
            //3. Update Old Asset:  (NEW) (find based on RMA.Serial_Number__c)
            //if(assetMapBySN.containsKey(rma.Serial_Number__c)) {
            originalAsset = TriggerRMAHelper.removeCustomerInfo(originalAsset);
            originalAsset.Status = 'Returned'; //Uncomment after testing 1026
            /* 1. Remove information related to current Customer:
                a. AccountID = "NVIDIA Return" (Custom metadate: Service Cloud Setting."NVIDIA Return Account ID")
                i. Store Account ID/Name in the custom metadata.
                b. Remove Address Information
                c. Remove Var, Soldto etc.
                2.set Asset Status to “Returned”*/
            //}
            existingAssets.add(originalAsset);
            //assetsToUpdate.add(originalAsset);
        }
        System.debug('existingAssets == '+ existingAssets);
        System.debug('newAssetsMap == '+ newAssetsMap);
        if(existingAssets != null && existingAssets.size() > 0){
            try{
                upsert existingAssets;
            }
            catch(Exception ex){
                NV_Error_Log__c nvError = new NV_Error_Log__c();
                nvError.Error_Description__c = String.valueof(ex).left(255);
                nvError.Error_Message__c = ex.getStackTraceString().left(255);
                nvError.Functionality__c = 'Asset Update Error-TriggerRMAHelper';
                insert nvError;            
            }    
        }
        if(newAssetsMap != null && newAssetsMap.size() > 0)
            upsert newAssetsMap.values();
        if(assetRelationshipMapBySN != null && assetRelationshipMapBySN.size() > 0) {
            for(String keySN: assetRelationshipMapBySN.keyset()) {
                Asset asst = newAssetsMap.get(keySN);
                assetRelationshipMapBySN.get(keySN).RelatedAssetId = asst.Id;
            }
            insert assetRelationshipMapBySN.values();
        }
    }
    //Clone Asset
    public static Asset getClonedAsset(Asset originalAsset) {
        Asset clonedAsset                       = originalAsset.clone();
        System.debug('Account ID == ' + originalAsset.AccountId);
        clonedAsset.InstallDate                 = Date.today();
        clonedAsset.Hostname__c                 = '';
        clonedAsset.Local_FSL_not_available__c  = false;
        clonedAsset.SAP_Order__c                = NULL;
        clonedAsset.Sales_Order_Number__c       = '';
        clonedAsset.SAP_Account_Number__c       = '';
        clonedAsset.SAP_Delivery_Number__c      = '';
        clonedAsset.VAR_SAP_Number__c           = '';
        clonedAsset.VAR__c                      = NULL;
        clonedAsset.Sold_To_Partner__c          = NULL;
        clonedAsset.Sold_To_Partner_SAP_Number__c = '';
        clonedAsset.SAP_PECC_Number__c          = '';
        clonedAsset.Partner__c                  = NULL;
        clonedAsset.PurchaseDate                = NULL;
        clonedAsset.PO_Number__c                = '';
        return clonedAsset;
    }
    public static Asset removeCustomerInfo(Asset originalAsset) {
        originalAsset.AccountId                 = ESP_Utility.ESPConstants.ServiceCloudSettings.NVIDIA_Return_Account_ID__c;//'0011D00000ib99x'; //Get it from Custom metadata
        system.debug('NVIDIA_Return_Account_ID__c: '+ ESP_Utility.ESPConstants.ServiceCloudSettings.NVIDIA_Return_Account_ID__c);
        originalAsset.PAKID__c                  = '';
        originalAsset.ContactId                 = NULL;
        originalAsset.Street_1__c               = '';
        originalAsset.Street_2__c               = '';
        originalAsset.City__c                   = '';
        originalAsset.State__c                  = '';
        originalAsset.Postal_Code__c            = '';
        originalAsset.Country__c                = '';
        originalAsset.Hostname__c               = '';
        originalAsset.Local_FSL_not_available__c= false;
        originalAsset.Description               = '';
        originalAsset.SAP_Order__c              = NULL;
        originalAsset.Sales_Order_Number__c     = '';
        originalAsset.SAP_Account_Number__c     = '';
        originalAsset.SAP_Delivery_Number__c    = '';
        originalAsset.VAR_SAP_Number__c         = '';
        originalAsset.VAR__c                    = NULL;
        originalAsset.Sold_To_Partner__c        = NULL;
        originalAsset.Sold_To_Partner_SAP_Number__c = '';
        originalAsset.SAP_PECC_Number__c        = '';
        originalAsset.Partner__c                = NULL;
        originalAsset.PurchaseDate              = NULL;
        originalAsset.PO_Number__c              = '';
        //originalAsset.pro;
        return originalAsset;
    }
   /*
    *   This method is invoked/fired on After update trigger event on the RMA__c object
    *
    *   Pupose of this method is to update the Case record for incident status with value 'With Engineering + RMA'
    *
    *   The following Case records are eligible for update
    *   - Firstly these Case records are identified from the input RMA records where they are referred to as a lookup
    *   - The tracking number on the RMA record should have changed from 'blank' to a 'valid tracking number'
    */
    public static void updateCaseStatus() { //List<RMA__c> newRecords, Map<Id,RMA__c> oldRecordsMap){
        //Updating Incident_Status__c in Case
        Map<String,Case> lstCase = new    Map<String,Case>();
        for(RMA__c rma:newRecords){
            if(String.isNotEmpty(rma.Tracking_Number__c) 
                && rma.Case__c !=null 
                && String.isEmpty(oldRecordsMap.get(rma.Id).Tracking_Number__c) && rma.Case_Status__c!='Closed'){
                Case cas = new Case(Id = rma.Case__c, Incident_Status__c ='With Engineering + RMA');
                lstCase.put(cas.Id,cas);                  
            }
        }
        if(lstCase.size() >0){
            upsert lstCase.values();
        }
    }
   /*
    *   This method is invoked/fired on After insert trigger event on the RMA__c object
    *   Pupose of this method is to update the Case record for incident status with value 'With RMA'
    *   The Case records are identified from the input RMA records where they are referred to as a lookup
    */
    public static void updateCaseStatusNew(){//List<RMA__c> newRecords){
        Map<String,Case> lstCase = new Map<String,Case>();
        
        //Updating Incident_Status__c in Case
        for(RMA__c rma:newRecords){
            if(rma.Case__c !=null){
                Case cas = new Case(Id = rma.Case__c, Incident_Status__c ='With RMA');
                lstCase.put(cas.Id,cas);        
            }
        }
        if(lstCase.size() >0){
            update lstCase.values();
        }
    }
 
    // SDS-1574  : Start
    public static void sendEmail() { //List<RMA__c> lstRMA,Map<Id,RMA__c> oldMap){
        emailAdditionalAddressesTrackingNumberPopulated(newRecords,oldRecordsMap);
    }
    
    public static void emailAdditionalAddressesTrackingNumberPopulated(List<RMA__c> lstRMA, Map<Id,RMA__c> oldMap){
        List<RMA__c> lstChangedRMA = new List<RMA__c>();
        for(RMA__C tmpRMA : lstRMA)
        {
            if(tmpRMA.Additional_Email_Addresses__c !=null && tmpRMA.Tracking_Number__c !=null && (oldMap.get(tmpRMA.id).Additional_Email_Addresses__c!=tmpRMA.Additional_Email_Addresses__c || oldMap.get(tmpRMA.id).Tracking_Number__c !=tmpRMA.Tracking_Number__c )&& (tmpRMA.RMA_Status__C=='INPR' ||tmpRMA.RMA_Status__C=='SHIP') )
                lstChangedRMA.add(tmpRMA);            
        }
        if(lstChangedRMA.isEmpty())
            return;
        
        EmailTemplate templateId = [Select DeveloperName,Id,subject from EmailTemplate where DeveloperName= 'Service_Cloud_RMA_Notification_to_Customer' limit 1];
        OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where Address='no_reply@nvidia.com' limit 1];
        
        List<Messaging.SingleEmailMessage> lstMessages= new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail ;
        List<string> lstToAddresses = new List<string>();
        for(RMA__C tmpRMA : lstChangedRMA)
        {
            if(tmpRMA.Additional_Email_Addresses__c !=null && tmpRMA.Tracking_Number__c !=null && (oldMap.get(tmpRMA.id).Additional_Email_Addresses__c!=tmpRMA.Additional_Email_Addresses__c || oldMap.get(tmpRMA.id).Tracking_Number__c !=tmpRMA.Tracking_Number__c )&& (tmpRMA.RMA_Status__C=='INPR' ||tmpRMA.RMA_Status__C=='SHIP') ){
                if(tmpRMA.Additional_Email_Addresses__c.contains(','))
                    lstToAddresses=tmpRMA.Additional_Email_Addresses__c.split(',');
                else if(tmpRMA.Additional_Email_Addresses__c.contains(';'))
                    lstToAddresses=tmpRMA.Additional_Email_Addresses__c.split(';');
                else
                    lstToAddresses.add(tmpRMA.Additional_Email_Addresses__c);
                mail = new Messaging.SingleEmailMessage();
                mail.setOrgWideEmailAddressId(owa.id);
                mail.setTemplateID(templateId.Id); 
                mail.setTargetObjectId(Label.Service_Cloud_RMA_Email_Template_Contact_Id_TriggerRMAHelper);
                mail.setSaveAsActivity(false);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setToAddresses(lstToAddresses); 
                mail.setWhatId(tmpRMA.id);
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
 //SDS-1574 : End   
 //SDS-1686  Start
    /* -----------------------------------------------------------------
      getRMAs : This method gets the list of RMAs associated with Cases 
      and displays in Data table Lightning component CEDispatch
    --------------------------------------------------------------------*/
    @auraEnabled
    public static List<RMA__c > getRMAs(string strCaseId) {
        system.debug('**inside getRMAs');
        List<RMA__c> lstRMA = [SELECT Id,Name,NVIDIA_Part_Number__c,Tracking_Number_Formula__c,NVIDIA_Part_Description__c,Complaint_Number__c,Crm_Complaint_Number__c,
        Serial_Number__c,Reship_Part_Number__c,Case__c,CE_Dispatch_Request_Date_Time__c,CreatedDate,RMA_Status__c,RMA_Status_Formula__c,Tracking_Number__c,
        Request_CE_Dispatch__c,Customer_Engineers_Email__c,On_site_Engineer_s__c,Customer_Engineers_Phone__c,SAP_RMA_Number__c,Product_Category__c,
        Case_Owner_Email__c,Scheduled_Date_and_Time_for_Installation__c,case__r.Regional_TAM__r.email,case__r.Account_Manager__r.email FROM RMA__c  WHERE Case__c =: strCaseId and Crm_Complaint_Number__c!=null];
        return lstRMA;
    }
    @auraEnabled
    public static List<APXTConga4__Conga_Email_Template__c> getEmailTemplates(){
        List<APXTConga4__Conga_Email_Template__c> lstEmailTemplate = [select Id,APXTConga4__Name__c from APXTConga4__Conga_Email_Template__c where APXTConga4__Template_Group__c = 'RMA' OR APXTConga4__Template_Group__c='CE'];
        return lstEmailTemplate;
    }
    
    @auraEnabled
    public static string initiateDispatch(List<RMA__c> lstRMAs, string strEmailTemplateId) {
        string strCaseId;
        if(lstRMAs!=null && !lstRMAs.isEmpty())
            strCaseId = lstRMAs.get(0).Case__C;
        else return null;
        List<APXTConga4__Conga_Email_Template__c> lstEmailTemplate = [select Id,APXTConga4__Name__c,email_ids__c from APXTConga4__Conga_Email_Template__c where id=:strEmailTemplateId];
        system.debug('**' + strCaseId );
        string strRMAIds='';
        string strEmailToAddresses='';
        string strRelatedToId='';
        if(lstEmailTemplate!=null && !lstEmailTemplate.isEmpty() ){
        for (integer i = 0; i < lstRMAs.size(); i++){
            lstRMAs.get(i).Request_CE_Dispatch__c = true;
            lstRMAs.get(i).CE_Dispatch_Request_Date_Time__c= system.now();
            if(i==0){
                strRMAIds= '\''+lstRMAs.get(0).Id+'\'';
            }    
            else
                strRMAIds= strRMAIds+ '|'+ '\'' + lstRMAs.get(i).Id +'\'';
        }
            if(lstEmailTemplate!=null && lstEmailTemplate.get(0).APXTConga4__Name__c.contains('CE Dispatch') && lstEmailTemplate.get(0).APXTConga4__Name__c.contains('Initial')){
                strEmailToAddresses = UserInfo.getUserEmail()+ (lstRMAs.get(0).Case_Owner_Email__c!=null ? ','+lstRMAs.get(0).Case_Owner_Email__c: '')  +(lstRMAs.get(0).case__r.Regional_TAM__C !=null ? ','+ lstRMAs.get(0).case__r.Regional_TAM__r.email : '') +(lstRMAs.get(0).case__r.Account_Manager__c !=null ? ','+ lstRMAs.get(0).case__r.Account_Manager__r.email : '') +(lstEmailTemplate.get(0).email_ids__c!=null ? ','+ lstEmailTemplate.get(0).email_ids__c : '') ;
        update lstRMAs;
            }
            else if(lstEmailTemplate!=null && lstEmailTemplate.get(0).APXTConga4__Name__c.contains('CE Dispatch') && lstEmailTemplate.get(0).APXTConga4__Name__c.contains('CALLONE')){
                strEmailToAddresses = UserInfo.getUserEmail()+ (lstRMAs.get(0).Case_Owner_Email__c!=null ? ','+lstRMAs.get(0).Case_Owner_Email__c: '')+(lstEmailTemplate.get(0).email_ids__c!=null ? ','+ lstEmailTemplate.get(0).email_ids__c : '') ;
                strRelatedToId = strCaseId;
            }
            else if(lstEmailTemplate!=null && lstEmailTemplate.get(0).APXTConga4__Name__c.contains('CE Dispatch') && lstEmailTemplate.get(0).APXTConga4__Name__c.contains('Dispatch Information')){
                strEmailToAddresses = UserInfo.getUserEmail()+ (lstRMAs.get(0).Case_Owner_Email__c!=null ? ','+lstRMAs.get(0).Case_Owner_Email__c: '')+ (lstRMAs.get(0).Customer_Engineers_Email__c!=null ? ','+lstRMAs.get(0).Customer_Engineers_Email__c: '') +(lstRMAs.get(0).case__r.Regional_TAM__C !=null ? ','+ lstRMAs.get(0).case__r.Regional_TAM__r.email : '') +(lstRMAs.get(0).case__r.Account_Manager__c !=null ? ','+ lstRMAs.get(0).case__r.Account_Manager__r.email : '') +(lstEmailTemplate.get(0).email_ids__c!=null ? ','+ lstEmailTemplate.get(0).email_ids__c : '') ;
            }            
        }
        String SessionId = Userinfo.getSessionID();
        String ServerURL = URL.getSalesforceBaseUrl().toExternalForm();
        String Organizationid = UserInfo.getOrganizationId().substring(0,15);
        String salesforceURL = ServerURL+'/services/Soap/u/47.0/'+Organizationid;
        string strURL;
        if(strRelatedToId == strCaseId)
            strURL = '/apex/APXTConga4__Conga_Composer?sessionId='+SessionId+'&id='+strCaseId+'&EmailTemplateId='+ strEmailTemplateId +'&CETG=RMA,CE&QueryId='+'[RMADatasetSingle]'+ label.Service_Cloud_RMA_CE_Dispatch_Query_Single +'?pv0='+strRMAIds+',[RMADataset]'+ label.Service_Cloud_RMA_CE_Dispatch_Query +'?pv0='+strRMAIds+'&serverUrl='+salesforceURL+'&EmailRelatedToId='+lstRMAs.get(0).case__c+'&EmailAdditionalTo='+strEmailToAddresses ;
        else
            strURL = '/apex/APXTConga4__Conga_Composer?sessionId='+SessionId+'&id='+strCaseId+'&EmailTemplateId='+ strEmailTemplateId +'&CETG=RMA,CE&QueryId='+'[RMADatasetSingle]'+ label.Service_Cloud_RMA_CE_Dispatch_Query_Single +'?pv0='+strRMAIds+',[RMADataset]'+ label.Service_Cloud_RMA_CE_Dispatch_Query +'?pv0='+strRMAIds+'&serverUrl='+salesforceURL+'&EmailRelatedToId='+lstRMAs.get(0).id+'&EmailAdditionalTo='+strEmailToAddresses ;
        system.debug('***strURL***'+ strURL);            
        return strURL ;
    }       
//SDS-1686  End
    public static void createFANVBug (){
        List<NVBug__c > lstNVBug = new List<NVBug__c >();
        DescribeSObjectResult describeResult = RMA__c.getSObjectType().getDescribe();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        set<Id> setIds = new set<Id>();
        setIds = oldRecordsMap.keyset();
        String strquery = ' SELECT ' + String.join( fieldNames, ',' ) + ', Part__r.name, Case__r.CreatedDate, Case__r.Working_Theory__c, Case__r.Description, Case__r.subject, Case__r.Product_Family__c, Case__r.CaseNumber FROM ' + describeResult.getName() +' WHERE ID IN :setIds'; 
        system.debug('**strquery**' + strquery);
        List<RMA__c> lstRMAs = (List<RMA__c>)Database.query(strquery);       
        NVBug__c newNVBug;
        for(RMA__c tmpRma : lstRMAs ){
            if(tmpRma.Create_FA_Bug__c == true){
                system.debug('**System.isFuture()**'+System.isFuture());
                if(!System.isFuture() && tmpRma.Quantity__c!=null && tmpRma.Quantity__c>0 && oldRecordsMap.get(tmprma.id).RMA_Status__c!=null 
                && oldRecordsMap.get(tmprma.id).RMA_Status__c!='INPR' && tmpRma.RMA_Status__c=='INPR' && tmpRma.nvbug__c==null){
                    for(integer i=0;i<tmpRma.Quantity__c;i++){
                        newNVBug = new NVBug__c();
                        newNVBug.name = 'NVBug from RMA';
                        newNVBug.rma__c = tmprma.id;
                        newNVBug.case__c = tmpRma.case__c;
                        newNVBug.Priority__c = '5-Normal';
                        newNVBug.Severity__c = '3-Functionality';
                        newNVBug.Is_Send_Notification__c = true;
                        newNVBug.NVBug_Template__c = '('+ label.Service_Cloud_FA_NVBug_Template_Number +')';
                        newnvbug.Synopsis__c = '['+ (tmpRma.Case__r.Product_Family__c!=null ? tmpRma.Case__r.Product_Family__c :'') + ' - ' + (tmpRma.Part__c!=null && tmpRma.Part__r.name!=null ? tmpRma.Part__r.name : '') + ' : ' + tmpRma.Account_name__C + '][DOA- ' + tmpRma.Dead_on_Arrival__c+ '][' + tmprma.Case__r.CaseNumber + '] Issue - ' + tmprma.Case__r.subject;
                        newnvbug.NVBug_Description__c = getFABugDescription(tmpRma);
                        lstNVBug.add(newNVBug);
                    }
                }
            }
        }
        if(lstNVBug!=null && !lstNVBug.isEmpty()){
            insert lstNVBug;
            NVbugCallout(JSON.serialize(lstNVbug));
        } 
    }
@future(Callout=true)
    public static void NVbugCallout (string strlstNVBug){
        List<NVBug__c> lstNVbug = new List<NVBug__c>();
        Map<Id,Rma__c> mapRmaBug = new Map<Id,Rma__c>();
        Rma__c rma;
        lstNVbug = (List<NVBug__c>)JSON.deserialize(strlstNVBug, List<NVBug__c>.class);
        for(NVBug__c tmpnvbug : lstNVbug){
            NVBugOperations.saveBug(tmpnvbug);
            mapRmaBug.put(tmpnvbug.rma__c,new RMA__c(id=tmpnvbug.rma__c,NVBug__c=tmpnvbug.id));
        }
        if(mapRmaBug!=null && !mapRmaBug.values().isEmpty())
            update mapRmaBug.values();
    }  
    
public static string getFABugDescription(RMA__C rma){

string strDescription = '<table border="1" class="ql-table-blob">   <tbody>     <tr>            <td colspan="1" rowspan="1">' + 
 '<p>&nbsp;<strong>Occurrence Date:</strong></p>            </td>           <td colspan="1" rowspan="1">' + 
 '<p>&nbsp;'+rma.case__r.createdDate+'</p>         </td>       </tr>       <tr>            <td colspan="1" rowspan="1">' + 
 '<p>&nbsp;<strong>RMA#:</strong></p>           </td>           <td colspan="1" rowspan="1">' + 
 '<p>&nbsp;'+rma.SAP_RMA_Number__c+'</p>         </td>       </tr>       <tr>            <td colspan="1" rowspan="1">' + 
 '<p>&nbsp;<strong>Chassis#:</strong></p>           </td>           <td colspan="1" rowspan="1">' + 
 '<p>&nbsp;'+rma.Serial_Number__c+'</p>         </td>       </tr>       <tr>            <td colspan="1" rowspan="1">&nbsp;<strong>Subcomponent PN#</strong></td>' + 
 '<td colspan="1" rowspan="1">          <p>&nbsp;'+rma.Actual_Return_Part_Number__c+'</p>           </td>       </tr>       <tr>            <td colspan="1" rowspan="1">' + 
 '<p>&nbsp;<strong>Return Component SN#:</strong></p>           </td>           <td colspan="1" rowspan="1">' + 
 '<p>&nbsp;'+rma.Returned_Serial_Number__c+'</p>         </td>       </tr>       <tr>            <td colspan="1" rowspan="1">' + 
 '<p>&nbsp;<strong>Operational Runtime:</strong></p>            </td>           <td colspan="1" rowspan="1">' + 
 '<p>&nbsp;</p>         </td>       </tr>   </tbody></table><br /><br /><span style="font-family: Arial,Helvetica,sans-serif;">' +
'<u><em>CUSTOMER REPORTED FAIL DESCRIPTION (INCLUDE SUFFICIENT INFORMATION TO REPRODUCE THE BUGS.&nbsp;&nbsp;ATTACH ANY SUPPORTING LOGS.):</em></u></span>' +
'<br /><br /><br /><strong>Problem Description:</strong><br /><br />'+rma.Case__r.Description+'<br /><br />&nbsp;<br /><br /><strong>Working Theory:</strong>' +
'<br /><br />'+rma.Case__r.Working_Theory__c+'<br/><br />&nbsp;<br /><br />&nbsp;<br /><br /><strong>FIELD INVESTIGATION RESULTS:</strong><br /><br />&nbsp;' +
'<br /><br />&nbsp;<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' +
'<br /><br />&nbsp;<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.<br /><br />&nbsp;<br /><br />&nbsp;<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3.' +
'<br /><br />&nbsp;<br /><br />&nbsp;<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.<br /><br />&nbsp;<br /><br />&nbsp;<br /><br /><strong>NEXT STEPS:' +
'</strong><br /><br />&nbsp;<br /><br />&nbsp;<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.' +
'<br /><br />&nbsp;<br /><br />&nbsp;<br /><br /><strong>RMA TRACKING LOCATION LOG:</strong><br /><br />&nbsp;<br /><br />&nbsp;' +
'<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<u>Shipped Date from the customer</u>:' +
'<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br /><br />&nbsp;' +
'<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<u>Arrival Date - NV Location:</u>' +
'<br /><br />&nbsp;<br /><br />&nbsp;<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' +
'<u>Shipped Date to CM:</u><br /><br />&nbsp;<br /><br />&nbsp;<br /><br /><strong>TEST ENVIRONMENT:</strong>' +
'<br /><br />&nbsp;<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<u>Temperature &amp; Humidity:</u><br /><br /><br /><br />&nbsp;';
return strDescription;
}      

}