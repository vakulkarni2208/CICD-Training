/*
    SOQ_CreateQuoteLine_BAT.cls
    2020.09.24 - pjena - Batch class to create Quote Line Items for Opp Reg Opportunites. 
    It is called from the batch SOQ_CreateQuote_BAT_SCH's finish method (chaining)
*/

public class SOQ_CreateQuoteLine_BAT implements Database.Batchable<SObject>, Database.RaisesPlatformEvents {
    
    list<SBQQ__Quote__c> lstQuotes = new  list<SBQQ__Quote__c>();
    map<string, SOQ_OppReg_Product_Map__c> mapSOQOppRegProducts = new map<string, SOQ_OppReg_Product_Map__c>();  
    private string OPP_TYPE = 'Deal Registration';
    private DateTime dtLookBackTime;
    
    public SOQ_CreateQuoteLine_BAT (){
        dtLookBackTime  = SOQ_QuoteCreation_Settings__c.getOrgDefaults().BATCHJOB_OppCreationCutOffDateTime__c ; // DateTime
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([Select id,  Programmatic_Disc_Type__c,  SBQQ__Opportunity2__c,
                                            SBQQ__Opportunity2__r.DR_Product__c, SBQQ__Opportunity2__r.DR_SKU__c, SBQQ__Opportunity2__r.DR_SKU_Quantity__c, 
                                            SBQQ__Opportunity2__r.DR_Secondary_Product__c, SBQQ__Opportunity2__r.DR_Secondary_SKU__c, SBQQ__Opportunity2__r.DR_Secondary_SKU_Quntity__c
                                        From SBQQ__Quote__c
                                        Where SBQQ__Primary__c = true
                                            And SBQQ__LineItemCount__c = 0
                                            And SBQQ__Opportunity2__r.Type = :OPP_TYPE
                                            And SBQQ__Opportunity2__r.CreatedDate >= :dtLookBackTime
                                        Order By LastModifiedDate desc
                                    ]);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        system.debug('---------Entering Batch Job SOQ_CreateQuoteLine_BAT execute method-------------------');
        if (scope != null && !scope.isEmpty()){
                lstQuotes = (List<SBQQ__Quote__c>) scope;
                system.debug('***lstQuotes > ' + lstQuotes);
                list<string> oppRegProdNames = new list<string>();
                list<SOQ_OppReg_Product_Map__c> lstSOQOppRegProducts = new list<SOQ_OppReg_Product_Map__c>();

                for (SBQQ__Quote__c oppRegQuote : lstQuotes){

                    //Get all the Opp Reg Products
                    oppRegProdNames.add(oppRegQuote.SBQQ__Opportunity2__r.DR_Product__c);
                    oppRegProdNames.add(oppRegQuote.SBQQ__Opportunity2__r.DR_SKU__c);
                    oppRegProdNames.add(oppRegQuote.SBQQ__Opportunity2__r.DR_Secondary_Product__c);
                    oppRegProdNames.add(oppRegQuote.SBQQ__Opportunity2__r.DR_Secondary_SKU__c);
                    
                    //get all the product information associated with the opp reg
                    lstSOQOppRegProducts = [  SELECT OppReg_Product_Name__c,Term__c, Product__c, Product__r.ProductCode 
                                                        FROM SOQ_OppReg_Product_Map__c
                                                        WHERE OppReg_Product_Name__c in :oppRegProdNames];
                    for (SOQ_OppReg_Product_Map__c SOQOppRegMap : lstSOQOppRegProducts){
                        mapSOQOppRegProducts.put(SOQOppRegMap.OppReg_Product_Name__c, SOQOppRegMap);
                    }
                    //End: get all the product information associated with the opp reg

                    //Collect Primary, Secondary and thier SKUs
                    string strPrimaryProductId, strPrimarySupportSKUProductId, strSecondaryProductId, strSecondarySupportSKUProductId;
                    SOQ_OppReg_Product_Map__c oppRegProdMapPrimary, oppRegProdMapPrimarySKU, oppRegProdMapSecondary, oppRegProdMapSecondarySKU;
                    SBQQ__QuoteLine__c primaryQuoteLine, primarySKUQuoteLine, secondaryQuoteLine, secondarySKUQuoteLine;
                    list<Id> lstPrimarySecondaryProducts = new list<id>();
                    
                    if (oppRegQuote.SBQQ__Opportunity2__r.DR_Product__c != null && mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_Product__c) != null){
                        strPrimaryProductId = mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_Product__c).Product__c;
                        oppRegProdMapPrimary = mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_Product__c);
                        lstPrimarySecondaryProducts.add(strPrimaryProductId);
                    }
                    if (oppRegQuote.SBQQ__Opportunity2__r.DR_SKU__c != null && mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_SKU__c) != null){
                        strPrimarySupportSKUProductId = mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_SKU__c).Product__c;
                        oppRegProdMapPrimarySKU = mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_SKU__c);
                    }
                    if (oppRegQuote.SBQQ__Opportunity2__r.DR_Secondary_Product__c != null && mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_Secondary_Product__c) != null){
                        strSecondaryProductId = mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_Secondary_Product__c).Product__c;
                        oppRegProdMapSecondary = mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_Secondary_Product__c);
                        lstPrimarySecondaryProducts.add(strSecondaryProductId);
                    }
                    If (oppRegQuote.SBQQ__Opportunity2__r.DR_Secondary_SKU__c != null && mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_Secondary_SKU__c) != null){
                        strSecondarySupportSKUProductId = mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_Secondary_SKU__c).Product__c;
                        oppRegProdMapSecondarySKU = mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_Secondary_SKU__c);
                    }
                    //End: Collect Primary, Secondary and thier SKUs

                    //get all features and options
                    list<SBQQ__ProductOption__c> lstProductOptions = [Select SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, Id, SBQQ__Feature__c, SBQQ__Type__c 
                                                                            From SBQQ__ProductOption__c
                                                                            Where SBQQ__ConfiguredSKU__c = :lstPrimarySecondaryProducts];
                    map<string, SBQQ__ProductOption__c> mapConfOptKeyProdOptions = new map<string, SBQQ__ProductOption__c>();
                    for (SBQQ__ProductOption__c prodOptions : lstProductOptions){
                        mapConfOptKeyProdOptions.put(prodOptions.SBQQ__ConfiguredSKU__c + '' + prodOptions.SBQQ__OptionalSKU__c, prodOptions);
                    }
                    //End: get all features and options


                    //get all the mandatory product information like Mandatory Installations
                    /*
                    The structure of  map<Id, list<SOQ_OppReg_Product_Map__c>> mapMandatoryProductOptions should be like this
                    DGX A100 40GB HW.Id > list [1. DGX A100 Mandatory Installation - Partner.Id. 2. DGX A100 Mandatory Installation - Self]
                    */
                    list<SOQ_OppReg_Product_Map__c> lstMandatoryProductOptions = [  SELECT Mandatory_Parent_Product__c, Product__c, Term__c
                                                        FROM SOQ_OppReg_Product_Map__c
                                                        WHERE  Mandatory_Parent_Product__c != null];

                    map<Id, list<SOQ_OppReg_Product_Map__c>> mapMandatoryProductOptions = new map<Id, list<SOQ_OppReg_Product_Map__c>>();
                    for (SOQ_OppReg_Product_Map__c mandatoryProductOption : lstMandatoryProductOptions){
                        list<SOQ_OppReg_Product_Map__c> lstOppRegProdMap;
                        if (mapMandatoryProductOptions.get(mandatoryProductOption.Mandatory_Parent_Product__c) == null){
                            lstOppRegProdMap = new list<SOQ_OppReg_Product_Map__c>();
                            mapMandatoryProductOptions.put(mandatoryProductOption.Mandatory_Parent_Product__c, lstOppRegProdMap);
                        }else{
                            lstOppRegProdMap = mapMandatoryProductOptions.get(mandatoryProductOption.Mandatory_Parent_Product__c);
                        }
                        lstOppRegProdMap.add(mandatoryProductOption);
                    }
                    //End: get all the mandatory product information like Mandatory Installations
                    


                     //Create Quote Lines
                     //==========================================================================================================================================================
                     List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
                     decimal lineNumber = 0;
                     decimal parentLineNumber = 0;
                     boolean QuoteLineHierarchyNeeded = false;

                    //Create Quote Line related to Primary Product
                    //--------------------------------------------------------------------------------------------------------------------------------------------------------
                    if (strPrimaryProductId != null){
                        //Create Quote Line for Primary Product
                        lineNumber += 1;
                        parentLineNumber = lineNumber;
                        primaryQuoteLine = AddQuoteLine(lineNumber, oppRegQuote.Id, oppRegProdMapPrimary.Product__c, oppRegQuote.SBQQ__Opportunity2__r.DR_SKU_Quantity__c, oppRegProdMapPrimary.Term__c, null);
                        quoteLines.add(primaryQuoteLine);

                        //Create Quote Line for Primary Support SKU
                        If (strPrimarySupportSKUProductId != null){
                            lineNumber += 1;
                            primarySKUQuoteLine = AddQuoteLine(lineNumber, oppRegQuote.Id, oppRegProdMapPrimarySKU.Product__c, oppRegQuote.SBQQ__Opportunity2__r.DR_SKU_Quantity__c, oppRegProdMapPrimarySKU.Term__c, parentLineNumber);
                            SBQQ__ProductOption__c option = mapConfOptKeyProdOptions.get(strPrimaryProductId + strPrimarySupportSKUProductId);
                            if (option != null){
                                primarySKUQuoteLine.SBQQ__ProductOption__c = option.Id;
                                primarySKUQuoteLine.SBQQ__DynamicOptionId__c = option.SBQQ__Feature__c;
                            }
                            quoteLines.add(primarySKUQuoteLine);
                            QuoteLineHierarchyNeeded = true;
                        }

                        //Create Quote Lines for Mandatory Installation like Products
                        if (mapMandatoryProductOptions.get(strPrimaryProductId) != null){
                            list<SOQ_OppReg_Product_Map__c> lstMandatoryProductOptionsForPrimary = mapMandatoryProductOptions.get(strPrimaryProductId);
                            SBQQ__QuoteLine__c mandatoryQL;
                            for (SOQ_OppReg_Product_Map__c oppregMandatryProdmap : lstMandatoryProductOptionsForPrimary){
                                lineNumber += 1;
                                mandatoryQL = AddQuoteLine(lineNumber, oppRegQuote.Id, oppregMandatryProdmap.Product__c, oppRegQuote.SBQQ__Opportunity2__r.DR_SKU_Quantity__c, oppregMandatryProdmap.Term__c, parentLineNumber);
                                SBQQ__ProductOption__c option = mapConfOptKeyProdOptions.get(strPrimaryProductId + '' + oppregMandatryProdmap.Product__c);
                                if (option != null){
                                    mandatoryQL.SBQQ__ProductOption__c = option.Id;
                                    mandatoryQL.SBQQ__DynamicOptionId__c = option.SBQQ__Feature__c;
                                }
                                quoteLines.add(mandatoryQL);
                                QuoteLineHierarchyNeeded = true;
                            }
                        }
                    }
                    //--------------------------------------------------------------------------------------------------------------------------------------------------------
                    //End: Create Quote Line related to Primary Product

                    //Create Quote Line related to Secondary Product
                    //--------------------------------------------------------------------------------------------------------------------------------------------------------
                    if (strSecondaryProductId != null){
                        //Create Quote Line for Secondary Product
                        lineNumber += 1;
                        parentLineNumber = lineNumber;
                        secondaryQuoteLine = AddQuoteLine(lineNumber, oppRegQuote.Id, oppRegProdMapSecondary.Product__c, oppRegQuote.SBQQ__Opportunity2__r.DR_Secondary_SKU_Quntity__c, oppRegProdMapSecondary.Term__c, null);
                        quoteLines.add(secondaryQuoteLine);

                        //Create Quote Line for Secondary Support SKU
                        If (strSecondarySupportSKUProductId != null){
                            lineNumber += 1;
                            secondarySKUQuoteLine = AddQuoteLine(lineNumber, oppRegQuote.Id, oppRegProdMapSecondarySKU.Product__c, oppRegQuote.SBQQ__Opportunity2__r.DR_Secondary_SKU_Quntity__c, oppRegProdMapSecondarySKU.Term__c, parentLineNumber);
                            SBQQ__ProductOption__c option = mapConfOptKeyProdOptions.get(strSecondaryProductId + strSecondarySupportSKUProductId);
                            if (option != null){
                                secondarySKUQuoteLine.SBQQ__ProductOption__c = option.Id;
                                secondarySKUQuoteLine.SBQQ__DynamicOptionId__c = option.SBQQ__Feature__c;
                            }
                            quoteLines.add(secondarySKUQuoteLine);
                            QuoteLineHierarchyNeeded = true;
                        }

                        //Create Quote Lines for Mandatory Installation like Products
                        if (mapMandatoryProductOptions.get(strSecondaryProductId) != null){
                            list<SOQ_OppReg_Product_Map__c> lstMandatoryProductOptionsForSecondary = mapMandatoryProductOptions.get(strSecondaryProductId);
                            SBQQ__QuoteLine__c mandatoryQL;
                            for (SOQ_OppReg_Product_Map__c oppregMandatryProdmap : lstMandatoryProductOptionsForSecondary){
                                lineNumber += 1;
                                mandatoryQL = AddQuoteLine(lineNumber, oppRegQuote.Id, oppregMandatryProdmap.Product__c, oppRegQuote.SBQQ__Opportunity2__r.DR_Secondary_SKU_Quntity__c, oppregMandatryProdmap.Term__c, parentLineNumber);
                                SBQQ__ProductOption__c option = mapConfOptKeyProdOptions.get(strSecondaryProductId + '' + oppregMandatryProdmap.Product__c);
                                if (option != null){
                                    mandatoryQL.SBQQ__ProductOption__c = option.Id;
                                    mandatoryQL.SBQQ__DynamicOptionId__c = option.SBQQ__Feature__c;
                                }
                                quoteLines.add(mandatoryQL);
                                QuoteLineHierarchyNeeded = true;
                            }
                        }
                    }
                    //--------------------------------------------------------------------------------------------------------------------------------------------------------
                    //End: Create Quote Line related to Secondary Product
                   
                    //Insert Quote Lines and track it in OppReg_Quote_Tracker__c
                     //--------------------------------------------------------------------------------------------------------------------------------------------------------
                    system.debug('***Before Insert | quoteLines = ' + quoteLines);
                    if (quoteLines.size() > 0){
                        insert quoteLines;
                        system.debug('***After Insert | quoteLines = ' + quoteLines);
                        
                        //Insert Quote Id to OppReg_Quote_Tracker__c so the quote lines can be made as hierarchical
                        system.debug('***BQuoteLineHierarchyNeeded = ' + QuoteLineHierarchyNeeded);
                        OppReg_Quote_Tracker__c oORQTracker = new OppReg_Quote_Tracker__c();
                        oORQTracker.QuoteId__c = oppRegQuote.Id;
                        oORQTracker.QuoteLineCreated__c = true;
                        if (QuoteLineHierarchyNeeded){
                            oORQTracker.QuoteLineHierarchyNeeded__c = true;
                        }
                        insert oORQTracker;
                        system.debug('***After Insert oORQTracker = ' + oORQTracker);
                    }
                     //--------------------------------------------------------------------------------------------------------------------------------------------------------
                    //End: Insert Quote Lines and track it in OppReg_Quote_Tracker__c

                    //End: Create Quote Lines
                    //==========================================================================================================================================================
                }
        }
        system.debug('---------Exiting Batch Job SOQ_CreateQuoteLine_BAT execute method-------------------');
    }

    public void finish(Database.BatchableContext BC) {
        system.debug('---------Entering Batch Job finish method-------------------');
        system.debug('---------Chains SOQ_CreateQuoteLineHierarchy_BAT to create quote lines-------------------');
        if(!Test.isRunningTest()){
            Id batchJobId = Database.executeBatch(new SOQ_CreateQuoteLineHierarchy_BAT(), 1);
        }
        system.debug('---------Exiting Batch Job finish method-------------------');
    }

     //Add quote lines for Primary and Secondary Products to list
    private SBQQ__QuoteLine__c AddQuoteLine(decimal lineNumber, Id quoteId, Id productId, decimal quantity, decimal term, decimal parentLineNumber) {
        system.debug('---------Entering AddQuoteLine method-------------------'); 
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Number__c = lineNumber;
        ql.SBQQ__Quote__c = quoteId;
        ql.SBQQ__Product__c = productId;
        ql.SBQQ__Quantity__c = quantity;
        ql.Sales_Type__c = 'Initial';
        //ql.SBQQ__SubscriptionTerm__c = term;
        //ql.SAP_Term__c = term;
        //ql.Term__c = (term == 0) ? Null : string.valueof(term); 
        ql.Product_Term__c = (term == 0) ? Null : string.valueof(term); 
        ql.Parent_Line_Number__c = parentLineNumber;
        system.debug('---------Exiting AddQuoteLine method-------------------'); 
        return ql;
    }
    //End: Add quote lines for Primary and Secondary Products
}