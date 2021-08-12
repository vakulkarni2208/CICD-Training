public class NV_LeadExtension {
    private final Lead objLead;
    public List<NPN_Onboarding_Automation_2__c> lstNPNCustomSetting {get;set;}
    public String strDocumentIds {get;set;}
    public String strVPFirstName {get;set;}
    public String strVPLastName {get;set;}
    public String strVPEmail {get;set;}
    public String strEmailSubject {get;set;}
    public String strEmailBody {get;set;}
    public set<String> setProgramTypes;
    
    public NV_LeadExtension(ApexPages.StandardController stdController) {
        setProgramTypes = new set<String>();
        this.objLead = [select id, Approved_Program_Type__c , Approved_Competencies__c , Region__c, country, Organization_Type_select_one__c, Competencies_Interested_In__c from Lead where id = :ApexPages.CurrentPage().getParameters().get('Id')];        
        NPN_Onboarding_Automation_2__c objNPNCustomSetting = NPN_Onboarding_Automation_2__c.getInstance(objLead.country);
        NPN_Contract_Packet_Config__c objNPNContractsPacketConfig = NPN_Contract_Packet_Config__c.getInstance();
        map<String, NPN_Onboarding_Competency_Level_Mapping__c> mapNPNCompetencyProgramTypeMapping = NPN_Onboarding_Competency_Level_Mapping__c.getAll();
        map<String, NPN_Docusign_Program_Type_KeyContact__c> mapNPNDocusignPrgmTypeKeyContact = NPN_Docusign_Program_Type_KeyContact__c.getAll();
        strVPFirstName = objNPNContractsPacketConfig.VP_First_Name__c;
        strVPLastName = objNPNContractsPacketConfig.VP_Last_Name__c;
        strVPEmail = objNPNContractsPacketConfig.VP_Email__c;  
        strEmailSubject = objNPNContractsPacketConfig.Email_Subject__c;
        strEmailBody = objNPNContractsPacketConfig.Email_Body__c;
        if(objNPNCustomSetting == null) {
            if(objLead.Region__c == null) {
                objNPNCustomSetting = NPN_Onboarding_Automation_2__c.getInstance('');
            } else {
                objNPNCustomSetting = NPN_Onboarding_Automation_2__c.getInstance(objLead.region__c);
            }
        }
        if(objNPNCustomSetting != null) {
            strDocumentIds = objNPNCustomSetting.Cover_Letter__c + ','
                            + objNPNCustomSetting.Master_Agreement__c + ',';                                
            /*if(objLead.Approved_Program_Type__c!= null && objLead.Approved_Program_Type__c.contains(COMM_Constants.PA_PROGRAM_SP)) {                
                bSolutionProvider = true;
                if(objLead.Approved_Competencies__c!= null && objLead.Approved_Competencies__c.contains(COMM_Constants.TEST_PORTAL_COMPETENCY_AC)) {
                    strDocumentIds += objNPNCustomSetting.NPN_SP_CompetencyExhibit_AC__c + ',';
                } 
                if(objLead.Approved_Competencies__c!= null && objLead.Approved_Competencies__c.contains(COMM_Constants.TEST_PORTAL_COMPETENCY_CV_SPC)) {
                    strDocumentIds += objNPNCustomSetting.NPN_SP_CompetencyExhibit_CV__c + ',';
                } 
                if(objLead.Approved_Competencies__c!= null && objLead.Approved_Competencies__c.contains(COMM_Constants.TEST_PORTAL_COMPETENCY_PV)) {
                    strDocumentIds += objNPNCustomSetting.NPN_SP_CompetencyExhibit_PV__c + ',';
                } 
            } if(objLead.Approved_Program_Type__c!= null && objLead.Approved_Program_Type__c.contains(COMM_Constants.PA_PROGRAM_OEM)) {                
                bOEM = true;
                if(objLead.Approved_Competencies__c!= null && objLead.Approved_Competencies__c.contains(COMM_Constants.TEST_PORTAL_COMPETENCY_AC)) {
                    strDocumentIds += objNPNCustomSetting.NPN_OEM_CompetencyExhibit_AC__c + ',';
                }
                if(objLead.Approved_Competencies__c!= null && objLead.Approved_Competencies__c.contains(COMM_Constants.TEST_PORTAL_COMPETENCY_PV)) {
                    strDocumentIds += objNPNCustomSetting.get('NPN_OEM_CompetencyExhibit_PV__c') + ',';
                } 
            }*/
            for(NPN_Onboarding_Competency_Level_Mapping__c objNPNCompetencyProgramTypeMapping : mapNPNCompetencyProgramTypeMapping.values()) {
                if((objLead.Approved_Competencies__c!= null && objLead.Approved_Competencies__c.contains(objNPNCompetencyProgramTypeMapping.Competency__c)) 
                && (objLead.Approved_Program_Type__c!= null && objLead.Approved_Program_Type__c.contains(objNPNCompetencyProgramTypeMapping.Program_Type__c))) {
                    strDocumentIds += objNPNCustomSetting.get(objNPNCompetencyProgramTypeMapping.Docusign_Template_Id__c) + ',';
                }
            }
            strDocumentIds += objNPNCustomSetting.NPN_Key_Contacts_Form__c + ',';
            if(objNPNCustomSetting.NPN_Distribution_Form__c != '' && objNPNCustomSetting.NPN_Distribution_Form__c != 'N/A') {
                strDocumentIds += objNPNCustomSetting.NPN_Distribution_Form__c  + ',';
            }                
            if(objNPNCustomSetting.NEW_MDF_REBATE_VENDOR_SETUP_FORM__c != '' && objNPNCustomSetting.NEW_MDF_REBATE_VENDOR_SETUP_FORM__c != 'N/A') {
                strDocumentIds += objNPNCustomSetting.NEW_MDF_REBATE_VENDOR_SETUP_FORM__c + ',';
            }
            for(NPN_Onboarding_Competency_Level_Mapping__c objNPNCompetencyProgramTypeMapping : mapNPNCompetencyProgramTypeMapping.values()) {
                if(!setProgramTypes.contains(objNPNCompetencyProgramTypeMapping.Program_Type__c) && objLead.Approved_Program_Type__c!= null && objLead.Approved_Program_Type__c.contains(objNPNCompetencyProgramTypeMapping.Program_Type__c)) {
                    strDocumentIds += objNPNCustomSetting.get(objNPNCompetencyProgramTypeMapping.Docusign_Program_Guide_Template_Id__c) + ',';
                    setProgramTypes.add(objNPNCompetencyProgramTypeMapping.Program_Type__c);
                }
            }
            if(strDocumentIds != '' && strDocumentIds != null) {
                strDocumentIds = strDocumentIds.replaceAll('null,','');
            }
            if(strDocumentIds != '' && strDocumentIds != null) {                
                strDocumentIds = strDocumentIds.substring(0,strDocumentIds.length()-1);
            }          
        }
    }
}