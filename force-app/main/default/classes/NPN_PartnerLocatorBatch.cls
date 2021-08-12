global class NPN_PartnerLocatorBatch implements Database.Batchable<sObject> {


    Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('NPN_Account_Registry').getRecordTypeId();
    String query ='';

    public NPN_PartnerLocatorBatch(){


        if(String.isNotBlank(System.Label.NPN_Partner_Locator_Query)) {

            query = System.Label.NPN_Partner_Locator_Query;
        }else{
            query = 'SELECT Id, Name, BillingStreet, BillingCity, BillingState,BillingPostalCode, BillingCountry,Billing_Region__c,Website, '+
                    '(SELECT Id, Account_Name__c,Partner_Competency__c,Partner_Program_Name__c,Partner_Sub_Program__c,Program_Level__c, ATP_Partner__c, ATP_Partner_Start_Date__c, ATP_Partner_Termination_Date__c FROM Account_Attributes__r WHERE Date_Competency_Terminated__c = null AND CALENDAR_YEAR(Date_Competency_Signed__c) != 2099 AND Partner_Competency__c IN (\'Tesla\',\'vGPU\',\'Quadro\',\'DGX\') AND Partner_Program_Name__c IN (\'Solution Provider\',\'OEM\',\'Distributor\',\'Cloud Service Provider\',\'Solutions Integration Partner\',\'Service Delivery Partner\'))'+ // All the active partner attributes
                    'FROM Account WHERE RecordTypeId = :accRecTypeId AND NPN_Program_Termination_Date__c = NULL AND Inactive__c = FALSE';
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> scope){

        List<NPN_Partner_Locator__c> partnerLocatorsForInsert = new List<NPN_Partner_Locator__c>();
        Map<Id, Integer> accountCount = new Map<Id, Integer>();
        for(Account acnt : scope) {

            accountCount.put(acnt.Id, acnt.Account_Attributes__r.size());
            if(!acnt.Account_Attributes__r.isEmpty()) {
                for(Partner_Attribute__c pat : acnt.Account_Attributes__r) {

                    NPN_Partner_Locator__c plObj = new NPN_Partner_Locator__c();

                    plObj.Account_Name__c           = acnt.Id;
                    plObj.Partner_Name__c           = acnt.Name;
                    plObj.Country__c                = String.isNotBlank(acnt.BillingCountry) ? acnt.BillingCountry : '';
                    plObj.State__c                  = String.isNotBlank(acnt.BillingState) ? acnt.BillingState : '';
                    plObj.City__c                   = String.isNotBlank(acnt.BillingCity) ? acnt.BillingCity : '';
                    plObj.Street__c                 = String.isNotBlank(acnt.BillingStreet) ? acnt.BillingStreet : '';
                    plObj.Region__c                 = String.isNotBlank(acnt.Billing_Region__c) ? acnt.Billing_Region__c : '';
                    plObj.Zip_Postal_Code__c        = String.isNotBlank(acnt.BillingPostalCode) ? acnt.BillingPostalCode : '';
                    plObj.Website__c                = String.isNotBlank(acnt.Website) ? acnt.Website : '';
                    plObj.Partner_Competency__c     = String.isNotBlank(pat.Partner_Competency__c) ? pat.Partner_Competency__c : '';
                    plObj.Program_Level__c          = String.isNotBlank(pat.Program_Level__c) ? pat.Program_Level__c : '';
                    plObj.Partner_Sub_Program__c    = String.isNotBlank(pat.Partner_Sub_Program__c) ? pat.Partner_Sub_Program__c : '';

                    if(String.isNotBlank(pat.Partner_Program_Name__c) && COMM_Constants.PA_PROGRAM_SDP.equalsIgnoreCase(pat.Partner_Program_Name__c) && String.isNotBlank(pat.Partner_Sub_Program__c)) {
                        if('EDU Services'.equalsIgnoreCase(pat.Partner_Sub_Program__c)) {
                            plObj.Partner_Program_Name__c   = 'Education Services';
                        }else if ('Professional Services'.equalsIgnoreCase(pat.Partner_Sub_Program__c)) {
                            plObj.Partner_Program_Name__c   ='Professional Services';
                        }
                    }else {
                        plObj.Partner_Program_Name__c   = String.isNotBlank(pat.Partner_Program_Name__c) ? pat.Partner_Program_Name__c : '';
                    }


                    if(String.isNotBlank(pat.Partner_Competency__c) && pat.Partner_Competency__c.contains('DGX') && pat.ATP_Partner__c && pat.ATP_Partner_Start_Date__c != null && pat.ATP_Partner_Termination_Date__c == null ) {
                        plObj.ATP_Partner__c = true;
                    }
                    partnerLocatorsForInsert.add(plObj);
                }
            }
        }

        System.debug('--> accountCount '+ accountCount);
        System.debug('--> partnerLocatorsForInsert.size() '+ partnerLocatorsForInsert.size());
        if(!partnerLocatorsForInsert.isEmpty()) {
            Database.SaveResult[] sr = Database.Insert(partnerLocatorsForInsert, false);
            system.debug('--> save result :'+ sr);
        }



    }

    global void finish(Database.BatchableContext bc){

    }
}