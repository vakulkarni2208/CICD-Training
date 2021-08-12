trigger CustomOrderTrigger on Order ( before insert, before update) {
    
    
    
    if (trigger.isInsert || trigger.isUpdate){
        system.debug('---------'+trigger.new);
        if(Utility.IsTriggered == false) {      
        OrderTriggerClass.ProcessOrder(trigger.new);
            Utility.IsTriggered=true;
            }
        
    }
    
   
}