/**************************************************************************************************
* Name       : TriggerRMAHelper
* Purpose    : Test class for TriggerRMA Trigger 
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 11/15/2017      | Initial Draft
*Perficient         | 1.0        | 1/15/2017       | Final Draft
*Perficient         | 2.0        | Feb 2018        | Testing with 200 RMA
*Perficient         | 3.0        | 3/14/2018       | Fix failure for using Opportunity in Contract
*Akhilesh Gupta     | 4.0        | 08/15/2018      | Code Formatting changes and Fix for CPQ 2.0
*Akhilesh Gupta     | 5.0        | 08/18/2018      | Use Common utility functions.
Note: Need to remove commented code in next cleanup
**************************************************************************************************/
@isTest
public class TestTriggerRMAHelper {
    final static String NAME = 'TestTriggerRMAHelper';
    
    @testsetup
    public static void setup(){
        Date startDate = Date.today(); //date.newInstance(System.now().year(), System.now().month(), System.now().day());
        
        //Account creation
        Account acc     = Test_COMM_Factory.getAccount(NAME);
        insert acc;
        
        //Opportunity creation
        Opportunity opp = Test_COMM_Factory.getOpportunity(NAME, acc.Id);
        insert opp;

        //Contract creation
        Contract contract= Test_COMM_Factory.getContract(acc.Id);
        //contract.SBQQ__Opportunity__c = opp.Id;
        insert contract;
        
        //Activate contract
        contract.Status = 'Activated';
        update contract;
        
        //Product creation
        Product2 product = Test_COMM_Factory.getProduct('Test Product');
        insert product;
        
        //Subscription creation and implicit Entitlement creation
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        //<Change: Need to test with Same serial number for multiple Subscriptions
        for(Integer i = 0; i < 2; i++) {
            SBQQ__Subscription__c subscription = Test_COMM_Factory.getSubscription(acc.Id, product.Id, contract.Id);
            subscription.Hardware_Serial_Number__c = 'Serial111'+i;
                                                
            if(i == 1) 
                subscription.Hardware_Serial_Number__c = 'Update Serial111';//'Serial1110'; //
            subList.add(subscription);
        }
        
        insert subList;
         Asset ast1                     =  Test_COMM_Factory.getAsset(NAME, acc.id);
        ast1.Serial_Number__c       = 'Update Serial111';
        ast1.SerialNumber           = 'Update Serial111';
        ast1.Material_Number__c     = '22222';
        ast1.SAP_PECC_Number__c     = '22222';
        ast1.PAKID__c               = '22222';
        ast1.InstallDate            =  System.today();
        //ast1.ContactId                = con.Id;
        ast1.Street_1__c            = 'Street 1';
        ast1.Street_2__c            = 'Street 2';
        ast1.State__c               = 'State 1';
        ast1.Country__c             = 'India';
        ast1.Postal_Code__c         = '23456';
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
        insert ast1; 
        
        Entitlement Ent = new Entitlement();
        Ent.AccountId = acc.Id;
        Ent.Service_Product__c=product.id;
        Ent.Hardware_Serial_Number__c = 'Update Serial111';
        Ent.Name = 'Serial';
        ent.startDate= System.Today();
        ent.endDate= System.Today();
        ent.Subscription__c=subList[0].id;
        ent.AssetId = ast1.Id;
        insert Ent;
        
        Part__c pt = Test_COMM_Factory.getPart();
        pt.Part_Number__c = '920-200-2500';
        insert pt;
        
        //map<string, Id> map_CUSTOMER_CASE_RT = COMM_Utility.getRTsByName('Case', CaseTriggerHelper.COMM_CASE_RT_DEV_NAME);
        //Case creation
        RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='Case' AND DeveloperName=: CaseTriggerHelper.COMM_CASE_RT_DEV_NAME];
        
        list<Case> caseList = new list<Case>();
        for(Integer i = 0; i < 2; i++) {
            Case cas    = Test_COMM_Factory.getCase(acc.Id, rt.Id);
            //Case cas  = Test_COMM_Factory.getCase(acc.Id, map_CUSTOMER_CASE_RT.get(CaseTriggerHelper.COMM_CASE_RT_DEV_NAME));
            cas.Subject = NAME+i;
            cas.ownerId = UserInfo.getUserId();
            if(Math.mod(i,2)==1)
                cas.Product_category__c='DGX';                
            caseList.add(cas);
        }
        system.debug('12345 before');
        insert caseList;
        system.debug('12345 after'+ caseList);
    }

    @isTest
    public static void TestRMATrigger(){
        Account acct = [SELECT Id FROM Account WHERE Name = :NAME];
        //Entitlement ent =[SELECT Id, Hardware_Serial_Number__c FROM Entitlement];
        system.debug('acct 08152020: '+ acct);
        list<Entitlement> entiList = [SELECT Id, Name,Hardware_Serial_Number__c FROM Entitlement WHERE AccountId = :acct.Id];
        
        system.debug('entiList 08152020: '+ entiList);
        for(Entitlement enti : entiList){
            System.assert(enti.Name.contains('Serial'));
        }

        list<Case> caseList = [SELECT Id, Incident_Status__c FROM Case WHERE AccountId=:acct.Id AND Subject like 'TestTriggerRMAHelper%'];
        //RMA creation        
        list<RMA__c> lstRma = new list<RMA__c>();
        for(Integer i = 0; i < 2; i++) {
            RMA__c rma          = new RMA__c();
            Integer idx         = i/100;
            rma.Entitlement__c  = entiList[idx].Id;
            rma.Case__c         = caseList[i].Id;
            rma.Serial_Number__c= 'Update Serial111';
            rma.On_site_Contact1_Email__c = 'a@a.com';
            rma.Onsite_Contact2_Email__c= 'b@b.com';
            rma.Crm_Complaint_Number__c = 'crm' + i;
            lstRma.add(rma);
        }
        
        Test.startTest();
        
        insert lstRma;
        lstRma=TriggerRMAHelper.getRMAs(lstRma[0].Case__c);
        List<APXTConga4__Conga_Email_Template__c> lstCongaEmail = new List<APXTConga4__Conga_Email_Template__c>();
        APXTConga4__Conga_Email_Template__c conga = new APXTConga4__Conga_Email_Template__c();
        conga.APXTConga4__Name__c = 'CE Dispatch Initial';
        conga.APXTConga4__Template_Group__c = 'CE';
        conga.Email_Ids__c = 'na@na.com';
        lstCongaEmail.add(conga);
        conga = new APXTConga4__Conga_Email_Template__c();
        conga.APXTConga4__Name__c = 'CE Dispatch CALLONE';
        conga.APXTConga4__Template_Group__c = 'CE';
        conga.Email_Ids__c = 'na@na.com';
        lstCongaEmail.add(conga);
        conga = new APXTConga4__Conga_Email_Template__c();
        conga.APXTConga4__Name__c = 'CE Dispatch Information';
        conga.APXTConga4__Template_Group__c = 'CE';
        conga.Email_Ids__c = 'na@na.com';
        lstCongaEmail.add(conga);
        insert lstCongaEmail;
        lstCongaEmail = TriggerRMAHelper.getEmailTemplates();
        string str;
        str = TriggerRMAHelper.initiateDispatch(lstRma,lstCongaEmail.get(0).id);
        str = TriggerRMAHelper.initiateDispatch(lstRma,lstCongaEmail.get(1).id);
        str = TriggerRMAHelper.initiateDispatch(lstRma,lstCongaEmail.get(2).id);
        
        for(Case cas : [SELECT Id,Incident_Status__c FROM Case WHERE ID IN :caseList]){
            System.assertEquals('With RMA', cas.Incident_Status__c);
        }
        //entiList[0].Hardware_Serial_Number__c ='serial';
        //update entiList;
        lstRma = new List<RMA__c>();
        lstRma =[SELECT Id, serial_number__c, Reship_Part_Number__c,additional_email_addresses__c ,RMA_Status__c ,Tracking_Number__c, Entitlement__c, Replacement_Serial_Number__c FROM RMA__c];
        system.debug('lstRma 08152020: '+ lstRma);
        List<RMA__c> lstRmaUpdate = new List<RMA__c>();
        for(Integer i = 0; i < 2; i++) {
            RMA__c tmp = new RMA__c();
            lstRma[i].Replacement_Serial_Number__c  = 'Update' + String.valueOf(i);
            lstRma[i].additional_email_addresses__c = 'abc'+String.valueOf(i)+'@gmail.coma@a.com';
            lstRma[i].Reship_Part_Number__c         = '920-200-2500';
            lstRma[i].Tracking_Number__c            = String.valueOf(i)+String.valueOf(i)+String.valueOf(i)+String.valueOf(i);
            lstRma[i].RMA_Status__c                 = 'INPR';
            lstRma[i].RMA_Status__c                 = 'SHIP';
            lstRma[i].Serial_Number__c              = 'Update Serial111';
            tmp = lstRma[i];
            update tmp;
            //lstRma[i].Entitlement__c              = entiList[0].Id;
        }
        
        Test.stopTest();
        
        for(Case cas : [SELECT Id, Incident_Status__c FROM Case WHERE ID IN :caseList]){
            System.assertEquals('With Engineering + RMA', cas.Incident_Status__c);
        }

        List<Entitlement> entiListUpdated = [SELECT Id, Name, Hardware_Serial_Number__c FROM Entitlement];
        system.debug('Updated Entitlements: '+ entiListUpdated);
        for(Entitlement enti : entiListUpdated){
            //System.assert(!enti.Name.contains('Update'));
        }
        for(SBQQ__Subscription__c subUpdated : [SELECT Hardware_Serial_Number__c FROM SBQQ__Subscription__c WHERE SBQQ__Account__c = :acct.Id]){
            //System.assert(!subUpdated.Hardware_Serial_Number__c.contains('Update'));
        }
        /*
        for(Integer i=0; i<1 ;i++){
            system.assertEquals(lstRma[i].Replacement_Serial_Number__c, 
                                entMap.get(lstRma[i].Entitlement__c).Hardware_Serial_Number__c);
            system.assertEquals(String.valueOf(i), entMap.get(lstRma[i].Entitlement__c).Hardware_Serial_Number__c);
            
        }*/
    }
}