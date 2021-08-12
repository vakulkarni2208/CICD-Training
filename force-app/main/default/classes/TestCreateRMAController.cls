/**************************************************************************************************
* Name       : TestCreateRMAController
* Purpose    : Test class for CreateRMALightningController
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 1/15/2017       | Initial Draft
*Perficient         | 1.0        | 1/17/2017       | Final Draft
*Akhilesh Gupta     | 3.0        | 08/15/2018      | Code Formatting changes and Fix for CPQ 2.0
*Akhilesh Gupta     | 4.0        | 08/18/2018      | Use Common utility functions.
Note: Need to remove commented code in next cleanup 
**************************************************************************************************/
@isTest
public class TestCreateRMAController {
    final static String NAME = 'TestCreateRMAController';
    @isTest
    public static void testRMACreation(){
        Account acct = [SELECT Id FROM Account WHERE Name = :NAME];
        Case cas = [SELECT Id, EntitlementId,Entitlement.AssetId, ContactId, AccountId, Product_Family__c 
                    FROM Case WHERE AccountId=:acct.Id AND EntitlementId != NULL];

        RMA__C rma = new RMA__c(Case__c = cas.Id,On_site_Contact1_Name__c ='name1',Entitlement__c = cas.EntitlementId,
                                Additional_Email_Addresses__c ='t@test.com,t1@test.com',Special_Instructions_to_RMA_Team__c='sp instr',On_site_Contact2_Name__c='con2');
        RMA__C rmaAsset = new RMA__c(Case__c = cas.Id,On_site_Contact1_Name__c ='name1',Entitlement__c = cas.EntitlementId,
                                Additional_Email_Addresses__c ='t@test1122.com,twe1@test.com',asset__c=cas.Entitlement.assetid,Special_Instructions_to_RMA_Team__c='sp instr',On_site_Contact2_Name__c='con2');
        //Case cas1 = new Case(Origin = 'Email', Status='New');
        //insert cas1;
        
        PageReference ref = Page.CreateRMAFormLightning;
        ref.getParameters().put('Id', cas.id);
        ref.getParameters().put('rowIndex', '1');
        Test.setCurrentPage(ref);
        Test.setMock(HttpCalloutMock.Class, new TestCalloutMock('RMA'));
        Test.startTest();
        
        ApexPages.StandardController controller = new ApexPages.StandardController(cas);
        createRMALightningController createRMA = new createRMALightningController(controller);
        createRMA.init();
        createRMA.isUpdateShippingInAsset = true;
        createRMA.isUpdateInstallInAsset = true;
        createRMA.isUpdateShippingInAsset = true;
        
        //Calling controller methods for code coverage
        List<SelectOption> lstquantity = createRMA.quantity;
        List<SelectOption> lstcountries = createRMA.countries;
        //createRMA.reinitialiseRMA();
        createRMA.AddRMArows();
        createRMA.deleteRow();
        createRMA.resetRMArows();
        createRMA.lstRMA.get(0).Quantity =2;
        createRMA.addQuantity();
        createRMA.rma.add(rma);
        createRMA.rma.add(rmaAsset);
        List<SelectOption> lstPart = createRMA.lstRMA.get(0).lstPart;
        //createRMA.addDescription();
        //Inserting RMA
        createRMA.isInstallDetail=false;
        createRMA.SaveRMA();
        
        createRMA.Cancel();
        Test.stopTest();
        List<RMA__c> lstRMA =[SELECT Id FROM RMA__c];
        System.debug('lstRMA after insertion----->'+lstRMA);
        //Verifying RMA creation
        system.assert(lstRMA.size()>1);
    }
    @isTest
    public static void testRMACreationwithoutAsset(){
        Account acct = [SELECT Id FROM Account WHERE Name = :NAME];
        Case cas = [SELECT Id, EntitlementId,Entitlement.AssetId, ContactId, AccountId, Product_Family__c 
                    FROM Case WHERE AccountId=:acct.Id AND EntitlementId != NULL];
        Entitlement ent1 = new Entitlement(Id=cas.EntitlementId,AssetId=null);
        update ent1;
        RMA__C rma = new RMA__c(Case__c = cas.Id,On_site_Contact1_Name__c ='name1',Entitlement__c = cas.EntitlementId,
                                Additional_Email_Addresses__c ='t@test.com,t1@test.com');
        
        PageReference ref = Page.CreateRMAFormLightning;
        ref.getParameters().put('Id', cas.id);
        ref.getParameters().put('rowIndex', '1');
        Test.setCurrentPage(ref);
        Test.setMock(HttpCalloutMock.Class, new TestCalloutMock('RMA'));
        Test.startTest();
        
        ApexPages.StandardController controller = new ApexPages.StandardController(cas);
        createRMALightningController createRMA = new createRMALightningController(controller);
        createRMA.isUpdateShippingInAsset = true;
        createRMA.isUpdateInstallInAsset = true;
        createRMA.isUpdateShippingInAsset = true;
        createRMA.init();
        //Calling controller methods for code coverage
        List<SelectOption> lstquantity = createRMA.quantity;
        List<SelectOption> lstcountries = createRMA.countries;
        //createRMA.reinitialiseRMA();
        createRMA.AddRMArows();
        createRMA.deleteRow();
        createRMA.resetRMArows();
        createRMA.lstRMA.get(0).Quantity =2;
        createRMA.addQuantity();
        createRMA.rma.add(rma);
        createRMA.differentInstallAddress();
        List<SelectOption> lstPart = createRMA.lstRMA.get(0).lstPart;
        //Inserting RMA
        createRMA.SaveRMA();
        
        createRMA.Cancel();
        Test.stopTest();
        List<RMA__c> lstRMA =[SELECT Id FROM RMA__c];
        System.debug('lstRMA after insertion----->'+lstRMA);
        //Verifying RMA creation
        system.assert(lstRMA.size()>1);
    }
    
    @isTest
    public static void testRMACreationCallout(){
        Account acct = [SELECT Id FROM Account WHERE Name = :NAME];
        Case cas = [SELECT Id, EntitlementId, ContactId, AccountId, Product_Family__c 
                    FROM Case WHERE AccountId=:acct.Id AND EntitlementId != NULL];
        
        String query = PRFT_DomainLayer.buildQueryFields('RMA__c','','Select ');
        List<RMA__c> lstRMA =  Database.query(query);
        
        //Setting up Mocking for Test class
        Test.setMock(HttpCalloutMock.Class, new TestCalloutMock('RMA'));
        Test.startTest();
        
        ApexPages.StandardController controller = new ApexPages.StandardController(cas);
        createRMALightningController createRMA = new createRMALightningController(controller);
        createRMA.isUpdateShippingInAsset = true;
        createRMA.isUpdateInstallInAsset = true;
        createRMA.isUpdateShippingInAsset = true;
        
        createRMA.init();
        createRMA.initialistRMAFields();
        createRMA.initialistExistingRMAFields(lstRMA.get(0));
        createRMA.rma.add(lstRMA.get(0));
        system.debug('***'+ lstRMA.get(0));
        createRMA.rmaCallout();
        crmcomplaintproxyresponse crprx = new crmcomplaintproxyresponse();
        crmcomplaintproxyresponse.crmcomplaintproxyResponse_element res = new crmcomplaintproxyresponse.crmcomplaintproxyResponse_element();
        crmcomplaintproxyresponse.RMA_element ele = new crmcomplaintproxyresponse.RMA_element();
        Test.stopTest();
        
        lstRMA =  Database.query(query);
        Set<String> rmaSAPNumber = new Set<String>();
        for(RMA__c rma :lstRMA){
            rmaSAPNumber.add(rma.SAP_RMA_Number__c);
        }
        system.debug('rmaSAPNumber-->'+rmaSAPNumber);
        System.assert(rmaSAPNumber.contains('100'));
        
    }
    
    @testsetup
    public static void setup(){
        //Date startDate = date.newInstance(System.now().year(), System.now().month(), System.now().day());
        //Date endDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        
        //Account creation
        Account acc = Test_COMM_Factory.getAccount(NAME);
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account'];       
        //Account acc = new Account(Name =NAME);
        acc.RecordTypeId = rt.Id;
        insert acc;
        
        //Opportunity creation
        Opportunity oppt    = Test_COMM_Factory.getOpportunity(NAME, acc.Id);
        //Opportunity oppt = new Opportunity();
        /*oppt.Name = 'NAME';
        oppt.StageName = 'Discovery';
        oppt.AccountId = acc.Id;
        oppt.CloseDate = Date.today();*/
        insert oppt;
        
        //Contract creation
        Contract contract       = Test_COMM_Factory.getContract(acc.Id);
        //Contract contract = new Contract();
        /*contract.AccountId = acc.Id;
        contract.Status ='Draft';
        contract.StartDate = startDate;*/
        //contract.SBQQ__Opportunity__c=oppt.Id;
        insert contract;
        
        //Activate contract
        contract.Status = 'Activated';
        update contract;
        
        //Product creation
        Product2 product = Test_COMM_Factory.getProduct('Test Product');
      
        //Product2 product = new Product2(Name ='Test Product', Family='DGX-1 Pascal Product Family');
        insert product;
        //Subscription creation and implicit Entitlement creation
        SBQQ__Subscription__c subscription1 = Test_COMM_Factory.getSubscription(acc.Id, product.Id, contract.Id);
            subscription1.Hardware_Serial_Number__c = 'Serial111';
            //subscription1.SBQQ__SubscriptionStartDate__c = startDate;
            //subscription1.SBQQ__SubscriptionEndDate__c = endDate;
        /*SBQQ__Subscription__c subscription1 = new SBQQ__Subscription__c
            (SBQQ__Account__c = acc.Id, SBQQ__Product__c =product.Id,
             SBQQ__Contract__c = contract.Id , SBQQ__Quantity__c =2,
             Hardware_Serial_Number__c ='Serial111',SBQQ__SubscriptionStartDate__c =startDate,
             SBQQ__SubscriptionEndDate__c = endDate);*/
        insert subscription1;
        
        //Contact creation
        Contact con = Test_COMM_Factory.getContact(acc.Id);
        //Contact con = new Contact();
       /*con.firstName = 'firstName';
        con.lastName = 'lastName';
        con.Email = 'test37838@test.com';
        con.MailingStreet = 'Street1';
        con.Mailing_Street_2__c = 'Street2';
        con.MailingCity = 'Pittsburgh';
        con.MailingState = 'Punjab';
        con.MailingCountry = 'India';
        con.MailingPostalCode = '15213';
        con.IDM_ExternalId__c = acc.Id+'-'+'test37838@test.com';
        con.AccountId = acc.Id;
        con.is_GRID_Contact__c =true;
        con.is_DGX_Contact__c = true;
        con.Synced_IDM_DGX__c = false;*/
        
        insert con;
        Asset ast1                  =  Test_COMM_Factory.getAsset(NAME, acc.id);
        ast1.Serial_Number__c       = 'Update Serial111';
        ast1.SerialNumber           = 'Update Serial111';
        ast1.Material_Number__c     = '22222';
        ast1.SAP_PECC_Number__c     = '22222';
        ast1.PAKID__c               = '22222';
        ast1.InstallDate            =  System.today();
        //ast1.ContactId                = con.Id;
        ast1.Street_1__c            = 'Street 1';
        ast1.Street_2__c            = 'Street 2';
        ast1.State__c               = 'St1';
        ast1.Country__c             = 'CN';
        ast1.Postal_Code__c         = '234 56';
        ast1.City__c                = 'Mumbai';
        ast1.Hostname__c            = 'Host name';
        ast1.Description            = 'Description';
        ast1.Status_Notes__c        = 'Notes one';
        ast1.SAP_Account_Number__c  = '1111';
        ast1.SAP_Delivery_Number__c = '1111';
        ast1.VAR_SAP_Number__c      = '1111';
        ast1.Sold_To_Partner_SAP_Number__c  = '11111';
        ast1.SAP_PECC_Number__c             = '11111';
        ast1.PurchaseDate                   = System.today();
        ast1.Asset_Processing_Status__c     = 'Asset Processed Successfully';
        ast1.Installation_Address_1__c = 'installation_address1__C';
        insert ast1;                     
        //Case creation
        Entitlement Ent = new Entitlement();
        Ent.AccountId = acc.Id;
        Ent.Service_Product__c=product.id;
        Ent.Hardware_Serial_Number__c = 'Serial111';
        Ent.Name = 'Entq1q';
        ent.startDate= System.Today();
        ent.endDate= System.Today();
        ent.assetId=ast1.id;
        insert Ent;
//        Entitlement ent =[SELECT Id, Hardware_Serial_Number__c, Status FROM Entitlement];
        String rtName = CaseTriggerHelper.COMM_CASE_RT_DEV_NAME;
        RecordType caseRT = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=:rtName];
        Case cas    = Test_COMM_Factory.getCase(acc.Id, caseRT.Id);
        cas.EntitlementId = ent.Id;
        cas.Origin = 'Email'; 
        cas.ContactId = con.Id;
        cas.Product_Family__c='DGX-1 Pascal Product Family';
       /* Case cas = new Case(EntitlementId = ent.Id,Origin = 'Email', ContactId = con.Id,
                            AccountId = acc.Id,RecordTypeId = caseRT.Id,
                            Product_Family__c='DGX-1 Pascal Product Family');*/
        insert cas;

        //Part Number creation
        Part__c part = Test_COMM_Factory.getPart();
        part.Part_Number__c='920-22787-2500-000';
        part.Description__c='CRU, FAN DC 12V(92*92*56)';
        part.Component_Part_Name__c ='LINKCOMP2';
        part.Product_Family__c='DGX-1 Pascal Product Family';
        /*Part__c part = new Part__c (Part_Number__c='920-22787-2500-000', Description__c='CRU, FAN DC 12V(92*92*56)', 
                                    Component_Part_Name__c ='LINKCOMP2',
                                    Product_Family__c='DGX-1 Pascal Product Family');*/
        insert part;
        
        //RMA creation        
        RMA__c rma = new RMA__c(Case__c = cas.Id,On_site_Contact1_Name__c ='name1',
                                Entitlement__c = cas.EntitlementId,Country__c = 'CA',Zip_Code__c = '234 56',
                                Additional_Email_Addresses__c ='t@test.com,t1@test.com',
                                Serial_Number__c = '12345678',On_site_Contact2_Name__c='na11 test',Return_Date__c = system.Today()+10,Reship_Date__c=system.Today()+15);
        insert rma;
    }
    
}