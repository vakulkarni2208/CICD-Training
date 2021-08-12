public class SOQ_CloneQuoteLines_BAT implements Database.Batchable<SObject>, Database.RaisesPlatformEvents, Database.Stateful{
    
    public string ORIGINAL_OPPORTUNITY_ID;
    public string CLONED_OPPORTUNITY_ID;
    
    public SOQ_CloneQuoteLines_BAT(String originalOppId, String clonedOppId) {
        ORIGINAL_OPPORTUNITY_ID = originalOppId;
        CLONED_OPPORTUNITY_ID = clonedOppId;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('ORIGINAL_OPPORTUNITY_ID:1105 '+ ORIGINAL_OPPORTUNITY_ID);
        system.debug('CLONED_OPPORTUNITY_ID:1105 '+ CLONED_OPPORTUNITY_ID);
        if(CLONED_OPPORTUNITY_ID != NULL) {
        //Query all New Opportunities based on Parent Opportunity IDs
        return Database.getQueryLocator([SELECT Id, SBQQ__PrimaryQuote__c
                                         FROM Opportunity 
                                         WHERE Id =: CLONED_OPPORTUNITY_ID]);
        }
        return null;
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        system.debug('---------Entering Batch Job SOQ_CloneQuoteLines_BAT execute method-------------------');
        system.debug('ORIGINAL_OPPORTUNITY_ID:1105 '+ ORIGINAL_OPPORTUNITY_ID);
        system.debug('CLONED_OPPORTUNITY_ID:1105 '+ CLONED_OPPORTUNITY_ID);
        system.debug('Scope:1105 ' + Scope);
        if (scope != null && !scope.isEmpty()){
            //Clone Quote Lines from Original(Parent) Opportunity.
            SOQ_Utils.cloneQuoteLines(ORIGINAL_OPPORTUNITY_ID, CLONED_OPPORTUNITY_ID);
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        system.debug('---------Entering Batch Job finish method-------------------');
        system.debug('---------Chains SOQ_CreateQuoteLineHierarchy_BAT to create Hierarchy between QuoteLines-------------------');
        Id batchJobId = Database.executeBatch(new SOQ_CreateQuoteLineHierarchy_BAT(), 1);
        system.debug('---------Exiting Batch Job finish method-------------------');
    }
}

/*
 
    public set<String> ParentOpportunityIds = new set<String>();
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Query all New Opportunities based on Parent Opportunity IDs
        return Database.getQueryLocator([SELECT Id, SBQQ__PrimaryQuote__c, Opportunity_Id__c
                                         FROM Opportunity 
                                         WHERE Opportunity_Id__c in: ParentOpportunityIds]);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        system.debug('---------Entering Batch Job SOQ_CloneQuoteLines_BAT execute method-------------------');
        if (scope != null && !scope.isEmpty()){
            Map<Id, Opportunity> newOpportunitiesMap = new Map<Id, Opportunity>((List<opportunity>) scope);
            system.debug('***lstOpportunity Scope > ' + Scope);
            set<String> ParentOppIds = new set<String>();
            set<Id> newOppIdsToReset = new set<Id>();
            for(Opportunity opp : newOpportunitiesMap.values()){
                if(opp.Opportunity_Id__c != opp.Id) {
                	ParentOppIds.add(opp.Opportunity_Id__c);
                    newOppIdsToReset.add(opp.Id);
                }
            }
            
            //Clone Quote Lines from Original(Parent) Opportunity.
            SOQ_Utils.cloneQuoteLines(ParentOppIds);
            
            //Reset Opportunity_Id(Text) on new Opportunities.
            SOQ_Utils.resetOpportunityIdField(newOppIdsToReset);
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        system.debug('---------Entering Batch Job finish method-------------------');
        system.debug('---------Chains SOQ_CreateQuoteLineHierarchy_BAT to create Hierarchy between QuoteLines-------------------');
        Id batchJobId = Database.executeBatch(new SOQ_CreateQuoteLineHierarchy_BAT(), 1);
        system.debug('---------Exiting Batch Job finish method-------------------');
    } 
  */