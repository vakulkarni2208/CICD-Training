trigger SuRF_DGX_HOT_CPL_tgr on SuRF_DGX_HOT_Compliance__c (after insert) {
    
    
    if((Trigger.isAfter && Trigger.isInsert)) {
        SuRF_DGX_HOT_CPL_tgr_cls.process_DGX_HOT_Status (trigger.NewMap);    
    }

}