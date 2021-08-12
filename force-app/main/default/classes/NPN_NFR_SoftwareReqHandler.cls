public without sharing class NPN_NFR_SoftwareReqHandler {

	public static boolean flag = true;

	/**
	 * @name    afterUpdate
	 * @param   triggerNewMap
	 * @param   triggerOldMap
	 */
	public static void afterInsert(Map<Id, NPN_NFR_Software_Request__c> triggerNewMap, Map<Id, NPN_NFR_Software_Request__c> triggerOldMap) {
		NPN_NFR_SoftwareReqHelper.changeOwner(triggerNewMap);
	}

	/**
	 * @name    afterUpdate
	 * @param   triggerNewMap
	 * @param   triggerOldMap
	 */
	public static void afterUpdate(Map<Id, NPN_NFR_Software_Request__c> triggerNewMap, Map<Id, NPN_NFR_Software_Request__c> triggerOldMap) {
		if(flag) {
			flag = false;
			NPN_NFR_SoftwareReqHelper.linkDocuSignStatus(triggerNewMap);
		}
	}
}