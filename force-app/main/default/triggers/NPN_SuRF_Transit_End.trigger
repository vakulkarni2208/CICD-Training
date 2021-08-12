trigger NPN_SuRF_Transit_End on SuRF_UpdateTime__c (after insert) {
    SuRF_Transit__c trans = SuRF_Transit__c.getOrgDefaults();
    trans.isTransit__c = false;
    update trans;
}