trigger NV_NPN_PAM on NPN_PartnerAttributes_Modifiaction__c (after update) {
    
    list<NPN_PartnerAttributes_Modifiaction__c> lstPAMFullTermination = new list<NPN_PartnerAttributes_Modifiaction__c>();
    list<NPN_PartnerAttributes_Modifiaction__c> lstPAMCompetencyTermination = new list<NPN_PartnerAttributes_Modifiaction__c>();
    
    for(NPN_PartnerAttributes_Modifiaction__c objPAM : trigger.new) {
        if(Trigger.oldMap.get(objPAM.id).Competency_Termination_30_days_Complete__c != Trigger.newMap.get(objPAM.id).Competency_Termination_30_days_Complete__c && Trigger.newMap.get(objPAM.id).Competency_Termination_30_days_Complete__c == True) {
            if(objPAM.PartnerAttributes_Modification__c == 'Termination') {
                lstPAMFullTermination.add(objPAM);
            } else if(objPAM.PartnerAttributes_Modification__c == 'Competency Termination') {
                lstPAMCompetencyTermination.add(objPAM);
            }
            
        }
    }
    
    if(lstPAMFullTermination.size() > 0) {        
        NV_DocusignAccountHelper.Termination(lstPAMFullTermination);
    }
    if(lstPAMCompetencyTermination.size() > 0) {
        NV_DocusignAccountHelper.competencyTermination(lstPAMCompetencyTermination);
    }
    if((Trigger.isAfter && Trigger.isUpdate)) {
        NPN_PAMHandler.afterUpdate(trigger.NewMap, trigger.OldMap);
    }
}