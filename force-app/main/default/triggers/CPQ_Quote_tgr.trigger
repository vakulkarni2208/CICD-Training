trigger CPQ_Quote_tgr on SBQQ__Quote__c (after update,after Insert, before Insert, before Update) {
    if(CPQ_Quote_tgr_cls.DISABLE_TRIGGER == FALSE) {
        CPQ_Quote_tgr_cls helper = new CPQ_Quote_tgr_cls();
        helper.execute();
    }
}