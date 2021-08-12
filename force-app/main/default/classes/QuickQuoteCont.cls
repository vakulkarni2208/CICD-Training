public class QuickQuoteCont {
    
    @AuraEnabled
    public static SBQQ__Quote__c getQuote(Id quoteId) {
        // Perform isAccessible() checks here
        return [SELECT id, name FROM SBQQ__Quote__c WHERE Id = :quoteId];
    }

}