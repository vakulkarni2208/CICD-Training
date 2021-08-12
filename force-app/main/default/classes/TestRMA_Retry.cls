/**************************************************************************************************
* Name       : TestRMA_Retry
* Purpose    : Test class for Batch Job to retry failed RMA records. 
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 1/5/2017        | Initial Draft
*Akhilesh Gupta     | 2.0        | 08/15/2018      | Code Formatting changes and Fix for CPQ 2.0
*Akhilesh Gupta     | 3.0        | 08/18/2018      | Use Common utility functions.
Note: Need to remove commented code in next cleanup
*  Akhilesh Gupta     | 04/07/2019      | Remove Code related to RMA Retry Job, only keeping contructor call
**************************************************************************************************/

@isTest
public class TestRMA_Retry {
	
	@isTest
    public static void TestRMARetry() {
    	RMA_Retry r = new RMA_Retry();
    }
    /*@isTest
    public static void RetryHappyPath(){
        
        String query = PRFT_DomainLayer.buildQueryFields('RMA__c','','Select ');
        List<RMA__c> lstRMA =  Database.query(query);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.Class, new TestCalloutMock('RMA'));
        RMA_Retry rmaRetry = new RMA_Retry();
        Database.BatchableContext     bc;
        System.runAs(new User(Id=UserInfo.getUserId())){
            rmaRetry.start(bc);
            rmaRetry.execute(bc,lstRMA);
            rmaRetry.finish(bc);
        }
        Test.stopTest();
               
        lstRMA =  Database.query(query);
        Set<String> rmaSAPNumber = new Set<String>();
        for(RMA__c rma :lstRMA){
            rmaSAPNumber.add(rma.SAP_RMA_Number__c);
        }
		System.assert(rmaSAPNumber.contains('100'));
		
	}
    
    @isTest
    public static void RetrySadPath(){
        
        String query = PRFT_DomainLayer.buildQueryFields('RMA__c','','Select ');
        List<RMA__c> lstRMA =  Database.query(query);
        Test.startTest();
        Test.setMock(HttpCalloutMock.Class, new TestCalloutMock(''));
        RMA_Retry rmaRetry = new RMA_Retry();
        rmaRetry = new RMA_Retry();
        Database.BatchableContext     bc;
        System.runAs(new User(Id=UserInfo.getUserId())){
            rmaRetry.start(bc);
            rmaRetry.execute(bc,lstRMA);
            rmaRetry.finish(bc);
        }
        Test.stopTest();
        
        lstRMA =  Database.query(query);
        Set<String> rmaSAPNumber = new Set<String>();
        for(RMA__c rma :lstRMA){
            rmaSAPNumber.add(rma.SAP_RMA_Number__c);
        }
		System.assert(!rmaSAPNumber.contains('100'));
		
	}
    
    @testsetup
    public static void setup(){
        Date startDate = date.newInstance(System.now().year(), System.now().month(), System.now().day());
        Date endDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        
        //Account creation
        Account acc = new Account(Name ='Test Account');
        insert acc;
        
        //Opportunity creation
        Opportunity oppt = new Opportunity();
        oppt.Name = 'NAME';
        oppt.StageName = 'Discovery';
        oppt.AccountId = acc.Id;
        oppt.CloseDate = Date.today();
        insert oppt;
        
		//Contract creation
        Contract contract = new Contract();
        contract.AccountId = acc.Id;
        contract.Status ='Draft';
        contract.StartDate = startDate;
        //contract.SBQQ__Opportunity__c=oppt.Id;
        insert contract;
        //Activate contract
        contract.Status = 'Activated';
        update contract;
        
        //Product creation
        Product2 product = new Product2(Name ='Test Product', Family='DGX-1 Pascal Product Family');
        insert product;
        
        //Subscription creation and implicit Entitlement creation
        SBQQ__Subscription__c subscription1 = new SBQQ__Subscription__c
            (SBQQ__Account__c = acc.Id, SBQQ__Product__c =product.Id,
             SBQQ__Contract__c = contract.Id , SBQQ__Quantity__c =2,
             Hardware_Serial_Number__c ='Serial111',SBQQ__SubscriptionStartDate__c =startDate,
            SBQQ__SubscriptionEndDate__c = endDate);
        insert subscription1;
		
        //Contact creation
		Contact con = new Contact();
        con.firstName = 'firstName';
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
        con.Synced_IDM_DGX__c = false;
        
        insert con;

        //Case creation
        Entitlement ent =[SELECT Id, Hardware_Serial_Number__c, Status FROM Entitlement];
        Case cas = new Case(EntitlementId = ent.Id,Origin = 'Email', ContactId = con.Id,
                            AccountId = acc.Id,
                            Product_Family__c='DGX-1 Pascal Product Family');
        insert cas;
		
		//RMA Creation        
		List<RMA__c> lstRMA = new List<RMA__c>();
        for(Integer i=0;i<1;i++){
            RMA__C rma = new RMA__c(Case__c = cas.Id,On_site_Contact1_Name__c ='name1',Entitlement__c = ent.Id,
                               Additional_Email_Addresses__c ='t@test.com,t1@test.com');
            lstRMA.add(rma);
        }
        system.debug('lstRMA------------------------------->'+lstRMA);
        insert lstRMA;
		
    }
*/
}