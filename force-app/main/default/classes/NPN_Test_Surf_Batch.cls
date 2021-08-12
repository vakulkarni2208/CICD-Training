@isTest
private class NPN_Test_Surf_Batch {
    
    static testMethod void testBatchC() {
        SuRF_Contacts__c objSC = new SuRF_Contacts__c();
        insert objSC;
        NPN_SuRF_Batch_C objC = new NPN_SuRF_Batch_C();
        Database.executeBatch(objC);
    }
    
    static testMethod void testBatchCT() {
        SuRF_Contacts_and_Training__c objSCT = new SuRF_Contacts_and_Training__c();
        insert objSCT;
        NPN_SuRF_Batch_CT objCT = new NPN_SuRF_Batch_CT();
        Database.executeBatch(objCT);
    }
    
    static testMethod void testBatchLM() {
        SuRF_Lead_Management__c objSLM = new SuRF_Lead_Management__c();
        insert objSLM;
        NPN_SuRF_Batch_LM objLM = new NPN_SuRF_Batch_LM();
        Database.executeBatch(objLM);
    }
    
    static testMethod void testBatchO() {
        SuRF_Opportunity__c objSO = new SuRF_Opportunity__c();
        insert objSO;
        NPN_SuRF_Batch_O objO = new NPN_SuRF_Batch_O();
        Database.executeBatch(objO);
    }
    
    static testMethod void testBatchPL() {
        SuRF_Portal_Login__c objSPL = new SuRF_Portal_Login__c();
        insert objSPL;
        NPN_SuRF_Batch_PL objPL = new NPN_SuRF_Batch_PL();
        Database.executeBatch(objPL);
    }
    
    static testMethod void testBatchPOS() {
        SuRF_POS__c objSPOS = new SuRF_POS__c();
        insert objSPOS;
        NPN_SuRF_Batch_POS objPOS = new NPN_SuRF_Batch_POS();
        Database.executeBatch(objPOS);
    }
    
    static testMethod void testBatchPPS() {
        SuRF_Partner_Performance_Scorecard__c objSPPS = new SuRF_Partner_Performance_Scorecard__c();
        insert objSPPS;
        NPN_SuRF_Batch_PPS objPPS = new NPN_SuRF_Batch_PPS();
        Database.executeBatch(objPPS);
    }
    
    static testMethod void testBatchPS() {
        SuRF_Transit__c trans = SuRF_Transit__c.getOrgDefaults();
        trans.isTransit__c = true;
        insert trans;
        SuRF_UpdateTime__c objSUT = new SuRF_UpdateTime__c();
        insert objSUT;
        SuRF_UpdateStart__c objSUS = new SuRF_UpdateStart__c();
        insert objSUS;
        SuRF_POS_Submission__c objSPS = new SuRF_POS_Submission__c();
        insert objSPS;
        NPN_SuRF_Batch_PS objPS = new NPN_SuRF_Batch_PS();
        Database.executeBatch(objPS);
    }

    @isTest 
    static void testBatchDHTC(){
        SuRF_DGX_HOT_Compliance__c  objDHTC = new SuRF_DGX_HOT_Compliance__c ();
        insert objDHTC;
        NPN_SuRF_Batch_DGX_HOT_Compliance objDHTC_Batch = new NPN_SuRF_Batch_DGX_HOT_Compliance();
        Database.executeBatch(objDHTC_Batch);
    }

    @isTest 
    static void testBatchDHTCC(){
        SuRF_DGX_HOT_CPL_Contacts__c  objDHTCC = new SuRF_DGX_HOT_CPL_Contacts__c ();
        insert objDHTCC;
        NPN_SuRF_Batch_DGX_HOT_CPL_Contacts objDHTCC_Batch = new NPN_SuRF_Batch_DGX_HOT_CPL_Contacts();
        Database.executeBatch(objDHTCC_Batch);
    }
}