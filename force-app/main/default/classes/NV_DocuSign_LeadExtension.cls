public class NV_DocuSign_LeadExtension {
    private final Lead objLead;
    public List<NPN_Onboarding_Automation_2__c> lstNPNCustomSetting {get;set;}
    public String strDocumentIds {get;set;}
    public String strVPFirstName {get;set;}
    public String strVPLastName {get;set;}
    public String strVPEmail {get;set;}
    public String strEmailSubject {get;set;}
    public String strEmailBody {get;set;}
    public list<String> listProgramTypes;
    public list<String> listCompetency;
    public list<String> listSubProgram;
    public String strRegion;
    
    public NV_DocuSign_LeadExtension(ApexPages.StandardController stdController) {
        strDocumentIds = '';
        this.objLead = [select id, Approved_Program_Type__c , Approved_Competencies__c , Approved_SubProgram_Type__c, Region__c, country, CSP_Yes_No__c, Organization_Type_select_one__c, Competencies_Interested_In__c from Lead where id = :ApexPages.CurrentPage().getParameters().get('Id')];                
        listProgramTypes = objLead.Approved_Program_Type__c.split(';');
        listCompetency = objLead.Approved_Competencies__c.split(';');
        listSubProgram = new list<string>();
        if(objLead.Approved_Subprogram_type__c != null)
            listSubProgram = objLead.Approved_SubProgram_Type__c.split(';');
        NPN_Contract_Packet_Config__c objNPNContractsPacketConfig = NPN_Contract_Packet_Config__c.getInstance();
        strVPFirstName = objNPNContractsPacketConfig.VP_First_Name__c;
        strVPLastName = objNPNContractsPacketConfig.VP_Last_Name__c;
        strVPEmail = objNPNContractsPacketConfig.VP_Email__c;  
        strEmailSubject = objNPNContractsPacketConfig.Email_Subject__c;
        strEmailBody = objNPNContractsPacketConfig.Email_Body__c;
        //list<NPN_DocuSign_Id__c> lstDocusignConfig = [select id,Docusign_Template_ID__c from NPN_DocuSign_Id__c where ((NPN_Docusign_Region__c='' and NPN_DocusiNPN_Docusign_Progn_ProgramType__c='' and NPN_Docusign_SubProgramType__c='' and NPN_Docusign_Comptency__c='') or (NPN_Docusign_Region__r.Name=:objLead.region__c and NPN_DocusiNPN_Docusign_Progn_ProgramType__c='' and NPN_Docusign_SubProgramType__c='' and NPN_Docusign_Comptency__c='') or (NPN_Docusign_Region__r.Name=:objLead.region__c and NPN_DocusiNPN_Docusign_Progn_ProgramType__r.Name=:listProgramTypes and NPN_Docusign_SubProgramType__c='' and NPN_Docusign_Comptency__c='') or (NPN_Docusign_Region__r.Name=:objLead.region__c and NPN_DocusiNPN_Docusign_Progn_ProgramType__r.Name=:listProgramTypes and NPN_Docusign_SubProgramType__c='' and NPN_Docusign_Comptency__r.Name=:listCompetency) or (NPN_Docusign_Region__r.Name=:objLead.region__c and NPN_DocusiNPN_Docusign_Progn_ProgramType__r.Name=:listProgramTypes and NPN_Docusign_Comptency__r.Name=:listCompetency)) and CSP_Yes_No__c=:objLead.CSP_Yes_No__c and Contracts_Packet__c=true];
        list<NPN_DocuSign_Id__c> lstDocusignRegion = [select id, NPN_Docusign_Region__r.Name from NPN_DocuSign_Id__c where NPN_Docusign_Region__r.Name=:objLead.country limit 1];
        if(lstDocusignRegion.size() > 0) {
            strRegion = objLead.country;
        } else {
            strRegion = objLead.Region__c;
        }
        list<NPN_DocuSign_Id__c> lstDocusignConfig = [select id,Docusign_Template_ID__c from NPN_DocuSign_Id__c where ((NPN_Docusign_Region__c='' or NPN_Docusign_Region__r.Name=:strRegion) and (NPN_DocusiNPN_Docusign_Progn_ProgramType__c='' or NPN_DocusiNPN_Docusign_Progn_ProgramType__r.Name=:listProgramTypes) and (NPN_Docusign_SubProgramType__c='' or NPN_Docusign_SubProgramType__r.Name=:listSubProgram) and (NPN_Docusign_Comptency__c='' or NPN_Docusign_Comptency__r.Name=:listCompetency)) and CSP_Yes_No__c=:objLead.CSP_Yes_No__c and Contracts_Packet__c=true order by order__c];
        for(NPN_DocuSign_Id__c objDocConf : lstDocusignConfig) {            
            if(!strDocumentIds.contains(objDocConf.Docusign_Template_ID__c))
                strDocumentIds += objDocConf.Docusign_Template_ID__c+',';
        }        
        strDocumentIds = strDocumentIds.substring(0,strDocumentIds.length()-1);
    }
}