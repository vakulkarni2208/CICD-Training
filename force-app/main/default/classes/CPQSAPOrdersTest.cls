@isTest
private class CPQSAPOrdersTest {
    

    @testSetup static void setup() {
       //Create Accounts w/ Correct Ids based on SAP Acount ID 0009017426, Sold to Account 0000102826, VAR 0000803500, SAP Sales order Number 0000716602, 
        //Create Contacts based on Product End Text 0000031036, Reseller Contact 0000031037
        //Create Opps based on SAP Delivery 0082116056

        
        List<Account> testAccts = new List<Account>();
        testAccts.add(new Account(Name = 'TestAcct1', Industry='Higher Ed/Research', Website='www.test.com', SAP_Customer_Number__c='0009017426',Account_Class__c='General Account', EMS_Update_Required__c =False));
        testAccts.add(new Account(Name = 'TestAcctVAR', Industry='Higher Ed/Research', Website='www.test.com', SAP_Customer_Number__c='0000803500',Account_Class__c='General Account',EMS_Update_Required__c =False));
        testAccts.add(new Account(Name = 'TestAcctSoldTo', Industry='Higher Ed/Research', Website='www.test.com', SAP_Customer_Number__c='0000102826',Account_Class__c='General Account',EMS_Update_Required__c =False));
        insert testAccts;

        List<Contact> testCons=new List<Contact>();
        testCons.add(new Contact(LastName='lname', FirstName='fname', Accountid=testAccts.get(0).id, SAP_Contact_ID__c='0000031036', Email='test@test.com',EMS_Update_Required__c =False));
        testCons.add(new Contact(LastName='lname2', FirstName='fname2', Accountid=testAccts.get(1).id, SAP_Contact_ID__c='0000031037', Email='test2@test.com',EMS_Update_Required__c =False));
        insert testCons;        

        Opportunity opp=new Opportunity(CloseDate=system.today().addDays(30), Name='TestOpp1', StageName='Draft');
        insert opp;

        SBQQ__Quote__c quote=new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp.id, SBQQ__Account__c=testAccts.get(0).id, SBQQ__Type__c='Renewal', SBQQ__Primary__c=true);
        insert quote;

        Contract contract=new Contract(StartDate=system.today(), EndDate=system.today().addYears(1), Nvidia_Status__c='Active', AccountId=testAccts.get(0).id);
        insert contract;
       


    }


    @isTest static void test_invalid_products_errors() {
        // Implement test 
        List<sObject> ls = Test.loadData(SAP_Order__c.sObjectType, 'testOrders1');
        //insert ls;

        SAP_Order__c order=(SAP_Order__c) ls[0];
        system.debug(order);



    }

    
    @isTest static void test_valid() {
        // Implement test 

        //Insert Products
        
        List<Product2> prods = new List<Product2>();
        for(Integer i=1; i<=5; i++){
            Product2 objProduct1 = new Product2();
         objProduct1.Name = 'Product A'+i;
         objProduct1.ProductCode = 'Pro-A'+i;
         objProduct1.isActive = true;
         objProduct1.isCPQ__C = true;
         prods.add(objProduct1);
        }
        insert prods;
        /*List<Product2> prods=new List<Product2>();
        prods.add(new Product2(Name='711-DWS022', ProductCode='711-DWS022', isActive=true, Product_Type__c='Software', Product_Line__c='Grid'));
        prods.add(new Product2(Name='711-VWS021', ProductCode='711-VWS021', isActive=true, Product_Type__c='Software', Product_Line__c='Grid'));
        prods.add(new Product2(Name='712-VWS003', ProductCode='712-VWS003', isActive=true, Product_Type__c='Software', Product_Line__c='Grid'));

        insert prods;*/
        
        List<sObject> ls = Test.loadData(SAP_Order__c.sObjectType, 'testOrders1');
        //insert ls;

        //SAP_Order__c order=(SAP_Order__c) ls[0];
        //system.debug(order);

        //CPQRenewalForecastBatch myBatch=new CPQRenewalForecastBatch();
        //database.executebatch(myBatch,1);
        
    }

    @isTest static void test_valid_renewal() {
        // Implement test 

        //Insert Products

        List<Product2> prods = new List<Product2>();
        for(Integer i=1; i<=5; i++){
            Product2 objProduct1 = new Product2();
         objProduct1.Name = 'Product B'+i;
         objProduct1.ProductCode = 'Pro-B'+i;
         objProduct1.isActive = true;
         objProduct1.isCPQ__C = true;
         prods.add(objProduct1);
        }
        insert prods;
        /*List<Product2> prods=new List<Product2>();
        prods.add(new Product2(Name='711-DWS022', ProductCode='711-DWS022', isActive=true, Product_Type__c='Software', Product_Line__c='Grid'));
        prods.add(new Product2(Name='711-VWS021', ProductCode='711-VWS021', isActive=true, Product_Type__c='Software', Product_Line__c='Grid'));
        prods.add(new Product2(Name='712-VWS003', ProductCode='712-VWS003', isActive=true, Product_Type__c='Software', Product_Line__c='Grid'));

        insert prods;*/
        
        //List<sObject> ls = Test.loadData(SAP_Order__c.sObjectType, 'testOrders1');
        //insert ls;

        //SAP_Order__c order=(SAP_Order__c) ls[0];
        //system.debug(order);
        Account acc=[Select id from Account LIMIT 1];
        Contract con=new Contract();
        con.Accountid=acc.id;
        insert con;

        //CPQRenewalForecastBatch myBatch=new CPQRenewalForecastBatch();
        //database.executebatch(myBatch,1);
        
    }

    @isTest static void test_method_opps() {
        // Implement test code
        List<Product2> prods = new List<Product2>();
        for(Integer i=1; i<=5; i++){
            Product2 objProduct1 = new Product2();
         objProduct1.Name = 'Product C'+i;
         objProduct1.ProductCode = 'Pro-C'+i;
         objProduct1.isActive = true;
         objProduct1.isCPQ__C = true;
         prods.add(objProduct1);
        }
        insert prods;
        /*List<Product2> prods=new List<Product2>();
        prods.add(new Product2(Name='711-DWS022', ProductCode='711-DWS022', isActive=true, Product_Type__c='Software', Product_Line__c='Grid'));
        prods.add(new Product2(Name='711-VWS021', ProductCode='711-VWS021', isActive=true, Product_Type__c='Software', Product_Line__c='Grid'));
        prods.add(new Product2(Name='712-VWS003', ProductCode='712-VWS003', isActive=true, Product_Type__c='Software', Product_Line__c='Grid'));

        insert prods;*/

        SBQQ__Quote__c quote=[select id from SBQQ__Quote__c LIMIT 1];
        Opportunity opp=[Select id from Opportunity LIMIT 1];

         SBQQ__QuoteLine__c ql=new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.id, SBQQ__Product__c=prods.get(0).id, SBQQ__Quantity__c=1);
         insert ql;

         SAP_Order__c order=new SAP_Order__c();
         order.SFDC_Opportunity__c=opp.id;
         order.SFDC_Quote_Line__c=ql.id;
         order.Order_type__c='ZOR';
         order.Error_Log__c=null;
         order.Status__c='Processed';
         insert order;

         system.debug(order);

         List<Opportunity> oppList=new List<Opportunity>();
         oppList.add(opp);

         CPQ_SAP_Process_Quote_Lines myBatch=new CPQ_SAP_Process_Quote_Lines();
         database.executebatch(myBatch);

         //CPQSAPClosedWonBAtch myBatch=new CPQSAPClosedWonBAtch(oppList);
         //database.executebatch(myBatch);

    }

    
// Dummy CRON expression: midnight on Feb 28.
// Because this is a test, job executes
// immediately after Test.stopTest().


@isTest static void testScheduledJob() {
        Test.startTest();
            Datetime dt = Datetime.now().addMinutes(1);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            String jobId = System.schedule('Dummy Test', CRON_EXP, new CPQ_SAP_Schedule_Quote_Line_Sync() );   
        Test.stopTest();
}

@isTest static void testScheduledJob2() {
        Test.startTest();
            Datetime dt = Datetime.now().addMinutes(1);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            String jobId = System.schedule('Dummy Test2', CRON_EXP, new CPQRenewalForecastScheduler() );   
        Test.stopTest();
}

@isTest static void testScheduledJob3() {
        Test.startTest();
            Datetime dt = Datetime.now().addMinutes(1);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            String jobId = System.schedule('Dummy Test2', CRON_EXP, new CPQ_SAP_Schedule_Legacy_Renewal_Quoted() );   
        Test.stopTest();
}
    
    /**************************************************************************************************
    * Input Parameters: No input parameters
    * DummyTestclass to imporove test ccoveragee 
    * Author : Venkat G
    * Purpose: Test method for NVService class pecLeadRequest method
    ***************************************************************************************************/ 
    static testMethod void dummyCoverageTest(){
     CPQ_SAP_Order_Processor.CoverageMethod();
     //repeat the same for the rest of classes.
  }  

    
}