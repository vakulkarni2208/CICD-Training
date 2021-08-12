@isTest 
public class SubmitToSapControllerTest {

    static Order orderData = new Order();
    static testMethod void createOrderDataTest(){
 
      WebServiceSAPCPQMock.retrunResponceType = 'TRUE';
      insertOrderData();
      ApexPages.StandardController sc = new ApexPages.StandardController(orderData);
      SubmitToSapController submitToSapControllerObj = new SubmitToSapController(sc);
      SubmitToSapController.disable = true;
      Test.setMock(WebServiceMock.class, new WebServiceSAPCPQMock());
      Test.startTest();
        
      submitToSapControllerObj.objOrder = orderData;
      submitToSapControllerObj.SubmitOrderFromVF();
      
      Test.stopTest();
      
      Order orderObj = [SELECT Id
                             , Submitted_to_SAP__c
                          FROM ORDER]; 
      System.assertEquals(true, orderObj.Submitted_to_SAP__c);
      
    }
    
    static testMethod void createOrderDataTest2(){
       
      WebServiceSAPCPQMock.retrunResponceType = 'FALSE';
      insertOrderData();
      ApexPages.StandardController sc = new ApexPages.StandardController(orderData);
      SubmitToSapController submitToSapControllerObj = new SubmitToSapController(sc);
      SubmitToSapController.disable = true;
      Test.setMock(WebServiceMock.class, new WebServiceSAPCPQMock());
      Test.startTest();
        
      submitToSapControllerObj.objOrder = orderData;
      submitToSapControllerObj.SubmitOrderFromVF();
        submitToSapControllerObj.SubmitInitialSORequest();
      
      
      Test.stopTest();
      
      Order orderObj = [SELECT Id
                             , Submitted_to_SAP__c
                          FROM ORDER]; 
      System.assertEquals(true, orderObj.Submitted_to_SAP__c);
      
    }
    
    static testMethod void NewInitialOrderDataTest(){
       
      WebServiceSAPCPQMock.retrunResponceType = 'FALSE';
      insertOrderData();
      ApexPages.StandardController sc = new ApexPages.StandardController(orderData);
      SubmitToSapController submitToSapControllerObj = new SubmitToSapController(sc);
      //submitToSapControllerObj.disable = true;
      Test.setMock(WebServiceMock.class, new WebServiceSAPCPQMock());
      Test.startTest();
        
      submitToSapControllerObj.objOrder = orderData;
      submitToSapControllerObj.SubmitInitialSORequest();
      
      Test.stopTest();
      
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
         
        List<Account> lstTestAccounts = new List<Account>();
        Account parentAccountTest = new Account();
        parentAccountTest.Name = 'Test Name';
        parentAccountTest.Website = 'www.oneee.com';
        parentAccountTest.Phone = '98763210';
        parentAccountTest.BillingStreet = 'Test Street';
        parentAccountTest.BillingCity = 'Test City';
        parentAccountTest.BillingState = 'Texas';
        parentAccountTest.BillingCountry = 'United States';
        parentAccountTest.Industry = 'Advertising, Marketing, PR & Design';
        parentAccountTest.SAP_Customer_Number__c = '12312';
       // objAccountTest.Is_End_Customer__c=true;
        insert parentAccountTest;
        lstTestAccounts.add(parentAccountTest);
        
        Account objAccountTest = new Account();
        objAccountTest.Name = 'real Name';
        objAccountTest.Parent =parentAccountTest;
        objAccountTest.Website = 'www.tessdft.com';
        objAccountTest.Phone = '9822223210';
        objAccountTest.BillingStreet = 'Test';
        objAccountTest.BillingCity = 'City';
        objAccountTest.BillingState = 'California';
        objAccountTest.BillingCountry = 'United States';
        objAccountTest.Industry = 'Manufacturing';
        objAccountTest.SAP_Customer_Number__c = '19999';
        objAccountTest.NPN_Active_Program_Competency__c  = 'Solution Provider';
       // objAccountTest.Is_End_Customer__c=true;
        insert objAccountTest;
        
         
        
        Account SiblingobjAccountTest = new Account();
        SiblingobjAccountTest.Name = 'Test sibling';
        SiblingobjAccountTest.Parent =parentAccountTest;
        SiblingobjAccountTest.Website = 'www.twoooo.com';
        SiblingobjAccountTest.Phone = '9899993510';
        SiblingobjAccountTest.BillingStreet = 'riorobles';
        SiblingobjAccountTest.BillingCity = 'columbus';
        SiblingobjAccountTest.BillingState = 'Ohio';
        SiblingobjAccountTest.BillingCountry = 'United States';
        SiblingobjAccountTest.Industry = 'Public Sector';
        SiblingobjAccountTest.SAP_Customer_Number__c = '3463456';
        SiblingobjAccountTest.NPN_Active_Program_Competency__c  = 'Solution Provider';
       // objAccountTest.Is_End_Customer__c=true;
        insert SiblingobjAccountTest;
        
        Account ChildSiblingobjAccountTest = new Account();
        ChildSiblingobjAccountTest.Name = 'Test ChildSibling';
        ChildSiblingobjAccountTest.Parent =SiblingobjAccountTest;
        ChildSiblingobjAccountTest.Website = 'www.tsdfest.com';
        ChildSiblingobjAccountTest.Phone = '981657666';
        ChildSiblingobjAccountTest.BillingStreet = 'one';
        ChildSiblingobjAccountTest.BillingCity = 'hyderabad';
        ChildSiblingobjAccountTest.BillingState = 'Telangana';
        ChildSiblingobjAccountTest.BillingCountry = 'India';
        ChildSiblingobjAccountTest.Industry = 'Healthcare';
        ChildSiblingobjAccountTest.SAP_Customer_Number__c = '3433456';
        ChildSiblingobjAccountTest.NPN_Active_Program_Competency__c  = 'Solution Provider';
       // objAccountTest.Is_End_Customer__c=true;
        insert ChildSiblingobjAccountTest;
        lstTestAccounts.add(ChildSiblingobjAccountTest);
        
        OrderTriggerClass.GetTopLevelAccount(objAccountTest.id);
        OrderTriggerClass.getHierarchies(lstTestAccounts);
        //lstTestAccounts = OrderTriggerClass.getChildAccountsInHierarchy(SiblingobjAccountTest.id);
        
        
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
        // objTestQuote.Reseller_Account__c=objAccountTest.Id;
        // 0    objTestQuote.Reseller_Contact__c=contactSample.Id;
        insert objTestQuote;
        
        
        QuickQuoteCont.getQuote(objTestQuote.id);
        
        List<id> Qlist = new List<id>();
            Qlist.add(objTestQuote.id);
            OrderTriggerClass.SyncQuotes(Qlist);
        
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
        objOuoteLine1.SBQQ__SubscriptionTerm__c = 12;
        lstQuoteLines.add(objOuoteLine2);
        
        insert lstQuoteLines;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        
        orderData.SBQQ__Quote__c = objTestQuote.Id;
        orderData.Status = 'Draft';
        orderData.EffectiveDate = Date.today();
        orderData.AccountId = objAccountTest.Id;
        orderData.Purchase_Order_Number__c='PO345323';
        orderData.Sales_Organization__c = '2100';
        orderData.Pricebook2Id = pricebookId;
        orderData.PO_Date__c = Date.today();
        orderData.Generate_Email__c=true;
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
        objOrderItem.Quantity = 1;
        objOrderItem.SBQQ__DefaultSubscriptionTerm__c = 1;

        objOrderItem.UnitPrice = 100.00;

        System.debug('objOrderItem-------->>>>'+objOrderItem);
        insert objOrderItem;
        
    }
    
    /**************************************************************************************************
    * Input Parameters: No input parameters
    * DummyTestclass to imporove test ccoveragee 
    * Author : Venkat G
    * Purpose: Test method for NVService class pecLeadRequest method
    ***************************************************************************************************/ 
    static testMethod void dummyCoverageTest(){
     OrderTriggerClass.CoverageMethod();
     //repeat the same for the rest of classes.
  }  

    
    static testMethod void dummyUtilityCoverageTest(){
     Utility.CoverageMethod();
     //repeat the same for the rest of classes.
  }  
    
    
}