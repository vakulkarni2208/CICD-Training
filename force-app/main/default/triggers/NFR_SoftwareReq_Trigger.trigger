trigger NFR_SoftwareReq_Trigger on NPN_NFR_Software_Request__c (before update, after insert, after update) {

	if((Trigger.isAfter && Trigger.isInsert)) {
		NPN_NFR_SoftwareReqHandler.afterInsert(trigger.NewMap, trigger.OldMap);
	}

	if((Trigger.isAfter && Trigger.isUpdate)) {
		NPN_NFR_SoftwareReqHandler.afterUpdate(trigger.NewMap, trigger.OldMap);
	}
}