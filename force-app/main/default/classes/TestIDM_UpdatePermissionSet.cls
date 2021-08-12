/**************************************************************************************************
* Name       : TestCalloutMock
* Purpose    : Mock class for WebService Callouts
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 1/16/2018       | Initial Draft
*Perficient         | 1.0        | 1/17/2018       | Final Draft
**************************************************************************************************/

@isTest
public class TestIDM_UpdatePermissionSet {
    
    @testSetup 
    public static void setup(){
        Date startDate = Date.today().addDays(-8);
        Date endDate = Date.today().addDays(-1);
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
        Contract contract  = Test_COMM_Factory.getContract(acc.Id);
        contract.StartDate = startDate;
        //Contract contract = new Contract();
        /*contract.AccountId = acc.Id;
        contract.Status ='Draft';*/
        //contract.SBQQ__Opportunity__c=oppt.Id;
        insert contract;
        contract.Status = 'Activated';
        update contract;
        
        //Product creation
        Product2 product = new Product2(Name ='Test Product', Family='DGX-1 Pascal Product Family');
        insert product;
        
        //Contact creation
        List<Contact> lstContact = new List<Contact>();
        list<Entitlement> lstEntitlement = new list<Entitlement>();
        for(Integer i=0;i<1;i++){
            Contact con = new Contact();
            con.firstName = 'firstName';
            con.lastName = 'lastName';
            con.Email = 'test37838'+String.valueOf(i)+'@test.com';
            con.MailingStreet = 'Street1';
            con.Mailing_Street_2__c = 'Street2';
            con.MailingCity = 'Pittsburgh';
            con.MailingState = 'Punjab';
            con.MailingCountry = 'India';
            con.MailingPostalCode = '15213';
            con.IDM_ExternalId__c = acc.Id+'-'+'test37838'+String.valueOf(i)+'@test.com';
            con.AccountId = acc.Id;
            //con.is_GRID_Contact__c =true;
            con.is_DGX_Contact__c = true;
            lstContact.add(con);
            Entitlement objEnitilement = Test_COMM_Factory.getEntitlement('Entitlement'+i,acc.ID);      
            objEnitilement.service_product__c = product.ID;
            objEnitilement.StartDate = System.today() -14;
            objEnitilement.EndDate = System.today() -7;
            lstEntitlement.add(objEnitilement);
        }
        insert lstEntitlement;
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
        Date startDate = Date.today().addDays(-8);
        Date endDate = Date.today().addDays(-1);
        Account acc = [SELECT Id FROM Account][0];
        Product2 product = [SELECT Id FROM Product2][0];
        Contract contract = [SELECT Id FROM Contract][0];
        
        //Creating subscription which creates entitlement with dgx product family
        List<SBQQ__Subscription__c> lstSubscription = new List<SBQQ__Subscription__c>();
        for(Integer i=0; i<1;i++){
            SBQQ__Subscription__c subscription1 = new SBQQ__Subscription__c
            (SBQQ__Account__c = acc.Id, SBQQ__Product__c =product.Id,
             SBQQ__Contract__c = contract.Id , SBQQ__Quantity__c =2,
             Hardware_Serial_Number__c ='Serial111'+String.valueOf(i),
             SBQQ__SubscriptionEndDate__c =  endDate, SBQQ__SubscriptionStartDate__c = startDate
             );
            lstSubscription.add(subscription1);
        }
        insert lstSubscription;
        
        Test.StartTest();
        
        IDM_UpdatePermissionSet UpdatePermissionSet = new IDM_UpdatePermissionSet();
        UpdatePermissionSet = new IDM_UpdatePermissionSet(true);
        Database.executeBatch(UpdatePermissionSet);
        Test.StopTest();
   }
}