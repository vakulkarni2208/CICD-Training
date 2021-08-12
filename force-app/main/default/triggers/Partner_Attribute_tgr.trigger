/*
	2016.09.24 - After insert, after update, after delete events - set Account field "NPN Active Program - Competency"
	2017.11.08 - Level Change Date - Update existing NPN Revenue Target for Current Fiscal Year

*/

trigger Partner_Attribute_tgr on Partner_Attribute__c (after insert, after update, after delete) {
	
    if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
    	//Insert NPN Revenue Target record for current Year and matching Competency, Level (if it is not already present)
        Partner_Attribute_tgr_cls.createNPNRevenueTarget(trigger.new);
        
        //2016.09.24 - After insert, after update, after delete events - set Account field "NPN Active Program - Competency"
        Partner_Attribute_tgr_cls.setAccountNPNActiveProgramCompetency(trigger.new);
        
        //2017.11.08 - Level Change Date - Update existing NPN Revenue Target for Current Fiscal Year
        if (trigger.isAfter && trigger.isUpdate){
        	Partner_Attribute_tgr_cls.updateExistingNPNRevenueTargetOnLevelChange(trigger.oldMap, trigger.newMap);
        }
    }
    
    
    //2016.09.24 - After insert, after update, after delete events - set Account field "NPN Active Program - Competency"
    if (trigger.isAfter && trigger.IsDelete){
    	Partner_Attribute_tgr_cls.setAccountNPNActiveProgramCompetency(trigger.old);
    }
}