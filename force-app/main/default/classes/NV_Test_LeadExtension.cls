@isTest
private class NV_Test_LeadExtension {
    
    static Id leadId;
    static Lead objLead;
    static void createData() {
    
        RecordType leadRec = [select id from RecordType where sobjectType='Lead' and developerName='NPN_Web_Onboard_Form'];
        objLead = new Lead();
        objLead.Approved_Competencies__c = 'High Performance Computing; GPU Virtualization';
        objLead.Approved_Program_Type__c = 'OEM';
        objLead.Program_Level__c = 'Elite';
        objLead.lastname = 'Varun Test';
        objLead.email = 'varun@test.com';
        objLead.Company = 'NVD';
        objLead.Country = 'India';
        objLead.recordTypeId = leadRec.id;
        insert objLead;
        leadId = objLead.id;
        NPN_Docusign_Region__c objRg = new NPN_Docusign_Region__c(name='India');
        insert objRg;
        NPN_Docusign_Comptency__c objCptcy = new NPN_Docusign_Comptency__c(name='High Performance Computing');
        insert objCptcy;
        NPN_Docusign_ProgramType__c objPT = new NPN_Docusign_ProgramType__c(name='OEM');
        insert objPT;
        NPN_DocuSign_Id__c objDcsgId = new NPN_DocuSign_Id__c();
        objDcsgId.NPN_Docusign_Region__c = objRg.id;
        objDcsgId.NPN_DocusiNPN_Docusign_Progn_ProgramType__c = objPT.id;
        objDcsgId.NPN_Docusign_Comptency__c = objCptcy.id;
        objDcsgId.Contracts_Packet__c = True;
        objDcsgId.Docusign_Template_ID__c = 'abcdef';
        insert objDcsgId;
        Attachment att = new Attachment(parentId = objLead.id, name='test Att', body = Blob.valueOf('Str'));
        insert att;
        NPN_Key_Contact__c objNPN = new NPN_Key_Contact__c(lead__c = objLead.id, email__c = 'varun@test.com', Job_Role__c = 'Sales', sales_training__c = true, technical_Training__c = true);
        insert objNPN;
        NPN_Onboarding_GPU_Genius_Map__c objNPNGPU = new NPN_Onboarding_GPU_Genius_Map__c(Name = 'abcd', Competency__c = 'High Performance Computing', Role__c = 'Sales', GPU_Genius_Group__c = 'abcd');
        insert objNPNGPU;
        NPN_Onboarding_Competency_Level_Mapping__c objNPNLVLMAP = new NPN_Onboarding_Competency_Level_Mapping__c(Name = 'abcd', Competency__c = 'High Performance Computing', Program_Type__c = 'OEM', Docusign_Template_Id__c = 'Cover_Letter__c', Docusign_Program_Guide_Template_Id__c='NPN_SP_ProgramGuide__c', CSP_sell_to_other_CSPs__c='No');
        insert objNPNLVLMAP;
        NPN_Competency_Permissions_Group_Map__c objNPNPGMAP = new NPN_Competency_Permissions_Group_Map__c(Name = 'abcd', Competency__c = 'High Performance Computing', Program_Type__c = 'OEM', Program_Level__C = 'Elite', Permissions_and_Group__c = 'abcd');
        insert objNPNPGMAP;
        NPN_Onboarding_Automation_2__c objNPNOnb = new NPN_Onboarding_Automation_2__c(Name='India', NPN_Key_Contacts_Form__c='Test' , NPN_SP_ProgramGuide__c='test',NPN_Distribution_Form__c='TEst');
        insert objNPNOnb;
    }
    
    static testmethod void convertLeadTest() {
        createData();
        Test.startTest();
            PageReference pageRef = Page.NV_Lead_Docusign;
            pageRef.getParameters().put('id', String.valueOf(leadId));
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(objLead);
            NV_LeadExtension objNVLeadExtn = new NV_LeadExtension(sc); 
            NV_DocuSign_LeadExtension objDLE = new NV_DocuSign_LeadExtension(sc);
        Test.stopTest();
    }
    
}