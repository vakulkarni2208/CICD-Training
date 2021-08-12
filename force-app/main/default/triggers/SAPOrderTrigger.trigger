/*

    Updated 7/3/2018
    Removed Connection to Quote Generator Helper and replaced with new CPQ Class
    Changed from after Insert to before insert/before update
*/
trigger SAPOrderTrigger on SAP_Order__c (before insert, before update, after insert) {
  
    //// generate quote from SAP order
    //if (Trigger.isInsert && Trigger.isAfter) {
        
    //    // orders will be modified to add the opportunity Id, and Trigger.new is read-only
    //    // need to create a new list
         
    //    Set<Id> newOrderIds = Trigger.newMap.keyset();
        
    //    List<SAP_Order__c> orders = new List<SAP_Order__c>();
    //    for (SAP_Order__c order :Trigger.New) {
            
    //        // clone and preserve id
    //        orders.add(order.clone(true));
            
    //    }
        
    //    if (!Test.isRunningTest()) {
            
    //    	QuoteGeneratorHelper.createQuotes(orders);
            
    //    }
     
    //}

	if(!SAPOrder_tgr_cls.skipTriggerActions) {
		SAPOrder_tgr_cls handler = new SAPOrder_tgr_cls();
		handler.execute();
	    if (trigger.isBefore) { //!Test.isRunningTest() && 
	        CPQ_SAP_Order_Processor cpq=new CPQ_SAP_Order_Processor();
	        cpq.initialization(trigger.new);
	    } else if (trigger.isAfter) { //!Test.isRunningTest() &&  
	        CPQ_SAP_Order_Processor cpq=new CPQ_SAP_Order_Processor();
	        cpq.processSapIds(trigger.new);
	    }
	}
}