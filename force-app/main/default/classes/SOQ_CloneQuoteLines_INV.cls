public class SOQ_CloneQuoteLines_INV {
    
    @InvocableMethod
    public static void cloneQuoteLInes(list<String> OppKeys) {
        system.debug('OppKeys:1105 '+ OppKeys);
        if(OppKeys == NULL || OppKeys.isEmpty())
            return;
        
        list<String> oppList = OppKeys[0].split('-');
        system.debug('oppList:1105 '+ oppList);
        SOQ_CloneQuoteLines_BAT bat = new SOQ_CloneQuoteLines_BAT(oppList[0], oppList[1]);
        //bat.ParentOpportunityIds = ParentOpportunityIds;
        Id batchJobId = Database.executeBatch(bat, 1);
        system.debug('batchJobId: '+ batchJobId);
        //system.debug('parentOppId:1105 '+ parentOppId);
        
        /*if(OpportunityIds != NULL && OpportunityIds.size() > 0) {
            System.debug('OpportunityIds := ' + OpportunityIds);
            
            set<String> ParentOpportunityIds = new set<String>();
            ParentOpportunityIds.addAll(OpportunityIds);
            
            SOQ_CloneQuoteLines_BAT bat = new SOQ_CloneQuoteLines_BAT();
            bat.ParentOpportunityIds = ParentOpportunityIds;
            Id batchJobId = Database.executeBatch(bat, 1);
            system.debug('batchJobId: '+ batchJobId);
        }*/
    }
}