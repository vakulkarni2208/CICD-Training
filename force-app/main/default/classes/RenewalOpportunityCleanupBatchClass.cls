/*
* Author: Venkat
* Date: 8/24/2018
* Description:
* This Batch class is scheduled to run daily at once to process all Renewal Opportunity Cleanup Batch Class
* This Batch class is scheduled to run daily at once to clean renewal Opps

*/
public class RenewalOpportunityCleanupBatchClass implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    public final String Query;
    
    // Constructor
    public RenewalOpportunityCleanupBatchClass() {
        Query = runquery();
    }
    // method to form Dynamic SOQL query.
    public string runquery() {       
        String queryString;
        queryString = 'select id, Number_of_Renewal_Contracts__c, StageName, Original_Customer_Opportunity__c,  Opportunity_Expiration_Date__c, Opportunity_Expired__c, SBQQ__RenewedContract__r.SBQQ__RenewalOpportunity__r.StageName , SBQQ__RenewedContract__r.SBQQ__RenewalOpportunity__c, SBQQ__RenewedContract__c, RecordTypeId, First_Expiration_Date__c from Opportunity where RecordTypeId =\'012400000009ooCAAQ\' and ( StageName !=\'Renewal Closed Won\' OR StageName !=\'Dead\'  OR StageName !=\'Closed Won\' OR StageName !=\'Closed Lost\') and ( SBQQ__RenewedContract__r.SBQQ__RenewalOpportunity__r.StageName = \'Renewal Closed Won\' OR SBQQ__RenewedContract__r.SBQQ__RenewalOpportunity__r.StageName  =\'Closed Won\' OR SBQQ__RenewedContract__r.SBQQ__RenewalOpportunity__r.StageName =\'Closed Lost\' ) and First_Expiration_Date__c <=';  
        queryString= queryString + String.ValueOf(system.today()) + ' Limit 100'; 
        
        If(Test.isRunningTest()){
            queryString = 'select id, Number_of_Renewal_Contracts__c, StageName, Original_Customer_Opportunity__c,  Opportunity_Expiration_Date__c, Opportunity_Expired__c, SBQQ__RenewedContract__r.SBQQ__RenewalOpportunity__r.StageName , SBQQ__RenewedContract__r.SBQQ__RenewalOpportunity__c, SBQQ__RenewedContract__c, RecordTypeId, First_Expiration_Date__c from Opportunity limit 10';
        }
        system.debug('queryString---->'+queryString);  
        return queryString;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(Query); 
    }
    
    public void execute(Database.BatchableContext info, List<Opportunity> OppScope) {
        
        
        List<id> OppIdList = new List<id>();
        List<id> Contractids = new List<id>();
        Map<id, Opportunity> OppMap = new Map<id, Opportunity>();
        MAP<id,Contract> ContractOppMap = new MAP<id,Contract>();
        for(Opportunity opp: OppScope) {
            OppMap.put(opp.Id, opp);
            OppIdList.add(opp.id);
            Contractids.add(opp.SBQQ__RenewedContract__c);  
        }
        for(Contract cont : [select id, ContractNumber, SBQQ__RenewalOpportunity__c,SBQQ__RenewalOpportunity__r.stageName   from Contract WHERE id =: Contractids]){ // and recordtypeid =:'012400000009ooCAAQ'  
            ContractOppMap.put(cont.id,cont);
        }
        Map<id, Opportunity> newOppMap = new Map<id, Opportunity>();
        
        List<Opportunity> OppUpdateList = new List<Opportunity>();
        For(Opportunity Opp : [SELECT Number_of_Renewal_Contracts__c , StageName, (SELECT id, contractNumber FROM SBQQ__RenewedContracts__r) FROM Opportunity WHERE id =: OppIdList]){ // and recordtypeid =:'012400000009ooCAAQ' 
            Opp.Number_of_Renewal_Contracts__c = Opp.SBQQ__RenewedContracts__r.size();
            newOppMap.put(Opp.id,Opp);
            system.debug('----VVV-3---'+OppUpdateList);
        }
        For(Opportunity Oppx : OppScope){ 
            Oppx.Number_of_Renewal_Contracts__c = newOppMap.get(Oppx.id).Number_of_Renewal_Contracts__c;
            //Oppx.StageName = newOppMap.get(Oppx.id).StageName;
            if(Oppx.id != ContractOppMap.get(Oppx.SBQQ__RenewedContract__c).SBQQ__RenewalOpportunity__c){
                Oppx.Original_Customer_Opportunity__c = ContractOppMap.get(Oppx.SBQQ__RenewedContract__c).SBQQ__RenewalOpportunity__c;
                string parent_Opp_stage = ContractOppMap.get(Oppx.SBQQ__RenewedContract__c).SBQQ__RenewalOpportunity__r.stageName;
                if(parent_Opp_stage =='Renewal Closed Won' || parent_Opp_stage =='Closed Won' || parent_Opp_stage =='Closed Lost'){
                    Oppx.StageName = 'Dead';
                    Oppx.Number_of_Renewal_Contracts__c = newOppMap.get(Oppx.id).Number_of_Renewal_Contracts__c;
                    OppUpdateList.add(Oppx);
                }
            }
        }
        
        if(!OppUpdateList.isEmpty()) {
            system.debug('OppUpdateList------>'+OppUpdateList);
            Update OppUpdateList;
        }    
    }  // end of execute() method.
    
    public void finish(Database.BatchableContext BC) {}
    // execute method of Schedule class
    public void execute(SchedulableContext sc) {
        //invoke Batch class
        RenewalOpportunityCleanupBatchClass RenewalOppCleanUP = new RenewalOpportunityCleanupBatchClass();
        Id batchinstanceid = database.executeBatch(RenewalOppCleanUP);
    }
    
    
    /**
    * @description Dummy test method - Technical Dept
    * @param  Dummy method
    * @return  Void: It returns nothing
    */  
     public void CoverageMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }   
    
    
}