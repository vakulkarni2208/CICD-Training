public without sharing class NV_PartnerTrainingPOSComplianceCtrl {
    
    private static Boolean isTransit = SuRF_Transit__c.getOrgDefaults().isTransit__c;
    public Decimal dTrainingCmpl{get;set;}
    public Decimal dPOSCmpl{get;set;}
    public Decimal dDGXHOTCmpl{get;set;}    // Added for SDS-3054
    public Decimal dRegComplStatus{get;set;}    // Added for SDS-3181
    public String strCompetency{get;set;}
    public static final string LEAD_PRODUCT_TYPE_PARABRICKS = 'Parabricks';
    public static final string LEAD_PRODUCT_TYPE_DLI = 'DLI';
    private lead objLead;
    list<Surf_Partner_Performance_Scorecard__c> lstPPS = new list<Surf_Partner_Performance_Scorecard__c>();
    list<Surf_Partner_Performance_Scorecard_Trans__c> lstPPST = new list<Surf_Partner_Performance_Scorecard_Trans__c>();
    List<SuRF_DGX_HOT_Compliance__c> lstSDHT = new List<SuRF_DGX_HOT_Compliance__c>();  // Added for SDS-3054
    List<SuRF_DGX_HOT_Compliance_Trans__c> lstSDHTT = new List<SuRF_DGX_HOT_Compliance_Trans__c>();  // Added for SDS-3054
    Set<String> signedCompetencySet = new Set<String>();

    public NV_PartnerTrainingPOSComplianceCtrl(ApexPages.StandardController controller) {
        objLead = [SELECT id,DR_Deal_Type__c,DR_Partner_Sales_Rep_Company__c FROM Lead where id =:controller.getId()];
        
        if(!isTransit) {
            if(objLead.DR_Deal_Type__c == COMM_CONSTANTS.LEAD_PRODUCT_TYPE_DGX || objLead.DR_Deal_Type__c == LEAD_PRODUCT_TYPE_PARABRICKS || objLead.DR_Deal_Type__c == LEAD_PRODUCT_TYPE_DLI) {
                strCompetency = COMM_CONSTANTS.TEST_PORTAL_COMPETENCY_DL;
                lstPPS = [SELECT id, Category__c, flag__c FROM Surf_Partner_Performance_Scorecard__c where Account_Id__c =:objLead.DR_Partner_Sales_Rep_Company__c and Partner_Program__c =:COMM_CONSTANTS.PA_PROGRAM_SP  and (competency__c =:COMM_CONSTANTS.TEST_PORTAL_COMPETENCY_DL or competency__c =:COMM_CONSTANTS.LEAD_PRODUCT_TYPE_DGX) and (Category__c = 'Training Compliance' or Category__c = 'POS Revenue') ];

                /* Changes for SDS-3054 START */
                lstSDHT = [SELECT Account_Id__c, Account_Name__c,BillingCountry__c,Billing_Sub_Region__c,Category__c,Competency__c,Flag__c,Id,Name,Order__c,Partner_Program_Name__c, Partner_Sub_Program__c FROM SuRF_DGX_HOT_Compliance__c WHERE Account_Id__c =:objLead.DR_Partner_Sales_Rep_Company__c AND Partner_Program_Name__c =:COMM_CONSTANTS.PA_PROGRAM_SP AND (Competency__c =:COMM_CONSTANTS.TEST_PORTAL_COMPETENCY_DL OR Competency__c =:COMM_CONSTANTS.LEAD_PRODUCT_TYPE_DGX) AND Category__c = 'Training Compliance'];
                /* Changes for SDS-3054 END */
            } else if(objLead.DR_Deal_Type__c == COMM_CONSTANTS.LEAD_PRODUCT_TYPE_GRID ) {
                strCompetency = COMM_CONSTANTS.TEST_PORTAL_COMPETENCY_GV ;
                lstPPS = [SELECT id, Category__c, flag__c FROM Surf_Partner_Performance_Scorecard__c where Account_Id__c =:objLead.DR_Partner_Sales_Rep_Company__c  and Partner_Program__c =:COMM_CONSTANTS.PA_PROGRAM_SP and competency__c = :COMM_CONSTANTS.TEST_PORTAL_COMPETENCY_GV and (Category__c = 'Training Compliance' or Category__c = 'POS Revenue') ];
            }
            if(lstPPS.size() > 0) {
                for(Surf_Partner_Performance_Scorecard__c objPPS : lstPPS) {
                    if(objPPS.Category__c == 'Training Compliance') {
                        dTrainingCmpl = objPPS.flag__c;
                    } else if (objPPS.Category__c == 'POS Revenue') {
                        dPOSCmpl = objPPS.flag__c;
                    }                
                }
            } else {
                dTrainingCmpl = -1;
                dPOSCmpl = -1;
            }
            // The value 9 indicates that DGX HOT Compliance Section is hidden if the lead is not SP Compute DGX/ DGX.
            dDGXHOTCmpl = !lstSDHT.isEmpty() ? lstSDHT[0].Flag__c : 9;  // Added for SDS-3054   
        } else {
            if(objLead.DR_Deal_Type__c == COMM_CONSTANTS.LEAD_PRODUCT_TYPE_DGX || objLead.DR_Deal_Type__c == LEAD_PRODUCT_TYPE_PARABRICKS || objLead.DR_Deal_Type__c == LEAD_PRODUCT_TYPE_DLI) {
                strCompetency = COMM_CONSTANTS.TEST_PORTAL_COMPETENCY_DL;
                lstPPST = [SELECT id, Category__c, flag__c FROM Surf_Partner_Performance_Scorecard_Trans__c where Account_Id__c =:objLead.DR_Partner_Sales_Rep_Company__c and Partner_Program__c =:COMM_CONSTANTS.PA_PROGRAM_SP  and (competency__c =:COMM_CONSTANTS.TEST_PORTAL_COMPETENCY_DL or competency__c =:COMM_CONSTANTS.LEAD_PRODUCT_TYPE_DGX) and (Category__c = 'Training Compliance' or Category__c = 'POS Revenue') ];
                
                /* Changes for SDS-3054 START */
                lstSDHTT = [SELECT Account_Id__c, Account_Name__c,BillingCountry__c,Billing_Sub_Region__c,Category__c,Competency__c,Flag__c,Id,Name,Order__c,Partner_Program_Name__c, Partner_Sub_Program__c FROM SuRF_DGX_HOT_Compliance_Trans__c WHERE Account_Id__c =:objLead.DR_Partner_Sales_Rep_Company__c AND Partner_Program_Name__c =:COMM_CONSTANTS.PA_PROGRAM_SP AND (Competency__c =:COMM_CONSTANTS.TEST_PORTAL_COMPETENCY_DL OR Competency__c =:COMM_CONSTANTS.LEAD_PRODUCT_TYPE_DGX)];
                /* Changes for SDS-3054 END */
            } else if(objLead.DR_Deal_Type__c == COMM_CONSTANTS.LEAD_PRODUCT_TYPE_GRID ) {
                strCompetency = COMM_CONSTANTS.TEST_PORTAL_COMPETENCY_GV ;
                lstPPST = [SELECT id, Category__c, flag__c FROM Surf_Partner_Performance_Scorecard_Trans__c where Account_Id__c =:objLead.DR_Partner_Sales_Rep_Company__c  and Partner_Program__c =:COMM_CONSTANTS.PA_PROGRAM_SP and competency__c = :COMM_CONSTANTS.TEST_PORTAL_COMPETENCY_GV and (Category__c = 'Training Compliance' or Category__c = 'POS Revenue') ];
            }
            if(lstPPST.size() > 0) {
                for(Surf_Partner_Performance_Scorecard_Trans__c objPPST : lstPPST) {
                    if(objPPST.Category__c == 'Training Compliance') {
                        dTrainingCmpl = objPPST.flag__c;
                    } else if (objPPST.Category__c == 'POS Revenue') {
                        dPOSCmpl = objPPST.flag__c;
                    }                
                }
            } else {
                dTrainingCmpl = -1;
                dPOSCmpl = -1;
            }
            // The value 9 indicates that DGX HOT Compliance Section is hidden if the lead is not SP Compute DGX/ DGX.    
            dDGXHOTCmpl = !lstSDHT.isEmpty() ? lstSDHT[0].Flag__c : -9;  // Added for SDS-3054          
        }
        /* Changes for SDS-3181 START */
        dRegComplStatus = -1;
        if(String.isNotBlank(objLead.DR_Partner_Sales_Rep_Company__c)){            
            for(Partner_Attribute__c paObj : [SELECT Account_Name__c,Partner_Competency__c FROM Partner_Attribute__c WHERE Date_Competency_Signed__c != null AND Date_Competency_Terminated__c = null AND Account_Name__c = :objLead.DR_Partner_Sales_Rep_Company__c AND (Partner_Competency__c = :strCompetency OR Partner_Competency__c = 'DGX')]){
                signedCompetencySet.add(paObj.Partner_Competency__c);
            }
        }
        if(!signedCompetencySet.isEmpty()){
            if(signedCompetencySet.contains(strCompetency) || signedCompetencySet.contains('DGX')){
                dRegComplStatus = 1;
            }
        }
        /* Changes for SDS-3181 END */
    }
}