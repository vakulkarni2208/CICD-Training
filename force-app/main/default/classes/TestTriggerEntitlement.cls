/**************************************************************************************************
* Name       : TestTriggerEntitlement
* Purpose    : Test class for TriggerEntitlement Trigger 
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 1/5/2017        | Initial Draft
*Akhilesh Gupta     | 2.0        | 08/15/2018      | Code Formatting changes and Fix for CPQ 2.0
*Akhilesh Gupta     | 3.0        | 08/18/2018      | Use Common utility functions.
*Akhilesh Gupta     | 4.0        | 04/25/2021      | Added new functions for ProductUpgrade and 24x7 support test scenarios.
Note: Need to remove commented code in next cleanup
**************************************************************************************************/
@isTest
public class TestTriggerEntitlement {
    final static String NAME = 'TestTriggerEntitlement';
    
    @testSetup 
    public static void TestUserCreation(){
        Date startDate = date.newInstance(System.now().year(), System.now().month(), System.now().day());
        Date endDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        
        /* NOT REQUIRED AS CODE IS REMOVED FROM TRIGGER HELPER TO USE THIS CUSTOM SETTING
        //RMA visibility custom setting
        RMA_IDM_Visibility__c generalvisibility = new RMA_IDM_Visibility__c(name='General Article',
                                                                            Default__c = true,
                                                                            Permission_Set_Name__c = 'General_Article_Visibility_for_All_Customers');
        insert generalvisibility;
        
        RMA_IDM_Visibility__c DGXVisibility = new RMA_IDM_Visibility__c(name='Entitled DGX Customers',
                                                                        Entitlement_Level__c = true,
                                                                        Permission_Set_Name__c = 'Entitled_DGX_Customers',
                                                                        Product_Family__c ='DGX');
        insert DGXVisibility;
        
        RMA_IDM_Visibility__c GridVisibility = new RMA_IDM_Visibility__c(name='Entitled GRID Customers',
                                                                         Entitlement_Level__c = true,
                                                                         Permission_Set_Name__c = 'Entitled_GRID_Customer',
                                                                         Product_Family__c='Grid');
        insert GridVisibility;
        
        RMA_IDM_Visibility__c DGXProductVisibility = new RMA_IDM_Visibility__c(name='Product DGX Customers',
                                                                        Product_Level__c = true,
                                                                        Permission_Set_Name__c = 'Product_DGX_Customer',
                                                                        Product_Family__c ='DGX');
        insert DGXProductVisibility;
        
        RMA_IDM_Visibility__c GridProductVisibility = new RMA_IDM_Visibility__c(name='Product GRID Customers',
                                                                         Product_Level__c = true,
                                                                         Permission_Set_Name__c = 'Product_GRID_Customer',
                                                                         Product_Family__c='Grid');
        insert GridProductVisibility;
        */
        
        //Account creation
        Account acc = Test_COMM_Factory.getAccount('Test Account');
        insert acc;
        
        //Opportunity creation
        Opportunity oppt    = Test_COMM_Factory.getOpportunity('NAME', acc.Id);
        insert oppt;
        
        //Contract creation
        Contract contract = Test_COMM_Factory.getContract(acc.Id);
        insert contract;
        
        contract.Status = 'Activated';
        update contract;
        
        //Product creation
        Product2 product = Test_COMM_Factory.getProduct('Test Product');
        insert product;
        
        //Create Asset - 
        Asset ast               = Test_COMM_Factory.getAsset(NAME, acc.Id);
        ast.Product2Id          = product.Id;
        ast.SerialNumber        = '123';
        insert ast;
        
        //Contact creation
        List<Contact> lstContact = new List<Contact>();
        for(Integer i=0;i<1;i++){
            Contact con = Test_COMM_Factory.getContact(acc.Id);
            con.Email = 'test37838'+String.valueOf(i)+'@test.com';
            con.IDM_ExternalId__c = acc.Id+'-'+'test37838'+String.valueOf(i)+'@test.com';
            con.is_DGX_Contact__c = true;
            lstContact.add(con);
        }
        insert lstContact;
        
        //User creation with the contacts
        CreateUser();
    }
    
    @future
    public static void CreateUser(){
        List<User> lstUser = new List<User>();
        List<Contact> lstContact = [SELECT Id, firstName, lastName, email, CompanyName__c FROM Contact];
        Set<String> lstEmailIds = new Set<String>();
        for(Contact con:lstContact){
            if(con.email !=null){
                lstEmailIds.add(con.email);
            }
        }
        for(Contact con :lstContact){
            String alias ='';
            if(con.firstName != null && con.firstName.length()>0){
                alias =''+con.FirstName.substring(0,1);
                if(con.LastName.length()>4)
                    alias = alias+con.LastName.substring(con.LastName.length()-4);
            }                    
            else if(con.lastName.length()>4)
                alias = con.LastName.substring(con.LastName.length()-5);
            User user = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name =:System.Label.Profile_for_DGX_Registration].Id,
                contactId = con.Id,
                FirstName = con.firstName,
                LastName = con.lastName,
                Email = con.email,
                Username = con.email,
                CompanyName = con.CompanyName__c,
                Alias = alias,
                is_Created__c = true,
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );
            lstUser.add(user);    
        }
        insert lstUser;
    }
    
    @isTest
    public static void testEntitlement(){
        Date startDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()-7);
        Date endDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()-1);
        Account acc = [SELECT Id FROM Account][0];
        Product2 product = [SELECT Id FROM Product2][0];
        Contract contract = [SELECT Id FROM Contract][0];
        system.debug('AccountId: '+ acc.Id);
        
        Contact con = Test_COMM_Factory.getContact(acc.Id);
        con.Email = 'test31238@test.com';
        con.IDM_ExternalId__c = acc.Id+'-'+'test31238@test.com';
        con.is_DGX_Contact__c = true;
        insert con;
        
        //Creating subscription which creates entitlement with dgx product family
        SBQQ__Subscription__c subscription1 = new SBQQ__Subscription__c
            (SBQQ__Account__c = acc.Id, SBQQ__Product__c =product.Id,
             SBQQ__Contract__c = contract.Id , SBQQ__Quantity__c =2,
             Hardware_Serial_Number__c ='Serial111'
             );
        insert subscription1;
        
        Product2 product2 = new Product2(Name ='GRID K1', Family='GRID Hardware');
        insert product2;
        
        //Creating subscription which creates entitlement with Grid product family
        SBQQ__Subscription__c subscription2 = new SBQQ__Subscription__c
            (SBQQ__Account__c = acc.Id, SBQQ__Product__c =product2.Id,
             SBQQ__Contract__c = contract.Id , SBQQ__Quantity__c =2,
             Hardware_Serial_Number__c ='Serial111'
             );
        insert subscription2;
        
        product2 =[SELECT Id, Name , Family FROM Product2 WHERE Name='GRID K1' AND Family='GRID Hardware'];
        product2.Family ='DGX-1 Pascal Product Family';
        update product2;
        
        //Changing product family of subscription1 from dgx to grid
        SBQQ__Subscription__c subscriptionupdate = new SBQQ__Subscription__c
            (Id = subscription1.Id, SBQQ__Product__c = product2.Id);
        update subscriptionupdate;
        
        //Create Entitlement - 
        //Entitlement ent  = Test_COMM_Factory.getEntitlement(NAME,acc.id);
        //insert ent;
        
        //Create Entitlement - 
        Entitlement Ent                 = Test_COMM_Factory.getEntitlement(NAME, acc.Id);
        Ent.Hardware_Serial_Number__c   = '123';
        //Ent.PAK_ID__c                 = '12345';
        Ent.Service_product__c          = product.Id;
        Ent.customer_contact__c          = con.id;
        //Ent.Link_Asset                = Link Asset;
        //Ent.EndDate                   = Date.today();
        //Ent.StartDate                 = Date.today().addDays(-1);
        insert Ent;
        List<Entitlement> lstEnt = new List<Entitlement>();
        lstEnt.add(Ent);
        TriggerEntitlementHelper.checkSupportPortalRegistration(lstEnt);            
        List<Entitlement> lstEntitlement = [SELECT Id, Status FROM Entitlement];
        for(Entitlement entit :lstEntitlement){
            entit.startDate = startDate;
            entit.EndDate = EndDate;
        }
        update lstEntitlement;
        
        lstEntitlement = [SELECT Id, Status FROM Entitlement];
        for(Entitlement entit :lstEntitlement){
            entit.startDate = System.today();
            entit.EndDate = System.today()+7;
        }
        update lstEntitlement;
        
        list<Id> accIdSet = new list<Id>();
        accIdSet.add(acc.Id);
        ESP_ReEvaluateEntitlementProcess.reEvaluateEntitlementProcess(accIdSet);
        TriggerEntitlementHelper.ESPContactNVIDIARenewalsButton('test','test');
    } 

    @isTest
    public static void testProductUpgrade(){
        Date startDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()-7);
        Date endDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        Account acc = [SELECT Id FROM Account][0];
        Product2 product = [SELECT Id FROM Product2][0];
        Contract contract = [SELECT Id FROM Contract][0];
        
        //Creating subscription which creates entitlement with dgx product family
        SBQQ__Subscription__c subscription1 = new SBQQ__Subscription__c
            (SBQQ__Account__c = acc.Id, SBQQ__Product__c =product.Id,
             SBQQ__Contract__c = contract.Id , SBQQ__Quantity__c =2,
             Hardware_Serial_Number__c ='12354'
             );
        insert subscription1;
        
        Product2 NewProd = new Product2(Name ='GRID K1', Family='GRID Hardware');
        insert NewProd;
        
        Product2 OldProd = new Product2(Name ='GRID K1', Family='GRID Hardware', Upgrade_Product__c = NewProd.Id);
        insert OldProd;
        
        Product2 UpgradeProd = new Product2(Name ='GRID K1', Family='GRID Hardware', ProductCode = '718-A180I1');
        insert UpgradeProd;
        
        //Create Entitlement - 
        Entitlement OldEnt                      = Test_COMM_Factory.getEntitlement(NAME, acc.Id);
        OldEnt.Hardware_Serial_Number__c        = '12354';
        OldEnt.Service_product__c               = OldProd.Id;
        OldEnt.Subscription__c                  = subscription1.Id;
        OldEnt.startDate                        = startDate;
        OldEnt.EndDate                          = EndDate;
        insert OldEnt;
        
        Entitlement NewEnt                      = Test_COMM_Factory.getEntitlement(NAME, acc.Id);
        NewEnt.Hardware_Serial_Number__c        = '12354';
        NewEnt.Service_product__c               = UpgradeProd.Id;
        NewEnt.Subscription__c                  = subscription1.Id;
        NewEnt.startDate                        = startDate;
        NewEnt.EndDate                          = EndDate;
        insert NewEnt;
                    
        Entitlement EntChk= [SELECT Id, Product_Upgrade_Entitlement__c, Status FROM Entitlement where Id =: NewEnt.Id];
        System.assertEquals(True, EntChk.Product_Upgrade_Entitlement__c);  
    }     
    
    @isTest
    public static void testBussinessCritical(){
        Date startDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()-7);
        Date endDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        Account acc = [SELECT Id FROM Account][0];
        Product2 product = [SELECT Id FROM Product2][0];
        Contract contract = [SELECT Id FROM Contract][0];
        
        //Creating subscription which creates entitlement with dgx product family
        SBQQ__Subscription__c subscription1 = new SBQQ__Subscription__c
            (SBQQ__Account__c = acc.Id, SBQQ__Product__c =product.Id,
             SBQQ__Contract__c = contract.Id , SBQQ__Quantity__c =2,
             Hardware_Serial_Number__c ='Serial111'
             );
        insert subscription1;
        
        Product2 NewProd = new Product2(Name ='GRID K1', Family='GRID Hardware', Support_level__c= ESP_Utility.ESPConstants.SLA_24X7SUPPORT, SLA_Scope__c = ESP_Utility.ESPConstants.SLA_Settings.SLA_By_SN_Label__c);
        insert NewProd;
        
        Product2 OldProd = new Product2(Name ='GRID K1', Family='GRID Hardware', Upgrade_Product__c = NewProd.Id, Support_level__c= ESP_Utility.ESPConstants.SLA_24X7SUPPORT, SLA_Scope__c = ESP_Utility.ESPConstants.SLA_Settings.SLA_By_Product_Line_Label__c);
        insert OldProd;
        
        Product2 UpgradeProd = new Product2(Name ='GRID K1', Family='GRID Hardware', ProductCode = '718-A180I1', Support_level__c= ESP_Utility.ESPConstants.SLA_24X7SUPPORT, SLA_Scope__c = ESP_Utility.ESPConstants.SLA_Settings.SLA_By_SN_Label__c);
        insert UpgradeProd;
        
        //Create Entitlement - 
        Entitlement OldEnt                      = Test_COMM_Factory.getEntitlement(NAME, acc.Id);
        OldEnt.Hardware_Serial_Number__c        = '12354';
        OldEnt.Service_product__c               = OldProd.Id;
        OldEnt.startDate                        = startDate;
        OldEnt.EndDate                          = EndDate;
        insert OldEnt;
        
        Entitlement NewEnt                      = Test_COMM_Factory.getEntitlement(NAME, acc.Id);
        NewEnt.Hardware_Serial_Number__c        = '12354';
        NewEnt.Service_product__c               = UpgradeProd.Id;
        NewEnt.startDate                        = startDate;
        NewEnt.EndDate                          = EndDate;
        insert NewEnt;
                    
        Entitlement EntChk= [SELECT Id, Product_Upgrade_Entitlement__c, Status FROM Entitlement where Id =: NewEnt.Id];
        System.assertEquals(True, EntChk.Product_Upgrade_Entitlement__c);  
        
        NewEnt.EndDate                          = EndDate-7;
        update NewEnt;
    }
}