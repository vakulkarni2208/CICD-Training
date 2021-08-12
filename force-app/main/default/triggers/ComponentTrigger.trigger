trigger ComponentTrigger on NV_Component__c (before insert, before update) {
    ComponentTriggerHelper helper = new ComponentTriggerHelper(); 
    helper.execute();
}