/**************************************************************************************************
* Name       : ComponentTriggerHelper
* Purpose    : Helper class for Component Trigger 
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Akhilesh Gupta     | 1.0        | 06/28/2020      | Initial Draft
*Akhilesh Gupta     | 1.0        | 06/28/2020      | Final Draft
*Akhilesh Gupta		| 1.1        | 06/28/2020      | Added two methods AddAnnouncement and getAnnoucementsToAddByAccount
*Akhilesh Gupta 	| 2.0		 | 06/28/2020	   | Updated code to implement Trigger Handler
												   | Add Logic to update Component Name	
												   | Remove code responsible to assign Knowledge Category Permissions
*Akhilesh Gupta 	| 2.0		 | 06/28/2020	   | SDS-2064 - Updated "UpdateComponent" function to use support level from Product 
    												- User new Constants framework, use ESP_Utility functions instead of ServiceCloudUtils.
**************************************************************************************************/

public with sharing class ComponentTriggerHelper extends NV_TriggerHandler {
    public list<NV_Component__c> oldRecords;
    private static list<NV_Component__c> triggerNewList;
    private static map<Id, NV_Component__c> mapTriggerOld;
    public override void init() {
        oldRecords = trigger.old;
        triggerNewList = trigger.New;
        if(oldRecords != null)
            mapTriggerOld = new map<Id, NV_Component__c>(oldRecords);
        System.debug('Old Records' + oldRecords + '1');
        System.debug('New Records' + trigger.New + '1');
    }
    
    public override void beforeInsert() {
        ComponentTriggerHelper.setPartsInformation();
        ComponentTriggerHelper.linkAsset();//Mit
    }
    public override void beforeUpdate() {
        ComponentTriggerHelper.setPartsInformation();
        ComponentTriggerHelper.linkAsset(); //Mit
    }
    
    public static void setPartsInformation(){
        try{
            set<String> partNumbers = new set<String>();
            for(NV_Component__c cmp : triggerNewList){
                if(cmp.System_Part__c == null && cmp.Material_Number__c != null && cmp.Material_Number__c != '')
                    partNumbers.add(cmp.Material_Number__c);
                if(cmp.Component_Part__c == null && cmp.Component_PN__c != null && cmp.Component_PN__c != '') 
                    partNumbers.add(cmp.Component_PN__c);
            }
            
            queryPartDetails(partNumbers);
            
            //Set System Part and Component Part
            for(NV_Component__c cmp : triggerNewList) {
                if(cmp.System_Part__c == null && cmp.Material_Number__c != null && cmp.Material_Number__c != '') {
                    Part__c part = Parts_By_PartNumber_Map.get(cmp.Material_Number__c);
                    if(part != null)
                        cmp.System_Part__c = part.Id;
                }
                if(cmp.Component_Part__c == null && cmp.Component_PN__c != null && cmp.Component_PN__c != '') {
                    Part__c part = Parts_By_PartNumber_Map.get(cmp.Component_PN__c);
                    if(part != null)
                        cmp.Component_Part__c = part.Id;
                }
            }
        }catch (Exception ex) {
            ServiceCloudUtils.LogErrors('ComponentTriggerHelper.setPartsInformation() : ' + ex.getMessage(), ex.getStackTraceString());
        }
    }
    
    public static map<String, Part__c> Parts_By_PartNumber_Map = new map<String, Part__c>();
    public static void queryPartDetails(set<String> partNumbers) {
        list<Part__c> partsList = [select Id, Part_Number__c from Part__c where Part_Number__c in: partNumbers];
        
        if(!partsList.isEmpty()) {
            for(Part__c part: partsList) {
                Parts_By_PartNumber_Map.put(part.Part_Number__c, part);
            }
        }
    }
    
    
    //Mit
        Public static void linkAsset(){
        set<String> serialNumberSet = new set<String>();
        for(NV_Component__c cmpnt : triggerNewList){
            if(cmpnt.Link_Asset__c == true && cmpnt.Asset_Serial_Number__c != null && cmpnt.Asset_Serial_Number__c != '')
            serialNumberSet.add(cmpnt.Asset_Serial_Number__c);
            cmpnt.Link_Asset__c = false;
        }
        
        if(serialNumberSet.isEmpty())
            return;

        List<Asset> AssetLst = new List<Asset>();
        AssetLst  = [Select Id, Name, SerialNumber from Asset where SerialNumber in: serialNumberSet];
        if(AssetLst.isEmpty())
            return; 
        
        Map <String, Asset> SNtoAssetMap = New Map<String, Asset>();
        for(Asset ast: AssetLst){
            SNtoAssetMap.put(ast.SerialNumber, ast);
        }

        for(NV_Component__c cmpnt: triggerNewList) {
            if(SNtoAssetMap.containsKey(cmpnt.Asset_Serial_Number__c)){
                cmpnt.Asset_Name__c = SNtoAssetMap.get(cmpnt.Asset_Serial_Number__c).id; 
            }
        }

        /*Map<String, List<NV_Component__c>> serialNumtoComponentMap = new Map<String, List<NV_Component__c>>();
        for(NV_Component__c cmpnt: triggerNewList){
            if(cmpnt != null){
                if(serialNumtoComponentMap.containsKey(cmpnt.Asset_Serial_Number__c)){
                    serialNumtoComponentMap.get(cmpnt.Asset_Serial_Number__c).add(cmpnt);
                } else {
                    list<NV_Component__c> tempCmpntList = new list<NV_Component__c>();
                    tempCmpntList.add(cmpnt);
                    serialNumtoComponentMap.put(cmpnt.Asset_Serial_Number__c, tempCmpntList);
                }
            }
        }
        
        List<NV_Component__c> ComponenttoUpdate = new List<NV_Component__c>();
        for(Asset ast : AsseltLst){
                if(serialNumtoComponentMap.containsKey(ast.SerialNumber)){
                    for(NV_Component__c cmpnt : serialNumtoComponentMap.get(ast.SerialNumber)){
                        if(cmpnt.Asset_Serial_Number__c == ast.SerialNumber){
                            cmpnt.Asset_Name__c = ast.Id;
                            cmpnt.Link_Asset__c = false;
                        	ComponenttoUpdate.add(cmpnt);
                        }
                    }
                }
            }
        //update ComponenttoUpdate;*/
    }
}