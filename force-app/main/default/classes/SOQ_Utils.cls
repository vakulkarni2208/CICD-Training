public class SOQ_Utils {
	public static void cloneQuoteLines(string OriginalOpportunityId, string clonedOpprotunityId) {//}
        System.debug('OriginalOpportunityId := ' + OriginalOpportunityId);
        System.debug('clonedOpprotunityId := ' + clonedOpprotunityId);
        Opportunity newOpp = [select Id, SBQQ__PrimaryQuote__c
                              //, (select Id from OpportunityLineItems)
                              from Opportunity 
                              where Id =: clonedOpprotunityId];
        
        
        //Query QuoteLines releated to Parent Opportunity.
        List<SBQQ__QuoteLine__c> QuoteLineList = [Select Id, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ConnectionReceivedId, 
                                                  ConnectionSentId, SBQQ__Quote__c, SBQQ__AdditionalDiscountAmount__c, SBQQ__AdditionalDiscount__c, 
                                                  SBQQ__AdditionalQuantity__c, SBQQ__AllowAssetRefund__c, SBQQ__BatchQuantity__c, SBQQ__BillingFrequency__c, 
                                                  SBQQ__BillingType__c, SBQQ__BlockPrice__c, SBQQ__Bundle__c, SBQQ__BundledQuantity__c, SBQQ__Bundled__c, SBQQ__CarryoverLine__c,
                                                  SBQQ__ChargeType__c,  SBQQ__ComponentCost__c, SBQQ__ComponentDiscountedByPackage__c, 
                                                  SBQQ__ComponentListTotal__c, SBQQ__ComponentSubscriptionScope__c, SBQQ__ComponentTotal__c, SBQQ__ComponentUpliftedByPackage__c,
                                                  SBQQ__ComponentVisibility__c, SBQQ__CompoundDiscountRate__c, SBQQ__ConfigurationRequired__c, SBQQ__ContractedPrice__c,
                                                  SBQQ__CostEditable__c, SBQQ__Cost__c, SBQQ__CustomerPrice__c, SBQQ__CustomerTotal__c, SBQQ__DefaultSubscriptionTerm__c,
                                                  SBQQ__Description__c, SBQQ__Dimension__c, SBQQ__DiscountScheduleType__c, SBQQ__DiscountSchedule__c, SBQQ__DiscountTier__c,
                                                  SBQQ__Discount__c, SBQQ__DistributorDiscount__c, SBQQ__DynamicOptionId__c, SBQQ__EffectiveEndDate__c, SBQQ__EffectiveQuantity__c,
                                                  SBQQ__EffectiveStartDate__c, SBQQ__EndDate__c, SBQQ__Existing__c, SBQQ__Favorite__c, SBQQ__GenerateContractedPrice__c,
                                                  SBQQ__GrossProfit__c, SBQQ__Group__c,  SBQQ__Hidden__c, SBQQ__Incomplete__c, SBQQ__ListPrice__c,
                                                  SBQQ__ListTotal__c, SBQQ__MarkupAmount__c, SBQQ__MarkupRate__c, SBQQ__Markup__c, SBQQ__MaximumPrice__c, SBQQ__MinimumPrice__c,
                                                  SBQQ__NetPrice__c, SBQQ__NetTotal__c, SBQQ__NonDiscountable__c, SBQQ__NonPartnerDiscountable__c, SBQQ__Number__c,
                                                  SBQQ__OptionDiscountAmount__c, SBQQ__OptionDiscount__c, SBQQ__OptionLevel__c, SBQQ__OptionType__c, SBQQ__Optional__c,
                                                  SBQQ__OriginalPrice__c,  SBQQ__OriginalUnitCost__c, SBQQ__PackageCost__c, SBQQ__PackageListTotal__c,
                                                  SBQQ__PackageProductCode__c, SBQQ__PackageProductDescription__c, SBQQ__PackageTotal__c, SBQQ__PartnerDiscount__c,
                                                  SBQQ__PartnerPrice__c, SBQQ__PartnerTotal__c, SBQQ__PreviousSegmentPrice__c, SBQQ__PreviousSegmentUplift__c,
                                                  SBQQ__PriceEditable__c, SBQQ__PricingMethodEditable__c, SBQQ__PricingMethod__c, SBQQ__PriorQuantity__c, SBQQ__ProductCode__c,
                                                  SBQQ__ProductFamily__c, SBQQ__ProductName__c, SBQQ__ProductOption__c, SBQQ__Product__c, SBQQ__ProrateMultiplier__c,
                                                  SBQQ__ProratedListPrice__c, SBQQ__ProratedPrice__c, SBQQ__Quantity__c, SBQQ__RegularPrice__c, SBQQ__RegularTotal__c,
                                                  SBQQ__Renewal__c, SBQQ__RenewedAsset__c, SBQQ__RenewedSubscription__c, SBQQ__RequiredBy__c, SBQQ__SegmentIndex__c,
                                                  SBQQ__SegmentKey__c, SBQQ__SegmentLabel__c, SBQQ__Source__c, SBQQ__SpecialPriceDescription__c, SBQQ__SpecialPriceType__c,
                                                  SBQQ__SpecialPrice__c, SBQQ__StartDate__c, SBQQ__SubscribedAssetIds__c, SBQQ__SubscriptionBase__c, SBQQ__SubscriptionCategory__c,
                                                  SBQQ__SubscriptionPercent__c, SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionScope__c, SBQQ__SubscriptionTargetPrice__c,
                                                  SBQQ__SubscriptionTerm__c, SBQQ__TaxCode__c, SBQQ__Taxable__c, SBQQ__TermDiscountSchedule__c, SBQQ__TermDiscountTier__c,
                                                  SBQQ__TermDiscount__c, SBQQ__TotalDiscountAmount__c, SBQQ__TotalDiscountRate__c, SBQQ__UnitCost__c, SBQQ__UnproratedNetPrice__c,
                                                  SBQQ__UpgradedAsset__c, SBQQ__UpgradedQuantity__c, SBQQ__UpgradedSubscription__c, SBQQ__UpliftAmount__c, SBQQ__Uplift__c,
                                                  SBQQ__VolumeDiscount__c, CPQ_Price_List__c, CPQ_QT_PAK_ID__c, CPQ_QT_Serial_Number__c, CPQ_Rate_Unit__c, Condition_Type__c,
                                                  Current_Date__c, Customer_Classification__c, Entitlement_ID__c, ExpirationDate__c, Hardware_Serial_Number__c, IsBundle__c,
                                                  NumberOfMonthsContract__c, Number_of_Days__c, PAK_ID__c, ProductType__c, QT_Part_Number__c, Renewal_End_Date__c,
                                                  Renewal_Start_Date__c, Renewal_Term_Formula__c, Renewal_Term__c, Renewed_Entitlement_ID__c, Renewed_PAK_ID__c,
                                                  SAP_Customer_Number__c, SAP_Order__c, SAP_Term__c, SAP_Term_in_Months__c, Sales_Type_Code__c, Sales_Type__c, number_of_Month__c,
                                                  CPQ_QT_Subscription_ID__c, SBQQ__OriginalQuoteLineId__c, SBQQ__PricebookEntryId__c, ENTITL_EXT_ID__c, EarliestStartDate__c,
                                                  OriginalEndDate__c, OriginalStartDate__c, QTListUnitPrice__c, QuoteDiscount__c, SalesOrderNumber__c, CPQCustomerClassification__c,
                                                  CPQPriceListUpdated__c, CPQRateUnitUpdated__c, CPQSAPCustomerNumber__c, CPQSalesType__c, SBQQ__ProductSubscriptionType__c,
                                                  SBQQ__SubscriptionType__c, SBQQ__Guidance__c, SBQQ__EarliestValidAmendmentStartDate__c, IsCPQProduct__c, 
                                                  SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__RequiredBy__r.SBQQ__Number__c,
                                                  Product_Term__c, Product_Term_Formula__c, SBQQ__EffectiveSubscriptionTerm__c, Term__c, Term_Based_Product__c
                                                  from SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__r.SBQQ__Opportunity2__c =: OriginalOpportunityId];
                                                  //WHERE SBQQ__Quote__r.SBQQ__Opportunity2__c in: oppMapByParentOppId.keySet()];
                                                  //where SBQQ__Quote__r.SBQQ__Opportunity2__c in: ParentOpportunityIds];
        
        System.debug('QuoteLines := ' + QuoteLineList);
        if(QuoteLineList.isEmpty())
            return;
        
        List<SBQQ__QuoteLine__c> cloneQLList = new List<SBQQ__QuoteLine__c>();
        map<Integer, Id> parentLineToIdMap = new map<Integer, Id>();
        map<Id, OppReg_Quote_Tracker__c> quoteTrackerToQutoeIdMap = new map<Id, OppReg_Quote_Tracker__c>();
        for(SBQQ__QuoteLine__c QL : QuoteLineList){
            //Opportunity newOpp = oppMapByParentOppId.get(QL.SBQQ__Quote__r.SBQQ__Opportunity2__c);
            SBQQ__QuoteLine__c clonedQL = QL.clone(false, true, false, false);
            
            //Logic to find/update Parent Line Number
            if(QL.SBQQ__RequiredBy__c != NULL) {
                clonedQL.Parent_Line_Number__c = QL.SBQQ__RequiredBy__r.SBQQ__Number__c;
                //Remove Required By Id of Old QuoteLines
                clonedQL.SBQQ__RequiredBy__c = NULL;
                
                //Create List of Quote Tracker to manage Hierarchy
                OppReg_Quote_Tracker__c tracker = new OppReg_Quote_Tracker__c(
                                                        QuoteId__c = newOpp.SBQQ__PrimaryQuote__c,
                                                        QuoteLineHierarchyNeeded__c=True,
                                                        QuoteLineHierarchyCompleted__c=False,
                                                        QuoteLineCreated__c = true 
                                                    );
                quoteTrackerToQutoeIdMap.put(newOpp.SBQQ__PrimaryQuote__c, tracker);
            }
            
            //Update new values on Cloned QuoteLines:
            clonedQL.SBQQ__Quote__c = newOpp.SBQQ__PrimaryQuote__c;
            cloneQLList.add(clonedQL);
        }
        
        System.debug('Cloned QuoteLines List: ' + cloneQLList);
        if(cloneQLList != NULL && cloneQLList.size() > 0)
            insert cloneQLList;
        
        System.debug('quoteTrackerToQutoeIdMap: ' + quoteTrackerToQutoeIdMap);
        if(quoteTrackerToQutoeIdMap != NULL && quoteTrackerToQutoeIdMap.size() > 0)
            insert quoteTrackerToQutoeIdMap.values();
    }
}
/*    //@future
    public static void cloneQuoteLines(set<String> ParentOpportunityIds) {//}
    //public static void cloneQuoteLines(set<Id> ParentOpportunityIds) {
        System.debug('OpportunityIds := ' + ParentOpportunityIds);
        
        //Query New Opportunity with OpportunityLineItems.
        Map<Id, Opportunity> newOpportunitiesMap = new Map<Id, Opportunity> ([select Id, SBQQ__PrimaryQuote__c, Opportunity_Id__c
                                                                              	//, (select Id from OpportunityLineItems)
                                                                              from Opportunity 
                                                                              where Opportunity_Id__c in: ParentOpportunityIds]); 
        
        //Get ParentOppIds for only when OppItem is > 0
        Map<Id, Opportunity> oppMapByParentOppId = new Map<Id, Opportunity>();
        for(Opportunity newOpp : newOpportunitiesMap.values()) {
            if(
                //newOpp.OpportunityLineItems != NULL && newOpp.OpportunityLineItems.size() > 0 && 
                newOpp.Opportunity_Id__c != newOpp.Id 
              )
                oppMapByParentOppId.put(newOpp.Opportunity_Id__c, newOpp);
        }
        
        system.debug('oppMapByParentOppId: '+ oppMapByParentOppId);
        if(oppMapByParentOppId.isEmpty()) {
            return;
        }
        
        //Query QuoteLines releated to Parent Opportunity.
        List<SBQQ__QuoteLine__c> QuoteLineList = [Select Id, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, ConnectionReceivedId, 
                                                  ConnectionSentId, SBQQ__Quote__c, SBQQ__AdditionalDiscountAmount__c, SBQQ__AdditionalDiscount__c, 
                                                  SBQQ__AdditionalQuantity__c, SBQQ__AllowAssetRefund__c, SBQQ__BatchQuantity__c, SBQQ__BillingFrequency__c, 
                                                  SBQQ__BillingType__c, SBQQ__BlockPrice__c, SBQQ__Bundle__c, SBQQ__BundledQuantity__c, SBQQ__Bundled__c, SBQQ__CarryoverLine__c,
                                                  SBQQ__ChargeType__c,  SBQQ__ComponentCost__c, SBQQ__ComponentDiscountedByPackage__c, 
                                                  SBQQ__ComponentListTotal__c, SBQQ__ComponentSubscriptionScope__c, SBQQ__ComponentTotal__c, SBQQ__ComponentUpliftedByPackage__c,
                                                  SBQQ__ComponentVisibility__c, SBQQ__CompoundDiscountRate__c, SBQQ__ConfigurationRequired__c, SBQQ__ContractedPrice__c,
                                                  SBQQ__CostEditable__c, SBQQ__Cost__c, SBQQ__CustomerPrice__c, SBQQ__CustomerTotal__c, SBQQ__DefaultSubscriptionTerm__c,
                                                  SBQQ__Description__c, SBQQ__Dimension__c, SBQQ__DiscountScheduleType__c, SBQQ__DiscountSchedule__c, SBQQ__DiscountTier__c,
                                                  SBQQ__Discount__c, SBQQ__DistributorDiscount__c, SBQQ__DynamicOptionId__c, SBQQ__EffectiveEndDate__c, SBQQ__EffectiveQuantity__c,
                                                  SBQQ__EffectiveStartDate__c, SBQQ__EndDate__c, SBQQ__Existing__c, SBQQ__Favorite__c, SBQQ__GenerateContractedPrice__c,
                                                  SBQQ__GrossProfit__c, SBQQ__Group__c,  SBQQ__Hidden__c, SBQQ__Incomplete__c, SBQQ__ListPrice__c,
                                                  SBQQ__ListTotal__c, SBQQ__MarkupAmount__c, SBQQ__MarkupRate__c, SBQQ__Markup__c, SBQQ__MaximumPrice__c, SBQQ__MinimumPrice__c,
                                                  SBQQ__NetPrice__c, SBQQ__NetTotal__c, SBQQ__NonDiscountable__c, SBQQ__NonPartnerDiscountable__c, SBQQ__Number__c,
                                                  SBQQ__OptionDiscountAmount__c, SBQQ__OptionDiscount__c, SBQQ__OptionLevel__c, SBQQ__OptionType__c, SBQQ__Optional__c,
                                                  SBQQ__OriginalPrice__c,  SBQQ__OriginalUnitCost__c, SBQQ__PackageCost__c, SBQQ__PackageListTotal__c,
                                                  SBQQ__PackageProductCode__c, SBQQ__PackageProductDescription__c, SBQQ__PackageTotal__c, SBQQ__PartnerDiscount__c,
                                                  SBQQ__PartnerPrice__c, SBQQ__PartnerTotal__c, SBQQ__PreviousSegmentPrice__c, SBQQ__PreviousSegmentUplift__c,
                                                  SBQQ__PriceEditable__c, SBQQ__PricingMethodEditable__c, SBQQ__PricingMethod__c, SBQQ__PriorQuantity__c, SBQQ__ProductCode__c,
                                                  SBQQ__ProductFamily__c, SBQQ__ProductName__c, SBQQ__ProductOption__c, SBQQ__Product__c, SBQQ__ProrateMultiplier__c,
                                                  SBQQ__ProratedListPrice__c, SBQQ__ProratedPrice__c, SBQQ__Quantity__c, SBQQ__RegularPrice__c, SBQQ__RegularTotal__c,
                                                  SBQQ__Renewal__c, SBQQ__RenewedAsset__c, SBQQ__RenewedSubscription__c, SBQQ__RequiredBy__c, SBQQ__SegmentIndex__c,
                                                  SBQQ__SegmentKey__c, SBQQ__SegmentLabel__c, SBQQ__Source__c, SBQQ__SpecialPriceDescription__c, SBQQ__SpecialPriceType__c,
                                                  SBQQ__SpecialPrice__c, SBQQ__StartDate__c, SBQQ__SubscribedAssetIds__c, SBQQ__SubscriptionBase__c, SBQQ__SubscriptionCategory__c,
                                                  SBQQ__SubscriptionPercent__c, SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionScope__c, SBQQ__SubscriptionTargetPrice__c,
                                                  SBQQ__SubscriptionTerm__c, SBQQ__TaxCode__c, SBQQ__Taxable__c, SBQQ__TermDiscountSchedule__c, SBQQ__TermDiscountTier__c,
                                                  SBQQ__TermDiscount__c, SBQQ__TotalDiscountAmount__c, SBQQ__TotalDiscountRate__c, SBQQ__UnitCost__c, SBQQ__UnproratedNetPrice__c,
                                                  SBQQ__UpgradedAsset__c, SBQQ__UpgradedQuantity__c, SBQQ__UpgradedSubscription__c, SBQQ__UpliftAmount__c, SBQQ__Uplift__c,
                                                  SBQQ__VolumeDiscount__c, CPQ_Price_List__c, CPQ_QT_PAK_ID__c, CPQ_QT_Serial_Number__c, CPQ_Rate_Unit__c, Condition_Type__c,
                                                  Current_Date__c, Customer_Classification__c, Entitlement_ID__c, ExpirationDate__c, Hardware_Serial_Number__c, IsBundle__c,
                                                  NumberOfMonthsContract__c, Number_of_Days__c, PAK_ID__c, ProductType__c, QT_Part_Number__c, Renewal_End_Date__c,
                                                  Renewal_Start_Date__c, Renewal_Term_Formula__c, Renewal_Term__c, Renewed_Entitlement_ID__c, Renewed_PAK_ID__c,
                                                  SAP_Customer_Number__c, SAP_Order__c, SAP_Term__c, SAP_Term_in_Months__c, Sales_Type_Code__c, Sales_Type__c, number_of_Month__c,
                                                  CPQ_QT_Subscription_ID__c, SBQQ__OriginalQuoteLineId__c, SBQQ__PricebookEntryId__c, ENTITL_EXT_ID__c, EarliestStartDate__c,
                                                  OriginalEndDate__c, OriginalStartDate__c, QTListUnitPrice__c, QuoteDiscount__c, SalesOrderNumber__c, CPQCustomerClassification__c,
                                                  CPQPriceListUpdated__c, CPQRateUnitUpdated__c, CPQSAPCustomerNumber__c, CPQSalesType__c, SBQQ__ProductSubscriptionType__c,
                                                  SBQQ__SubscriptionType__c, SBQQ__Guidance__c, SBQQ__EarliestValidAmendmentStartDate__c, IsCPQProduct__c, 
                                                  SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__RequiredBy__r.SBQQ__Number__c,
                                                  Product_Term__c, Product_Term_Formula__c, SBQQ__EffectiveSubscriptionTerm__c, Term__c, Term_Based_Product__c
                                                  from SBQQ__QuoteLine__c 
                                                  WHERE SBQQ__Quote__r.SBQQ__Opportunity2__c in: oppMapByParentOppId.keySet()];
                                                  //where SBQQ__Quote__r.SBQQ__Opportunity2__c in: ParentOpportunityIds];
        
        System.debug('QuoteLines := ' + QuoteLineList);
        if(QuoteLineList.isEmpty())
            return;
        
        List<SBQQ__QuoteLine__c> cloneQLList = new List<SBQQ__QuoteLine__c>();
        map<Integer, Id> parentLineToIdMap = new map<Integer, Id>();
        map<Id, OppReg_Quote_Tracker__c> quoteTrackerToQutoeIdMap = new map<Id, OppReg_Quote_Tracker__c>();
        for(SBQQ__QuoteLine__c QL : QuoteLineList){
            Opportunity newOpp = oppMapByParentOppId.get(QL.SBQQ__Quote__r.SBQQ__Opportunity2__c);
            SBQQ__QuoteLine__c clonedQL = QL.clone(false, true, false, false);
            
            //Logic to find/update Parent Line Number
            if(QL.SBQQ__RequiredBy__c != NULL) {
                clonedQL.Parent_Line_Number__c = QL.SBQQ__RequiredBy__r.SBQQ__Number__c;
                //Remove Required By Id of Old QuoteLines
                clonedQL.SBQQ__RequiredBy__c = NULL;
                
                //Create List of Quote Tracker to manage Hierarchy
                OppReg_Quote_Tracker__c tracker = new OppReg_Quote_Tracker__c(
                                                        QuoteId__c = newOpp.SBQQ__PrimaryQuote__c,
                                                        QuoteLineHierarchyNeeded__c=True,
                                                        QuoteLineHierarchyCompleted__c=False,
                                                        QuoteLineCreated__c = true 
                                                    );
                quoteTrackerToQutoeIdMap.put(newOpp.SBQQ__PrimaryQuote__c, tracker);
            }
            
            //Update new values on Cloned QuoteLines:
            clonedQL.SBQQ__Quote__c = newOpp.SBQQ__PrimaryQuote__c;
            cloneQLList.add(clonedQL);
        }
        
        System.debug('Cloned QuoteLines List: ' + cloneQLList);
        if(cloneQLList != NULL && cloneQLList.size() > 0)
            insert cloneQLList;
        
        System.debug('quoteTrackerToQutoeIdMap: ' + quoteTrackerToQutoeIdMap);
        if(quoteTrackerToQutoeIdMap != NULL && quoteTrackerToQutoeIdMap.size() > 0)
            insert quoteTrackerToQutoeIdMap.values();
        
        //Logic when this method is not called from Batch Job.
        //Batch job call SOQ_CreateQuoteLineHierarchy_BAT SOQ_CreateQuoteLineHierarchy_BAT
        //Id batchJobId = Database.executeBatch(new SOQ_CreateQuoteLineHierarchy_BAT(), 1);
        //system.debug('batchJobId: '+ batchJobId);
        //resetOpportunityIdField(oppMapByParentOppId);
    }
    
    public static void resetOpportunityIdField(set<Id> oppIdSet) {
        list<Opportunity> oppListToUpdate = new list<Opportunity>();
        //Reset Opportunity_Id(Text) = Opp.Id
        for(Id oppId: oppIdSet) {
            oppListToUpdate.add(new Opportunity(Id=oppId, Opportunity_Id__c = oppId));
        }
        System.debug('oppListToUpdate: ' + oppListToUpdate);
        if(oppListToUpdate != NULL && oppListToUpdate.size() > 0)
            update oppListToUpdate;
    }
                                
    public static void resetOpportunityIdField(Map<Id, Opportunity> newOpportunitiesMap) {
        //Reset Opportunity_Id(Text) = Opp.Id
        for(Opportunity opp : newOpportunitiesMap.values()) {
            opp.Opportunity_Id__c = opp.Id;
        }
        System.debug('newOpportunitiesMap: ' + newOpportunitiesMap);
        if(newOpportunitiesMap != NULL && newOpportunitiesMap.size() > 0)
            update newOpportunitiesMap.values();
    }
} */