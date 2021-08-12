trigger NPN_SuRF_Transit_Start on SuRF_UpdateStart__c (after insert) {
    SuRF_Transit__c trans = SuRF_Transit__c.getOrgDefaults();
    trans.isTransit__c = true;
    update trans;
    NPN_SuRF_Batch_PPS PPS = new NPN_SuRF_Batch_PPS();
    NPN_SuRF_Batch_C C = new NPN_SuRF_Batch_C();
    NPN_SuRF_Batch_CT CT = new NPN_SuRF_Batch_CT();
    NPN_SuRF_Batch_PL PL = new NPN_SuRF_Batch_PL();
    NPN_SuRF_Batch_O O = new NPN_SuRF_Batch_O();
    NPN_SuRF_Batch_LM LM = new NPN_SuRF_Batch_LM();
    NPN_SuRF_Batch_PS PS = new NPN_SuRF_Batch_PS();
    NPN_SuRF_Batch_POS POS = new NPN_SuRF_Batch_POS();
    NPN_SuRF_Batch_DGX_HOT_Compliance DHC = new NPN_SuRF_Batch_DGX_HOT_Compliance();
    NPN_SuRF_Batch_DGX_HOT_CPL_Contacts DHCC = new NPN_SuRF_Batch_DGX_HOT_CPL_Contacts();   
    Database.executeBatch(PPS);
    Database.executeBatch(C);
    Database.executeBatch(CT);
    Database.executeBatch(PL);
    Database.executeBatch(O);
    Database.executeBatch(LM);
    Database.executeBatch(PS);
    Database.executeBatch(POS);
    Database.executeBatch(DHC);
    Database.executeBatch(DHCC);
}