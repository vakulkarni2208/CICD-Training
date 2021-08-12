/*
    2020.12.14-PJENA-SDS-2748-EDU Lead Form Enhancements
        Show Pending, Approved, Rejected Edu Lead Registrations
*/
global without sharing class EDU_DR_Report_ctlr {
    private static list<lead> lstEduLeads{get;set;}
    private static Id accId {get; set;}
    private static Id contactId {get; set;}
    private static User partnerUser {get; set;}
    public static list<EDU_Lead_Wrapper> lstPendingEduLeads{get;set;}
    public static list<EDU_Lead_Wrapper> lstApprovedEduLeads{get;set;}
    public static list<EDU_Lead_Wrapper> lstRejectedEduLeads{get;set;}

    static {
        partnerUser = [Select ContactId, AccountId from User where id =: Userinfo.getUserid()];
        //contactId = partnerUser.ContactId;
        accId = partnerUser.AccountId;
        string eduLeadQuery = 'Select Lead_Number__c, Status, Company, DR_Program_Name__c, DR_Deal_Type__c, DR_Product__c, DR_SKU_Quantity__c, ' +
                                ' DR_Secondary_Product__c, DR_Secondary_SKU_Quantity__c, DR_Submitted_Date__c, Account_Executive_Name__c, DR_Partner_Sales_Rep_Company__c,  Partner_Details__c ' +
                                ' From Lead ' +
                                ' Where RecordType.developerName = \'EDU_Lead_Registration\'  And DR_Partner_Sales_Rep_Company__c = \'' + accId + '\' ' +
                                ' Order By CreatedDate' ;
        lstEduLeads = Database.query(eduLeadQuery);

        if (!lstEduLeads.isEmpty()){
            lstPendingEduLeads = new list<EDU_Lead_Wrapper>();
            lstApprovedEduLeads = new list<EDU_Lead_Wrapper>();
            lstRejectedEduLeads = new list<EDU_Lead_Wrapper>();
            EDU_Lead_Wrapper oEduLeadWraper;
            for (Lead oLead : lstEduLeads){
                oEduLeadWraper = new EDU_Lead_Wrapper();
                oEduLeadWraper.RequestId = oLead.Lead_Number__c;
                oEduLeadWraper.CustomerName = oLead.Company;
                oEduLeadWraper.ProgramName = oLead.DR_Program_Name__c;
                oEduLeadWraper.DealType = oLead.DR_Deal_Type__c;
                oEduLeadWraper.PrimaryProduct = oLead.DR_Product__c;
                oEduLeadWraper.PrimaryProductQuantity = oLead.DR_SKU_Quantity__c;
                oEduLeadWraper.SecondaryProduct = oLead.DR_Secondary_Product__c;
                oEduLeadWraper.SecondaryProductQuantity = oLead.DR_Secondary_SKU_Quantity__c;
                oEduLeadWraper.SubmittedDate = oLead.DR_Submitted_Date__c;
                oEduLeadWraper.AccountExecutiveName = oLead.Account_Executive_Name__c;
                oEduLeadWraper.PartnerDetails = oLead.Partner_Details__c;

                if (oLead.Status == 'In Review'){
                    lstPendingEduLeads.add(oEduLeadWraper);
                }else if (oLead.Status == 'Approved'){
                    lstApprovedEduLeads.add(oEduLeadWraper);
                }else if (oLead.Status == 'Rejected'){
                    lstRejectedEduLeads.add(oEduLeadWraper);
                }
            }
        }
    }

    @RemoteAction
    global static list<EDU_Lead_Wrapper> loadPendingEduLeads() {
        return lstPendingEduLeads;
    }

    @RemoteAction
    global static list<EDU_Lead_Wrapper> loadApprovedEduLeads() {
        return lstApprovedEduLeads;
    }

    @RemoteAction
    global static list<EDU_Lead_Wrapper> loadRejectedEduLeads() {
        return lstRejectedEduLeads;
    }
    

    global class EDU_Lead_Wrapper{
        public string RequestId{get;set;} //Lead_Number__c
        public string CustomerName {get;set;} //Company
        public string ProgramName {get;set;} //DR_Program_Name__c
        public string DealType{get;set;} //DR_Deal_Type__c
        public string PrimaryProduct {get;set;} // DR_Product__c
        public decimal PrimaryProductQuantity {get;set;} //DR_SKU_Quantity__c
        public string SecondaryProduct {get;set;} // DR_Secondary_Product__c
        public decimal SecondaryProductQuantity {get;set;} //DR_Secondary_SKU_Quantity__c
        public datetime SubmittedDate {get;set;} //DR_Submitted_Date__c
        public string AccountExecutiveName {get;set;} //Account_Executive_Name__c
        public string PartnerDetails {get;set;} //PartnerDetails__c
        public string Status {get;set;} //LeadStatus
    }
}