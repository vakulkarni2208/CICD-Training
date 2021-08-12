public class NPN_NFR_SendDocusignCtrl {

    private final NPN_NFR_Software_Request__c objNFRReq;
    public String strDocumentIds {get; set;}
    public String strVPFirstName {get; set;}
    public String strVPLastName {get; set;}
    public String strVPEmail {get; set;}
    public String strEmailSubject {get; set;}
    public String strEmailBody {get; set;}
    public String legalEmail {get; set;}
    public String pricingOpsEmail {get; set;}
    public String npnOnboardingEmail {get; set;}
    public String reqstrFName {get; set;}
    public String reqstrLName {get; set;}
    public String rqstrEmail {get; set;}
    public String pbmFName {get; set;}
    public String pbmLName {get; set;}
    public String pbmEmail {get; set;}
    Map<String, String> metaRecordsMap {get; set;}
    Map<String, NPN_NFR_VP_Data__mdt> vpDataMap {get; set;}

    public NPN_NFR_SendDocusignCtrl(ApexPages.StandardController stdController) {

        String region = '';
        String country = '';

        metaRecordsMap = new Map<String, String>();
        vpDataMap = new Map<String, NPN_NFR_VP_Data__mdt>();
        strDocumentIds = '';

        this.objNFRReq = [SELECT Id, vCS__c, VDWS__c, VPC__c, Company_Name__r.Billing_Region__c, Company_Name__r.BillingCountry, Email__c, Requested_By__r.FirstName, 
        Requested_By__r.LastName,Approver__r.FirstName, Approver__r.LastName, Approver__r.Email, Status__c FROM NPN_NFR_Software_Request__c 
        WHERE Id = :ApexPages.CurrentPage().getParameters().get('Id') ];


        region = String.isNotBlank(this.objNFRReq.Company_Name__r.Billing_Region__c) ? this.objNFRReq.Company_Name__r.Billing_Region__c : '';
        country = String.isNotBlank(this.objNFRReq.Company_Name__r.BillingCountry) ? this.objNFRReq.Company_Name__r.BillingCountry : '';

        list<NFR_Software_Licence__c> lstDocusignConfig = [SELECT Id,Docusign_Template_ID__c, Name FROM NFR_Software_Licence__c];
        for(NFR_Software_Licence__c objDocConf : lstDocusignConfig) {
            if(!strDocumentIds.contains(objDocConf.Docusign_Template_ID__c)) {
                strDocumentIds += objDocConf.Docusign_Template_ID__c+',';
            }
        }

        strDocumentIds = strDocumentIds.substring(0,strDocumentIds.length()-1);

        for(NPN_NFR_Request_Data__mdt mdRec : [SELECT Id, DeveloperName, MasterLabel, Value__c FROM NPN_NFR_Request_Data__mdt]) {
            metaRecordsMap.put(mdRec.DeveloperName, mdRec.Value__c);
        }

        for(NPN_NFR_VP_Data__mdt vpRec : [SELECT Id, DeveloperName, MasterLabel, Email__c, First_Name__c, Last_Name__c FROM NPN_NFR_VP_Data__mdt]) {
            vpDataMap.put(vpRec.MasterLabel, vpRec);
        }

        strEmailSubject = metaRecordsMap.get('ds_Subject');
        strEmailBody = metaRecordsMap.get('ds_MsgBody');
        legalEmail = metaRecordsMap.get('Legal');
        pricingOpsEmail = metaRecordsMap.get('WWFO_Pricing_Operations');
        npnOnboardingEmail = metaRecordsMap.get('NPN_Onboarding');

        rqstrEmail      = this.objNFRReq.Email__c;
        reqstrFName     = this.objNFRReq.Requested_By__r.FirstName;
        reqstrLName     = this.objNFRReq.Requested_By__r.LastName;
        pbmFName        = this.objNFRReq.Approver__r.FirstName;
        pbmLName        = this.objNFRReq.Approver__r.LastName;
        pbmEmail        = this.objNFRReq.Approver__r.Email;

        if(String.isNotBlank(country) && vpDataMap.containsKey(country)) {
            strVPFirstName = vpDataMap.get(country).First_Name__c;
            strVPLastName = vpDataMap.get(country).Last_Name__c;
            strVPEmail  = vpDataMap.get(country).Email__c;
        } else if(String.isNotBlank(region) && vpDataMap.containsKey(region)) {
            strVPFirstName = vpDataMap.get(region).First_Name__c;
            strVPLastName = vpDataMap.get(region).Last_Name__c;
            strVPEmail  = vpDataMap.get(region).Email__c;
        }
    }
}