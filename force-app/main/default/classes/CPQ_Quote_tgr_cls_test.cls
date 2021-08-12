@isTest
public class CPQ_Quote_tgr_cls_test {

    final static String NAME = 'CPQ_Quote_tgr';
    @testSetup 
    public static void TestDataCreation(){
        //Create Product
        Product2 product = Test_COMM_Factory.getProduct('Test Product');
        insert product;
        
        Account acc = Test_COMM_Factory.getAccount('Test Account');
        insert acc;
        
        Opportunity oppt    = Test_COMM_Factory.getOpportunity('NAME', acc.Id);
        oppt.Opportunity_Expiration_Date__c = Date.today().addYears(1);
        oppt.DR_Expiration_Date_Admin_Override__c = Date.today().addYears(1);
        insert oppt;
        
        // Create Quote
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        //quote.Name = Name+'Quote'; 
        //quote.IsDiscounted__c = True; 
        quote.SBQQ__ExpirationDate__c = Date.today().addDays(30);
        quote.SBQQ__Opportunity2__c = oppt.Id;
        quote.SBQQ__Status__c = 'Draft';
        //quote.SBQQ__LineItems__c = LineItem.Id;
        insert quote; 
        
        // Create Quote Line(s)
        SBQQ__QuoteLine__c LineItem = new SBQQ__QuoteLine__c();
        LineItem.SBQQ__Product__c = product.Id;
        LineItem.IsCPQProduct__c = True;
        LineItem.SBQQ__Quote__c = quote.Id;
        insert LineItem;
    }
    
    @isTest
    public static void testEntitlement(){
        System.debug('Limits.getQueries()- Start'+ Limits.getQueries());
        Account acc = [SELECT Id FROM Account][0];
        Product2 product = [SELECT Id FROM Product2][0];
        SBQQ__QuoteLine__c LineItem = [SELECT Id, SBQQ__Product__c, IsCPQProduct__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c][0];
        Opportunity contract = [SELECT Id FROM Opportunity][0];
        SBQQ__Quote__c quote = [SELECT Id, Name, IsDiscounted__c, SBQQ__ExpirationDate__c
                                            , SBQQ__Opportunity2__r.Name, SBQQ__Opportunity2__r.Opportunity_Expiration_Date__c
                                            , SBQQ__Opportunity2__r.DR_Expiration_Date_Admin_Override__c 
                                            , (select Id, SBQQ__Product__r.Name, IsCPQProduct__c from SBQQ__LineItems__r)
                                            from SBQQ__Quote__c][0];
        Test.startTest();
            quote.SBQQ__Status__c = 'Approved';
            update quote;
            System.debug('Limits.getQueries()- '+ Limits.getQueries());
            
            quote.SBQQ__Status__c = 'Draft';
            quote.Programmatic_Disc_Type__c = 'OppReg';
            update quote;
            System.debug('Limits.getQueries()- '+ Limits.getQueries());
            
            LineItem.IsCPQProduct__c = False;
            update LineItem;
            System.debug('Limits.getQueries()- '+ Limits.getQueries());
            
            quote.SBQQ__Status__c = 'Approved';
            //quote.IsDiscounted__c = False;
            update quote;
            System.debug('Limits.getQueries()- '+ Limits.getQueries());
        Test.stopTest();
    }
}