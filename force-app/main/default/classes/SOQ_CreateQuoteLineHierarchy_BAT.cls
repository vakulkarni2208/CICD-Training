/*
    SOQ_CreateQuoteLineHierarchy_BAT.cls
    2021.03.02 - pjena - Batch class to build hierarchy among Quote Line Items for Opp Reg Opportunites. 
    It is called from the batch SOQ_CreateQuoteLine_BAT's finish method (chaining)
*/
public class SOQ_CreateQuoteLineHierarchy_BAT implements Database.Batchable<SObject>, Database.RaisesPlatformEvents {
    list<OppReg_Quote_Tracker__c> lstORQTracker = new  list<OppReg_Quote_Tracker__c>();
    public SOQ_CreateQuoteLineHierarchy_BAT() {}

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,QuoteId__c,QuoteLineHierarchyNeeded__c,QuoteLineHierarchyCompleted__c 
                                        FROM OppReg_Quote_Tracker__c 
                                        Where   QuoteLineCreated__c = true 
                                            And QuoteLineHierarchyNeeded__c = true 
                                            And QuoteLineHierarchyCompleted__c = false
                                        Order By LastModifiedDate desc
                                    ]);

    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        system.debug('---------Entering Batch Job SOQ_CreateQuoteLineHierarchy_BAT execute method-------------------');
        if (scope != null && !scope.isEmpty()){
                list<OppReg_Quote_Tracker__c> lstORQTracker = new  list<OppReg_Quote_Tracker__c>();
                lstORQTracker = (List<OppReg_Quote_Tracker__c>) scope;
                system.debug('***lstPRQTracker > ' + lstORQTracker);
                
                for (OppReg_Quote_Tracker__c ORQTracker : lstORQTracker){
                    //Begin: Update Quote Lines
                    //------------------------------------------------------------------------------------------------------------------------
                    string quoteId = ORQTracker.QuoteId__c;
                    //Query all the Quote Line Items related to the Quote and create a map of Quote Line Number, Quote Line Id (ex. {10.0, a3p02000000GrdFAAS}, {20.0, a3p02000000GrdGAAS})
                    map<decimal, id> mapLineNumberQLId = new map<decimal, Id>();
                    list<SBQQ__QuoteLine__c> lstQLs = [Select Id, SBQQ__Number__c, Parent_Line_Number__c, SBQQ__RequiredBy__c
                                                        From SBQQ__QuoteLine__c 
                                                        Where SBQQ__Quote__c  = :quoteId];                                                        
                    for (SBQQ__QuoteLine__c oQL : lstQLs){
                        mapLineNumberQLId.put(oQL.SBQQ__Number__c, oQL.Id);
                    }

                    //For each of the Quote Lines; based on the Parent_Line_Number's QuoteLineId (get from Map), set the SBQQ__RequiredBy__c 
                    for (SBQQ__QuoteLine__c oQL : lstQLs){
                        if (oQL.Parent_Line_Number__c != null && mapLineNumberQLId.get(oQL.Parent_Line_Number__c) != null){
                            oQL.SBQQ__RequiredBy__c = mapLineNumberQLId.get(oQL.Parent_Line_Number__c);
                        }
                    }

                    system.debug('***Before Update | quoteLines = ' + lstQLs);
                    update lstQLs;
                    system.debug('***After Update | quoteLines = ' + lstQLs);

                    system.debug('***Before Update | ORQTracker = ' + ORQTracker);
                    ORQTracker.QuoteLineHierarchyCompleted__c = true;
                    update ORQTracker;
                    system.debug('***After Update | ORQTracker = ' + ORQTracker);

                    //End: Update Quote Lines
                    //------------------------------------------------------------------------------------------------------------------------
                }
            
        }
        system.debug('---------Exiting Batch Job SOQ_CreateQuoteLineHierarchy_BAT execute method-------------------');
    }

    public void finish(Database.BatchableContext BC) {
         //Some Finish logic
    }
}