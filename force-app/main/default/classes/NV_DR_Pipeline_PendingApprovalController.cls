/*
    Change List:
    2018.07.21 - PJENA - SDS-676 - Change on the dashboard to ensure that deals that are on or equal to the last day of the quarter
    2019.01.07 - PJENA - SDS-922 - Opp Reg: Super User Visibility for Registrations in the Portal
    2019.10.23 - RKAMBLE - SDS-1741 - PUB: Add Need Help? Section in Opp Reg Tab
    2021.01.20 - SOQ-79 - Replace reference of Preferred_Partner__c picklist field with the lookup field Primary_NPN_OEM_ODM_Disti__r.Name
    2021.06.15 - PJENA - SDS-3255 - OppReg Approval email to have Quote Number
 */
global without sharing class NV_DR_Pipeline_PendingApprovalController {

    private static String loadOverallPipeline;
    private static String loadOverallPipelineCurrentFQ;
    private static String loadClosedWonPipelineCurrentFQ;
    private static String loadOverallPipelineClosedWon;
    private static String loadOverallPipelineClosedLost;
    private static String loadPendingApprovalLeads;
    private static String loadRejectedLeads;
    public static Id accId {get; set;}
    public static Id contactId {get; set;}
    public static Period objPeriod;
    private static User partnerUser {get; set;}
    private static boolean isPRMSuperUser {get; set;}
    public static list<ContentDocument> lstContentDocument;                    // Added for SDS-1741
    public static String strOppRegPrgmGuideDocumentId {get; set;}      // Added for SDS-1741
    public static String strOppRegPrgmOvrvDocumentId {get; set;}       // Added for SDS-1741


    static {
        partnerUser = [Select ContactId, AccountId, IsPrmSuperUser from User where id =: Userinfo.getUserid()];
        contactId = partnerUser.ContactId;
        accId = partnerUser.AccountId;
        isPRMSuperUser = partnerUser.IsPrmSuperUser;
        string clauseIndividualOrSuperUser = '';
        
        if (isPRMSuperUser) {
            clauseIndividualOrSuperUser = 'DR_Partner_Sales_Rep_Company__c = \'' + accId + '\'';
        }else{
            clauseIndividualOrSuperUser = '(DR_Partner_Sales_Rep_Name__c = \'' + contactId + '\' OR DR_Additional_Team_Member__c = \'' + contactId + '\')';
        }

        /** Changes for SDS-1741 START */
        lstContentDocument = [SELECT Id, Title FROM ContentDocument WHERE Title = :Label.CRM_DR_NV_DR_Prgm_Guide OR Title = :Label.CRM_DR_NV_DR_Prgm_Overview];
    
        if(!lstContentDocument.isEmpty()) {
            for(ContentDocument objCD : lstContentDocument) {
                if(Label.CRM_DR_NV_DR_Prgm_Guide.equalsIgnoreCase(objCD.Title) && String.isBlank(strOppRegPrgmGuideDocumentId)) {
                    strOppRegPrgmGuideDocumentId = objCD.Id;
                } else if(Label.CRM_DR_NV_DR_Prgm_Overview.equalsIgnoreCase(objCD.Title) && String.isBlank(strOppRegPrgmOvrvDocumentId)) {
                    strOppRegPrgmOvrvDocumentId = objCD.Id;
                }
            }
        }
        /** Changes for SDS-1741 END */

        objperiod = [Select Number, StartDate, EndDate From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER];
        String startDateStr = DateTime.newInstance(objPeriod.StartDate.year(),objPeriod.StartDate.month(),objPeriod.StartDate.day()).format('yyyy-MM-dd');
        String endDateStr = DateTime.newInstance(objPeriod.EndDate.year(),objPeriod.EndDate.month(),objPeriod.EndDate.day()).format('yyyy-MM-dd');
        loadOverallPipeline = 'SELECT Name, Opportunity_Number__c, SBQQ__PrimaryQuote__r.name, Account.Name, DR_Customer_Contact__r.Name, Probability, Primary_NPN_OEM_ODM_Disti__r.Name, DR_Program_Name__c, CreatedDate, CloseDate, DR_Expiration_Date__c, Owner.Name, Owner.Email, (Select id, priceBookEntry.Product2.name, Quantity from OpportunityLineItems) '
                              + 'FROM Opportunity WHERE '+clauseIndividualOrSuperUser+' AND RecordType.developerName = \'Enterprise_Sales_Opportunity\' AND (DR_Deal_Status__c = \'Approved\' OR DR_Deal_Status__c = \'Extension Approved\') AND DR_Lead_Type__c = \'Deal Registration\''
                              + ' limit 40000';
        loadOverallPipelineCurrentFQ = 'SELECT Name, Opportunity_Number__c, SBQQ__PrimaryQuote__r.name, Account.Name, DR_Customer_Contact__r.Name, Probability, Primary_NPN_OEM_ODM_Disti__r.Name, DR_Program_Name__c, CreatedDate, CloseDate, DR_Expiration_Date__c, Owner.Name, Owner.Email, (Select id, priceBookEntry.Product2.name, Quantity from OpportunityLineItems) '
                                       + 'FROM Opportunity WHERE '+clauseIndividualOrSuperUser+' AND RecordType.developerName = \'Enterprise_Sales_Opportunity\' AND (DR_Deal_Status__c = \'Approved\' OR DR_Deal_Status__c = \'Extension Approved\') AND DR_Lead_Type__c = \'Deal Registration\' and CloseDate >= '+startDateStr+' and closeDate <= '+endDateStr
                                       + ' limit 40000';
        loadClosedWonPipelineCurrentFQ = 'SELECT Name, Opportunity_Number__c, SBQQ__PrimaryQuote__r.name, Account.Name, DR_Customer_Contact__r.Name, Probability, Primary_NPN_OEM_ODM_Disti__r.Name, DR_Program_Name__c, CreatedDate, CloseDate, DR_Expiration_Date__c, Owner.Name, Owner.Email, (Select id, priceBookEntry.Product2.name, Quantity from OpportunityLineItems) '
                                         + 'FROM Opportunity WHERE '+clauseIndividualOrSuperUser+' AND RecordType.developerName = \'Enterprise_Sales_Opportunity\' AND (DR_Deal_Status__c = \'Approved\' OR DR_Deal_Status__c = \'Extension Approved\') AND DR_Lead_Type__c = \'Deal Registration\' and StageName = \'Closed Won\' and CloseDate >= '+startDateStr+' and closeDate <= '+endDateStr
                                         + ' limit 40000';
        loadOverallPipelineClosedWon = 'SELECT Name, Opportunity_Number__c, SBQQ__PrimaryQuote__r.name, Account.Name, DR_Customer_Contact__r.Name, Probability, Primary_NPN_OEM_ODM_Disti__r.Name, DR_Program_Name__c, CreatedDate, CloseDate, DR_Expiration_Date__c, Owner.Name, Owner.Email, (Select id, priceBookEntry.Product2.name, Quantity from OpportunityLineItems) '
                                       + 'FROM Opportunity WHERE '+clauseIndividualOrSuperUser+' AND RecordType.developerName = \'Enterprise_Sales_Opportunity\' AND (DR_Deal_Status__c = \'Approved\' OR DR_Deal_Status__c = \'Extension Approved\') AND DR_Lead_Type__c = \'Deal Registration\' and StageName = \'Closed Won\''
                                       + ' limit 40000';
        loadOverallPipelineClosedLost = 'SELECT Name, Opportunity_Number__c, SBQQ__PrimaryQuote__r.name, Account.Name, DR_Customer_Contact__r.Name, Probability, Primary_NPN_OEM_ODM_Disti__r.Name, DR_Program_Name__c, CreatedDate, CloseDate, DR_Expiration_Date__c, Owner.Name, Owner.Email, (Select id, priceBookEntry.Product2.name, Quantity from OpportunityLineItems) '
                                        + 'FROM Opportunity WHERE '+clauseIndividualOrSuperUser+' AND RecordType.developerName = \'Enterprise_Sales_Opportunity\' AND (DR_Deal_Status__c = \'Approved\' OR DR_Deal_Status__c = \'Extension Approved\') AND DR_Lead_Type__c = \'Deal Registration\' and StageName = \'Closed Lost\''
                                        + ' limit 40000';
        loadPendingApprovalLeads = 'SELECT Name, Owner.Name, Owner.Email, SAP_Customer_No__c, DR_Product__c, Company, DR_Program_Name__c, DR_Program_Type__c, DR_SKU_Quantity__c, DR_SKU__c, LeadSource, CreatedDate '
                                   + 'FROM Lead WHERE '+clauseIndividualOrSuperUser+' AND (RecordType.developerName = \'Deal_Registration\' OR DR_Lead_Type__c=\'Deal Registration\' OR LeadSource=\'Deal Registration\')'
                                   + ' limit 40000';
        loadRejectedLeads = 'SELECT Name, Owner.Name, Owner.Email, SAP_Customer_No__c, DR_Product__c, Company, DR_Program_Name__c, DR_Program_Type__c, DR_SKU_Quantity__c, DR_SKU__c, LeadSource, CreatedDate '
                            + 'FROM Lead WHERE '+clauseIndividualOrSuperUser+' AND (RecordType.developerName = \'Deal_Registration\' OR DR_Lead_Type__c=\'Deal Registration\' OR LeadSource=\'Deal Registration\')'
                            + ' limit 40000';
    }

    @RemoteAction
    global static OpportunityWrapper[] loadOverallPipeline() {
        list<Opportunity> lstOpp = Database.query(loadOverallPipeline);
        list<OpportunityWrapper> lstOppWrapper = new list<OpportunityWrapper>();
        list<ProductWrapper> lstProductWrapper = new list<ProductWrapper>();
        for(Opportunity objOpp : lstOpp) {
            lstProductWrapper = new list<ProductWrapper>();
            OpportunityWrapper objOppWrapper = new OpportunityWrapper(objOpp.Name, objOpp.Opportunity_Number__c, objOpp.SBQQ__PrimaryQuote__r.name, objOpp.Account.Name, objOpp.DR_Customer_Contact__r.Name, objOpp.Probability, objOpp.Primary_NPN_OEM_ODM_Disti__r.Name, objOpp.DR_Program_Name__c, objOpp.CreatedDate, objOpp.CloseDate, objOpp.DR_Expiration_Date__c, objOpp.Owner.Name, objOpp.Owner.Email );
            for(OpportunityLineItem objOli : objOpp.OpportunityLineItems) {
                ProductWrapper objProdWrapper = new ProductWrapper();
                objProdWrapper.name = objOli.priceBookEntry.Product2.name;
                objProdWrapper.Quantity = objOli.Quantity;
                lstProductWrapper.add(objProdWrapper);
            }
            objOppWrapper.lstProductWrapper = lstProductWrapper;
            lstOppWrapper.add(objOppWrapper);
        }
        return lstOppWrapper;
    }

    @RemoteAction
    global static OpportunityWrapper[] loadOverallPipelineClosedWon() {
        list<Opportunity> lstOpp = Database.query(loadOverallPipelineClosedWon);
        list<OpportunityWrapper> lstOppWrapper = new list<OpportunityWrapper>();
        list<ProductWrapper> lstProductWrapper = new list<ProductWrapper>();
        for(Opportunity objOpp : lstOpp) {
            lstProductWrapper = new list<ProductWrapper>();
            OpportunityWrapper objOppWrapper = new OpportunityWrapper(objOpp.Name, objOpp.Opportunity_Number__c, objOpp.SBQQ__PrimaryQuote__r.name, objOpp.Account.Name, objOpp.DR_Customer_Contact__r.Name, objOpp.Probability, objOpp.Primary_NPN_OEM_ODM_Disti__r.Name, objOpp.DR_Program_Name__c, objOpp.CreatedDate, objOpp.CloseDate, objOpp.DR_Expiration_Date__c, objOpp.Owner.Name, objOpp.Owner.Email );
            for(OpportunityLineItem objOli : objOpp.OpportunityLineItems) {
                ProductWrapper objProdWrapper = new ProductWrapper();
                objProdWrapper.name = objOli.priceBookEntry.Product2.name;
                objProdWrapper.Quantity = objOli.Quantity;
                lstProductWrapper.add(objProdWrapper);
            }
            objOppWrapper.lstProductWrapper = lstProductWrapper;
            lstOppWrapper.add(objOppWrapper);
        }
        return lstOppWrapper;
    }
    
    @RemoteAction
    global static OpportunityWrapper[] loadOverallPipelineClosedLost() {
        list<Opportunity> lstOpp = Database.query(loadOverallPipelineClosedLost);
        list<OpportunityWrapper> lstOppWrapper = new list<OpportunityWrapper>();
        list<ProductWrapper> lstProductWrapper = new list<ProductWrapper>();
        for(Opportunity objOpp : lstOpp) {
            lstProductWrapper = new list<ProductWrapper>();
            OpportunityWrapper objOppWrapper = new OpportunityWrapper(objOpp.Name, objOpp.Opportunity_Number__c, objOpp.SBQQ__PrimaryQuote__r.name, objOpp.Account.Name, objOpp.DR_Customer_Contact__r.Name, objOpp.Probability, objOpp.Primary_NPN_OEM_ODM_Disti__r.Name, objOpp.DR_Program_Name__c, objOpp.CreatedDate, objOpp.CloseDate, objOpp.DR_Expiration_Date__c, objOpp.Owner.Name, objOpp.Owner.Email );
            for(OpportunityLineItem objOli : objOpp.OpportunityLineItems) {
                ProductWrapper objProdWrapper = new ProductWrapper();
                objProdWrapper.name = objOli.priceBookEntry.Product2.name;
                objProdWrapper.Quantity = objOli.Quantity;
                lstProductWrapper.add(objProdWrapper);
            }
            objOppWrapper.lstProductWrapper = lstProductWrapper;
            lstOppWrapper.add(objOppWrapper);
        }
        return lstOppWrapper;
    }

    @RemoteAction
    global static OpportunityWrapper[] loadClosedWonPipelineCurrentFQ() {
        list<Opportunity> lstOpp = Database.query(loadClosedWonPipelineCurrentFQ);
        list<OpportunityWrapper> lstOppWrapper = new list<OpportunityWrapper>();
        list<ProductWrapper> lstProductWrapper = new list<ProductWrapper>();
        for(Opportunity objOpp : lstOpp) {
            lstProductWrapper = new list<ProductWrapper>();
            OpportunityWrapper objOppWrapper = new OpportunityWrapper(objOpp.Name, objOpp.Opportunity_Number__c, objOpp.SBQQ__PrimaryQuote__r.name, objOpp.Account.Name, objOpp.DR_Customer_Contact__r.Name, objOpp.Probability, objOpp.Primary_NPN_OEM_ODM_Disti__r.Name, objOpp.DR_Program_Name__c, objOpp.CreatedDate, objOpp.CloseDate, objOpp.DR_Expiration_Date__c, objOpp.Owner.Name, objOpp.Owner.Email );
            for(OpportunityLineItem objOli : objOpp.OpportunityLineItems) {
                ProductWrapper objProdWrapper = new ProductWrapper();
                objProdWrapper.name = objOli.priceBookEntry.Product2.name;
                objProdWrapper.Quantity = objOli.Quantity;
                lstProductWrapper.add(objProdWrapper);
            }
            objOppWrapper.lstProductWrapper = lstProductWrapper;
            lstOppWrapper.add(objOppWrapper);
        }
        return lstOppWrapper;
    }
    
    @RemoteAction
    global static OpportunityWrapper[] loadOverallPipelineCurrentFQ() {
        list<Opportunity> lstOpp = Database.query(loadOverallPipelineCurrentFQ);
        list<OpportunityWrapper> lstOppWrapper = new list<OpportunityWrapper>();
        list<ProductWrapper> lstProductWrapper = new list<ProductWrapper>();
        for(Opportunity objOpp : lstOpp) {
            lstProductWrapper = new list<ProductWrapper>();
            OpportunityWrapper objOppWrapper = new OpportunityWrapper(objOpp.Name, objOpp.Opportunity_Number__c, objOpp.SBQQ__PrimaryQuote__r.name, objOpp.Account.Name, objOpp.DR_Customer_Contact__r.Name, objOpp.Probability, objOpp.Primary_NPN_OEM_ODM_Disti__r.Name, objOpp.DR_Program_Name__c, objOpp.CreatedDate, objOpp.CloseDate, objOpp.DR_Expiration_Date__c, objOpp.Owner.Name, objOpp.Owner.Email );
            for(OpportunityLineItem objOli : objOpp.OpportunityLineItems) {
                ProductWrapper objProdWrapper = new ProductWrapper();
                objProdWrapper.name = objOli.priceBookEntry.Product2.name;
                objProdWrapper.Quantity = objOli.Quantity;
                lstProductWrapper.add(objProdWrapper);
            }
            objOppWrapper.lstProductWrapper = lstProductWrapper;
            lstOppWrapper.add(objOppWrapper);
        }
        return lstOppWrapper;
    }

    @RemoteAction
    global static LeadWrapper[] loadPendingApprovalLeads() {
        list<Id> lstLeadIds = new list<Id>();
        list<Id> lstPNIds = new list<Id>();
        map<Id, String> mapNextApprover = new map<Id, String>();
        list<Lead> lstLead = Database.query(loadPendingApprovalLeads);
        if(lstLead.size() > 0) {
            for(Lead objLead : lstLead) {
                lstLeadIds.add(objLead.id);
            }
        }
        /*list<ProcessInstanceNode> lstPIN = [Select Id, ProcessNodeId from ProcessInstanceNode where ProcessInstanceId in (Select Id from ProcessInstance where targetObjectId in :lstLeadIds and Status = 'Pending') and NodeStatus='Pending'];
           for(ProcessInstanceNode objPIN : lstPIN) {
            lstPNIds.add(objPIN.ProcessNodeId);
           }*/
        list<ProcessInstanceWorkItem> lstPIWI = [Select Id, ProcessInstance.TargetObjectId, Actor.Name from ProcessInstanceWorkItem where ProcessInstanceId in (Select Id from ProcessInstance where targetObjectId in :lstLeadIds and Status = 'Pending')]; //and StepNodeId IN :lstPNIds
        for(ProcessInstanceWorkItem objPIWI : lstPIWI) {
            if(!mapNextApprover.containsKey(objPIWI.ProcessInstance.TargetObjectId)) {
                mapNextApprover.put(objPIWI.ProcessInstance.TargetObjectId, objPIWI.Actor.Name);
            }
        }
        list<LeadWrapper> lstLeadWrapper = new list<LeadWrapper>();
        LeadWrapper objLeadWrapper;
        if(lstLead.size() > 0) {
            for(Lead objLead : lstLead) {
                if(mapNextApprover.containsKey(objLead.Id)) {
                    objLeadWrapper = new LeadWrapper(objLead.Name, mapNextApprover.get(objLead.Id), objLead.Company, objLead.DR_Program_Name__c, objLead.LeadSource, objLead.CreatedDate, objLead.Owner.Name, objLead.Owner.Email, objLead.SAP_Customer_No__c, objLead.DR_Program_Type__c, objLead.DR_Product__c, objLead.DR_SKU__c, objLead.DR_SKU_Quantity__c);
                    lstLeadWrapper.add(objLeadWrapper);
                }/* else {lstLeadWrapper.add(objLeadWrapper);
                    objLeadWrapper = new LeadWrapper(objLead.Name, '', objLead.Company, objLead.Status, objLead.LeadSource, objLead.CreatedDate);
                    }*/
    
    
            }
        }
        return lstLeadWrapper;
    }

    @RemoteAction
    global static LeadWrapper[] loadRejectedLeads() {
        list<Id> lstLeadIds = new list<Id>();
        list<Id> lstPNIds = new list<Id>();
        map<Id, LeadRejectedWrapper> mapRejectedLeadDetails = new map<Id, LeadRejectedWrapper>();
        list<Lead> lstLead = Database.query(loadRejectedLeads);
        if(lstLead.size() > 0) {
            for(Lead objLead : lstLead) {
                lstLeadIds.add(objLead.id);
            }
        }
        list<ProcessInstanceStep> lstPIS = [Select Id, ProcessInstance.TargetObjectId, ProcessInstance.CompletedDate, Actor.Name, Comments from ProcessInstanceStep where StepStatus = 'Rejected' and ProcessInstanceId in (Select Id from ProcessInstance where targetObjectId in :lstLeadIds and Status = 'Rejected')]; //and StepNodeId IN :lstPNIds
        for(ProcessInstanceStep objPIS : lstPIS) {
            if(!mapRejectedLeadDetails.containsKey(objPIS.ProcessInstance.TargetObjectId)) {
                mapRejectedLeadDetails.put(objPIS.ProcessInstance.TargetObjectId, new LeadRejectedWrapper(objPIS.Actor.Name, objPIS.ProcessInstance.CompletedDate, objPIS.Comments));
            }
        }
        list<LeadWrapper> lstLeadWrapper = new list<LeadWrapper>();
        LeadWrapper objLeadWrapper;
        if(lstLead.size() > 0) {
            for(Lead objLead : lstLead) {
                if(mapRejectedLeadDetails.containsKey(objLead.Id)) {
                    objLeadWrapper = new LeadWrapper(objLead.Name, mapRejectedLeadDetails.get(objLead.Id).RejectionComment, objLead.Company, objLead.DR_Program_Name__c, objLead.LeadSource, objLead.CreatedDate, mapRejectedLeadDetails.get(objLead.Id).RejectedDate, mapRejectedLeadDetails.get(objLead.Id).RejectedNVApprover, objLead.SAP_Customer_No__c, objLead.DR_Program_Type__c, objLead.DR_Product__c, objLead.DR_SKU__c, objLead.DR_SKU_Quantity__c);
                    lstLeadWrapper.add(objLeadWrapper);
                }
            }
        }
        return lstLeadWrapper;
    }

    global class LeadRejectedWrapper {
        public DateTime RejectedDate;
        public String RejectedNVApprover;
        public String RejectionComment;
        
        public LeadRejectedWrapper(String RejectedNVApprover, DateTime RejectedDate, String RejectionComment) {
            this.RejectedDate= RejectedDate;
            this.RejectedNVApprover = RejectedNVApprover;
            this.RejectionComment = RejectionComment;
        }
    
    }

    global class LeadWrapper {
        public DateTime RejectedDate;
        public String RejectedNVApprover;
        public String RejectionComment;
        public String Name;
        public String ownerEmail;
        public String ownerName;
        public String NextApprover;
        public String Company;
        public String PrimaryCustomerContact;
        public String ProgramType;
        public String Product;
        public String SUMSSupport;
        public Decimal Quantity;
        public String ProgramName;
        public String LeadSource;
        public DateTime CreatedDate;
    
        public LeadWrapper(String Name, String NextApprover, String Company, String ProgramName, String LeadSource, DateTime CreatedDate, String ownerName, String ownerEmail, String PrimaryCustomerContact, String ProgramType, String Product, String SUMSSupport, Decimal Quantity) {
            this.Name = Name;
            this.ownerName = ownerName;
            this.ownerEmail = ownerEmail;
            this.NextApprover = NextApprover;
            this.Company = Company;
            this.ProgramName = ProgramName;
            this.LeadSource = LeadSource;
            this.CreatedDate = CreatedDate;
            this.PrimaryCustomerContact = PrimaryCustomerContact;
            this.ProgramType = ProgramType;
            this.Product = Product;
            this.SUMSSupport = SUMSSupport;
            this.Quantity = Quantity;
        }
        
        public LeadWrapper(String Name, String RejectionComment, String Company, String ProgramName, String LeadSource, DateTime CreatedDate, DateTime RejectedDate, String RejectedNVApprover, String PrimaryCustomerContact, String ProgramType, String Product, String SUMSSupport, Decimal Quantity) {
            this.Name = Name;
            this.RejectedDate= RejectedDate;
            this.RejectedNVApprover = RejectedNVApprover;
            this.RejectionComment = RejectionComment;
            this.Company = Company;
            this.ProgramName = ProgramName;
            this.LeadSource = LeadSource;
            this.CreatedDate = CreatedDate;
            this.PrimaryCustomerContact = PrimaryCustomerContact;
            this.ProgramType = ProgramType;
            this.Product = Product;
            this.SUMSSupport = SUMSSupport;
            this.Quantity = Quantity;
        }

    }

    global class OpportunityWrapper {
        public String Name;
        public String OpportunityNumber;
        public string QuoteNumber;
        public String Company;
        public String CustomerContact;
        public Decimal Probability;
        public String NextApprover;
        public String confirmedOEMODMDistiPartner;
        public String ProgramName;
        public DateTime CreatedDate;
        public DateTime CloseDate;
        public DateTime ExpirationDate;
        public String ownerEmail;
        public String ownerName;
        list<ProductWrapper> lstProductWrapper;
    
        public OpportunityWrapper(String Name, String OpportunityNumber, String QuoteNumber, String Company, String CustomerContact, Decimal Probability, String ConfirmedOEMODMDistiPartner, String ProgramName, DateTime CreatedDate, DateTime CloseDate, DateTime ExpirationDate, String ownerName, String ownerEmail) {
            this.Name = Name;
            this.OpportunityNumber = OpportunityNumber;
            this.QuoteNumber = QuoteNumber;
            this.Company = Company;
            this.CustomerContact = CustomerContact;
            this.Probability = Probability;
            this.NextApprover = NextApprover;
            this.confirmedOEMODMDistiPartner = confirmedOEMODMDistiPartner;
            this.ProgramName = ProgramName;
            this.CreatedDate = CreatedDate;
            this.CloseDate = CloseDate;
            this.ExpirationDate = ExpirationDate;
            this.ownerName = ownerName;
            this.ownerEmail = ownerEmail;
            this.lstProductWrapper = new list<ProductWrapper>();
        }
    
    }

    global class ProductWrapper {
        public String Name;
        public Decimal Quantity;
    }

}