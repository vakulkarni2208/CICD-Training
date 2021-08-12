/******************************************************************************************************************
       * Author: Samar Saha
       * Date: Apr 2021
       * Class Name : CPQPricingLookupTrigger_cls
       * Description: Handler class for CPQPricingLookupTrigger on CPQ_Pricing_Lookup__c object
******************************************************************************************************************/ 
public class CPQPricingLookupTrigger_cls{

    //Trigger Scenarios
    public static final String TRIGGER_BEFORE_INSERT = 'BEFORE_INSERT';
    public static final String TRIGGER_BEFORE_UPDATE = 'BEFORE_UPDATE';
    public static final String TRIGGER_AFTER_INSERT = 'AFTER_INSERT';
    public static final String TRIGGER_AFTER_UPDATE = 'AFTER_UPDATE'; 
    public static boolean firstRun = true;
    
    public CPQPricingLookupTrigger_cls(List<CPQ_Pricing_Lookup__c> newCPQPricingLookups, List<CPQ_Pricing_Lookup__c> oldCPQPricingLookups, String triggerAction) {
        System.debug('Inside CPQPricingLookupTrigger handler and trigger action is: ' + triggerAction); 
        List<CPQ_Pricing_Lookup__c> updateList = new List<CPQ_Pricing_Lookup__c>();
        
        if(triggerAction == TRIGGER_BEFORE_INSERT || triggerAction == TRIGGER_BEFORE_UPDATE)  {  
            List<String> priceIdentifierList = new List<String>();
            if(newCPQPricingLookups.size()>0 && newCPQPricingLookups !=null){
                for(CPQ_Pricing_Lookup__c cpqLook : newCPQPricingLookups ){
                    priceIdentifierList.add(cpqLook.Name + cpqLook.Condition_Type__c + cpqLook.Inactive_To_String__c + string.valueOf(cpqLook.Valid_To__c));                
                }
            }
            
            //fetching all CPQ lookup pricing records sharing same priceIdentifier as the new one pushed from SAP
            List<CPQ_Pricing_Lookup__c> cpqLookUpList = [Select Id, Name, Condition_Type__c, Inactive__c, Inactive_To_String__c, Valid_To__c, Condition_Record_Number__c, CPQ_Price_Identifier__c  
                                                         from CPQ_Pricing_Lookup__c where CPQ_Price_Identifier__c IN: priceIdentifierList];
                                                       
            if(cpqLookUpList.size()>0 && cpqLookUpList !=null && triggerAction == TRIGGER_BEFORE_INSERT){
                for(CPQ_Pricing_Lookup__c existingCPQLookUps : cpqLookUpList){
                    for(CPQ_Pricing_Lookup__c newCPQLookUps : newCPQPricingLookups ){
                        if(newCPQLookUps.Name == existingCPQLookUps.Name &&
                           newCPQLookUps.Condition_Type__c == existingCPQLookUps.Condition_Type__c &&
                           newCPQLookUps.Inactive__c == existingCPQLookUps.Inactive__c &&
                           newCPQLookUps.Valid_To__c == existingCPQLookUps.Valid_To__c){
                           if(newCPQLookUps.Condition_Record_Number__c >= existingCPQLookUps.Condition_Record_Number__c ){
                               existingCPQLookUps.Inactive__c = TRUE;  
                               updateList.add(existingCPQLookUps);
                           }
                           else{
                               newCPQLookUps.Inactive__c = TRUE;    
                           }                          
                        }               
                    }
                }
            }
            
            if(cpqLookUpList.size()> 1 && cpqLookUpList !=null && triggerAction == TRIGGER_BEFORE_UPDATE){
                for(CPQ_Pricing_Lookup__c existingCPQLookUps : cpqLookUpList){
                    for(CPQ_Pricing_Lookup__c updateCPQLookUps : newCPQPricingLookups ){
                        if(updateCPQLookUps.Id != existingCPQLookUps.Id &&
                           updateCPQLookUps.Name == existingCPQLookUps.Name &&
                           updateCPQLookUps.Condition_Type__c == existingCPQLookUps.Condition_Type__c &&
                           updateCPQLookUps.Inactive__c == existingCPQLookUps.Inactive__c &&
                           updateCPQLookUps.Valid_To__c == existingCPQLookUps.Valid_To__c){
                           if(updateCPQLookUps.Condition_Record_Number__c >= existingCPQLookUps.Condition_Record_Number__c ){
                               existingCPQLookUps.Inactive__c = TRUE;  
                               updateList.add(existingCPQLookUps); 
                           }
                           else{
                               updateCPQLookUps.Inactive__c = TRUE; 
                           }                          
                        }               
                    }
                }
            
            }
            
            if(updateList.size()>0 && updateList != null)
            update updateList;
            
            System.debug('*********Before Insert/Update event of CPQPricingLookupTrigger executed*********');                           
        }        
    }                   
}//End of class