/*
	Test class for  SOQ_CreateQuote_BAT_SCH
	2021.03.16 - pjena - Batch class to Create Quote/Quote Lines from Opp Reg Opportunities

 */
@isTest(SeeAllData=true)
private class  SOQ_CreateQuote_BAT_SCH_Test {
    
    static DR_Quote_Test_Helper__mdt OppRegDataHelper{get;set;}
    
    static {
        /*
        OppRegDataHelper =  [SELECT Id, Type__c, Deal_Type__c, Program_Type__c, PriceBookId__c, RecordTypeId__c, Stage__c, OppRegLeadId__c,
                            End_Customer_Account__c, End_Customer_Contact__c, End_Customer_Contact_Role__c,
                            Partner_VAR_Account__c,Partner_VAR_Contact__c,
                            Primary_HW_Product__c,Primary_Support_SKU__c,Secondary_HW_Product__c,Secondary_Support_SKU__c
                        FROM DR_Quote_Test_Helper__mdt 
                        WHERE DeveloperName = 'OppRegOpportunity' LIMIT 1];
        */
        OppRegDataHelper = SOQ_OppReg_Test_Factory.OppRegMDT;
        
    }
    
    static testMethod void createQuoteTest(){
        //Opportunity oppReg = createOpportunity('OppRegForQuoteCreation');
        Opportunity oppReg = SOQ_OppReg_Test_Factory.createOpportunity('OppRegForQuoteCreation');
        system.debug('***oppReg.Id > ' + oppReg.Id);
        list<Opportunity> lstOppReg = new list<Opportunity>();
		lstOppReg.add(oppReg);

        Test.startTest();
	      	Database.BatchableContext     bc;
            SOQ_CreateQuote_BAT_SCH bClass = new SOQ_CreateQuote_BAT_SCH();
	  		Database.QueryLocator ql = bClass.start(bc);
	  		bClass.execute(bc, lstOppReg);
	  		bClass.finish(bc);
	   	Test.stopTest();
    }

    static testMethod void createQuoteLineTest(){
        //Opportunity oppReg = createOpportunity('OppRegForQuoteLineCreation');
        Opportunity oppReg = SOQ_OppReg_Test_Factory.createOpportunity('OppRegForQuoteLineCreation');
        SBQQ__Quote__c quote = createQuote(oppReg);
        list<SBQQ__Quote__c> lstQuotes = new list<SBQQ__Quote__c>();
        lstQuotes = [Select id,  Programmatic_Disc_Type__c,  SBQQ__Opportunity2__c,
                        SBQQ__Opportunity2__r.DR_Product__c, SBQQ__Opportunity2__r.DR_SKU__c, SBQQ__Opportunity2__r.DR_SKU_Quantity__c, 
                        SBQQ__Opportunity2__r.DR_Secondary_Product__c, SBQQ__Opportunity2__r.DR_Secondary_SKU__c, SBQQ__Opportunity2__r.DR_Secondary_SKU_Quntity__c
                    From SBQQ__Quote__c
                    Where Id = :quote.Id];
       
        Test.startTest();
	      	Database.BatchableContext     bc;
            SOQ_CreateQuoteLine_BAT bClass = new SOQ_CreateQuoteLine_BAT();
	  		Database.QueryLocator ql = bClass.start(bc);
	  		bClass.execute(bc, lstQuotes);
	  		bClass.finish(bc);
	   	Test.stopTest();
    }


    static testMethod void updateQuoteLineHierarchyTest(){
       
        map<string, SOQ_OppReg_Product_Map__c> mapSOQOppRegProducts = new map<string, SOQ_OppReg_Product_Map__c>();
        list<string> oppRegProdNames = new list<string>();
        list<SOQ_OppReg_Product_Map__c> lstSOQOppRegProducts = new list<SOQ_OppReg_Product_Map__c>();
    
        map<string, SBQQ__ProductOption__c> mapConfOptKeyProdOptions = new map<string, SBQQ__ProductOption__c>();
        list<Id> lstPrimarySecondaryProducts = new list<id>();
    
        OppReg_Quote_Tracker__c oORQTracker = new OppReg_Quote_Tracker__c();
        list<OppReg_Quote_Tracker__c> lstORQT = new list<OppReg_Quote_Tracker__c>();

        //Collect Primary, Secondary and thier SKUs
        string strPrimaryProductId, strPrimarySupportSKUProductId, strSecondaryProductId, strSecondarySupportSKUProductId;
        SOQ_OppReg_Product_Map__c oppRegProdMapPrimary, oppRegProdMapPrimarySKU, oppRegProdMapSecondary, oppRegProdMapSecondarySKU;
        SBQQ__QuoteLine__c primaryQuoteLine, primarySKUQuoteLine, secondaryQuoteLine, secondarySKUQuoteLine;
        
        oppRegProdNames = new list<string>();
        lstSOQOppRegProducts = new list<SOQ_OppReg_Product_Map__c>();
        mapSOQOppRegProducts = new map<string, SOQ_OppReg_Product_Map__c>();

        oppRegProdNames.add(OppRegDataHelper.Primary_HW_Product__c);
        oppRegProdNames.add(OppRegDataHelper.Primary_Support_SKU__c);
        oppRegProdNames.add(OppRegDataHelper.Secondary_HW_Product__c);
        oppRegProdNames.add(OppRegDataHelper.Secondary_Support_SKU__c);
                    
        //get all the product information associated with the opp reg
        lstPrimarySecondaryProducts = new list<Id>();
        lstSOQOppRegProducts = [  SELECT OppReg_Product_Name__c,Term__c, Product__c, Product__r.ProductCode 
                                    FROM SOQ_OppReg_Product_Map__c
                                    WHERE OppReg_Product_Name__c in :oppRegProdNames];
        for (SOQ_OppReg_Product_Map__c SOQOppRegMap : lstSOQOppRegProducts){
            mapSOQOppRegProducts.put(SOQOppRegMap.OppReg_Product_Name__c, SOQOppRegMap);
            lstPrimarySecondaryProducts.add(SOQOppRegMap.Product__c);
        }

        //get all features and options
        //lstProductOptions = new list<SBQQ__ProductOption__c>();
        list<SBQQ__ProductOption__c> lstProductOptions = [Select SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, Id, SBQQ__Feature__c, SBQQ__Type__c 
                                                            From SBQQ__ProductOption__c
                                                            Where SBQQ__ConfiguredSKU__c = :lstPrimarySecondaryProducts];
        mapConfOptKeyProdOptions = new map<string, SBQQ__ProductOption__c>();
        for (SBQQ__ProductOption__c prodOptions : lstProductOptions){
            mapConfOptKeyProdOptions.put(prodOptions.SBQQ__ConfiguredSKU__c + '' + prodOptions.SBQQ__OptionalSKU__c, prodOptions);
        }
        //End: get all features and options

        //Opportunity oppReg = createOpportunity('OppRegForQuoteLineHierarchy');
        Opportunity oppReg = SOQ_OppReg_Test_Factory.createOpportunity('OppRegForQuoteLineHierarchy');
        SBQQ__Quote__c quote = createQuote(oppReg);
        list<SBQQ__Quote__c> lstQuotes = new list<SBQQ__Quote__c>();
        lstQuotes = [Select id,  Programmatic_Disc_Type__c,  SBQQ__Opportunity2__c,
                        SBQQ__Opportunity2__r.DR_Product__c, SBQQ__Opportunity2__r.DR_SKU__c, SBQQ__Opportunity2__r.DR_SKU_Quantity__c, 
                        SBQQ__Opportunity2__r.DR_Secondary_Product__c, SBQQ__Opportunity2__r.DR_Secondary_SKU__c, SBQQ__Opportunity2__r.DR_Secondary_SKU_Quntity__c
                    From SBQQ__Quote__c
                    Where Id = :quote.Id];
        SBQQ__Quote__c oppRegQuote = lstQuotes[0];

                    
        if (oppRegQuote.SBQQ__Opportunity2__r.DR_Product__c != null && mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_Product__c) != null){
            strPrimaryProductId = mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_Product__c).Product__c;
            oppRegProdMapPrimary = mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_Product__c);
        }
        if (oppRegQuote.SBQQ__Opportunity2__r.DR_SKU__c != null && mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_SKU__c) != null){
            strPrimarySupportSKUProductId = mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_SKU__c).Product__c;
            oppRegProdMapPrimarySKU = mapSOQOppRegProducts.get(oppRegQuote.SBQQ__Opportunity2__r.DR_SKU__c);
        }

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

        }
        
        //Insert Quote Lines and track it in OppReg_Quote_Tracker__c
        //--------------------------------------------------------------------------------------------------------------------------------------------------------
        system.debug('***Before Insert | quoteLines = ' + quoteLines);
        Test.startTest();
            if (quoteLines.size() > 0){
                insert quoteLines;
                system.debug('***After Insert | quoteLines = ' + quoteLines);
                            
                //Insert Quote Id to OppReg_Quote_Tracker__c so the quote lines can be made as hierarchical
                system.debug('***BQuoteLineHierarchyNeeded = ' + QuoteLineHierarchyNeeded);
                oORQTracker = new OppReg_Quote_Tracker__c();
                oORQTracker.QuoteId__c = oppRegQuote.Id;
                oORQTracker.QuoteLineCreated__c = true;
                if (QuoteLineHierarchyNeeded){
                    oORQTracker.QuoteLineHierarchyNeeded__c = true;
                }
                insert oORQTracker;
                system.debug('***After Insert oORQTracker = ' + oORQTracker);
            }

            lstORQT = new list<OppReg_Quote_Tracker__c>();
            lstORQT = [Select QuoteId__c,QuoteLineHierarchyNeeded__c,QuoteLineHierarchyCompleted__c 
                        From OppReg_Quote_Tracker__c                                      
                        Where Id = :oORQTracker.Id];
	      	Database.BatchableContext     bc;
            SOQ_CreateQuoteLineHierarchy_BAT bClass = new SOQ_CreateQuoteLineHierarchy_BAT();
	  		Database.QueryLocator ql = bClass.start(bc);
	  		bClass.execute(bc, lstORQT);
	  		bClass.finish(bc);
	   	Test.stopTest();
    }

    //Add quote lines for Primary and Secondary Products to list
    static SBQQ__QuoteLine__c AddQuoteLine(decimal lineNumber, Id quoteId, Id productId, decimal quantity, decimal term, decimal parentLineNumber) {
        system.debug('---------Entering AddQuoteLine method-------------------'); 
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Number__c = lineNumber;
        ql.SBQQ__Quote__c = quoteId;
        ql.SBQQ__Product__c = productId;
        ql.SBQQ__Quantity__c = quantity;
        ql.Sales_Type__c = 'Initial';
        ql.Product_Term__c = (term == 0) ? Null : string.valueof(term); 
        ql.Parent_Line_Number__c = parentLineNumber;
        system.debug('---------Exiting AddQuoteLine method-------------------'); 
        return ql;
    }
    //End: Add quote lines for Primary and Secondary Products

    /*
    static Opportunity createOpportunity(string oppName){
            Opportunity oppReg = new Opportunity();
            oppReg.name = oppName;
            oppReg.Type =  OppRegDataHelper.Type__c; //'Deal Registration';
            oppReg.DR_Deal_Type__c = OppRegDataHelper.Deal_Type__c; //DGX
            oppReg.DR_Lead_Type__c = OppRegDataHelper.Type__c;
            //oppReg.DR_Program_Name__c = '';
            oppReg.Program_Type__c = OppRegDataHelper.Program_Type__c; //'DGX Opp Reg';
            //opp.Industry__c
            oppReg.Primary_Customer_Use_Case__c = 'test';
            oppReg.Pricebook2Id = OppRegDataHelper.PriceBookId__c;
            oppReg.RecordTypeId = OppRegDataHelper.RecordTypeId__c;
            oppReg.StageName = 'Prospecting';
            oppReg.Probability = 10.0;
            oppReg.DR_Is_Approved__c = true;
            oppReg.DR_Approved_Date__c = Datetime.now();
            oppReg.CloseDate = System.Today();
            oppReg.Lead_Id_For_Opportunity__c = OppRegDataHelper.OppRegLeadId__c;
    
            //PEC
            oppReg.AccountId = OppRegDataHelper.End_Customer_Account__c;
            oppReg.DR_Customer_Contact__c = OppRegDataHelper.End_Customer_Contact__c;
            oppReg.Primary_Contact_Role__c = OppRegDataHelper.End_Customer_Contact_Role__c;
    
            //SP/VAR
            oppReg.DR_Partner_Sales_Rep_Company__c = OppRegDataHelper.Partner_VAR_Account__c;
            oppReg.DR_Partner_Sales_Rep_Name__c = OppRegDataHelper.Partner_VAR_Contact__c;
            oppReg.Do_you_have_a_NPN_Solution_Provider_VAR__c = 'Yes';
            oppReg.NPN_Solution_Provider_VAR__c = OppRegDataHelper.Partner_VAR_Account__c;
            //opp.Primary_NPN_OEM_ODM_Disti__c = OppRegDataHelper.;
            
            //Product Info
            oppReg.DR_Product__c = OppRegDataHelper.Primary_HW_Product__c;
            oppReg.DR_SKU__c = OppRegDataHelper.Primary_Support_SKU__c;
            oppReg.DR_SKU_Quantity__c = 1;
            oppReg.DR_Secondary_Product__c = OppRegDataHelper.Secondary_HW_Product__c;
            oppReg.DR_Secondary_SKU__c = OppRegDataHelper.Secondary_Support_SKU__c;
            oppReg.DR_Secondary_SKU_Quntity__c = 1;
    
            insert oppReg;

            return oppReg;
    }
    */

    static SBQQ__Quote__c createQuote(Opportunity oppReg){
        string QuoteRTID  = SOQ_QuoteCreation_Settings__c.getOrgDefaults().RecordTypeId__c;
        string initialQuoteStatus  = SOQ_QuoteCreation_Settings__c.getOrgDefaults().Initial_Status__c;
        string OppRegProgDiscType = SOQ_QuoteCreation_Settings__c.getOrgDefaults().OppReg_Prog_Disc_Type__c;
        string QuoteProcessId = SOQ_QuoteCreation_Settings__c.getOrgDefaults().Quote_Process_Id__c;
        string QuoteType = SOQ_QuoteCreation_Settings__c.getOrgDefaults().Quote_Type_c__c;
        string CustomerClassification = SOQ_QuoteCreation_Settings__c.getOrgDefaults().Customer_Classification__c; 

        SBQQ__Quote__c quote = new SBQQ__Quote__c();

        //quote.SBQQ__Status__c = 'Draft';
        quote.SBQQ__Primary__c = True;
        quote.SBQQ__Type__c = QuoteType; //"Quote"
        quote.SBQQ__Opportunity2__c = oppReg.Id;

        quote.RecordTypeId = QuoteRTID;
        quote.SBQQ__QuoteProcessId__c = QuoteProcessId;
        quote.SBQQ__Status__c = initialQuoteStatus;
        quote.Programmatic_Disc_Type__c = OppRegProgDiscType;
        quote.SBQQ__Account__c = oppReg.AccountId; //End Customer Account
        quote.SBQQ__SalesRep__c = oppReg.OwnerId;
        quote.End_Customer_Contact__c = oppReg.DR_Customer_Contact__c;

        //quote.Sold_To__c = 'Should be the Id of Sold to; but in Opportunity it is a picklist; so how to map ask team';
        quote.Reseller_Account__c = oppReg.NPN_Solution_Provider_VAR__c;
        quote.Reseller_Contact__c = oppReg.DR_Partner_Sales_Rep_Name__c;
        //quote.SBQQ__Partner__c = oppReg.DR_Partner_Sales_Rep_Company__c;

        insert quote;

        return quote;
    }
}