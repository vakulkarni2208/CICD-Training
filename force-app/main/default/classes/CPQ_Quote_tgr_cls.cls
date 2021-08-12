public class CPQ_Quote_tgr_cls extends NV_TriggerHandler {
	public list<SBQQ__Quote__c> oldRecords;
    private static list<SBQQ__Quote__c> newRecords;
    private static map<Id, SBQQ__Quote__c> oldRecordsMap;
    public static boolean DISABLE_TRIGGER = false;
    public override void init() { 
        OBJECT_NAME = 'SBQQ__Quote__c';
        oldRecords = trigger.old;
        newRecords = trigger.New;
        if(oldRecords != null)
            oldRecordsMap = new map<Id, SBQQ__Quote__c>(oldRecords);
        System.debug('Old Records' + oldRecords + '1');
        System.debug('New Records' + trigger.New + '1'); 
    }
    //public override void beforeInsert() {}
    
    public override void beforeUpdate() {
        setQuoteExpirationDate();
    }
    
    //public override void afterInsert() {}
    //public override void afterUpdate() {}
    
    public static void setQuoteExpirationDate() {
        map<Id, SBQQ__Quote__c> quotesToUpdateMap = new map<Id, SBQQ__Quote__c>();
        //set<Id> quoteIdsSet = new set<Id>();
        for(SBQQ__Quote__c qt : newRecords){
            SBQQ__Quote__c oldRecord = oldRecordsMap.get(qt.Id);
            if(qt.SBQQ__Status__c == 'Approved' && oldRecord.SBQQ__Status__c != 'Approved') {
                quotesToUpdateMap.put(qt.Id, qt);
                //quoteIdsSet.add(qt.Id);
            }
        }
        
        if(quotesToUpdateMap.isEmpty())
            return;
        
        map<Id, SBQQ__Quote__c> quotesWithAllDetails = new map<Id, SBQQ__Quote__c>(
            							[select Id, Name, IsDiscounted__c, SBQQ__ExpirationDate__c
                                         	, SBQQ__Opportunity2__r.Name, SBQQ__Opportunity2__r.Opportunity_Expiration_Date__c
                                         	, SBQQ__Opportunity2__r.DR_Expiration_Date_Admin_Override__c, SBQQ__Opportunity2__r.DR_Expiration_Date__c
                                         	, (select Id, SBQQ__Product__r.Name, IsCPQProduct__c from SBQQ__LineItems__r) 
                                         	from SBQQ__Quote__c 
                                         	where Id in: quotesToUpdateMap.keyset()
                                        ]);
        
        if(quotesWithAllDetails.isEmpty())
        	return;
        
        Period currentFiscalQuarter = getCurrentFiscalQuarter();
        
        list<Opportunity> oppToUpdate = new list<Opportunity>();
        for(SBQQ__Quote__c qt : quotesToUpdateMap.values()) {
            SBQQ__Quote__c qtWithDetails = quotesWithAllDetails.get(qt.Id);
            String opportunityType 	= qt.Programmatic_Disc_Type__c; //OppReg or non-OppReg
            String productType 		= getProductType(qtWithDetails.SBQQ__LineItems__r);//platformOnly or Enterprise
            boolean isDiscounted 	= qt.IsDiscounted__c;
            system.debug('opportunityType: '+ opportunityType);
            system.debug('productType: '+ productType);
            
            if(isDiscounted) {
                if(productType == 'platformOnly') {
                    continue;
                } if(productType != 'platformOnly') {
                    if(opportunityType == 'OppReg') {
                        qt.SBQQ__ExpirationDate__c = currentFiscalQuarter.EndDate;
                        if(currentFiscalQuarter.EndDate > qtWithDetails.SBQQ__Opportunity2__r.DR_Expiration_Date_Admin_Override__c) {
                            system.debug('qtWithDetails.SBQQ__Opportunity2__r.DR_Expiration_Date_Admin_Override__c: '+ qtWithDetails.SBQQ__Opportunity2__r.DR_Expiration_Date_Admin_Override__c);
                            Opportunity opp = new Opportunity(Id = qt.SBQQ__Opportunity2__c, DR_Expiration_Date_Admin_Override__c = currentFiscalQuarter.EndDate);
                            oppToUpdate.add(opp);
                        }
                    } else if(opportunityType != 'OppReg') {
                        qt.SBQQ__ExpirationDate__c = currentFiscalQuarter.EndDate;
                    }
                }
            } else {
                if(opportunityType == 'OppReg') {
                    qt.SBQQ__ExpirationDate__c = qtWithDetails.SBQQ__Opportunity2__r.DR_Expiration_Date__c;
                } else 
                    qt.SBQQ__ExpirationDate__c = NULL;
            }
        }
        
        if(!oppToUpdate.isEmpty())
            update oppToUpdate;
    }
    
    public static string getProductType(List<SBQQ__QuoteLine__c> quoteLineItems) {
        String productType = 'platformOnly';
        
        if(quoteLineItems != NULL) {
            for(SBQQ__QuoteLine__c item: quoteLineItems) {
                if(item.IsCPQProduct__c) 
                    productType = 'Enterprise';
            }
        }
        
        return productType;
    }
    
    public static Period getCurrentFiscalQuarter() {
        // Get the Fiscal Quarters defined in the system
        return [select StartDate, EndDate, Number, FiscalYearSettings.Name
             		from Period
             		where Type = 'Quarter'
                		and StartDate <=: Date.today() and EndDate >=: Date.today()
               ];
	}
}