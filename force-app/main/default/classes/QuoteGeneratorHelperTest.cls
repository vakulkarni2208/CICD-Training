@isTest
public class QuoteGeneratorHelperTest {

    static Product2 CreateProduct(string pCode) {

        Product2 prod = new Product2();
        prod.Name = pCode;
        prod.ProductCode = pCode;
        prod.IsActive = true;
        prod.SBQQ__DefaultQuantity__c = 1;
        prod.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        prod.SBQQ__SubscriptionTerm__c = 12;
        prod.SBQQ__SubscriptionBase__c = 'List';
        prod.SBQQ__SubscriptionType__c = 'Renewable';

        return prod;

    }

    static public Account CreateAccount(string name, string accountNum, string compentency, string recordTypeName) {

        Id recordTypeId = null;
        if (recordTypeName != '') {
            List<RecordType> recTypes = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Account' AND Name = :recordTypeName];
            if (recTypes.size() == 1) { recordTypeId = recTypes[0].Id; }
        }

        
        Account acct = new Account();
        acct.Name = name;
        acct.SAP_Customer_Number__c = accountNum;
        acct.NPN_Active_Program_Competency__c = compentency;
        acct.NPN_Program_Signed_Date__c = Date.today();
        if (recordTypeId != null) {
            acct.RecordTypeId = recordTypeId;
        }

        return acct;
    }
    

    static PriceBook2 CreatePriceBook(string name, string description) {

        PriceBook2 pb = new PriceBook2();
        pb.Name = name;
        pb.Description = description;

        return pb;
    } 

    static public SAP_Order__c CreateOrder(string sku, decimal quantity, string accountNum, string varNum, string soldToNum, string PAKID, 
                                    Date startDate, Date endDate, string renewEntID, string renewPAK, string serialNum, string entID) {

        SAP_Order__c ord = new SAP_Order__c();
        ord.Product_SKU__c = sku;
        ord.Quantity__c = quantity;
        ord.SAP_Account__c = accountNum;
        ord.VAR__c = varNum;
        ord.Sold_To_Partner__c = soldToNum;
        ord.SAP_PAK_ID__c = PAKID;
        ord.Start_Date__c = startDate;
        ord.End_Date__c = endDate;
        ord.Renewed_Entitlement_ID__c = renewEntID;
        ord.Renewed_PAK_ID__c = renewPAK;
        ord.Hardware_Serial_Number__c = serialNum;
        ord.Entitlement_ID__c = entID;
        ord.ENTITL_EXT_ID__c = entID;                                

        return ord;
    }

        // 711-GVPCP1   GRID vPC Perpetual License, 1 CCU: 711-GVPCP0, 711-GVAPP1
        // 711-GVPCP0   GRID vPC Perpetual License Comp, 1 CCU
        // 711-GVWSP1   GRID vWS Perpetual License, 1 CCU: 711-GVWSP0,  711-GVAPP1
        // 711-GVWSP0   GRID vWS Perpetual License Comp, 1 CCU
        // 711-GVPCS1   GRID vPC Subscription License, 1 CCU: 711-GVPCS0, 711-GVAPS1
        // 711-GVPCS0   GRID vPC Subscription License Comp, 1 CCU
        // 711-GVAPS1   GRID vApps Subscription License, 1 CCU
        // 711-GVWS1    GRID vWS Subscription License, 1 CCU: 711-GVWS0, 711-GVAPS1
        // 711-GVWS0    GRID vWS Subscription License Comp, 1 CCU
        // 712-GVAPM1   GRID vApps SUMS 1 CCU
        // 712-GVPCM1   GRID vPC SUMS 1 CCU
        // 712-GVWSM1   GRID vWS SUMS 1 CCU
        // 718-22787A   8-GPU/512GB DGX-1 System Support
        // 711-GVAPP1   GRID vApps Perpetual License

    static public void CreateTestProducts() {
        
        List<PriceBook2> pbooks = new List<PriceBook2>();
        pbooks.Add(CreatePriceBook(Label.CPQ_Price_Book_Name, 'Test Price Book'));
        
        insert pbooks;

        List<Product2> products = new List<Product2>();
        products.Add(CreateProduct('711-GVPCP1'));
        products.Add(CreateProduct('711-GVPCP0'));
        products.Add(CreateProduct('711-GVWSP1'));
        products.Add(CreateProduct('711-GVWSP0'));
        products.Add(CreateProduct('711-GVPCS1'));
        products.Add(CreateProduct('711-GVPCS0'));
        products.Add(CreateProduct('711-GVAPS1'));
        products.Add(CreateProduct('711-GVWS1'));
        products.Add(CreateProduct('711-GVWS0'));
        products.Add(CreateProduct('712-GVAPM1'));
        products.Add(CreateProduct('712-GVPCM1'));
        products.Add(CreateProduct('712-GVWSM1'));
        products.Add(CreateProduct('718-22787A'));
        products.Add(CreateProduct('711-GVAPP1'));

        Insert products;
    }

    static Map<string, Id> CreateProductMap() {

        Map<string, Id> pMap = new Map<string, Id>();
        List<Product2> products = [SELECT Id, ProductCode FROM Product2];

        for (Product2 prod: products) {

            pMap.put(prod.ProductCode, prod.Id);

        }

        return pMap;
    }

    @testSetup public static void CreateTestOrders() {

        CreateTestProducts();

        List<Account> accounts = new List<Account>();
        accounts.add(CreateAccount('Acme', 'SAP001', '', 'New Customer Account'));
        accounts.add(CreateAccount('Sesame', 'SAP034', '', 'New Customer Account'));
        accounts.add(CreateAccount('VAR', 'SAP010', 'Solution Provider', 'NPN Account Registry'));
        accounts.add(CreateAccount('Sold To', 'SAP020', '', 'New Customer Account'));

        insert accounts;

        // three orders (3 PAK IDs)
        // a bundle and a single subscription for one
        // the other two have one subscription each, one a bundle and the other a single, respectively
        List<SAP_Order__c> orders = new List<SAP_Order__c>();
        Date startDate = date.newinstance(2018, 2, 01);
        Date endDate = date.newinstance(2019, 1, 31);
        // (sku, quantity, accountNum, varNum, soldToNum, PAKID, startDate, endDate, renewEntID, renewPAK, serialNum, entID
        orders.add(CreateOrder('711-GVPCS1', 4, 'SAP034', 'SAP010', 'SAP020', 'PK-23883', startDate, endDate, '10000008', 'PAK0001', '', '10000009')); 
        orders.add(CreateOrder('712-GVAPM1', 1, 'SAP034', 'SAP010', 'SAP020', 'PK-23883', startDate, endDate, '', '', '', '10000019'));
        orders.add(CreateOrder('711-GVWS1', 2, 'SAP001', 'SAP010', 'SAP020', 'PK-23822', startDate, endDate, '10000018', 'PAK0001', '', '10000018')); 
        orders.add(CreateOrder('712-GVAPM1', 3, 'SAP001', 'SAP010', 'SAP020', 'PK-23793', startDate, endDate, '10000028', 'PAK0001', '', '10000028'));

        insert orders;
    }


    public static void CreateTestOpportunities() {

        List<SAP_Order__c> orders = GetOrders();

        QuoteGeneratorHelper.productMap = QuoteGeneratorHelper.GetQuoteProducts(orders);

        QuoteGeneratorHelper.CreatePAK_ID_AccountMap(orders);

        QuoteGeneratorHelper.createdOpportunities = QuoteGeneratorHelper.CreateOpportunitiesFromOrders();

        QuoteGeneratorHelper.updatedOrders = QuoteGeneratorHelper.LinkOrdersWithOpportunity(orders);

    }

    public static void CreateQuotesAndProductMap() {

        QuoteGeneratorHelper.oppQuoteMap = QuoteGeneratorHelper.CreateQuotesFromOpportunities(QuoteGeneratorHelper.updatedOrders);
        QuoteGeneratorHelper.pOptions = QuoteGeneratorHelper.CreateProductOptionMap(QuoteGeneratorHelper.productMap.values());

    }

    public static List<SAP_Order__c> GetOrders() {

        List<SAP_Order__c> orders = [SELECT Id, Changed_Date__c, CreatedById, CreatedDate, Created_Date__c, IsDeleted,
                                     Description__c, End_Date__c, Entitlement_ID__c, Entitlement_Type__c, Hardware_PAK_ID__c,
                                     Hardware_Serial_Number__c, LastModifiedById, LastModifiedDate, Opportunity__c, OwnerId,
                                     Product_SKU__c, Quantity__c, ConnectionReceivedId, Renewed_Entitlement_ID__c,
                                     Renewed_PAK_ID__c, SAP_Account__c, SAP_Delivery__c, Name, SAP_PAK_ID__c,
                                     ConnectionSentId, Serial_Entitlement_ID__c, Sold_To_Partner__c, Start_Date__c,
                                     Status_Flag__c, Subscription_ID__c, Subscription_Term__c, SystemModstamp,
                                     Unit_of_Measure__c, VAR__c, ENTITL_EXT_ID__C
                                     FROM SAP_Order__c];

        return orders;

    }
    
    static testMethod void TestPopulateOpportunity() {

        Test.startTest();

        CreateTestOpportunities();

        Test.stopTest();

        List<Opportunity> opps = [SELECT Sold_To__r.Name, NPN_Solution_Provider_VAR__r.Name, Pricebook2Id FROM Opportunity];
        Id pbId = [SELECT Name, Description FROM PriceBook2 Where Name = :Label.CPQ_Price_Book_Name].Id;

        System.assertEquals(3, opps.size(), 'Three opportunities created');
        System.assertEquals('VAR', opps[0].NPN_Solution_Provider_VAR__r.Name, 'NPN Solution Provider VAR populated');
        System.assertEquals('Sold To', opps[0].Sold_To__r.Name, 'NPN Solution Provider VAR populated');
        System.assertEquals(pbId, opps[0].Pricebook2Id, 'Pricebook populated');

        List<SAP_Order__c> testOrders = [SELECT Id, Opportunity__r.Name FROM SAP_Order__c WHERE SAP_PAK_ID__c = 'PK-23883'];

        System.assertEquals(2, testOrders.size(), 'Correct number of orders created');
        System.assertEquals('PK-23883', testOrders[0].Opportunity__r.Name, 'Opportunity name has been set');
        
    }

    static testMethod void TestLinkOrdersWithOpportunity() {

        Test.startTest();

        CreateTestOpportunities();

        Test.stopTest();

        System.assertEquals(3, QuoteGeneratorHelper.PAK_ID_AccountMap.size(), 'PAK_ID_AccountMap created');

        List<Opportunity> opps = [SELECT Name FROM Opportunity];

        System.assertEquals(3, opps.size(), 'Three opportunities created');

        List<SAP_Order__c> testOrders = [SELECT Id, Opportunity__r.Name FROM SAP_Order__c WHERE SAP_PAK_ID__c = 'PK-23883'];

        System.assertEquals(2, testOrders.size(), 'Correct number of orders created');
        System.assertEquals('PK-23883', testOrders[0].Opportunity__r.Name, 'Opportunity name has been set');

    }

    static testMethod void TestCreateQuotesFromOpportunities() {

        Test.startTest();

        CreateTestOpportunities();

        CreateQuotesAndProductMap();

        Test.stopTest();

        List<SBQQ__Quote__c> quotes = [SELECT Id, SBQQ__StartDate__c, SBQQ__Primary__c, SBQQ__SubscriptionTerm__c FROM SBQQ__Quote__c];

        System.assertEquals(3, quotes.size(), 'Three quotes created');
        System.assertEquals(date.newinstance(2018, 2, 01), quotes[0].SBQQ__StartDate__c, 'Start date is initialized');
        System.assertEquals(true, quotes[0].SBQQ__Primary__c, 'Quote 1 is primary');
        System.assertNotEquals(null, quotes[0].Id, 'Quote Id is assigned');

    }

    static testMethod void TestCreateOneQuoteOneQuoteLine() {

        Test.startTest();

        List<SAP_Order__c> orders = GetOrders();
        
        List<SAP_Order__c> firstOrder = new List<SAP_Order__c>();
        
        firstOrder.Add(orders[0]);

        QuoteGeneratorHelper.createQuotes(firstOrder);

        Test.stopTest();

        integer rows = [SELECT COUNT() FROM SBQQ__QuoteLine__c];

        System.assertEquals(1, rows, '1 quote line created');
        
        List<SBQQ__QuoteLine__c> lines = [SELECT Entitlement_ID__c, Renewed_Entitlement_ID__c, SAP_Order__c FROM SBQQ__QuoteLine__c];
 
        System.assertEquals('10000009', lines[0].Entitlement_ID__c, 'The correct entitlement id is assigned');
        System.assertEquals('10000008', lines[0].Renewed_Entitlement_ID__c, 'The correct renewal entitlement id is assigned');
                      
        System.assertEquals(orders[0].Id, lines[0].SAP_Order__c, 'SAP order lookup is assigned');
        
    }

    static testMethod void TestCreateSingleQuote10QuoteLines() {

        Test.startTest();

        List<SAP_Order__c> orders = GetOrders();
        
        List<SAP_Order__c> additionalOrders = new List<SAP_Order__c>();
        
        SAP_Order__c ord = orders[0];
        
        for (Integer i = 0; i < 10; i++) {
            additionalOrders.add(CreateOrder( ord.Product_SKU__c, ord.Quantity__c, ord.SAP_Account__c, ord.VAR__c, ord.Sold_To_Partner__c,
                                             ord.SAP_PAK_ID__c, ord.Start_Date__c, ord.End_Date__c, 
                                             ord.Renewed_Entitlement_ID__c, ord.Renewed_PAK_ID__c, ord.Hardware_Serial_Number__c,
                                             ord.Entitlement_ID__c + Integer.valueOf(i)));
        }
        
        insert(additionalorders);

        QuoteGeneratorHelper.createQuotes(additionalOrders);

        Test.stopTest();

        integer rows = [SELECT COUNT() FROM SBQQ__QuoteLine__c];

        System.assertEquals(10, rows, '10 quote lines created');
        
    }
    
    static testMethod void TestPopulateRenewalEntitlementAndRenewalPAKID() {

        Test.startTest();

        List<SAP_Order__c> orders = GetOrders();
        
        List<SAP_Order__c> firstOrder = new List<SAP_Order__c>();
        
        firstOrder.Add(orders[1]); // take the second order with no renewal entitlement id

        QuoteGeneratorHelper.createQuotes(firstOrder);

        Test.stopTest();
        
        System.assertEquals(null, orders[1].Renewed_Entitlement_ID__c, 'Renewal entitlement starts out blank'); 
        System.assertEquals(null, orders[1].Renewed_PAK_ID__c, 'Renewal PAK starts out blank'); 
        
        List<SBQQ__QuoteLine__c> lines = [SELECT Renewed_Entitlement_ID__c, Renewed_PAK_ID__c FROM SBQQ__QuoteLine__c];
 
        System.assertEquals('10000019', lines[0].Renewed_Entitlement_ID__c, 'The correct renewal entitlement id is assigned');
        System.assertEquals('PK-23883', lines[0].Renewed_PAK_ID__c, 'The correct renewal PAK id is assigned');
        
    }
    
}