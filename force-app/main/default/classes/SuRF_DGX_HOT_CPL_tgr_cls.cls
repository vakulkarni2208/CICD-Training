public without sharing class SuRF_DGX_HOT_CPL_tgr_cls {
    
    public static void process_DGX_HOT_Status (Map<Id, SuRF_DGX_HOT_Compliance__c > triggerNewMap){
        
        Map<String, SuRF_DGX_HOT_Compliance__c> accIdDHCMap = new Map<String, SuRF_DGX_HOT_Compliance__c>();
        Map<String, Decimal> accIdDHCStatusMap = new Map<String, Decimal>();
        Map<String, Boolean> accIdSpecialRegFlagMap = new Map<String, Boolean>();

        List<Account> accountsForUpdate = new List<Account>();
        List<Partner_Attribute__c> partnerAttrbForUpdate = new List<Partner_Attribute__c>();
        
        for(SuRF_DGX_HOT_Compliance__c dObj : triggerNewMap.values()){

            if(COMM_Constants.PA_PROGRAM_SP.equals(dObj.Partner_Program_Name__c)  && dObj.Competency__c.contains('DGX')){
                accIdDHCMap.put(dObj.Account_Id__c, dObj);
                accIdDHCStatusMap.put(dObj.Account_Id__c, dObj.Flag__c);
            }
        }
        
        if(!accIdDHCStatusMap.isEmpty()){
            for(String accId : accIdDHCStatusMap.keySet()){
                // Update the Special_Reg_Enabled_c flag on account
                if(accIdDHCStatusMap.get(accId) == 1){
                    accIdSpecialRegFlagMap.put(accId, true);
                }else{
                    accIdSpecialRegFlagMap.put(accId, false);
                }
            }
        }
        
        List<Account> accountList = [SELECT Id, Special_Reg_Enabled__c, (SELECT Id, ATP_Partner__c, ATP_Partner_Start_Date__c  FROM Account_Attributes__r WHERE Date_Competency_Terminated__c = null AND Partner_Competency__c LIKE '%DGX%' AND Partner_Program_Name__c = 'Solution Provider') FROM Account WHERE Id IN :accIdSpecialRegFlagMap.keySet()];

        if(!accountList.isEmpty()){
            for(Account accObj : accountList){
                if(accObj.Account_Attributes__r.size() > 0){
                    for(Partner_Attribute__c paObj : accObj.Account_Attributes__r){
                        if(paObj.ATP_Partner__c != accIdSpecialRegFlagMap.get(accObj.Id) && accIdSpecialRegFlagMap.get(accObj.Id)){
                            paObj.ATP_Partner__c = true;
                            paObj.ATP_Partner_Start_Date__c = Date.Today();
                        }else{
                            paObj.ATP_Partner__c = false;
                            paObj.ATP_Partner_Start_Date__c = null;
                        }
                        partnerAttrbForUpdate.add(paObj);
                    }

                    if(accObj.Special_Reg_Enabled__c != accIdSpecialRegFlagMap.get(accObj.Id)){
                        accObj.Special_Reg_Enabled__c = accIdSpecialRegFlagMap.get(accObj.Id);
                        accountsForUpdate.add(accObj);
                    }
                }
            }
        }
        
        if(!partnerAttrbForUpdate.isEmpty() && !accountsForUpdate.isEmpty()){
            System.enqueueJob(new SuRF_QueableClassForDML(partnerAttrbForUpdate, accountsForUpdate));
        }
    }

    public without sharing class SuRF_QueableClassForDML implements Queueable {

        List<Account> accountsForUpdate = new List<Account>();
        List<Partner_Attribute__c> partnerAttributesForUpdate = new List<Partner_Attribute__c>();

        public SuRF_QueableClassForDML(List<Partner_Attribute__c> partnerAttributesForUpdate, List<Account> accountsForUpdate){

            if(partnerAttributesForUpdate != null && !partnerAttributesForUpdate.isEmpty()) {
                this.partnerAttributesForUpdate = partnerAttributesForUpdate;
            }
            if(accountsForUpdate != null && !accountsForUpdate.isEmpty()) {
                this.accountsForUpdate = accountsForUpdate ;
            }        
        }
        
        public void execute(QueueableContext context) {
            
            if(!partnerAttributesForUpdate.isEmpty()) {
                Database.SaveResult[] srListForPAUpdate = Database.Update(partnerAttributesForUpdate, false);
                System.debug('>>> srListForPAUpdate: '+srListForPAUpdate);
            }
            
            if(!accountsForUpdate.isEmpty()) {
                Database.SaveResult[] srListForAccountUpdate = Database.Update(accountsForUpdate, false);
                System.debug('>>> srListForAccountUpdate: '+srListForAccountUpdate);
            }
        }
    }
}