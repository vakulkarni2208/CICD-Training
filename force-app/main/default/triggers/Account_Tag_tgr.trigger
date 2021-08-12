/*
	Trigger trigger Account_Tag__c object 
	
	Functionality:
	2017.04.17 - After insert, after update, after delete events - set Account field "Account_Tags__c"
	
*/

trigger Account_Tag_tgr on Account_Tag__c (after delete, after insert, after update) {
    if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
    	       
        //2017.04.17 - After insert, after update, after delete events - set Account field "Account_Tags__c"
        Account_Tag_tgr_cls.setAccountTags(trigger.new);
    }
    
    if (trigger.isAfter && trigger.IsDelete){
    	//2017.04.17 - After insert, after update, after delete events - set Account field "Account_Tags__c"
    	Account_Tag_tgr_cls.setAccountTags(trigger.old);
    }
    
}