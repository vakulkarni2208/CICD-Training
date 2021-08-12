public class Asset_tgr_cls extends NV_TriggerHandler {
    public list<Asset> oldRecords;
    private static list<Asset> newRecords;
    private static map<Id, Asset> oldRecordsMap;
    public static boolean LINK_ALL_ASSETS = false;
    static boolean isInsert = false;
    public override void init() { 
        OBJECT_NAME = 'Asset';
        oldRecords = trigger.old;  
        newRecords = trigger.New;  
        if(oldRecords != null)
            oldRecordsMap = new map<Id, Asset>(oldRecords);
        System.debug('Old Records' + oldRecords + '1');
        System.debug('New Records' + trigger.New + '1');
        LINK_ALL_ASSETS = ESP_Utility.ESPConstants.ServiceCloudSettings.Link_All_Assets__c;
    }
    
    public override void beforeInsert() {
        isInsert = true;
        Asset_tgr_cls.autopopulateDetails();
        //get custom setting for object
        /* Moved below code to afterInsert
         * Boolean linkAsset = FeatureManagement.checkPermission('Service_Link_Assets');
        if(linkAsset) {
            Asset_tgr_cls.linkEntitlements();
            Asset_tgr_cls.linkComponents();
        } */
        //Asset_tgr_cls.UpdateName();
    }
    public override void beforeUpdate() {
        Asset_tgr_cls.autopopulateDetails();
        Asset_tgr_cls.RelinkEntandComponents();
        Boolean linkAsset = FeatureManagement.checkPermission('Service_Link_Assets');
        if(linkAsset) {
            Asset_tgr_cls.linkEntitlements();
            Asset_tgr_cls.linkComponents();
        }
        //Asset_tgr_cls.UpdateName();
    }
    
    public override void afterInsert() {
        isInsert = true;
        Boolean linkAsset = FeatureManagement.checkPermission('Service_Link_Assets');
        if(linkAsset) {
            Asset_tgr_cls.linkEntitlements();
            Asset_tgr_cls.linkComponents();
        }
    }
    /*public override void afterUpdate() {
        Asset_tgr_cls.RelinkEntandComponents();
        Boolean linkAsset = FeatureManagement.checkPermission('Service_Link_Assets');
        if(linkAsset) {
            Asset_tgr_cls.linkEntitlements();
            Asset_tgr_cls.linkComponents();
        }
    }*/
    
    public static void linkEntitlements(){
        Asset_tgr_cls.linkEntitlements(newRecords);
    }
    
    public static void linkComponents(){
        Asset_tgr_cls.linkComponents(newRecords);
    }
    
    public static void autopopulateDetails(){
        Set<String> sapAccNumberSet = new Set<String>();
        Set<String> sapContactNumberSet = new Set<String>();
        Set<String> sapPrdMaterialSet = new Set<String>();
        for(Asset ast : newRecords) {
            if(trigger.isInsert)
            	ast.Status = 'Installed/Active';
            if(ast.SAP_Account_Number__c != NULL && ast.SAP_Account_Number__c != ''){
                sapAccNumberSet.add(ast.SAP_Account_Number__c);
            }
            if(ast.VAR_SAP_Number__c != NULL && ast.VAR_SAP_Number__c != ''){
                sapAccNumberSet.add(ast.VAR_SAP_Number__c);
            }
            if(ast.Sold_To_Partner_SAP_Number__c != NULL && ast.Sold_To_Partner_SAP_Number__c != ''){
                sapAccNumberSet.add(ast.Sold_To_Partner_SAP_Number__c);
            }
            if(ast.SAP_PECC_Number__c != NULL && ast.SAP_PECC_Number__c != ''){
                sapContactNumberSet.add(ast.SAP_PECC_Number__c);
            }
            /*if(ast.Material_Number__c != NULL && ast.Material_Number__c != ''){
                //string astMaterial = '%' + ast.Material_Number__c + '%';
                sapPrdMaterialSet.add(ast.Material_Number__c);
                //sapPrdMaterialSet.add(astMaterial);
            }*/
        }
        
        system.debug('sapContactNumberSet: '+ sapContactNumberSet);
        List<Account> accountList = [select Id, SAP_Customer_Number__c from Account where SAP_Customer_Number__c IN: sapAccNumberSet];
        Map<String, Account> accountToSAPAccNumberMap = new map<String, Account>();
        for(Account acc : accountList) {
            if(acc.SAP_Customer_Number__c != null && acc.SAP_Customer_Number__c != '')
                accountToSAPAccNumberMap.put(acc.SAP_Customer_Number__c, acc);
        }
        
        List<Contact> contactList = new list<Contact>();
        if(sapContactNumberSet != null && sapContactNumberSet.size() > 0)
            contactList = [select Id, SAP_Contact_ID__c from Contact where SAP_Contact_ID__c IN: sapContactNumberSet];
        
        Map<String, Contact> contactToSAPAccNumberMap = new map<String, Contact>();
        for(Contact con : contactList) {
            if(con.SAP_Contact_ID__c != null && con.SAP_Contact_ID__c != '')
                contactToSAPAccNumberMap.put(con.SAP_Contact_ID__c, con);
        }
        
        //List<Product2> productList = [select Id, NVIDIA_Product_SKUs__c, StockKeepingUnit, Material_Number__c from Product2 where Material_Number__c IN: sapPrdMaterialSet];
        map<Id, Product2> productMap = new map<Id, Product2>([select Id, NVIDIA_Product_SKUs__c, Name, Description from Product2]);//List<Product2> productList = [select Id, NVIDIA_Product_SKUs__c, Name from Product2];// where NVIDIA_Product_SKUs__c like: sapPrdMaterialSet ];
        // Query all products  NVIDIA_Product_SKUs__c skus, LIke keyword use use
        /*Map<String, Product2> productToSAPAccNumberMap = new map<String, Product2>();
        for(Product2 prd : productList) {
            if(prd.Material_Number__c != null && prd.Material_Number__c != '')
                productToSAPAccNumberMap.put(prd.Material_Number__c, prd);
        }*/
        
        for(Asset ast : newRecords){
            if(accountToSAPAccNumberMap.containsKey(ast.SAP_Account_Number__c) ){ 
                Account acc = accountToSAPAccNumberMap.get(ast.SAP_Account_Number__c);
                ast.AccountId  = acc.Id;
            } 
            if(accountToSAPAccNumberMap.containsKey(ast.VAR_SAP_Number__c)){
                Account acc = accountToSAPAccNumberMap.get(ast.VAR_SAP_Number__c);
                ast.VAR__c = acc.Id;
            }
            if(accountToSAPAccNumberMap.containsKey(ast.Sold_To_Partner_SAP_Number__c)){
                Account acc = accountToSAPAccNumberMap.get(ast.Sold_To_Partner_SAP_Number__c);
                ast.Sold_To_Partner__c = acc.Id;
            }
            if(contactToSAPAccNumberMap.containsKey(ast.SAP_PECC_Number__c)){
                Contact con = contactToSAPAccNumberMap.get(ast.SAP_PECC_Number__c);
                ast.ContactId = con.Id;
                System.debug('Contact Updated->>>'+con.id);
            }
            //Find Product
            /*if(productToSAPAccNumberMap.containsKey(ast.Material_Number__c)){ 
                Product2 prd = productToSAPAccNumberMap.get(ast.Material_Number__c);
                System.debug('Product Updated->>>'+prd.id);
                ast.Product2Id = prd.Id;
            } */
            
            String description = '';
            if(ast.Product2Id == Null && ast.Material_Number__c != NULL && ast.Material_Number__c != '') {
                for(Product2 prd : productMap.values()) {
                	if(prd.NVIDIA_Product_SKUs__c != null && prd.NVIDIA_Product_SKUs__c != '') {
                        if(prd.NVIDIA_Product_SKUs__c.contains(ast.Material_Number__c)){
                            ast.Product2Id = prd.Id;
                            //description = string.IsBlank(prd.Name) ? '' : '-' + prd.Name;
            				////String astName = string.IsBlank(ast.SerialNumber) ? ast.PAKID__c  +  description : ast.SerialNumber + description;
            				////ast.Name = astName.left(80);
                        }                        	
                	}
            	}
            }
            
            Product2 pd = productMap.get(ast.Product2Id);
            description = (pd != Null && !string.IsBlank(pd.Description)) ? pd.Description : '';
            String astName = string.IsBlank(ast.SerialNumber) ? ast.PAKID__c + '-' + description : ast.SerialNumber + '-' + description;
            ast.Name = astName.left(80);
            
            //Set Processing Status
            if(ast.Product2Id != null && ast.ContactId != null 
				&& ast.Sold_To_Partner__c != null 
               	&& ast.VAR__c != null && ast.AccountId != null)
                ast.Asset_Processing_Status__c = 'Asset Processed Succesfully';
            else{
                ast.Asset_Processing_Status__c = '';
                if(ast.Product2Id == null) 			
                    ast.Asset_Processing_Status__c  = 'Product Missing'+'; ';
                if(ast.ContactId == null) 			
                    ast.Asset_Processing_Status__c += 'Contact Missing'+'; ';
                if(ast.Sold_To_Partner__c == null) 	
                    ast.Asset_Processing_Status__c += 'Sold to Partner Missing'+'; ';
                if(ast.VAR__c == null) 				
                    ast.Asset_Processing_Status__c += 'VAR Missing'+'; ';
                if(ast.AccountId == null) 			
                    ast.Asset_Processing_Status__c += 'Account Missing'+'; ';
            }
            
            if(ast.ContactId == NULL && ast.AccountId == NULL) 
                ast.ContactId = ESP_Utility.ESPConstants.ServiceCloudSettings.Default_Asset_Contact_ID__c;
        }
    }
    
    public static void linkEntitlements(list<Asset> assetList){
        System.debug('In Side Asset Trigger');
        set<String> assetSerialNumSet = new set<String>();
        //set<String> assetPAKIDset = new set<string>();
        map<String, Asset> assetToSNMap = new map<String, Asset>();
        for(Asset asst : assetList)  {
            system.debug('111 asst: '+ asst);
            if(asst != null && (asst.Link_Entitlements__c == true || LINK_ALL_ASSETS)) {
                if(asst.SerialNumber != Null && asst.SerialNumber != '') {
                    assetSerialNumSet.add(asst.SerialNumber);
                    assetToSNMap.put(asst.SerialNumber, asst);
                }
                
                /*Commented to remove search by PAK ID
                if(asst.PAKID__c != Null && asst.PAKID__c != '') {
                    assetSerialNumSet.add(asst.PAKID__c);
                    assetToSNMap.put(asst.PAKID__c, asst);
                } */ 
                if(asst.SAP_Delivery_Number__c != null && asst.SAP_Delivery_Number__c != ''
                  	&& (asst.SerialNumber == Null || asst.SerialNumber == '')
                  ) {
                    assetSerialNumSet.add(asst.SAP_Delivery_Number__c);
                    assetToSNMap.put(asst.SAP_Delivery_Number__c, asst);
                }
                
                if(!isInsert)
                	asst.Link_Entitlements__c = false;
            }
        }
        
        List<Entitlement> EntitlemtLst = new List<Entitlement>();
        EntitlemtLst = [Select Id, PAK_ID__c, AssetId, SAP_Delivery_Number__c, Name, Hardware_Serial_Number__c 
                        From Entitlement where Hardware_Serial_Number__c in: assetSerialNumSet 
                        //OR PAK_ID__c in: assetSerialNumSet //Commented to remove search by PAK ID
                        OR SAP_Delivery_Number__c in: assetSerialNumSet];
        
        if(EntitlemtLst.isEmpty())
            return;
            
        List<Entitlement> EntitlementtoUpdate = new List<Entitlement>();
        for(Entitlement ent: EntitlemtLst){
            if(ent.Hardware_Serial_Number__c != null && ent.Hardware_Serial_Number__c != ''){
                Asset asst = assetToSNMap.get(ent.Hardware_Serial_Number__c);
                if(asst != null){
                    ent.AssetId = asst.Id;
                    system.debug('ent.AssetId : '+ ent.AssetId);
                    asst.Link_Entitlements__c = false;
                }
            }
            
            /*Commented to remove search by PAK ID
            if(ent.PAK_ID__c != null && ent.PAK_ID__c != ''){
                Asset asst = assetToSNMap.get(ent.PAK_ID__c);
                if(asst != null){ 
                    ent.AssetId = asst.Id;
                    system.debug('ent.AssetId : '+ ent.AssetId);
                    asst.Link_Entitlements__c = false;
                }
            } */
            
            if(ent.SAP_Delivery_Number__c != null && ent.SAP_Delivery_Number__c != ''){
                Asset asst = assetToSNMap.get(ent.SAP_Delivery_Number__c);
                if(asst != null){
                    ent.AssetId = asst.Id;
                    system.debug('ent.AssetId : '+ ent.AssetId);
                    asst.Link_Entitlements__c = false;
                }
            }
            
            EntitlementtoUpdate.add(ent);
        }
        //update assetList;
        system.debug('Before Update Entilement =  ' + EntitlementtoUpdate );    
        update EntitlementtoUpdate;
    }
    
    public static void linkComponents(list<Asset> assetList){
        System.debug('In Side Asset Trigger');
        set<String> AssetSerialNumSet = new set<String>();
        for(Asset asst : assetList)  {  
            if(asst != null && asst.SerialNumber != NULL && asst.SerialNumber != '' && (asst.Link_Components__c == true || LINK_ALL_ASSETS))
                AssetSerialNumSet.add(asst.SerialNumber);
        }
        
        List<NV_Component__c> ComponentLst = new List<NV_Component__c>();
        ComponentLst = [ Select Id, Asset_Name__c, Name, Asset_Serial_Number__c From NV_Component__c where Asset_Serial_Number__c in: AssetSerialNumSet];
        Map<String, List<NV_Component__c>> AssetSerialNumtoComponentMap = new Map<String, List<NV_Component__c>>();
        for(NV_Component__c cmp : ComponentLst){
            if(cmp != null){
                if(AssetSerialNumtoComponentMap.containsKey(cmp.Asset_Serial_Number__c)){
                    AssetSerialNumtoComponentMap.get(cmp.Asset_Serial_Number__c).add(cmp);
                } else {
                    list<NV_Component__c> tempCTMList = new list<NV_Component__c>();
                    tempCTMList.add(cmp);
                    AssetSerialNumtoComponentMap.put(cmp.Asset_Serial_Number__c, tempCTMList);
                }
            }
        }
        
        List<NV_Component__c> ComponentoUpdate = new List<NV_Component__c>();
        for(Asset o : assetList) {
            System.debug('Test Point 0000000');
            list<NV_Component__c> existingComponentList = AssetSerialNumtoComponentMap.get(o.SerialNumber);
            if(AssetSerialNumtoComponentMap.containsKey(o.SerialNumber)){
                System.debug('Test Point 11111111');
                for(NV_Component__c cmp : existingComponentList){
                    System.debug('Ent data :' + cmp);
                    if(cmp.Asset_Serial_Number__c == o.SerialNumber){
                        cmp.Asset_Name__c = o.Id;
                        ComponentoUpdate.add(cmp);
                    }
                }
                o.Link_Components__c = false;
            }
        }
        //update assetList;
        update ComponentoUpdate;
    }
    
    /*public static void UpdateName() {
        for(Asset ast : newRecords) {
            String description = string.IsBlank(ast.Product2.Name) ? '' : '-' + ast.Product2.Name;
            String astName = string.IsBlank(ast.SerialNumber) ? ast.PAKID__c  +  description : ast.SerialNumber + description;
            ast.Name = astName.left(80);
        }
    } */
    
    public static void RelinkEntandComponents() {
        Set<String> astIdSet = new Set<String>();
        for(Asset ast : newRecords) {
            Asset oldAsset = oldRecordsMap.get(ast.Id);
            if(ast.Serial_Number__c != oldAsset.Serial_Number__c || ast.PAKID__c != oldAsset.PAKID__c) {
                astIdSet.add(ast.Id);
                ast.Link_Components__c = true;
                ast.Link_Entitlements__c = true;
            }
        }
        if(astIdSet.size()> 0){
            List<NV_Component__c> ComponentList = [Select Id, Asset_Name__c From NV_Component__c where Asset_Name__c IN: astIdSet];
            List<Entitlement> EntitlemtList = [Select  Id, AssetId From Entitlement where AssetId IN: astIdSet];
            
            if(ComponentList != null && ComponentList.size()>0){
                for(NV_Component__c cmp : ComponentList) {
                    cmp.Asset_Name__c = null;
                }
                update ComponentList;
            }
            
            if(EntitlemtList != null && EntitlemtList.size()>0){
                for(Entitlement ent : EntitlemtList) {
                    ent.AssetId = null;
                }
                update EntitlemtList;
            }
            Asset_tgr_cls.linkEntitlements();
            Asset_tgr_cls.linkComponents();
        }
        
        
        //1. Logic to remove AssetID from entitlemnts
        //If(Serial Number is changed or PAKID is changed)
        //Find all Entitlements and Components matching with AssetIDs
        //	Then Entitlement.AssetId = NULL;
        //	And Component.AssetId = NULL;
        
        //2. Find and Link new Entitlements and Components.
        //Call functions to link any existing Entitlments and Entitlements:
        //Asset_tgr_cls.linkEntitlements();
        //Asset_tgr_cls.linkComponents();
    }
    
}