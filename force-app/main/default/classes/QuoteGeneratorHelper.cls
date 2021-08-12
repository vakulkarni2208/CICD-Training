Global class QuoteGeneratorHelper {
    
    // assumptions: account already created
    // flow:
    // 1) create opportunity
    // 2) create quote record and associate with opportunity
    // 3) create quote lines and associated with quote record
    // 4) check "contracted" on opportunity (creates contract, assets, subscriptions)
    // 5) locate contract and check "renewal forecast" (creates renewal opportunity)
    // 
    // concerns: bulkify ... large number of order conversions will trigger other workflows ... limits? Step 4) may have to be outside of this code

    public static Set<String> getFieldValues(SObject[] objects, SObjectField field) {
  
        Set<String> result = new Set<String>();
        if (null != objects) {
            final String fieldName = field.getDescribe().getName();
            for (SObject o : objects) {
                result.add(String.valueOf(o.get(fieldName)));
            }
            result.remove(null);
        }

        return result;
    }
    
    // creates one quote for each end customer in orders
    // called on SAP_Order__c after insert trigger
    // assumption is that all order records for a given end customer are associated with a single opportunity
     
    public static Map<string, Id> productMap;
    public static List<Account> orderAccounts;
    public static Map<string, Id> PAK_ID_AccountMap;
    public static Map<string, Id> PAK_ID_VARMap;
    public static Map<string, Id> PAK_ID_SoldToMap;
    public static List<Opportunity> createdOpportunities;
    public static Map<Id, SBQQ__Quote__c> oppQuoteMap;
    public static Map<Id, List<SBQQ__ProductOption__c>> pOptions;
    public static List<SAP_Order__c> updatedOrders;
    
    global static void createQuotes(List<SAP_Order__c> orders) {

        // get all subscription products related to SAP orders
        productMap = GetQuoteProducts(orders);
        
        // each PAK ID is a "header record" and is associated with an account
        // the PAK ID / account map will be used to create the opportunities and assign the account id
        CreatePAK_ID_AccountMap(orders);
        
        // update co-termination fields (Set Co-Termination to "Never" prior to inserting quotes)
        DropCoTerminationTermsOnAccount(orderAccounts);
        
        // create opportunities and set the name to the PAK ID
        createdOpportunities = CreateOpportunitiesFromOrders();
        
        // update orders with link to associated opportunity (make available for future user reference)
        updatedOrders = LinkOrdersWithOpportunity(orders);
        
        // create quote from opportunity
        oppQuoteMap = CreateQuotesFromOpportunities(updatedOrders);
        
        // create a map that provides a list of options for each parent bundle product
        pOptions = CreateProductOptionMap(productMap.values());

        // create quote lines directly related to the products in the orders
        List<Id> uniqueQuotes = CreateTopLevelQuoteLines(updatedOrders);
        
        // create the child options associated with the parent bundles
        CreateOptionalQuoteLines(uniqueQuotes);  
        
        // update co-termination fields (Set Co-Termination to "Always" now that quotes have been created)
        SetCoTerminationTermsOnAccount(orderAccounts);
        
        // trigger CPQ to create contracts and subscriptions
        // this triggers an asynchronous process
        // nothing else synchronous is relevant after this point
        SetOpportunitiesToClosedWon(createdOpportunities);
    }
    
    public static Map<string, Id> GetQuoteProducts(List<SAP_Order__c> orders) {
        
        Map<string, Id> pMap = new Map<string, Id>();
        Set<String> uniqueProductCodes = getFieldValues(orders, SAP_Order__c.Product_SKU__c);
        
        for (Product2 prod : [SELECT ProductCode, Id FROM Product2 WHERE ProductCode IN :uniqueProductCodes]) {
            if (!pMap.containsKey(prod.ProductCode)) {
                pMap.put(prod.ProductCode, prod.Id);
            }
        }    
        
        system.debug(pMap.size());
            
        return pMap;
    }
    
    public static void CreatePAK_ID_AccountMap(List<SAP_Order__c> orders) {
        
        // compile list of SAP End Customer Account Numbers in this batch of orders
        Set<String> uniqueAccountNumbers = getFieldValues(orders, SAP_Order__c.SAP_Account__c);
        uniqueAccountNumbers.addAll(getFieldValues(orders, SAP_Order__c.VAR__c));
        uniqueAccountNumbers.addAll(getFieldValues(orders, SAP_Order__c.Sold_To_Partner__c));
        
        // retrieve account Id for each SAP Account Number
        orderAccounts = [SELECT Id, SAP_Customer_Number__c, SBQQ__ContractCoTermination__c, SBQQ__CoTerminationEvent__c 
                               FROM Account 
                               WHERE SAP_Customer_Number__c IN :uniqueAccountNumbers];
        
        // convert into a map
        Map<string, Id> acctMap = new Map<string, Id>();
        for (Account acct: orderAccounts) {
            acctMap.put(acct.SAP_Customer_Number__c, acct.Id);
        }

        PAK_ID_AccountMap = new Map<string, Id>();
        PAK_ID_VARMap = new Map<string, Id>();
        PAK_ID_SoldToMap = new Map<string, Id>();

        // create all three account maps
        for (SAP_Order__c order: orders) {
            if (!PAK_ID_AccountMap.containsKey(order.SAP_PAK_ID__c)) {
                PAK_ID_AccountMap.put(order.SAP_PAK_ID__c, acctMap.get(order.SAP_Account__c));
            }
            if (!PAK_ID_VARMap.containsKey(order.SAP_PAK_ID__c) && order.VAR__c != null) {
                PAK_ID_VARMap.put(order.SAP_PAK_ID__c, acctMap.get(order.VAR__c));
            }
            if (!PAK_ID_SoldToMap.containsKey(order.SAP_PAK_ID__c) && order.Sold_To_Partner__c != null) {
                PAK_ID_SoldToMap.put(order.SAP_PAK_ID__c, acctMap.get(order.Sold_To_Partner__c));
            }
        }
    }

    public static List<Opportunity> CreateOpportunitiesFromOrders() {
        
        // retrieve price book Id
        Id pbId = [SELECT Name, Description FROM PriceBook2 Where Name = :Label.CPQ_Price_Book_Name].Id;
        Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Label.CPQ_Opportunity_Record_Type).getRecordTypeId();
        
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity opp;
        
        for (string key : PAK_ID_AccountMap.keySet()) {
            opp = new Opportunity();
            opp.Name = key; // PAK ID
            opp.CloseDate = Date.today();
            opp.StageName = Label.CPQ_Opportunity_Stage;
            opp.RecordTypeId = recTypeId;
            opp.AccountId = PAK_ID_AccountMap.get(key);
            opp.NPN_Solution_Provider_VAR__c = PAK_ID_VARMap.containsKey(key) ? PAK_ID_VARMap.get(key) : null;
            opp.Sold_To__c = PAK_ID_SoldToMap.containsKey(key) ? PAK_ID_SoldToMap.get(key) : null;
            opp.Pricebook2Id = pbId;
            opps.add(opp);
        }
        
        insert opps;
        
        return opps;
    }
    
    public static List<SAP_Order__c> LinkOrdersWithOpportunity(List<SAP_Order__c> orders) {
            
        // compile list of unique PAK IDs in this batch of orders
        Set<String> uniquePAKIDs = getFieldValues(orders, SAP_Order__c.SAP_PAK_ID__c); 
        
        // retrieve opportunity Id for each SAP PAK ID
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE Name IN :uniquePAKIDs];
        
        // convert into a map
        Map<string, Id> oppMap = new Map<string, Id>();
        for (Opportunity opp: opps) {
            oppMap.put(opp.Name, opp.Id);
        }
        
        // update orders with opportunity id lookup
        for (SAP_Order__c order: orders) {
            order.Opportunity__c = oppMap.get(order.SAP_PAK_ID__c);
        }
        
        update orders;
        
        // from this point forward the updated orders collection is required
        return orders;
    }
    
    public static Map<Id, SBQQ__Quote__c> CreateQuotesFromOpportunities(List<SAP_Order__c> orders) {
        
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote;
        Map<Id, SBQQ__Quote__c> oqMap = new Map<Id, SBQQ__Quote__c>();
        Map<Id, SBQQ__Quote__c> oppDataMap = GetUniqueOpportunityData(orders);
        
        for (Id key : oppDataMap.keySet()) {
            quote = new SBQQ__Quote__c();
            quote.SBQQ__Status__c = 'Draft';
            quote.SBQQ__Primary__c = True;
            quote.SBQQ__Type__c = 'Quote';
            quote.SBQQ__Opportunity2__c = key;
            quote.SBQQ__StartDate__c = oppDataMap.get(key).SBQQ__StartDate__c;
            quote.SBQQ__SubscriptionTerm__c = oppDataMap.get(key).SBQQ__SubscriptionTerm__c;
            quotes.add(quote);
        }
        
        insert quotes;
        
        // convert these quotes into a map based upon opportunity -> this is used in the next step
        for (SBQQ__Quote__c qt :quotes) {
            
            oqMap.put(qt.SBQQ__Opportunity2__c, qt);
            
        }
        
        return oqMap;

    }
    
    public static Map<Id, SBQQ__Quote__c>  GetUniqueOpportunityData(List<SAP_Order__c> orders) {
        
        // one quote is created for each opportunity
        // the start date, subscription term on the quote is the earliest start date, greatest subscription term of all items on the order
        Map<Id, SBQQ__Quote__c> oppData = new Map<Id, SBQQ__Quote__c>();
        SBQQ__Quote__c qData;
        boolean putData = false;
        
        for (SAP_Order__c order :orders) {
            
            putData = false;
            if (!oppData.containsKey(order.Opportunity__c)) {
                
                qData = new SBQQ__Quote__c();
                qData.SBQQ__StartDate__c = order.Start_Date__c;
                qData.SBQQ__SubscriptionTerm__c = CalculateSubscriptionTerm(order.Start_Date__c, order.End_Date__c, order.Subscription_Term__c);
                oppData.put(order.Opportunity__c, qData);
                
            }
            
            else {
                
                qData = (SBQQ__Quote__c)oppData.get(order.Opportunity__c);
                
                if (qData.SBQQ__StartDate__c > order.Start_Date__c) {
                    
                    qData.SBQQ__StartDate__c = order.Start_Date__c;
                    putData = true;

                }
                
                 if (qData.SBQQ__SubscriptionTerm__c < CalculateSubscriptionTerm(order.Start_Date__c, order.End_Date__c, order.Subscription_Term__c)) {
                    
                    qData.SBQQ__SubscriptionTerm__c = CalculateSubscriptionTerm(order.Start_Date__c, order.End_Date__c, order.Subscription_Term__c);
                    putData = true;

                }
                
            }
            
            if (putData) {
                
                oppData.put(order.Opportunity__c, qData);
                
            }
            
        }
        
        return oppData;
        
    }
    
    public static Map<Id, List<SBQQ__ProductOption__c>> CreateProductOptionMap(List<string> productIds) {
        
        List<SBQQ__ProductOption__c> options = [SELECT Id, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, SBQQ__Type__c, SBQQ__Selected__c, SBQQ__Required__c, SBQQ__Number__c
                                                 FROM SBQQ__ProductOption__c
                                                 WHERE SBQQ__ConfiguredSKU__c IN :productIds
                                                 ORDER BY SBQQ__ConfiguredSKU__c, SBQQ__Number__c];
        
        // the goal is to create a map with each product and its associated options
        // this will be used to add the options for each bundle product as quote lines
        
        Map<Id, List<SBQQ__ProductOption__c>> optionMap = new Map<Id, List<SBQQ__ProductOption__c>>();
        List<SBQQ__ProductOption__c> prodOptions;
        Id productId = null;
        for (SBQQ__ProductOption__c option :options) {
            
            if (productId <> option.SBQQ__ConfiguredSKU__c) {
                
                if (productId <> null) {
                    
                    // add key to map
                    optionMap.put(productId, prodOptions);
                    
                }
                
                // create new list of options
                prodOptions = new List<SBQQ__ProductOption__c>();
                productId = option.SBQQ__ConfiguredSKU__c;
                
            }
            
            // add option to current list
            prodOptions.add(option);
            
        }
        
        // add final key to map
        if (productId <> null) {
            
            optionMap.put(productId, prodOptions);
            
        }
                                       
        return optionMap;
    }
    
    public static SBQQ__QuoteLine__c AddQuoteLine(Id quoteId, Id productId, decimal quantity, boolean isBundle, decimal lineNumber, decimal term, 
                                                  date startDate, date endDate, integer optionLevel, string optionType, Id pOption, Id requiredBy, 
                                                  string renewID, string renewPAK, string serialNo, string entId, Id sapOrder, decimal renewalTerm) {
        
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quote__c = quoteId;
        ql.SBQQ__Product__c = productId;
        ql.SBQQ__Quantity__c = quantity;
        ql.SBQQ__Bundle__c = isBundle;
        ql.SBQQ__Number__c = lineNumber;
        ql.SBQQ__SubscriptionTerm__c = term;
        ql.SBQQ__StartDate__c = startDate;
        ql.SBQQ__EndDate__c = endDate;
        ql.SBQQ__OptionLevel__c = optionLevel;
        ql.SBQQ__OptionType__c = optionType;
        ql.SBQQ__ProductOption__c = pOption;
        ql.SBQQ__RequiredBy__c = requiredBy;
        ql.Renewed_Entitlement_ID__c = renewID;
        ql.Renewed_PAK_ID__c = renewPAK;
        ql.Hardware_Serial_Number__c = serialNo;
        ql.Entitlement_ID__c = entId;  
        ql.SAP_Order__c = sapOrder;
        // ql.Renewal_Term__c = renewalTerm;    not currently needed, leaving in for testing purposes                                         
            
        return ql;
    }
    
    public static List<Id> CreateTopLevelQuoteLines(List<SAP_Order__c> orders) {
        
        // create quote lines for every order item
        // this assumes that only parent bundles and individual (non-bundle) items are included in the SAP order
        // once these quote lines are created, the options are added in a separate method
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        List<Id> quoteIds = new List<Id>();
        SBQQ__QuoteLine__c ql;
        Id prodId;
        Id quoteId;
        boolean isParent;
        integer lineNum;
        
        // links: order.Opportunity__c = quote.SBQQ__Opportunity2__c
       
        for (SAP_Order__c order :orders) {
            
            prodId = productMap.get(order.Product_SKU__c);
            if (quoteId == null || quoteId != ((SBQQ__Quote__c)oppQuoteMap.get(order.Opportunity__c)).Id) {
                
                LineNum = 10;
                quoteId = ((SBQQ__Quote__c)oppQuoteMap.get(order.Opportunity__c)).Id;
                quoteIds.add(quoteId);
                
            } else
            {
                
                lineNum = lineNum + 10;
                
            }
            
            ql = AddQuoteLine(
                    quoteId,
                    prodId,
                    order.Quantity__c,
                    pOptions.containsKey(prodId),
                    lineNum,
                    CalculateSubscriptionTerm(order.Start_Date__c, order.End_Date__c, order.Subscription_Term__c),
                    order.Start_Date__c,
                    order.End_Date__c,
                    null, // option level
                    null, // option type
                    null, // product option id
                    null, // required by
                    String.isEmpty(order.Renewed_Entitlement_ID__c) ? order.Entitlement_ID__c : order.Renewed_Entitlement_ID__c,
                    String.isEmpty(order.Renewed_PAK_ID__c) ? order.SAP_PAK_ID__c : order.Renewed_PAK_ID__c,
                    order.Hardware_Serial_Number__c,
            		order.Entitlement_ID__c,
                	order.Id,
                    CalculateSubscriptionTerm(order.Start_Date__c, order.End_Date__c, order.Subscription_Term__c));

            quoteLines.add(ql);
        
        }
        
        insert quoteLines;
                                                    
        return quoteIds;
        
    }
    
    public static void CreateOptionalQuoteLines(List<Id> uniqueQuotes) {
        
        // only return
        List<SBQQ__QuoteLine__c> parentLines = [SELECT Id, SBQQ__Quote__c, SBQQ__Product__c, SBQQ__Quantity__c, SBQQ__Number__c,
                                               SBQQ__SubscriptionTerm__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Renewed_Entitlement_ID__c, 
                                               Renewed_PAK_ID__c, Hardware_Serial_Number__c, Entitlement_ID__c, SAP_Order__c, Renewal_Term__c
                                               FROM SBQQ__QuoteLine__c
                                               WHERE SBQQ__Bundle__c = true AND SBQQ__Quote__c IN :uniqueQuotes
                                               ORDER BY SBQQ__Quote__c, SBQQ__Number__c];
        
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql;
        decimal lineNum;
      
        // for each parent quote line ...
        for (SBQQ__QuoteLine__c pl :parentLines) {
            
            // create an addition line for each option associated with this parent bundle
            lineNum = pl.SBQQ__Number__c;
            for (SBQQ__ProductOption__c option : pOptions.get(pl.SBQQ__Product__c)) {
                
                lineNum++;
                ql = AddQuoteLine(
                    pl.SBQQ__Quote__c,
                    option.SBQQ__OptionalSKU__c,
                    pl.SBQQ__Quantity__c,
                    false, // isBundle
                    lineNum,
                    pl.SBQQ__SubscriptionTerm__c,
                    pl.SBQQ__StartDate__c,
                    pl.SBQQ__EndDate__c,
                    1, // option level
                    option.SBQQ__Type__c,
                    option.Id, // product option id
                    pl.Id,
                    pl.Renewed_Entitlement_ID__c,
                    pl.Renewed_PAK_ID__c,
                    pl.Hardware_Serial_Number__c,
                	pl.Entitlement_ID__c,
                	pl.SAP_Order__c,
                    pl.Renewal_Term__c);                

                quoteLines.add(ql);               
                
            }

        }

        insert quoteLines;
        
    }
    
    public static decimal CalculateSubscriptionTerm(Date startDate, Date endDate, decimal term) {
        
        if (startDate == null || term == null) {
            
            return 0;
            
        }
        
        Date termEndDate = startDate.addMonths(term.intValue());
      
        return startDate.daysBetween(termEndDate);
        
    }
    
    public static void DropCoTerminationTermsOnAccount(List<Account> accts) {
        
        // need to disable co-termination to prevent CPQ from running additional queries during batch loading
        for (Account acct: accts) {
            
            acct.SBQQ__ContractCoTermination__c = 'Never';
            acct.SBQQ__CoTerminationEvent__c = '';
            
        }
        
        update(accts);
        
    }

    public static void SetCoTerminationTermsOnAccount(List<Account> accts) {
        
        for (Account acct: accts) {
            
            acct.SBQQ__ContractCoTermination__c = 'Always';
            acct.SBQQ__CoTerminationEvent__c = 'Add-On';
            
        }
        
        update(accts);
        
    }

    public static void SetOpportunitiesToClosedWon(List<Opportunity> opps) {
        
        for (Opportunity opp: opps) {
            
            opp.StageName = 'Closed Won';
            
        }
        
        update(opps);
        
    }

}