/******************************************************************************************************************
       * Author: Samar Saha
       * Date: Apr 2021
       * Trigger - CPQPricingLookupTrigger on CPQ_Pricing_Lookup__c object 
       * Description: Trigger to handle udplicate records
******************************************************************************************************************/  
trigger CPQPricingLookupTrigger on CPQ_Pricing_Lookup__c (before insert, after insert, before update, after update) {   
        
    CPQPricingLookupTrigger_cls cpqPricingLookupTriggerHandler;    
        
    if (Trigger.isBefore && Trigger.isInsert)
    { 
        cpqPricingLookupTriggerHandler = new CPQPricingLookupTrigger_cls(Trigger.new, Trigger.old, CPQPricingLookupTrigger_cls.TRIGGER_BEFORE_INSERT);
    }
    if (Trigger.isBefore && Trigger.isUpdate)
    {
       if(CPQPricingLookupTrigger_cls.firstRun){
           cpqPricingLookupTriggerHandler = new CPQPricingLookupTrigger_cls(Trigger.new, Trigger.old, CPQPricingLookupTrigger_cls.TRIGGER_BEFORE_UPDATE);
       }
       CPQPricingLookupTrigger_cls.firstRun = False;
    }
    if (Trigger.isAfter && Trigger.isInsert)
    { 
       cpqPricingLookupTriggerHandler = new CPQPricingLookupTrigger_cls(Trigger.new, Trigger.old, CPQPricingLookupTrigger_cls.TRIGGER_AFTER_INSERT);
    }
    if (Trigger.isAfter && Trigger.isUpdate)
    {
        cpqPricingLookupTriggerHandler = new CPQPricingLookupTrigger_cls(Trigger.new, Trigger.old, CPQPricingLookupTrigger_cls.TRIGGER_AFTER_UPDATE);
    }
    
}