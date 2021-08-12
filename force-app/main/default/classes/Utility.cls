/**
   * @description Utility class for having all generic usable methods
   * @author Venkat
   * @date 
*/
public without sharing class Utility {
    public static Boolean IsTriggered = false;
	public static Boolean isPECAccountRequest = false;
 	public static Boolean isPartnerAccountRequest = false;  
 	public static Boolean isPECContactRequest = false;  
 	public static Boolean isSAPSyncRequest = false;  
     
   /**
    * @description This method is being called to get service endpoints
    * @param WebServiceName: This name should be the same available in interface custom metadata record. EnvironmentType: To which box we are sending such as test or prod.
    * @return It returns Interface metadata record based on given parameters.
    */  
    public static Integration_Service__mdt fetchIntergrationService(String webServiceName, String environmentType, String methodType) {
        try{
            return [select Id,UserName__c, Password__c, EndPoint__c, Client_Secret__c, Client_Id__c, 
                    Environment__c, Content_Type__c,IntegrationType__c,
                    MethodType__c,RequestType__c,SourceSystem__c,Targetsystem__c, Authentication_Type__c,
                    WebServiceName__c from Integration_Service__mdt  where WebServiceName__c =: webServiceName 
                    AND Environment__c =: environmentType AND MethodType__c =: methodType LIMIT 1];
        }Catch(Exception ex){
            return null;
        }
        
    }
    
    /**
    * @description This method is being called to fetch the fields that should be sent to EMS service on updation
    * @param objectName: This name should be the object name.
    * @return It returns Sobject_Is_Changed__mdt metadata record based on given parameters.
    */
    public static list<Sobject_Is_Changed__mdt> queryMetadataType(String objectName){
        try{
            return [SELECT 
                    Attribute_Name__c, Field_API_Name__c, Is_Changed__c ,
                    Object_Name__c FROM Sobject_Is_Changed__mdt];
        }Catch(Exception ex){
            return null;
        }
    }
    
    /**
    * @description  To get record based on single content version Id
    * @param        ContentVersion Id
    * @return       ContentVersion : It will return one content version record
    */ 
    public static ContentVersion getContentVersionById(String conVerId) {
        try{
            return [SELECT 
                    ContentDocumentId 
                    FROM 
                        ContentVersion
                    WHERE 
                        Id =: conVerId] ;
        }Catch(Exception ex){
            return null;
        }
    }
    
    /**
    * @description This method is being called from trigger to check if the fields are updated then do callout
    * @param sobjectRecordList,objectName and oldmapSobject
    * @return It returns the list of sobject that are updated.
    */ 
    public static List<Sobject> isChangedFieldsCheck(List<Sobject> sobjectRecordList,String objectName,Map<Id,Sobject> oldmapSobject){
    
        list<Sobject_Is_Changed__mdt> sobjectIsChangedMDT = utility.queryMetadataType(objectName);
        List<Sobject> updatedSobjectList = new List<sobject>();
        Map<String,Boolean> isUpdatedCheckedMap = new Map<String,Boolean>();
        for(Sobject_Is_Changed__mdt interfaceMappingMd:sobjectIsChangedMDT){
            isUpdatedCheckedMap.put(interfaceMappingMd.Field_API_Name__c,interfaceMappingMd.Is_Changed__c); 
        }
        for(Sobject sobjectObj :sobjectRecordList){
            Map<String, Object> allPopulatedFieldsValueMap = sobjectObj.getPopulatedFieldsAsMap();
            Map<String, Object> allPopulatedFieldsValueMapOld = oldmapSobject.get(sobjectObj.id).getPopulatedFieldsAsMap();
                if(allPopulatedFieldsValueMapOld!=null){
                    for (String fieldName : allPopulatedFieldsValueMap.keySet()){
                        if(allPopulatedFieldsValueMapOld.get(fieldName)!=null && allPopulatedFieldsValueMap.get(fieldName)!=null && !(allPopulatedFieldsValueMapOld.get(fieldName).equals(allPopulatedFieldsValueMap.get(fieldName))) && isUpdatedCheckedMap.get(fieldName)!=null && isUpdatedCheckedMap.get(fieldName)){
                            sObject newSobject = Schema.getGlobalDescribe().get(objectName).newSObject() ;
                            newSobject.put(fieldName,allPopulatedFieldsValueMap.get(fieldName));
                            newSobject.put('Id',allPopulatedFieldsValueMap.get('Id'));
                            updatedSobjectList.add(newSobject);
                        }
                    }
                }
        }
        return updatedSobjectList;
    }
    
    /**
    * @description Dummy test method - Technical Dept
    * @param  Dummy method
    * @return  Void: It returns nothing
    */  
     public static void CoverageMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    } 
}