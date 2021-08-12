/*
	PJENA: 2019.08.02 - trigger to set Region from Country with reference to Country_List__c mapping records
	
*/
trigger Dev_Contact_tgr on Dev_Contact__c (before insert, before update) {
     if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        Dev_Contact_tgr_cls.setRegion(trigger.new);
     }
}