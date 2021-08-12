public class NV_AddOnPromoDemoTerminationController {

    public NPN_PartnerAttributes_Modifiaction__c objPAM {get; set;}
    public Id accountID;
    public String strPAM {get; set;}
    public String strDocumentIds {get;set;}
    public String strVPFirstName {get;set;}
    public String strVPLastName {get;set;}
    public String strVPEmail {get;set;}
    public String strEmailSubject {get;set;}
    public String strEmailBody {get;set;}
    public list<String> listCompetency;
    public String strRegion;
    public Account acc;
    public String strLegalEmail {get;set;}
    public String strOnboardingEmail {get;set;}
    
    public NV_AddOnPromoDemoTerminationController(ApexPages.StandardController controller) {
        accountID = ApexPages.CurrentPage().getParameters().get('id');
        if(accountID!= null)
            acc = [select id,ownerId, owner.email, Owner.FirstName, Owner.LastName, BillingCountry, Billing_Region__c from Account where id = :accountID];
        objPAM = new NPN_PartnerAttributes_Modifiaction__c();
        objPAM.account__c = accountID;
        objPAM.AccountOwner__c = acc.ownerId;
    }
    
    public PageReference Save() {
        list<NPN_PartnerAttributes_Modifiaction__c> lstPAM = [select id from NPN_PartnerAttributes_Modifiaction__c where account__c=:accountID and DocuSign_Envelope_ID__c=''];      
        if(lstPAM.size() > 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Another process already in progrerss. Please try again after 2-4 minutes.'));
            return null;
        }
        list<String> lstProgramNames = new list<String>();
        list<String> lstSubProgramNames = new list<String>();
        map<String, Date> mapCompetencyProgramTypeDateSigned = new map<String, Date>();
        list<Partner_Attribute__c> lstPA = [select id, Partner_Competency__c , partner_program_name__c, Partner_Sub_Program__c, Program_Level__c,Date_Competency_Signed__c from Partner_Attribute__c where Date_Competency_Terminated__c = NULL and Account_Name__c=:accountID];        
        for(Partner_Attribute__c objPA : lstPA) {
            lstProgramNames.add(objPA.Partner_Program_Name__c);
            lstSubProgramNames.add(objPA.Partner_Sub_Program__c);
            mapCompetencyProgramTypeDateSigned.put(objPA.Partner_Competency__c + objPA.partner_program_name__c + objPA.Partner_Sub_Program__c, objPA.Date_Competency_Signed__c);
        }
        objPAM.account__c = accountID;
        if(mapCompetencyProgramTypeDateSigned.containsKey(objPAM.Competency__c + objPAM.program_Type__c + objPAM.SubProgram_Type__c)) 
            objPAM.Competency_Signed_Date__c = mapCompetencyProgramTypeDateSigned.get(objPAM.Competency__c + objPAM.program_Type__c + objPAM.SubProgram_Type__c);  
        insert objPAM;
        listCompetency = objPAM.competency__c.split(';');
        strDocumentIds = '';
        NPN_Contract_Packet_Config__c objNPNContractsPacketConfig = NPN_Contract_Packet_Config__c.getInstance();
        strVPFirstName = objNPNContractsPacketConfig.VP_First_Name__c;
        strVPLastName = objNPNContractsPacketConfig.VP_Last_Name__c;
        strVPEmail = objNPNContractsPacketConfig.VP_Email__c;  
        strEmailSubject = objNPNContractsPacketConfig.Email_Subject__c;
        strEmailBody = objNPNContractsPacketConfig.Email_Body__c;
        strLegalEmail = System.Label.NPN_Legal_Email;
        strOnboardingEmail = System.Label.NPN_Onboarding_Email;
        //list<NPN_DocuSign_Id__c> lstDocusignConfig = [select id,Docusign_Template_ID__c from NPN_DocuSign_Id__c where ((NPN_Docusign_Region__c='' and NPN_DocusiNPN_Docusign_Progn_ProgramType__c='' and NPN_Docusign_SubProgramType__c='' and NPN_Docusign_Comptency__c='') or (NPN_Docusign_Region__r.Name=:objLead.region__c and NPN_DocusiNPN_Docusign_Progn_ProgramType__c='' and NPN_Docusign_SubProgramType__c='' and NPN_Docusign_Comptency__c='') or (NPN_Docusign_Region__r.Name=:objLead.region__c and NPN_DocusiNPN_Docusign_Progn_ProgramType__r.Name=:listProgramTypes and NPN_Docusign_SubProgramType__c='' and NPN_Docusign_Comptency__c='') or (NPN_Docusign_Region__r.Name=:objLead.region__c and NPN_DocusiNPN_Docusign_Progn_ProgramType__r.Name=:listProgramTypes and NPN_Docusign_SubProgramType__c='' and NPN_Docusign_Comptency__r.Name=:listCompetency) or (NPN_Docusign_Region__r.Name=:objLead.region__c and NPN_DocusiNPN_Docusign_Progn_ProgramType__r.Name=:listProgramTypes and NPN_Docusign_Comptency__r.Name=:listCompetency)) and CSP_Yes_No__c=:objLead.CSP_Yes_No__c and Contracts_Packet__c=true];
        list<NPN_DocuSign_Id__c> lstDocusignRegion = [select id, NPN_Docusign_Region__r.Name from NPN_DocuSign_Id__c where NPN_Docusign_Region__r.Name=:acc.billingcountry limit 1];
        if(lstDocusignRegion.size() > 0) {
            strRegion = acc.billingcountry;
        } else {
            strRegion = acc.Billing_Region__c;
        }
        String strCompetency = String.join(listCompetency,'\',\'');
        strCompetency = '\'' + strCompetency;
        strCompetency += '\'';
        Contact con = [select id, FirstName, LastName, Email from Contact where id = :objPAM.contact__c];
        String strWhere = 'Add_on_Contracts_Packet__c=true';
        if(objPAM.PartnerAttributes_Modification__c == 'Add On Contracts Packet')
            strWhere = 'Add_on_Contracts_Packet__c=true';
        else if(objPAM.PartnerAttributes_Modification__c == 'Promotion')
            strWhere = 'Promotion__c=true';
        else if(objPAM.PartnerAttributes_Modification__c == 'Demotion')
            strWhere = 'Demotion__c=true';
        else if(objPAM.PartnerAttributes_Modification__c == 'Termination')
            strWhere = 'Termination__c=true';
        else if(objPAM.PartnerAttributes_Modification__c == 'Competency Termination')
            strWhere = 'Competency_Termination__c=true';
        list<NPN_DocuSign_Id__c> lstDocusignConfig = Database.Query('select id,Docusign_Template_ID__c from NPN_DocuSign_Id__c where (((NPN_Docusign_Region__c=\'\' or NPN_Docusign_Region__r.Name=\''+strRegion+'\') and (NPN_DocusiNPN_Docusign_Progn_ProgramType__c=\'\' or NPN_DocusiNPN_Docusign_Progn_ProgramType__r.Name=\''+objPAM.program_type__c+'\') and (NPN_Docusign_SubProgramType__c=\'\' or NPN_Docusign_SubProgramType__r.Name=\''+objPAM.subprogram_type__c+'\') and (NPN_Docusign_Comptency__c=\'\' or NPN_Docusign_Comptency__r.Name IN :listCompetency)) and CSP_Yes_No__c='+objPAM.CSP_Yes_No__c+' and '+strWhere+') AND ((NOT TemplateName__c like \'%Guide%\') OR NPN_DocusiNPN_Docusign_Progn_ProgramType__r.Name NOT IN :lstProgramNames OR (NPN_Docusign_SubProgramType__c!=null AND NPN_Docusign_SubProgramType__r.Name NOT IN :lstSubProgramNames)) order by order__c');
        for(NPN_DocuSign_Id__c objDocConf : lstDocusignConfig) {            
            if(!strDocumentIds.contains(objDocConf.Docusign_Template_ID__c))
                strDocumentIds += objDocConf.Docusign_Template_ID__c+',';
        }        
        if(strDocumentIds != '') {
            strDocumentIds = strDocumentIds.substring(0,strDocumentIds.length()-1);
        }
        PageReference pgRef = new PageReference('/apex/dsfs__DocuSign_CreateEnvelope');
        pgRef.getParameters().put('SourceID', objPAM.id);
        pgRef.getParameters().put('DST', strDocumentIds);
        pgRef.getParameters().put('CES', strEmailSubject);
        pgRef.getParameters().put('CEM', strEmailBody);
        if(objPAM.PartnerAttributes_Modification__c == 'Add On Contracts Packet'){
        pgRef.getParameters().put('CCRM', 'PBM~PBM;Partner User~Partner User;Key Contact~Key Contact;VP~VP;Legal~Legal;NPNTeam~NPNTeam;');
        pgRef.getParameters().put('CCTM', 'PBM~Signer;Partner User~Signer;Key Contact~Signer;VP~Signer;Legal~Carbon Copy;NPNTeam~Carbon Copy;');
        }
        else{
        pgRef.getParameters().put('CCRM', 'PBM~PBM;Partner User~Partner User;Legal~Legal;NPNTeam~NPNTeam;');
        pgRef.getParameters().put('CCTM', 'PBM~Signer;Partner User~Carbon Copy;Legal~Carbon Copy;NPNTeam~Carbon Copy;');
        }
        pgRef.getParameters().put('CRL', 'Email~'+acc.owner.email+';Role~PBM;FirstName~'+acc.Owner.FirstName+';LastName~'+acc.Owner.LastName+';RoutingOrder~1;,Email~'+con.email+';FirstName~'+con.FirstName+';LastName~'+con.LastName+';Role~Partner User;RoutingOrder~2;,Email~'+con.Email+';FirstName~'+con.FirstName+';LastName~'+con.LastName+';Role~Key Contact;RoutingOrder~3;,Email~'+strVPEmail+';Role~VP;FirstName~'+strVPFirstName+';LastName~'+strVPLastName+';RoutingOrder~4;,Email~'+strLegalEmail+';Role~Legal;FirstName~Legal;LastName~Legal;RoutingOrder~5;,Email~'+strOnboardingEmail+';Role~NPNTeam;FirstName~NPN;LastName~Onboarding;RoutingOrder~6;');
        pgRef.setRedirect(true);        
        return pgRef;
    }

}