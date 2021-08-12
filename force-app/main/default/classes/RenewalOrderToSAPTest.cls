@isTest
public class RenewalOrderToSAPTest {
    static Order orderData = new Order();
    static testMethod void createOrderDataTest(){
      WebServiceSAPCPQMock.retrunResponceType = 'TRUE';
      insertOrderData();

      Test.setMock(WebServiceMock.class, new WebServiceSAPCPQMock());
      Test.startTest();

       
       SAPCPQIntegration_Functions.ReturnItem item1 = new SAPCPQIntegration_Functions.ReturnItem();
       
       SAPCPQIntegration_Functions.MESSAGES_element item2 = new SAPCPQIntegration_Functions.MESSAGES_element();
       
       
      // TODO - Construct Order Data
      //List<Id> lstOrderIds=new List<Id>();
      //lstOrderIds.add(orderData.Id);
      String result = RenewalOrderToSAP.SubmitOrder(orderData.Id, true);
      System.debug('ErrorLog 1' + result);

      Test.stopTest();
      System.assertEquals(result, 'The order [Mock response Web Service] has been successfully sent to SAP');

    }

    static testMethod void createOrderDataTest2(){

      WebServiceSAPCPQMock.retrunResponceType = 'FALSE';
      insertOrderData();

      Test.setMock(WebServiceMock.class, new WebServiceSAPCPQMock());
      Test.startTest();

      // TODO - Construct Order Data
      // List<Id> lstOrderIds=new List<Id>();
      // lstOrderIds.add(orderData.Id);
      String result = RenewalOrderToSAP.SubmitOrder(orderData.Id, true);
      System.debug('ErrorLog 2' + result);

      Test.stopTest();
      System.assertEquals(result, 'The order submission failed and will be automatically resubmitted.');

    }

    public static void insertOrderData()
    {

    List<Product2> lstTestProducts = new List<Product2>();
        for(Integer i=1; i<=5; i++){
            Product2 objProduct1 = new Product2();
         objProduct1.Name = 'Product X'+i;
         objProduct1.ProductCode = 'Pro-X'+i;
         objProduct1.isActive = true;
         lstTestProducts.add(objProduct1);
        }
        insert lstTestProducts;

        Id testRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('New Customer Account').getRecordTypeId();
        
        Account objAccountTest = new Account();
        objAccountTest.Name = 'Test Name';
        objAccountTest.Website = 'www.test.com';
        objAccountTest.Phone = '9876543210';
        objAccountTest.BillingStreet = 'Test Street';
        objAccountTest.BillingCity = 'Test City';
        objAccountTest.BillingState = 'Ohio';
        objAccountTest.BillingCountry = 'United States';
        objAccountTest.Industry = 'Advertising, Marketing, PR & Design';
        objAccountTest.SAP_Customer_Number__c = '19999';
        objAccountTest.NPN_Active_Program_Competency__c  = 'Solution Provider';
        objAccountTest.AccountTags__c = 'Enterprise Customer';
        objAccountTest.RecordTypeId = testRecordTypeId;
        insert objAccountTest;

        Contact contactSample = new Contact();
        contactSample.FirstName = 'Ronit';
        contactSample.LastName = 'Roy';
        contactSample.Email = 'rroy@gmail.com';
        contactSample.AccountId=objAccountTest.Id;
        contactSample.SAP_Contact_ID__c='xyz';

        insert contactSample;
        
        CPQ_Settings__c setting = new CPQ_Settings__c();
        setting.Name = 'org';
        setting.URL__c = 'url';
        setting.UserName__c = 'user name';
        setting.Password__c = 'password';
        insert setting;

        /*Contact contactSample2 = new Contact();
        contactSample2.FirstName = 'Ronit';
        contactSample2.LastName = 'Roy';
        contactSample2.Email = 'rroy@gmail.com';
        contactSample2.AccountId=objAccountTest.Id;
        contactSample2.SAP_Contact_ID__c='xyz';

        insert contactSample2;*/

        //Create Opportunity
        Opportunity objTestOpportunity = new Opportunity();
        objTestOpportunity.Name = 'Test Opp';
        objTestOpportunity.StageName = 'Discovery';
        objTestOpportunity.AccountId = objAccountTest.Id;
        objTestOpportunity.CloseDate = Date.today();

        insert objTestOpportunity;

        //Create Quote
        SBQQ__Quote__c objTestQuote = new SBQQ__Quote__c();
        objTestQuote.SBQQ__Opportunity2__c = objTestOpportunity.Id;
        objTestQuote.SBQQ__Primary__c = true;
        //objTestQuote.Reseller_Account__c=objAccountTest.Id;
        //objTestQuote.Reseller_Contact__c=contactSample.Id;
        objTestQuote.Sold_To__c=objAccountTest.Id;
        objTestQuote.End_Customer_Contact__c=contactSample.Id;
        insert objTestQuote;


        //Add QuoteLines
        List<SBQQ__QuoteLine__c> lstQuoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c objOuoteLine1 = new SBQQ__QuoteLine__c();
        objOuoteLine1.SBQQ__Quote__c = objTestQuote.Id;
        objOuoteLine1.SBQQ__ListPrice__c=10;
        objOuoteLine1.SBQQ__Product__c = lstTestProducts.get(0).Id;
        objOuoteLine1.SBQQ__Number__c = 1;
        objOuoteLine1.SBQQ__StartDate__c=Date.today();
        objOuoteLine1.SBQQ__EndDate__c=Date.today();
        objOuoteLine1.SBQQ__SubscriptionTerm__c = 12;
        lstQuoteLines.add(objOuoteLine1);

        SBQQ__QuoteLine__c objOuoteLine2 = new SBQQ__QuoteLine__c();
        objOuoteLine2.SBQQ__Quote__c = objTestQuote.Id;
        objOuoteLine2.SBQQ__Product__c = lstTestProducts.get(1).Id;
        objOuoteLine2.SBQQ__Number__c = 1;
        objOuoteLine2.SBQQ__ListPrice__c=10;
        objOuoteLine2.SBQQ__StartDate__c=Date.today();
        objOuoteLine2.SBQQ__EndDate__c=Date.today();
        objOuoteLine2.SBQQ__SubscriptionTerm__c = 12;
        lstQuoteLines.add(objOuoteLine2);

        insert lstQuoteLines;


        Id pricebookId = Test.getStandardPricebookId();

        orderData.SBQQ__Quote__c = objTestQuote.Id;
        orderData.Status = 'Draft';
        orderData.EffectiveDate = Date.today();
        orderData.AccountId = objAccountTest.Id;
        orderData.Purchase_Order_Number__c='as23';
        orderData.Sales_Organization__c = '2100';
        orderData.Pricebook2Id = pricebookId;
        orderData.PO_Date__c = Date.today();
        insert orderData;




        PricebookEntry objPbEntry = new PricebookEntry();
            objPbEntry.Pricebook2Id = pricebookId;
            objPbEntry.Product2Id = lstTestProducts.get(0).Id;
            objPbEntry.UnitPrice = 100.00;
            objPbEntry.IsActive = true;

        insert objPbEntry;

        OrderItem objOrderItem = new OrderItem();
        objOrderItem.PricebookEntryId = objPbEntry.Id;
        objOrderItem.OrderId = orderData.Id;
        objOrderItem.SBQQ__QuoteLine__c = lstQuoteLines.get(0).Id;
        //objOrderItem.SBQQ__Activated__c = true;
        objOrderItem.Quantity = 1;
        objOrderItem.SBQQ__DefaultSubscriptionTerm__c = 1;
       // objOrderItem.SBQQ__Status__c = 'Activated';
        //objOrderItem.blng__HoldBilling__c = 'No';
        //objOrderItem.blng__InvoiceRunStatus__c = 'Queued for Invoice';
        objOrderItem.UnitPrice = 100.00;
        //objOrderItem.SBQQ__ChargeType__c = 'One-Time';
        //objOrderItem.blng__BillingRule__c = objBillingRule.Id;
        //objOrderItem.blng__RevenueRecognitionRule__c = objRevenueRec.Id;
        //objOrderItem.blng__TaxRule__c = objTaxRule.Id;
        System.debug('objOrderItem-------->>>>'+objOrderItem);
        insert objOrderItem;

    }
}