/**************************************************************************************************
* Name       : TestTriggerUser
* Purpose    : Test class for TriggerUser
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | 12/13/2017       | Initial Draft
*Perficient         | 1.0        | 1/19/2017        | Final Draft
*Akhilesh Gupta     | 2.0        | 08/15/2018       | Code Formatting changes and Fix for CPQ 2.0
*Akhilesh Gupta     | 3.0        | 08/18/2018       | Use Common utility functions.
*Akhilesh Gupta     | 3.1        | 08/21/2018       | Remove createAccount function.
Note: Need to remove commented code in next cleanup
**************************************************************************************************/
@isTest
public class TestTriggerUser {
    final static String NAME = 'TestTriggerUser';
    
    @testSetup 
    public static void TestUserCreation(){
        RecordType accountRT = [SELECT Id FROM RecordType WHERE SObjectType='Account' AND DeveloperName='New_Customer_Account']; 
        Date startDate = date.newInstance(System.now().year(), System.now().month(), System.now().day());
        Date endDate = date.newInstance(System.now().year(), System.now().month(), System.now().day()+7);
        
        //Adding visibility permissions
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
        Account acc = Test_COMM_Factory.getAccount(NAME);
        //Account acc = createAccount(NAME,accountRT);
        insert acc;
        
        //Opportunity creation
        Opportunity oppt    = Test_COMM_Factory.getOpportunity(NAME, acc.Id);       
       // Opportunity oppt = new Opportunity();
       /* oppt.Name = NAME;
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
        
        //Product creation for DGX Product family
        Product2 product = Test_COMM_Factory.getProduct('Test Product');
        product.family = 'DGX';
        //Product2 product = new Product2(Name ='Test Product', Family='DGX-1 Pascal Product Family');
        insert product;
        
        //Product creation for GRID family
        Product2 product2 = Test_COMM_Factory.getProduct('Test Product');
        product2.family = 'Grid';
        //Product2 product2 = new Product2(Name ='Test Product', Family='GRID Hardware');
        insert product2;
        
        //Subscription creation and implicit Entitlement creation
        SBQQ__Subscription__c subscription1 = Test_COMM_Factory.getSubscription(acc.Id, product.Id, contract.Id);
        subscription1.Hardware_Serial_Number__c = 'Serial111';
        /*SBQQ__Subscription__c subscription1 = new SBQQ__Subscription__c
            (SBQQ__Account__c = acc.Id, SBQQ__Product__c =product.Id,
             SBQQ__Contract__c = contract.Id , SBQQ__Quantity__c =2,
             Hardware_Serial_Number__c ='Serial111');*/
        insert subscription1;
        
        //Contact creation
        List<Contact> lstContact = new List<Contact>();
        list<Entitlement> lstEntitlement = new list<Entitlement>();
        for(Integer i=0;i<10;i++){
            Contact con = Test_COMM_Factory.getContact(acc.Id);
            con.Email = 'test37838'+String.valueOf(i)+'@test.com';
            con.IDM_ExternalId__c = acc.Id+'-'+'test37838'+String.valueOf(i)+'@test.com';
            //Contact con = new Contact();
            /*con.firstName = 'firstName';
            con.lastName = 'lastName';
            con.MailingStreet = 'Street1';
            con.Mailing_Street_2__c = 'Street2';
            con.MailingCity = 'Pittsburgh';
            con.MailingState = 'Punjab';
            con.MailingCountry = 'India';
            con.MailingPostalCode = '15213';
            con.AccountId = acc.Id;*/
            //con.is_GRID_Contact__c =true;
            con.is_DGX_Contact__c = true;
            lstContact.add(con);
            Entitlement objEnitilement = Test_COMM_Factory.getEntitlement('Entitlement'+i,acc.ID);      
            objEnitilement.service_product__c = product.ID;
            lstEntitlement.add(objEnitilement);      
        }
        
        //Account creation
        Account acc2 = Test_COMM_Factory.getAccount(NAME);
        //Account acc2 = createAccount(NAME+'2',accountRT);
        acc2.Name = 'A2' + NAME + String.valueOf(math.random() * 10);
        acc2.BillingState = 'Maharashtra';
        acc2.BillingCity = 'Pune';
        acc2.BillingCountry = 'India';
        acc2.BillingPostalCode = '411006';
        acc2.BillingStreet = 'XYZ Street';
        insert acc2;
        
        //Opportunity creation
        Opportunity oppt2   = Test_COMM_Factory.getOpportunity(NAME, acc.Id);
        //Opportunity oppt2 = new Opportunity();
      /*  oppt2.Name = NAME;
        oppt2.StageName = 'Discovery';
        oppt2.AccountId = acc.Id;
        oppt2.CloseDate = Date.today();*/
        insert oppt2;
        
        //Contract creation
        Contract contract2 = Test_COMM_Factory.getContract(acc2.Id);
        //Contract contract2 = new Contract();
       /* contract2.AccountId = acc2.Id;
        contract2.Status ='Draft';
        contract2.StartDate = startDate;*/
        //contract2.SBQQ__Opportunity__c=oppt2.Id;
        insert contract2;
        //Activate contract
        contract2.Status = 'Activated';
        update contract2;
        
        
        
        //Subscription creation and implicit Entitlement creation
        SBQQ__Subscription__c subscription2 = Test_COMM_Factory.getSubscription(acc2.Id, product2.Id, contract2.Id);
        subscription2.PAK_ID__c = 'Serial112';
        /*SBQQ__Subscription__c subscription2 = new SBQQ__Subscription__c
            (SBQQ__Account__c = acc2.Id, SBQQ__Product__c =product2.Id,
             SBQQ__Contract__c = contract2.Id , SBQQ__Quantity__c =2,
             PAK_ID__c ='Serial112');*/
        insert subscription2;
        
        //Contact creation
        for(Integer i=10;i<20;i++){
            Contact con = Test_COMM_Factory.getContact(acc2.Id);
            con.Email = 'test37838'+String.valueOf(i)+'@test.com';
            con.IDM_ExternalId__c = acc2.Id+'-'+'test37838'+String.valueOf(i)+'@test.com';
            con.is_GRID_Contact__c =true;
            //Contact con = new Contact();
            /*con.firstName = 'firstName';
            con.lastName = 'lastName';
            con.is_Created__c = true;
            con.MailingStreet = 'Street1';
            con.Mailing_Street_2__c = 'Street2';
            con.MailingCity = 'Pittsburgh';
            con.MailingState = 'Punjab';
            con.MailingCountry = 'India';
            con.MailingPostalCode = '15213';
            con.AccountId = acc2.Id;
            con.is_GRID_Contact__c =true;*/
            //con.is_DGX_Contact__c = true;
            lstContact.add(con);
            Entitlement objEnitilement = Test_COMM_Factory.getEntitlement('Entitlement'+i,acc2.ID);      
           /*if(Math.mod(i,2) == 0) 
                objEnitilement.service_product__c = product.ID;
            else 
                objEnitilement.service_product__c = product2.ID;
            */
            objEnitilement.service_product__c = product2.ID;
            lstEntitlement.add(objEnitilement); 
        }
        insert lstEntitlement;
        insert lstContact;
    }
    
    @isTest
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
        system.debug('Before insert User-->'+lstUser);
        insert lstUser;
     
        Test.startTest();
        Map<Id,Contact> Contacts = new Map<Id,Contact>
            ([SELECT Id,is_GRID_Contact__c,is_DGX_Contact__c, Synced_IDM_Grid__c,IDM_GRID_Callout_Message__c,
              Synced_IDM_DGX__c, IDM_DGX_Callout_Message__c FROM Contact 
              WHERE is_GRID_Contact__c =:true OR is_DGX_Contact__c=:true]);
        system.debug('Inserted contacts test class-->'+Contacts);
        lstUser =[select id,isActive from User WHERE contactId =:Contacts.keySet()];
        Set<Id> lstId = new Set<Id>();
        for(User user:lstUser){
            user.isActive =false;
            lstId.add(user.Id);
        }
        update lstUser;
        
        TriggerUserHelper.updateContactForActiveUsers(Contacts.keySet());
        Test.stopTest();
        List<PermissionSetAssignment> assignments = [SELECT Id, PermissionSetId, AssigneeId FROM PermissionSetAssignment
                                                    WHERE AssigneeId=:lstId];

        for(User usr :lstUser){
            Integer count=0;
            for(PermissionSetAssignment assignment : assignments){
                if(assignment.AssigneeId == usr.Id){
                    count++;
                }
            }
            //Asserting permissions added
            System.assertEquals(4, count);
        }
        
        for(Contact con : Contacts.values()){
            if(con.is_DGX_Contact__c){
                system.assertEquals(false, con.Synced_IDM_DGX__c);
                system.assertEquals(null, con.IDM_DGX_Callout_Message__c);
            }      
            if(con.is_GRID_Contact__c){
                system.assertEquals(false, con.Synced_IDM_Grid__c);
                system.assertEquals(null, con.IDM_GRID_Callout_Message__c);
            }      
        }
    }

   /*static Account createAccount(String name, RecordType rt){              
        Account acct = new Account();
        acct.Name = name;
        acct.BillingState ='California';
        acct.BillingCountry ='United States';
        acct.BillingStreet = name;
        acct.BillingCity =name;
        acct.BillingPostalCode ='123213';
        acct.Billing_Region__c = 'NALA';
        acct.RecordTypeId = rt.Id;
        return acct;
    }*/
}