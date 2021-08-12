/**
    Contains generic methods for creating infratructure to test Portal/Community related test scenarios
    
    2016.08.24: Retrofitting of Opportunity creation with Primary Contact and Contact Role to avoid being caught up with validation rule 
                that blocks opportunity record creation/update when the Probability is 40% (or any percent that could be changed later) without a primary contact and role
    
    2017.03.11: Create Community_Settings__c record to use in Test_COMM_AssignPSPG_To_CommUsrs_Batch class
    
    2017.03.13 - Opp Reg 2.0 (Phase I) - TAM Automation, Direct Opp Reg record creation, Regional Roll-out
    
    2017.06.16 - Add Deal_Reg_Record_Types__c to DR_Settings__c to fix test class failures
                This field was added on 6/7/2017 ~ 6:34pm to the Registration Status formula field to have the value "Not Applicable" if the opportunity is not Opp Reg
    
    2017.07.18 - Country/State picklist rollout changes
    
    2017.10.19 - Opp Reg 2.5 (Record Locked to Partner after Submit, Auto Extension)
                Crate partner attributes helper method
                Make it Duplicate rule safe
    
    2017.11.29 - PJENA - Deal Registration - retrofit test classes to support Deal Registration
    
    2018.02.05 - Remove the following logics which does not have any relevance now
            GEO Area logic, 
            Setting legacy audit fields, Cloned Opportunity Created Date Bug Fix
            setForecastCategoryName
    
    2018.06.02 - PJENA - New COMM_Sync_CommUserDataToContactRec_Batch class to sync Commnity User Data to Contact Records
    
    2018.07.20 - PJENA - SDS-587 (All NALA deal registrations to route to Anish Dave instead of following the Territory Alignment logic)

    2018.08.18 - Akhilesh Gupta - Added new common functions to support Service Cloud functionality.
    
    2018.10.04 - PJENA - test class for DR_OPPREG_SAP_SYNC_Batch
    
    2019.03.11 - PJENA - SDS-774 - Remove Partner Opportunity Record Types
    2019.08.14 - Akhilesh Gupta - Added getComponent function.
    2019.09.10 - Akhilesh Gupta - Added getEntitlement and getUser functions.
    2019.09.11 - Akhilesh Gupta - Moved createUser function in this class from DGXRegistrationHelper.
    2019.09.13 - Akhilesh Gupta - Added getEmailMessage funtion, which is used in TestEmailMessageHelper.
 */
@isTest
public class Test_COMM_Factory {
    
    public static User getUser(Id profileId, String name, String roleId){
        User testuser = new User(
                                    Alias               = 'testUser', 
                                    Email               = name+'@test.com',
                                    Emailencodingkey    = 'UTF-8', 
                                    Lastname            = name, 
                                    Languagelocalekey   = 'en_US',
                                    Localesidkey        = 'en_US',
                                    Profileid           = profileId, 
                                    Timezonesidkey      = 'America/Los_Angeles', 
                                    Username            = name+'@test.com',
                                    UserRoleId          = roleId,
                                    IsActive            = true
                                );
       return testuser;
    }
    
    public static void insertLeadSpaceCS() {
       /* list<leadspacesync__Trigger_Bypass__c> lstLS = new list<leadspacesync__Trigger_Bypass__c>();
        lstLS = leadspacesync__Trigger_Bypass__c.getAll().values();
        if(lstLS == null || lstLS.isEmpty()) {
            leadspacesync__Trigger_Bypass__c objLS1 = new leadspacesync__Trigger_Bypass__c(Name='Bypass Sync Definition - Account', leadspacesync__LS_Enriched_Trigger__c =False);
            leadspacesync__Trigger_Bypass__c objLS2 = new leadspacesync__Trigger_Bypass__c(Name='Bypass Sync Definition - Contact', leadspacesync__LS_Enriched_Trigger__c =False);
            leadspacesync__Trigger_Bypass__c objLS3 = new leadspacesync__Trigger_Bypass__c(Name='Bypass Sync Definition - Lead', leadspacesync__LS_Enriched_Trigger__c =False);
            lstLS.add(objLS1);
            lstLS.add(objLS2);
            lstLS.add(objLS3);
            insert lstLS; 
        }*/
    }
    
    public static Account getAccount(String Name) {
    //ID accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('New_Customer_Account').getRecordTypeId();
      insertLeadSpaceCS();
          Account acc = new Account();
        acc.Name    = Name;
       acc.BillingState       = 'California';
       acc.BillingCountry     = 'United States';
       acc.BillingStreet      = 'Test';
       acc.BillingCity        = 'Santa Clara';
       acc.BillingPostalCode  = '95051';
       acc.Billing_Region__c  = 'NALA';
       //acc.RecordTypeId     = accRecTypeId;
       
       acc.Website            = NAME+'@'+NAME+'.com';
       return acc;
    }

    public static Contact getContact(Id accountId) {
        //insertLeadSpaceCS();
        Contact con             = new Contact();
        con.firstName           = 'firstName'+Decimal.valueOf(Math.random()).setscale(1);
        con.lastName            = 'lastName'+ Decimal.valueOf(Math.random()).setscale(1);
        string strEmail = 'test'+ Decimal.valueOf(Math.random()).setscale(1)+ '@test.com';
        con.Email               = strEmail;
        con.MailingStreet       = '2788 San Tomas Expy';
        con.Mailing_Street_2__c = 'Street2';
        con.MailingCity         = 'Santa Clara';
        con.MailingState        = 'California';
        con.MailingCountry      = 'United States';
        con.MailingPostalCode   = '95051';
        //con.IDM_ExternalId__c     = accountId+'-'+'test37838@test.com';//
        con.AccountId           = accountId;
        //con.is_GRID_Contact__c    = false;//
        //con.is_DGX_Contact__c     = false;//
        //con.Synced_IDM_DGX__c     = false;
        return con;
    }
    
    public static Opportunity getOpportunity(String Name, Id accountId) {
        Opportunity opp = new Opportunity();
        opp.Name        = Name;
        opp.StageName   = 'Discovery';
        opp.AccountId   = accountId;
        opp.CloseDate   = Date.today();
        return opp;
    }
    
    public static Contract getContract(Id accountId) {
        Contract contract       = new Contract();
        contract.AccountId      = accountId;
        contract.Status         = 'Draft';
        contract.StartDate      = Date.today();
        return contract;
    }
    
    public static Product2 getProduct(String Name) {
        Product2 product = new Product2(
                                    Name        = Name, 
                                    Family      = 'DGX-1 Pascal Product Family',
                                    ProductCode = 'Test Product'
                                );
        return product;
    }
    
    public static SBQQ__Subscription__c getSubscription(Id accountId, Id productId, Id contractId) {
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c (
                                                    SBQQ__Account__c    = accountId, 
                                                    SBQQ__Product__c    = productId,
                                                    SBQQ__Contract__c   = contractId, 
                                                    SBQQ__Quantity__c   = 2,
                                                    Hardware_Serial_Number__c = 'ABC000',
                                                    SBQQ__SubscriptionStartDate__c = Date.today(),
                                                    SBQQ__SubscriptionEndDate__c = Date.today().addDays(7)
                                                );
        return subscription;
    }
    
    public static Environment_Profile__c getEnvironmentProfile(Account acc, string strEnvRecordTypeId){
        Environment_Profile__c ep = new Environment_Profile__c ();
        ep.Account__c = acc.id;
        ep.name='Test Env Prof';
        ep.RecordTypeId = strEnvRecordTypeId;
        return ep;
    }
    
    public static Part__c getPart() {
        Part__c pt = new Part__c(
                                    Part_Number__c  = '920-200-2500',
                                    description__c  = 'test',
                                    Full_System__c  = true
                                );
        return pt;
    }
    
    public static NV_Component__c getComponent() {
        NV_Component__c comp = new NV_Component__c();
        return comp;
    }
    
    public static Entitlement getEntitlement(String Name,Id accId){
        Entitlement Ent = new Entitlement();
        Ent.AccountId   = accId;
        Ent.Name        = NAME+'Ent';
        Ent.StartDate   = Date.today();
        Ent.EndDate     = Date.today().addYears(1);
        Ent.PAK_ID__c    = Name + accid;
        return Ent;        
    }
    
    public static Asset getAsset(String Name,Id accId){
        Asset ast = new Asset();
        ast.AccountId   = accId;
        ast.Name        = NAME+'ast';
        return ast;        
    }
    
    public static Case getCase(Id accountId, Id recordTypeId) {
        Case cas = new Case(
                                AccountId           = accountId,
                                Status              = 'New', 
                                Origin              = 'Email', 
                                Severity__c         = 'S2:_Severe', 
                                RecordTypeId        = recordTypeId,
                                Incident_Status__c  = 'Troubleshooting-Sub',
                                Subject             = 'Test Subject'
                            );
        return cas;
    }
    
    public static Announcement__c getAnnouncement(String Name, Id ProductId) {
        Announcement__c ann = new Announcement__c( 
                                        Name            = Name,
                                        Product__c      = ProductId, 
                                        Content__c      = 'Test Announcement Ignore',
                                        Announcement_Type__c= 'Latest'
                                        //,Access_Level__c='Product Specific'                                                                                
                                   );
        return ann;
    }
    
    public static EmailMessage getEmailMessage(Id parentId, String fromAddress, String toAddress){
        EmailMessage em = new EmailMessage();
        em.ParentId     = parentId;
        em.FromAddress  = fromAddress;
        em.ToAddress    = toAddress;
        em.Incoming     = True;
        em.Subject      = 'Test email';
        em.TextBody     = 'Test email body';
        return em;
    }
    
    /**************************************************************************************************
    * Input Parameters: List of contact record Ids
    * Output: None
    * Purpose: Create User record(s) asynchronously for the corresponding Contact records
    ***************************************************************************************************/ 
    /* This function is moved from DGXRegistrationHelper class. */
    @future (callout=true)
    public static void createUser(List<Id> lstContactIds){
        //Fetching Contacts from Id's
        List<Contact> lstContact = [SELECT Id, firstName, lastName, email, CompanyName__c, Phone FROM Contact WHERE Id =:lstContactIds];
        List<User> lstUser = new List<User>();
        try{
            Set<String> lstEmailIds = new Set<String>();
            for(Contact con:lstContact){
                if(con.email !=null){
                    lstEmailIds.add(con.email);
                }
            }
            String ProfileId = [SELECT Id FROM Profile WHERE Name =:System.Label.Profile_for_DGX_Registration].Id;
            List<User> lstExistingUsers = [SELECT Id, UserName, Email, isActive FROM User WHERE UserName =:lstEmailIds];
            
            for(Contact con :lstContact){
                //Creating alias names
                boolean userAlreadyExists = false; 
                for(User user:lstExistingUsers){
                    if(con.email.equals(user.UserName))
                        userAlreadyExists= true;
                }
                if(!userAlreadyExists){
                    String alias ='';
                    if(con.firstName != null && con.firstName.length()>0){
                        alias =''+con.FirstName.substring(0,1);
                        if(con.LastName.length()>4)
                            alias = alias+con.LastName.substring(con.LastName.length()-4);
                    }                    
                    else if(con.lastName.length()>4)
                        alias = con.LastName.substring(con.LastName.length()-5);
                    User user = new User(
                                    ProfileId       = ProfileId,
                                    contactId       = con.Id,
                                    FirstName       = con.firstName,
                                    LastName        = con.lastName,
                                    Email           = con.email,
                                    Username        = con.email,
                                    CompanyName     = con.CompanyName__c,
                                    Phone           = con.Phone,
                                    Alias           = alias,
                                    is_Created__c   = true,
                                    TimeZoneSidKey  = 'America/Los_Angeles',
                                    EmailEncodingKey= 'UTF-8',
                                    LocaleSidKey    = 'en_US',
                                    LanguageLocaleKey = 'en_US'
                                );    
                    lstUser.add(user);    
                }
            }
            
            insert lstUser;

        }catch(Exception e){
            System.debug(LOGGINGLEVEL.INFO+' Logged error in DGX Registration'+e.getStackTraceString());
            System.debug('get stack trace..'+e.getStackTraceString());
            //updateDGXRegistrationEntry(lstContact[0].email, e.getStackTraceString());
            //if(lstContact.size() ==2){
            //  updateDGXRegistrationEntry(lstContact[1].email, e.getStackTraceString());    
            //}
            //PRFT_Error err = new PRFT_Error('DGX Registration User Creation Error',e.getStackTraceString(),String.valueof(e),null,true);
        }
    }
    
    public static Account createAccount(string name, string recordTypeId, boolean isPartner, boolean isCustomerPortal) {
        insertLeadSpaceCS();
        Account acc = new Account(Name = name, RecordTypeId = recordTypeId);
        if (Test.isRunningTest()){
            insert acc;
        }
        //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
        if (isPartner == true){
            acc.IsPartner = true;
        } else if (isCustomerPortal == true){
            acc.IsCustomerPortal = true;
        }
        if (Test.isRunningTest() && (isPartner || isCustomerPortal)){
            update acc;
        }
        return acc;
    }
    
    public static Contact createContact(string lastName, string email, Id accountId, string recordTypeId, string strPortalGroups){
        //insertLeadSpaceCS();
        Contact con = new Contact(LastName = lastName, Email = email, AccountId = accountId, RecordTypeId = recordTypeId, Portal_Groups__c = strPortalGroups);
        if (Test.isRunningTest()){
            insert con;
        }
        return con;
    }
    
     public static list<Contact> createContacts(Id accountId, string recordTypeId, string strPortalGroups, integer iNumOfUsers){
        //insertLeadSpaceCS();
        list<Contact> lstCon = new list<Contact>();
        string lastName;
        string email;
        for (integer i = 0; i < iNumOfUsers; i++){
            lastName = 'TestLName' + i;
            email = lastName + '@nv.com';
            lstCon.add(new Contact(LastName = lastName, Email = email, AccountId = accountId, RecordTypeId = recordTypeId, Portal_Groups__c = strPortalGroups));
        }
        if (Test.isRunningTest()){
            insert lstCon;
        }
        return lstCon;
    }
    
    public static User createUser(string contactId, string profileId){
        Long lRandom, uniqueVal;        
                
        lRandom = Math.roundToLong(Math.random() * 999);
        uniqueVal = System.currentTimeMillis();  //Current Time will always return different instantaneous value
                
        User usr = new User(alias = 't' + lRandom,                                             
                            email = 't' + lRandom + uniqueVal + '@nv.com',                                             
                            lastname='test',                                                                                         
                            CommunityNickname = 't' + lRandom + uniqueVal + '@nv.com',                                                                                         
                            ProfileId = profileId,                                     
                            username='t' + lRandom + uniqueVal + '@nv.com',  
                            ContactId =  contactID,                                  
                            EmailEncodingKey  = COMM_Constants.USER_EMAILENCODEKEY,
                            LanguageLocaleKey = COMM_Constants.USER_LANGLOCALEKEY,
                            LocaleSidKey = COMM_Constants.USER_LOCALESIDKEY,
                            TimeZoneSidKey = COMM_Constants.USER_TZSIDKEY,
                            IsActive = true );                                                            
        if (Test.isRunningTest()){
            insert usr;
        }
        return usr;
    }
    
    public static User createUserWithEmail(string contactId, string contactEmail, string profileId){
        Long lRandom, uniqueVal;        
                
        lRandom = Math.roundToLong(Math.random() * 999);
        uniqueVal = System.currentTimeMillis();  //Current Time will always return different instantaneous value
                
        User usr = new User(alias = 't' + lRandom,                                             
                            email = contactEmail,                                             
                            lastname='test',                                                                                         
                            CommunityNickname = 't' + lRandom + uniqueVal + '@nv.com',                                                                                         
                            ProfileId = profileId,                                     
                            username='t' + lRandom + uniqueVal + '@nv.com',  
                            ContactId =  contactID,                                  
                            EmailEncodingKey  = COMM_Constants.USER_EMAILENCODEKEY,
                            LanguageLocaleKey = COMM_Constants.USER_LANGLOCALEKEY,
                            LocaleSidKey = COMM_Constants.USER_LOCALESIDKEY,
                            TimeZoneSidKey = COMM_Constants.USER_TZSIDKEY,
                            IsActive = true );                                                            
        if (Test.isRunningTest()){
            insert usr;
        }
        return usr;
    }
    
    public static list<User> createUsers(list<Contact> lstPartnerContacts, string profileId){
        Long lRandom, uniqueVal;
        list<User> lstUser = new list<User>();
        for (integer i = 0; i < lstPartnerContacts.size(); i++){
            
            lRandom = Math.roundToLong(Math.random() * 999);
            uniqueVal = System.currentTimeMillis();  //Current Time will always return different instantaneous value
                    
            User usr = new User(alias = 't' + lRandom,                                             
                                email = 't' + lRandom + uniqueVal + 's' + i  + '@extinvalid.com',                                             
                                lastname='test',                                                                                         
                                CommunityNickname = 't' + lRandom + uniqueVal + 's' + i + '@nv.com',                                                                                       
                                ProfileId = profileId,                                     
                                username='t' + lRandom + uniqueVal + 's' + i + '@nv.com',  
                                ContactId =  lstPartnerContacts[i].Id,                                  
                                EmailEncodingKey  = COMM_Constants.USER_EMAILENCODEKEY,
                                LanguageLocaleKey = COMM_Constants.USER_LANGLOCALEKEY,
                                LocaleSidKey = COMM_Constants.USER_LOCALESIDKEY,
                                TimeZoneSidKey = COMM_Constants.USER_TZSIDKEY,
                                IsActive = true );
            lstUser.add(usr);
        }
                                                  
        if (Test.isRunningTest()){
            insert lstUser;
        }
        return lstUser;
    }
    
    public static list<Lead> createLeads(list<Lead> lstLeads, string partnerLeadRecTypeId){
        list<Lead> lstPartnerLeads = new list<Lead>();
        for (Lead lead : lstLeads){
            lead.RecordTypeId = partnerLeadRecTypeId;
            lead.Street = COMM_Constants.ADDRESS_STREET + getRandomNumber();
            lead.City = COMM_Constants.ADDRESS_CITY;
            lead.State = COMM_Constants.ADDRESS_STATE;
            lead.Country = COMM_Constants.ADDRESS_COUNTRY;
            lead.PostalCode = COMM_Constants.ADDRESS_ZIP;
            lstPartnerLeads.add(lead);
        }
        
        if (Test.isRunningTest()){
            insert lstPartnerLeads;
        }
        return lstPartnerLeads;
    }
    
    public static list<LeadProductType_OpportunityRecordType__c> createCSLPT_ORT(list<LeadProductType_OpportunityRecordType__c> lstCSLPT_ORT){
        if (Test.isRunningTest()){
            insert lstCSLPT_ORT;
        }
        return lstCSLPT_ORT;
    }
    
    public static list<User> createUsers(integer numUsers, string profileId){
        Long lRandom, uniqueVal;
        list<User> lstUser = new list<User>();
        for (integer i = 0; i < numUsers; i++){
            
            lRandom = Math.roundToLong(Math.random() * 999);
            uniqueVal = System.currentTimeMillis();  //Current Time will always return different instantaneous value
                    
            User usr = new User(alias = 'd' + lRandom,                                             
                                email = 'd' + lRandom + uniqueVal + 's' + i  + '@nvidia.com',                                             
                                lastname='dtest',                                                                                         
                                CommunityNickname = 'd' + lRandom + uniqueVal + 's' + i + '@nv.com',                                                                                       
                                ProfileId = profileId,                                     
                                username='d' + lRandom + uniqueVal + 's' + i + '@nv.com',                                
                                EmailEncodingKey  = COMM_Constants.USER_EMAILENCODEKEY,
                                LanguageLocaleKey = COMM_Constants.USER_LANGLOCALEKEY,
                                LocaleSidKey = COMM_Constants.USER_LOCALESIDKEY,
                                TimeZoneSidKey = COMM_Constants.USER_TZSIDKEY,
                                IsActive = true );
            lstUser.add(usr);
        }
                                                  
        if (Test.isRunningTest()){
            insert lstUser;
        }
        lstUser = [Select Username From User Where Id = :lstUser];
        return lstUser;
    }
    //**************************************************************************************************************
    //          DEAL REGISTRATION RELATED
    //**************************************************************************************************************
    //Get all Record Types with SObjects in the given list - Called from Deal Reg Test class
    public static map<string, Id> getAllRTsByName(list<string> lstObjectName){
        map<string, Id> allRTsByName = new map<string, Id>();
        list<RecordType> lstRTs;
        if (lstObjectName != null && !lstObjectName.isEmpty()){
            lstRTs = [Select Name From RecordType Where SobjectType = :lstObjectName];
        } else{
            lstRTs = [Select Name From RecordType];
        }
        for (RecordType rt : lstRTs){
            allRTsByName.put(rt.Name, rt.Id);
        }
        return allRTsByName;
    }
    
    //Returns all Profiles by List of Name - Called from Deal Reg Test class
    public static map<string, Id> getProfsByName(list<string> lstProfName){
        map<string, Id> allProfsByName = new map<string, Id>();
        list<Profile> lstProfs;
        string strSQL = '';
        if (lstProfName != null && !lstProfName.isEmpty()){
            lstProfs = [Select Name From Profile Where Name = :lstProfName];
        } else{
            lstProfs = [Select Name From Profile];
        }
        for (Profile prof : lstProfs){
            allProfsByName.put(prof.Name, prof.Id);
        }
        return allProfsByName;
    }
    
    //Create Account with Billing Address
    public static Account createAccountWithBillingAddress(string name, Id recordTypeId, string billingStreet, string billingCity, string billingState, string billingCountry, string billingPostalCode){
        long lRandom = Math.roundToLong(Math.random() * 9999);
        long  uniqueVal = System.currentTimeMillis();
        string uniqueNameExt = lRandom + '' + uniqueVal;
        Account acc = new Account(Name = name, RecordTypeId = recordTypeId, BillingStreet = billingStreet+uniqueNameExt, BillingCity = billingCity, BillingState = billingState, BillingCountry = billingCountry, BillingPostalCode = billingPostalCode);
        if (Test.isRunningTest()){
            insert acc;
        }
        return acc;
    }
    
    
    //Create NPN Account with US Billing Address;
    public static Account createNPNAccountWithUSBillingAddressRegion(string name, Id recordTypeId){
        insertLeadSpaceCS();
        long lRandom = Math.roundToLong(Math.random() * 9999);
        long  uniqueVal = System.currentTimeMillis();
        string uniqueNameExt = lRandom + '' + uniqueVal;
        Account acc = new Account(  name = name, 
                                    RecordTypeId = recordTypeId, 
                                    BillingStreet = COMM_Constants.ADDRESS_STREET+uniqueNameExt, 
                                    BillingCity = COMM_Constants.ADDRESS_CITY, 
                                    BillingState = COMM_Constants.ADDRESS_STATE, 
                                    BillingCountry = COMM_Constants.ADDRESS_COUNTRY, 
                                    BillingPostalCode = COMM_Constants.ADDRESS_ZIP, 
                                    Billing_Region__c = COMM_Constants.ADDRESS_REGION_NALA, 
                                    Billing_Sub_Region__c = COMM_Constants.ADDRESS_SUBREGION_LA, 
                                    Billing_Territory__c = COMM_Constants.ADDRESS_TERRITORY_LA,
                                    SAP_Customer_Number__c =  String.valueOf(System.currentTimeMillis()).right(10),
                                    NPN_Program_Signed_Date__c = system.today() );
        if (Test.isRunningTest()){
            insert acc;
        }
        return acc;
    }
    
    //create partner attributes with competency
    public static Partner_Attribute__c createPartnerAttribute(Id accountId, string programName, string programLevel, string competencyName, Date competencySignedDate){
        Partner_Attribute__c pa = new Partner_Attribute__c(Account_Name__c = accountId, Partner_Program_Name__c = programName, Program_Level__c = programLevel, Partner_Competency__c = competencyName, Date_Competency_Signed__c = competencySignedDate);
        if (Test.isRunningTest()){
            insert pa;
        }
        return pa;
    }
    
    //Create Contact with US Mailing Address
    public static Contact createContactWithMailingAddress(string lastName, string firstName, Id accountId, string email, Id recordTypeId, string mailingStreet, string mailingCity, string mailingState, string mailingCountry, string mailingPostalCode){
        long lRandom = Math.roundToLong(Math.random() * 9999);
        long  uniqueVal = System.currentTimeMillis();
        string uniqueNameExt = lRandom + '' + uniqueVal;
        Contact con = new Contact(LastName = lastName, FirstName = firstName, AccountId = accountId, Email = email, RecordTypeId = recordTypeId, MailingStreet = mailingStreet+uniqueNameExt, MailingCity = mailingCity, MailingState = mailingState, MailingCountry = mailingCountry, MailingPostalCode = mailingPostalCode);
        if (Test.isRunningTest()){
            insert con;
        }
        return con;
    }
    
    //Create Opportunity 
    //2016.08.24: Retrofitting of Opportunity creation with Primary Contact and Contact Role to avoid being caught up with validation rule 
    public static Opportunity createOpportunity(string name, Id accountId, Id recordTypeId, string stageName, Date closeDate, string closedLostComments, Id pricebook2Id){
        //Create a partner Contact for Primary Contact and Role
        //get all Record Types
        list<string> lstSObjects = new list<string>{'Contact'};
        map<String, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);
        
        long lRandom, uniqueVal;
        lRandom = Math.roundToLong(Math.random() * 999);
        uniqueVal = System.currentTimeMillis();  //Current Time will always return different instantaneous value
        Contact partnerContact = Test_COMM_Factory.createContactWithMailingAddress(lRandom+'Last', lRandom+'First', accountId, 'f' + lRandom + uniqueVal + 'l' + '@extinvalid.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP);
        string strContactRole_SalesContact = COMM_Constants.OCR_DEFAULT_SALES_CONTACT;
        
        
        
        //Opportunity oppty = new Opportunity(Name = name, AccountId = accountId, RecordTypeId = recordTypeId, StageName = stageName, CloseDate = closeDate, Closed_Lost_Comments__c = closedLostComments, PriceBook2Id = pricebook2Id);
        Opportunity oppty = new Opportunity(Name = name, AccountId = accountId, RecordTypeId = recordTypeId, StageName = stageName, CloseDate = closeDate, Closed_Lost_Comments__c = closedLostComments, PriceBook2Id = pricebook2Id, DR_Customer_Contact__c = partnerContact.Id, Primary_Contact_Role__c = strContactRole_SalesContact,
                                                Design_Start_Date__c =  Date.today(), Design_EOL_Date__c= Date.today().addYears(2));
        if (Test.isRunningTest()){
            insert oppty;
        }
        return oppty;
    }
    
    
    //2016.08.24: Create mass Opportunities with Contact Roles. Mainly used in Test_CRM_OCR_Sync_Scheduler
    public static list<Opportunity> createMassOpportunityWithOCR(integer numberOfOpps, Id accountId, Id recordTypeId, string stageName, Date closeDate, string closedLostComments, Id pricebook2Id, Id primaryContactId, string strPrimaryContactRole){
    
        list<Opportunity> lstOpps = new list<Opportunity>();
        Opportunity opp;
        for (integer i = 0; i < numberOfOpps; i++){
            opp = new Opportunity(Name = 'MassOpportunityWithOCR'+i, AccountId = accountId, RecordTypeId = recordTypeId, StageName = stageName, CloseDate = closeDate, Closed_Lost_Comments__c = closedLostComments, PriceBook2Id = pricebook2Id, DR_Customer_Contact__c = primaryContactId, Primary_Contact_Role__c = strPrimaryContactRole);
            lstOpps.add(opp);
        }
        
        if (Test.isRunningTest() && lstOpps.size() > 0){
            insert lstOpps;
        }
        return lstOpps;
    }
    
    //Create Opportunity with SalesOpsAdmin Approver
    //2016.08.24: Retrofitting of Opportunity creation with Primary Contact and Contact Role to avoid being caught up with validation rule 
    public static Opportunity createOpportunityWithSalesOpsApprover(string name, Id accountId, Id recordTypeId, string stageName, Date closeDate, string closedLostComments, Id pricebook2Id, Id salesOpsAdminApprover){
        
        //Create a partner Contact for Primary Contact and Role
        //get all Record Types
        list<string> lstSObjects = new list<string>{'Contact'};
        map<String, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);
        
        long lRandom, uniqueVal;
        lRandom = Math.roundToLong(Math.random() * 999);
        uniqueVal = System.currentTimeMillis();  //Current Time will always return different instantaneous value
        Contact partnerContact = Test_COMM_Factory.createContactWithMailingAddress(lRandom+'Last', lRandom+'First', accountId, 'f' + lRandom + uniqueVal + 'l' + '@extinvalid.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP);
        string strContactRole_SalesContact = COMM_Constants.OCR_DEFAULT_SALES_CONTACT;
        
        //Opportunity oppty = new Opportunity(Name = name, AccountId = accountId, RecordTypeId = recordTypeId, StageName = stageName, CloseDate = closeDate, Closed_Lost_Comments__c = closedLostComments, PriceBook2Id = pricebook2Id, DR_SalesOps_Approver__c = salesOpsAdminApprover);
        Opportunity oppty = new Opportunity(Name = name, AccountId = accountId, RecordTypeId = recordTypeId, StageName = stageName, CloseDate = closeDate, Closed_Lost_Comments__c = closedLostComments, PriceBook2Id = pricebook2Id, DR_SalesOps_Approver__c = salesOpsAdminApprover, DR_Customer_Contact__c = partnerContact.Id, Primary_Contact_Role__c = strContactRole_SalesContact);
        if (Test.isRunningTest()){
            insert oppty;
        }
        return oppty;
    }
    
    //2018.10.04 - PJENA - test class for DR_OPPREG_SAP_SYNC_Batch
    //Create Deal Reg Enterprise Opportunity
    public static Opportunity createDealRegOpportunity(string name, Id recordTypeId, string stageName, Date closeDate, Id pricebook2Id, Id customerAccountId, Id partnerAccountId){
        
        //Create a partner Contact for Primary Contact and Role
        //get all Record Types
        list<string> lstSObjects = new list<string>{'Contact'};
        map<String, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);
        System.debug('Limits.getQueries()- '+ Limits.getQueries());
        
        long lRandom, uniqueVal;
        lRandom = Math.roundToLong(Math.random() * 999);
        uniqueVal = System.currentTimeMillis();  //Current Time will always return different instantaneous value
        Contact salesContact = Test_COMM_Factory.createContactWithMailingAddress(lRandom+'Last', lRandom+'First', customerAccountId, 'f' + lRandom + uniqueVal + 'l' + '@extinvalid.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_SALES_CONTACT), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP);
        System.debug('Limits.getQueries()- '+ Limits.getQueries());
        string strContactRole_SalesContact = COMM_Constants.OCR_DEFAULT_SALES_CONTACT;
        
        //Opportunity oppty = new Opportunity(Name = name, AccountId = accountId, RecordTypeId = recordTypeId, StageName = stageName, CloseDate = closeDate, Closed_Lost_Comments__c = closedLostComments, PriceBook2Id = pricebook2Id, DR_SalesOps_Approver__c = salesOpsAdminApprover);
        Opportunity oppty = new Opportunity();
        oppty.Name = name;
        oppty.AccountId = customerAccountId;
        oppty.RecordTypeId = recordTypeId;
        oppty.StageName = stageName;
        oppty.CloseDate = closeDate;
        oppty.LeadSource = 'Deal Registration';
        //oppty.Closed_Lost_Comments__c = closedLostComments;
        oppty.PriceBook2Id = pricebook2Id;
        //oppty.DR_SalesOps_Approver__c = salesOpsAdminApprover;
        oppty.DR_Customer_Contact__c = salesContact.Id;
        oppty.Primary_Contact_Role__c = strContactRole_SalesContact;
        
        /*
        oppty.Do_you_have_a_NPN_Solution_Provider_VAR__c = 'Yes';
        oppty.NPN_Solution_Provider_VAR__c = partnerAccountId;
        
        oppty.Type = DR_Settings__c.getOrgDefaults().Lead_Type__c;
        oppty.DR_Lead_Type__c = DR_Settings__c.getOrgDefaults().Lead_Type__c;
        oppty.DR_Partner_Sales_Rep_Company__c = customerAccountId;
        oppty.DR_Is_Approved__c = true;
        oppty.DR_Approved_Date__c = Datetime.now();
        */
        
        if (Test.isRunningTest()){
            insert oppty;
        }
        return oppty;
    }
    
    //2018.10.04 - PJENA - test class for DR_OPPREG_SAP_SYNC_Batch
    //set Deal Reg fields in Enterprise Opportunity
    public static void setDealRegFieldsInOpportunity(Id dealRegOppId, Id customerAccountId, Id partnerAccountId){
        Opportunity enterpriseSalesOppty = new Opportunity();
        enterpriseSalesOppty.Id = dealRegOppId;
        enterpriseSalesOppty.Do_you_have_a_NPN_Solution_Provider_VAR__c = 'Yes';
        enterpriseSalesOppty.NPN_Solution_Provider_VAR__c = partnerAccountId;
        
        enterpriseSalesOppty.Type = DR_Settings__c.getOrgDefaults().Lead_Type__c;
        enterpriseSalesOppty.DR_Lead_Type__c = DR_Settings__c.getOrgDefaults().Lead_Type__c;
        enterpriseSalesOppty.DR_Partner_Sales_Rep_Company__c = partnerAccountId;
        enterpriseSalesOppty.DR_Is_Approved__c = true;
        enterpriseSalesOppty.DR_Approved_Date__c = Datetime.now();
        update enterpriseSalesOppty;
    }
    
    //Create Product with Price
    public static PricebookEntry createProductAndSetPrice (string productName, string family, string productCode, boolean isDealEnabled, string priceBookName, decimal standardPrice, decimal customPrice){
        Product2 gridDealEnabledProduct = new Product2(Name = productName, Family = family, ProductCode= productCode, IsActive = true, Is_Deal_Enabled__c = isDealEnabled);
        if (Test.isRunningTest()){
            insert gridDealEnabledProduct;
        }
        
        // Get standard price book ID. This is available irrespective of the state of SeeAllData.
        Id standardPricebookId = Test.getStandardPricebookId();
        
        //Insert a price book entry for the standard price book. Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry gridProductStandardPrice = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = gridDealEnabledProduct.Id, UnitPrice = standardPrice, IsActive = true);
        if (Test.isRunningTest()){
            insert gridProductStandardPrice;
        }
        
        //Create a GRID Partner Pricebook
        PriceBook2 gridPartnerPB = new PriceBook2 (Name = priceBookName, Description = priceBookName, IsActive = true);
        if (Test.isRunningTest()){
            insert gridPartnerPB;
        }
        
        //Add the Product to GRID Partner Pricebook
        PricebookEntry gridProductPrice = new PricebookEntry(PriceBook2Id = gridPartnerPB.Id, Product2Id = gridDealEnabledProduct.Id, UnitPrice = customPrice, IsActive = true);
        if (Test.isRunningTest()){
            insert gridProductPrice;
        }
        gridProductPrice = [Select PriceBook2Id, Product2Id, UnitPrice From PricebookEntry Where Id = :gridProductPrice.Id];
        return gridProductPrice;
    }
    
    //2018.10.04 - PJENA - test class for DR_OPPREG_SAP_SYNC_Batch
    //prepare the infrastructre to create an Enterprise Opportunity
    public static PricebookEntry createEnterpriseProductAndSetPrice (string productName, string productCode, string family, boolean isDealEnabled, string priceBookName,  decimal standardPrice, decimal customPrice,  string BaseSKU, string Term){
        Product2 gridDealEnabledProduct = new Product2(Name = productName, Family = family, ProductCode= productCode, IsActive = true, Is_Deal_Enabled__c = isDealEnabled, Base_SKU__c = BaseSKU, Term__c = Term);
        if (Test.isRunningTest()){
            insert gridDealEnabledProduct;
        }
        
        // Get standard price book ID. This is available irrespective of the state of SeeAllData.
        Id standardPricebookId = Test.getStandardPricebookId();
        
        //Insert a price book entry for the standard price book. Standard price book entries require the standard price book ID we got earlier.
        PricebookEntry gridProductStandardPrice = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = gridDealEnabledProduct.Id, UnitPrice = standardPrice, IsActive = true);
        if (Test.isRunningTest()){
            insert gridProductStandardPrice;
        }
        
        //Create a GRID Partner Pricebook
        PriceBook2 gridPartnerPB = new PriceBook2 (Name = priceBookName, Description = priceBookName, IsActive = true);
        if (Test.isRunningTest()){
            insert gridPartnerPB;
        }
        
        //Add the Product to GRID Partner Pricebook
        PricebookEntry gridProductPrice = new PricebookEntry(PriceBook2Id = gridPartnerPB.Id, Product2Id = gridDealEnabledProduct.Id, UnitPrice = customPrice, IsActive = true);
        if (Test.isRunningTest()){
            insert gridProductPrice;
        }
        gridProductPrice = [Select PriceBook2Id, Product2Id, UnitPrice From PricebookEntry Where Id = :gridProductPrice.Id];
        return gridProductPrice;
    }
      
    //Sets DR : Settings data - Deal Reg related
    public static void setCSDRSettingsData(){
        DR_Settings__c csDRSettings = new DR_Settings__c();
        csDRSettings.Name = 'DR : Settings';
        csDRSettings.Deal_Reg_Reqd_Fields__c = 'name';
        csDRSettings.Deal_Status_ApprovalInProgress__c = 'Approval In-Progress';
        csDRSettings.Deal_Status_Approved__c = 'Approved';
        csDRSettings.Deal_Status_AutoTerminated__c = 'Auto Terminated';
        csDRSettings.Deal_Status_ClaimApprovalInProgress__c = 'Claim Approval In-Progress';
        csDRSettings.Deal_Status_ClaimApproved__c = 'Claim Approved';
        csDRSettings.Deal_Status_ClaimRejected__c = 'Claim Rejected';
        csDRSettings.Deal_Status_ExtensionApprovalInProgress__c = 'Extension Approval In-Progress';
        csDRSettings.Deal_Status_ExtensionApproved__c = 'Extension Approved';
        csDRSettings.Deal_Status_ExtensionRejected__c = 'Extension Rejected';
        csDRSettings.Deal_Status_NotSubmitted__c = 'Not Submitted';
        csDRSettings.Deal_Status_Rejected__c = 'Rejected';
        csDRSettings.Deal_Status_Terminated__c = 'Terminated';
        csDRSettings.DR_Set_Approvers_Fresh_OnEachSubmit__c = true;
        csDRSettings.DR_Constant_Others__c = 'Others';
        csDRSettings.DR_ForecastCategoryName_Closed__c = 'Closed';
        csDRSettings.PS_Name_PP_CRM_Partner_Deal_Editor__c = 'PP_CRM_PARTNER_DEAL_EDITOR';
        //2017.03.13 - Opp Reg 2.0 (Phase I) - TAM Automation, Direct Opp Reg record creation, Regional Roll-out: retrofitting the new fields added to custom settings
        csDRSettings.DR_Threshold_Submission__c = 0;
        csDRSettings.DR_Threshold_Extn_Submission__c = 0;
        //2017.05.09 - Opp Reg : Alt Partner Owner
        csDRSettings.Public_Group_OPP_REG_Alt_Submitter__c = 'OPPORTUNITY_REG_ALT_SUBMITTER';
        
        //2017.06.16 - Add Deal_Reg_Record_Types__c to DR_Settings__c to fix test class failures
        csDRSettings.Deal_Reg_Record_Types__c = 'GRID Partner Deal, Tesla Partner Deal, Quadro Partner Deal';
        
        //2017.11.29 - PJENA - Deal Registration - retrofit test classes to support Deal Registration
        csDRSettings.Lead_Source__c = 'Deal Registration';
        csDRSettings.Lead_Type__c = 'Deal Registration';
        csDRSettings.Lead_Status_IR__c = 'In Review';
        csDRSettings.Lead_Status_R__c = 'Rejected';
        csDRSettings.Lead_RecordTypeName_For_Deal_Reg__c  = 'Deal Registration';
        csDRSettings.DR_Opportunity_RTID__c = '0121W000000DybgQAC';
        csDRSettings.DR_PBID_OPPREG__c = '01s1W00000083MW';
        csDRSettings.DR_PBID_OPPREG_EDU__c = '01s1W00000083Mb';
        csDRSettings.DR_Opportunity_Stage__c = 'Prospecting';
        csDRSettings.DR_Opportunity_Probability__c = 10;
        
        //2018.07.20 - PJENA - SDS-587 (All NALA deal registrations to route to Anish Dave instead of following the Territory Alignment logic)
        csDRSettings.DR_NALA_TAM_User_Id__c = UserInfo.getUserId();
        
        
        if (Test.isRunningTest()){
            insert csDRSettings;
        }
    }
    
    //2018.10.04 - PJENA - test class for DR_OPPREG_SAP_SYNC_Batch
    //Sets DR : SAP SYNC : Settings used in Test_DR_OPPREG_SAP_SYNC_Batch.Test_COMM_Factory.setEnterpriseOpptyInfra method 
    public static void setDRSAPSYNCSettings(){
        DR_SAP_SYNC_Settings__c csDRSAPSYNCSettings = new DR_SAP_SYNC_Settings__c();
        csDRSAPSYNCSettings.Name = 'DR : SAP SYNC : Settings';
        csDRSAPSYNCSettings.BATCHJOB_BATCH_SIZE__c = 10;
        csDRSAPSYNCSettings.BATCHJOB_ENABLE_SCHDULED_JOB__c = true;
        csDRSAPSYNCSettings.BATCHJOB_LKBK_TIME__c = 30;
        csDRSAPSYNCSettings.BATCHJOB_RECUR__c = 15;
        csDRSAPSYNCSettings.CalloutTimeout__c = 9000;
        csDRSAPSYNCSettings.NamedCredentialEndPoint__c = 'callout:SAP_OppReg';
        if (Test.isRunningTest()){
            insert csDRSAPSYNCSettings;
        }
    }
    
    //Set DR : SalesOps : Admin
    public static void setDRSalesOpsAdmin(string strSapesOpsAdminUsername){
        if (Test.isRunningTest()){
            list<DR_SalesOps_Admins__c> lstDRSalesOpsAdmin = [Select DR_Billing_Country_s__c, DR_Admin_Username__c, Name From DR_SalesOps_Admins__c];
            
            if (!lstDRSalesOpsAdmin.isEmpty()) database.delete(lstDRSalesOpsAdmin);
            
            if (lstDRSalesOpsAdmin.isEmpty()){
                DR_SalesOps_Admins__c salesOpsAdminUS, salesOpsAdminOthers;
                
                //US Sales Ops Admin
                salesOpsAdminUS = new DR_SalesOps_Admins__c();
                salesOpsAdminUS.name = 'us';
                salesOpsAdminUS.DR_Billing_Country_s__c = 'United States';
                salesOpsAdminUS.DR_Admin_Username__c = strSapesOpsAdminUsername;
                lstDRSalesOpsAdmin.add(salesOpsAdminUS);
                
                //Others Sales Ops Admin
                salesOpsAdminOthers = new DR_SalesOps_Admins__c();
                salesOpsAdminOthers.name = 'Others';
                salesOpsAdminOthers.DR_Billing_Country_s__c = 'Others';
                salesOpsAdminOthers.DR_Admin_Username__c = strSapesOpsAdminUsername;
                lstDRSalesOpsAdmin.add(salesOpsAdminOthers);
                
                insert lstDRSalesOpsAdmin;
            }
        }
    }
       
    //2017.03.13 - Opp Reg 2.0 (Phase I) - TAM Automation, Direct Opp Reg record creation, Regional Roll-out
    //Build the Country List object records, returns the map of country name and other details
    public static map<string, Country_List__c> setCountryList(list<Country_List__c> lstNewCL){
        map<string, Country_List__c> mapCountryList = new map<string, Country_List__c>();
        if (Test.isRunningTest()){
            list<Country_List__c> existingCL = [Select Id From Country_List__c];
            if (!existingCL.isEmpty()) database.delete(existingCL);
            if (!lstNewCL.isEmpty()){
                insert lstNewCL;
                lstNewCL = [Select name, ISO_Code__c, ISO_Code_3__c, Region__c, Sub_Region__c, Territory__c From Country_List__c];
                for (Country_List__c country : lstNewCL){
                    mapCountryList.put(country.name, country);
                }
            } 
        }
        system.debug('***mapCountryList: ' + mapCountryList);
        return mapCountryList;
    }
    
    //2017.03.13 - Opp Reg 2.0 (Phase I) - TAM Automation, Direct Opp Reg record creation, Regional Roll-out
    //Build the TAM Matrix
    public static void setTerritoryMapping(list<Territory_Mapping__c> oTAMs){
        if (Test.isRunningTest()){
            list<Territory_Mapping__c> lstTM = [Select Id From Territory_Mapping__c];
            
            if (!lstTM.isEmpty()) database.delete(lstTM);
            
             if (lstTM.isEmpty() && !oTAMs.isEmpty()) insert oTAMs;
              
        }
    }
    
    
    //2018.10.04 - PJENA - test class for DR_OPPREG_SAP_SYNC_Batch
    //prepare the infrastructre to create an Enterprise Opportunity
    public static map<string, Object> setEnterpriseOpptyInfra(string ProdName, string ProdCode, string ProdFamily, boolean isDealEnabled, string PriceBookName, decimal StandardPrice, decimal CustomPrice, string BaseSKU, string Term){
        
        //Create Country_List__c
        list<Country_List__c> lstCountry = new list<Country_List__c>();
        Country_List__c countryUS = new Country_List__c(name = COMM_Constants.ADDRESS_COUNTRY, ISO_Code__c = COMM_Constants.ADDRESS_US_ISO2, ISO_Code_3__c=COMM_Constants.ADDRESS_US_ISO3, Region__c = COMM_Constants.ADDRESS_REGION_NALA, Sub_Region__c = COMM_Constants.ADDRESS_SUBREGION_LA, Territory__c = COMM_Constants.ADDRESS_TERRITORY_LA); 
        lstCountry.add(countryUS);
        map<string, Country_List__c> mapCountryList = Test_COMM_Factory.setCountryList(lstCountry);
        
        //Oppty Infra Map declaration
        map<string, Object> mapOpptyInfraObjects = new map<string, Object>();
        
        //Create a Product, Pricebook, PricebookEntry
        PricebookEntry dealProductPBEntry = Test_COMM_Factory.createEnterpriseProductAndSetPrice (ProdName, ProdCode, ProdFamily, isDealEnabled, PriceBookName, StandardPrice, CustomPrice, BaseSKU, Term);
        
        //get All Profiles
        list<string> lstProfNames = new list<string>{COMM_Constants.PROF_PP_VGX_GENERIC, COMM_Constants.PROF_INT_PARTNER_ADMIN };
        map<string, Id> mapProfNameId = Test_COMM_Factory.getProfsByName(lstProfNames);
        
        //get all Record Types
        list<string> lstSObjects = new list<string>{'Account', 'Contact', 'Opportunity'};
        map<String, Id> mapRTNameId = Test_COMM_Factory.getAllRTsByName(lstSObjects);
        
        //declare the Account and Contact variable so it is visible down below
        Account partnerAcc, customerAcc;
        Contact partnerContact;
        
        //Create a NPN Account with Billing Country, Region
        partnerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('NPNAccount1', mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY));
        system.debug('***partnerAcc: ' + partnerAcc);
        
        //Create a new Customer Account with Billing Country, Region
        customerAcc = Test_COMM_Factory.createNPNAccountWithUSBillingAddressRegion('NewCustomerAccount1', mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NEW_CUSTOMER));
        system.debug('***partnerAcc: ' + customerAcc);
        
        //we can not set IsParnter or IsCustomerPortal at the time of insert, so needs to do this on update
        partnerAcc.IsPartner = true;
        update partnerAcc;
        
        //Create Partner Attribute record with Program SP and Competency AC
        Partner_Attribute__c pa = new Partner_Attribute__c(Account_Name__c = partnerAcc.Id, Partner_Program_Name__c = COMM_Constants.PA_PROGRAM_SP, Partner_Competency__c = COMM_Constants.TEST_PORTAL_COMPETENCY_AC, Program_Level__c = COMM_Constants.PA_LEVEL_ELITE);
        insert pa;
        system.debug('***Partner Attribute PA =  ' + pa);
        
        //Create a Partner Contact 
        partnerContact = Test_COMM_Factory.createContactWithMailingAddress('LJena1', 'FContact', partnerAcc.Id, 'partnercontactjena1@nv.com', mapRTNameId.get(COMM_Constants.CONTACT_RT_PARTNER_CONTACT), COMM_Constants.ADDRESS_STREET, COMM_Constants.ADDRESS_CITY, COMM_Constants.ADDRESS_STATE, COMM_Constants.ADDRESS_COUNTRY, COMM_Constants.ADDRESS_ZIP );
        
        //Create a Partner User with profile named 'NPN Partner Community(LOGIN)'
        User partnerUser = Test_COMM_Factory.createUser(partnerContact.Id, mapProfNameId.get(COMM_Constants.PROF_PP_VGX_GENERIC));
        
        //create custom settings for Deal data
        Test_COMM_Factory.setCSDRSettingsData();
        
        //create custom settings for DR : SAP SYNC : Settings
        Test_COMM_Factory.setDRSAPSYNCSettings();
        
        //PBM User and Manager varaibles declaration
        list<User> lstPBMUsers;
        User PBMUser;
        User PBMManager;
        User SalesOpsAdmin;
        User TAMUser;
        User TAMUserManager;
        
        //get hold of the logged on user to flip the context to avoid the MIXD DML issue
        User self = [Select Id From User where id = :UserInfo.getUserId()];
        system.runAs(self){
            //Create PBM and PBM Manager
            lstPBMUsers = Test_COMM_Factory.createUsers(5, mapProfNameId.get(COMM_Constants.PROF_INT_PARTNER_ADMIN));
            PBMUser = lstPBMUsers[0];
            PBMManager = lstPBMUsers[1];
            PBMUser.ManagerId = PBMManager.Id;
            PBMUser.UserRoleId = userinfo.getUserRoleId();
            
            TAMUser = lstPBMUsers[3];
            TAMUserManager = lstPBMUsers[4];
            TAMUser.ManagerId = TAMUserManager.Id;
            TAMUser.UserRoleId = userinfo.getUserRoleId();
            
            //update PBMUser;
            list<User> lstPBMTAMUser = new list<User>();
            lstPBMTAMUser.add(PBMUser);
            lstPBMTAMUser.add(TAMUser);
            update lstPBMTAMUser;
            
            SalesOpsAdmin = lstPBMUsers[2];
        }
        
        //Assign the Partner Account ownership to PBM user 
        partnerAcc.OwnerId = PBMUser.Id;
        update partnerAcc;
        
        //create custom setting for Sales Ops Admin: svcDeploy or current user is the SalesOps Admin for both United States and Others
        Test_COMM_Factory.setDRSalesOpsAdmin(SalesOpsAdmin.Username);
        
        //fill the map
        if (!mapOpptyInfraObjects.isEmpty()) mapOpptyInfraObjects.clear();
        mapOpptyInfraObjects.put('customeraccount', customerAcc);
        mapOpptyInfraObjects.put('partneraccount', partnerAcc);
        mapOpptyInfraObjects.put('partnercontact', partnerContact);
        mapOpptyInfraObjects.put('partneruser', partnerUser);
        mapOpptyInfraObjects.put('pbm', PBMUser);
        mapOpptyInfraObjects.put('pbmmanager', PBMManager);
        mapOpptyInfraObjects.put('salesopsadmin', SalesOpsAdmin);
        mapOpptyInfraObjects.put('pricebookentry', dealProductPBEntry);
        mapOpptyInfraObjects.put('mapprofnameid', mapProfNameId);
        mapOpptyInfraObjects.put('maprectypenameid', mapRTNameId);
        mapOpptyInfraObjects.put('mapcountrynamecountrylist', mapCountryList);
        mapOpptyInfraObjects.put('tam', TAMUser);
        mapOpptyInfraObjects.put('tammanager', TAMUserManager);
        return mapOpptyInfraObjects;
    }
 
    //setup Custom Settings Lead Product Type and Partner Opportunity Record Type map. Used in Opportunity Trigger to set the Partner Opportunity Record Type based on its Lead Product Type
    public static void setCSLeadProductType_OpportunityRecordType(){
        if (Test.isRunningTest()){
            string custSettingsPtnrSuffix = '-Partner';
            string custSettingsInternalSuffix = '-Internal';
            list<LeadProductType_OpportunityRecordType__c> lstLPT_ORT = [Select Opportunity_RecordTypeName__c, Name From LeadProductType_OpportunityRecordType__c];
            
            if (!lstLPT_ORT.isEmpty()) database.delete(lstLPT_ORT);
            
            if (lstLPT_ORT.isEmpty()){
                LeadProductType_OpportunityRecordType__c oLPT_ORT;
                
                //Internal Opprty Rec Types
                oLPT_ORT = new LeadProductType_OpportunityRecordType__c();
                oLPT_ORT.name = COMM_Constants.LEAD_PRODUCT_TYPE_AUTOMOTIVE + custSettingsInternalSuffix;
                oLPT_ORT.Opportunity_RecordTypeName__c = COMM_Constants.OPPTY_RT_AUTOMOTIVE_INTERNAL_OPPTY;
                lstLPT_ORT.add(oLPT_ORT);
                
                /*
                oLPT_ORT = new LeadProductType_OpportunityRecordType__c();
                oLPT_ORT.name = COMM_Constants.LEAD_PRODUCT_TYPE_GRID + custSettingsInternalSuffix;
                oLPT_ORT.Opportunity_RecordTypeName__c = COMM_Constants.OPPTY_RT_QUADRO_INTERNAL_OPPTY; 
                lstLPT_ORT.add(oLPT_ORT);
                
                oLPT_ORT = new LeadProductType_OpportunityRecordType__c();
                oLPT_ORT.name = COMM_Constants.LEAD_PRODUCT_TYPE_QUADRO + custSettingsInternalSuffix;
                oLPT_ORT.Opportunity_RecordTypeName__c = COMM_Constants.OPPTY_RT_QUADRO_INTERNAL_OPPTY;
                lstLPT_ORT.add(oLPT_ORT);
                */
                
                //call the factory method to insert it
                lstLPT_ORT = Test_COMM_Factory.createCSLPT_ORT(lstLPT_ORT);
            }
        }
    }
    
    
    //setup Custom Settings CRM : OCR : Settings
    public static void set_CRM_OCR_Settings(){
        OCR_Settings__c csOCRSettings = new OCR_Settings__c();
        csOCRSettings.Name = 'CRM : OCR : Settings';
        csOCRSettings.Default_Contact_Role__c = COMM_Constants.OCR_DEFAULT_SALES_CONTACT;
        csOCRSettings.OCR_Msg__c = 'Msg set from Test Method, Opportunity Contact Role is required!';
        csOCRSettings.Batch_Job_Lookback_Date__c = system.now().addMinutes(-1);
        csOCRSettings.Job_Batch_Size__c = 10;
        csOCRSettings.Job_Exec_Frequency__c = 2;
        csOCRSettings.Job_Lookback_Duration__c = 1;
        csOCRSettings.Job_Schedule_Enabled__c = true;
        
        if (Test.isRunningTest()){
            insert csOCRSettings;
        }
    }
    

    //NV Contacts related test classes
    //------------------------------------------------------------------------------------------------------------
    
    //Sets NV_Permissions_and_PCL_Mapping__c
    public static void set_NV_Permissions_and_PCL_Mapping(){
        list<NV_Permissions_and_PCL_Mapping__c> lstNVContactsSettings = new list<NV_Permissions_and_PCL_Mapping__c>();
        
        NV_Permissions_and_PCL_Mapping__c NVContactsSettings = new NV_Permissions_and_PCL_Mapping__c();
        NVContactsSettings.name = 'OEM Accelerated Computing Preferred';
        NVContactsSettings.Program_Name__c = 'OEM';
        NVContactsSettings.Competency__c = 'Accelerated Computing';
        NVContactsSettings.Level__c = 'Preferred';
        NVContactsSettings.Combination__c = 'OEM Accelerated Computing Preferred';
        lstNVContactsSettings.add(NVContactsSettings);
        
        NVContactsSettings = new NV_Permissions_and_PCL_Mapping__c();
        NVContactsSettings.name = 'SPProfessional Visualization Preferred';
        NVContactsSettings.Program_Name__c = '  Solution Provider';
        NVContactsSettings.Competency__c = 'Professional Visualization';
        NVContactsSettings.Level__c = 'Preferred';
        NVContactsSettings.Combination__c = 'SP Professional Visualization Preferred';
        lstNVContactsSettings.add(NVContactsSettings);
        
        if (Test.isRunningTest()){
            insert lstNVContactsSettings;
        }
        
    }
    
    //Sets NV_Permissions_and_PCL_Mapping__c
    public static void set_NVContacts(Id userSalesManagerId, Id userAccountOwnerId){
        list<NV_Contacts__c> lstNVContacts = new list<NV_Contacts__c>();
        
        NV_Contacts__c NVContact = new NV_Contacts__c();
        NVContact.Name = 'VCA US';
        NVContact.Program_Type__c = 'Solution Provider';
        NVContact.Product_Line__c = 'Professional Visualization';
        NVContact.Billing_Country__c = 'United States';
        //NVContact.US_States__c = '';
        //NVContact.Region__c = '';
        //NVContact.Sub_Region__c = '';
        NVContact.Account_Owner_Name__c = userAccountOwnerId;
        NVContact.Sales_Manager_Name__c = userSalesManagerId;
        NVContact.Sales_Title__c = 'Sales Manager';
        NVContact.Sales_Manager_Email__c = 'salesmanagerproviz@nvidia.com';
        NVContact.Sales_Manager_Contact_Number__c = '5555555555';
        lstNVContacts.add(NVContact);
        
        NVContact = new NV_Contacts__c();
        NVContact.Name = 'GRID US';
        NVContact.Program_Type__c = 'OEM';
        NVContact.Product_Line__c = 'Accelerated Computing';
        NVContact.Billing_Country__c = 'United States';
        //NVContact.US_States__c = '';
        //NVContact.Region__c = '';
        //NVContact.Sub_Region__c = '';
        NVContact.Account_Owner_Name__c = userAccountOwnerId;
        NVContact.Sales_Manager_Name__c = userSalesManagerId;
        NVContact.Sales_Title__c = 'Sales Manager';
        NVContact.Sales_Manager_Email__c = 'salesmanagerac@nvidia.com';
        NVContact.Sales_Manager_Contact_Number__c = '5555555555';
        lstNVContacts.add(NVContact);
        
        if (Test.isRunningTest()){
            insert lstNVContacts;
        }
        
    }
    
    //End: NV Contacts related test classes
    //------------------------------------------------------------------------------------------------------------
    
    //=============================================================================================================
    //  Opportunity ReEngineering related test infrastructure
    //=============================================================================================================
    
    //setup Custom Settings: Opportunity Re Engineering Details
    public static void set_OpportunityReEngineeringDetailsSettings(string rtName, string priceBookName, string familyName, string productPageBlockSectionName, string quarterPageBlockSectionName, 
                                                                    string columnName, boolean bShowASP, boolean bShowRevenue, boolean bShowASOverride, string profileNames, string userNames){
        if (Test.isRunningTest()){
            list<Pricebook_Details__c> lstPricebook_Details = [ Select Name, Pricebook_Name__c, Product_Pageblock_Section_Name__c, Quarter_PageBlock_Section__c,
                                                                    Column_Name__c, Help_Url__c, Message_to_Select_Quarter__c, Guidlines_link__c,
                                                                    Training_Deck_Url__c, Opportunity_Type__c, family__c, Layout_Modified_Date__c, 
                                                                    ShowASP__c, ShowRevenue__c, Show_ASP_Override__c, 
                                                                    ASP_Override_Admin_Profile_s__c, ASP_Override_Admin_User_s__c
                                                                From Pricebook_Details__c];
            
            if (!lstPricebook_Details.isEmpty()) database.delete(lstPricebook_Details);
            
            if (lstPricebook_Details.isEmpty()){
                Pricebook_Details__c teslaPriceBookSettings, quadroPartnerPriceBookSettings;
                
                //Tesla Price Book Custom Settings details
                teslaPriceBookSettings = new Pricebook_Details__c();
                teslaPriceBookSettings.Name = rtName; //COMM_Constants.OPPTY_RT_TESLA_INTERNAL_OPPTY; //'Tesla Sales Opportunity';
                teslaPriceBookSettings.Pricebook_Name__c = priceBookName; //COMM_Constants.PB_TESLA_INTERNAL;//'Tesla Price Book';
                teslaPriceBookSettings.family__c = familyName; //COMM_Constants.PROD_FAMILY_TESLAHW;
                teslaPriceBookSettings.Product_Pageblock_Section_Name__c = productPageBlockSectionName;//'Tesla Products';
                teslaPriceBookSettings.Quarter_PageBlock_Section__c = quarterPageBlockSectionName; //'Tesla Product Revenue by Quarter';
                teslaPriceBookSettings.Column_Name__c = columnName; //'Tesla Product';
                teslaPriceBookSettings.Help_Url__c = '';
                teslaPriceBookSettings.Message_to_Select_Quarter__c = 'You must also select Starting Quarter (at bottom) or Select a Product to "save" Opportunity';
                teslaPriceBookSettings.Guidlines_link__c = '';
                teslaPriceBookSettings.Training_Deck_Url__c = '';
                teslaPriceBookSettings.Opportunity_Type__c = '';
                teslaPriceBookSettings.Layout_Modified_Date__c = datetime.now();
                teslaPriceBookSettings.ShowASP__c = bShowASP;
                teslaPriceBookSettings.ShowRevenue__c = bShowRevenue;
                teslaPriceBookSettings.Show_ASP_Override__c = bShowASOverride;
                teslaPriceBookSettings.ASP_Override_Admin_Profile_s__c = profileNames;
                teslaPriceBookSettings.ASP_Override_Admin_User_s__c = userNames;
                
                lstPricebook_Details.add(teslaPriceBookSettings);
                
                /*
                //Quadro Partner Price Book Custom Settings details
                quadroPartnerPriceBookSettings = new Pricebook_Details__c();
                quadroPartnerPriceBookSettings.Name = 'Quadro Partner Opportunity';
                quadroPartnerPriceBookSettings.Pricebook_Name__c = 'Quadro Partner Price Book';
                quadroPartnerPriceBookSettings.Product_Pageblock_Section_Name__c = 'Partner Products';
                quadroPartnerPriceBookSettings.Quarter_PageBlock_Section__c = 'Partner Product by Quarter';
                quadroPartnerPriceBookSettings.Column_Name__c = 'Partner Product';
                quadroPartnerPriceBookSettings.Help_Url__c = '/apex/Tesla_OppAndProductsPage_Help';
                teslaPriceBookSettings.Message_to_Select_Quarter__c = 'You must also select Starting Quarter (at bottom) or Select a Product to "save" Opportunity';
                quadroPartnerPriceBookSettings.Guidlines_link__c = '';
                quadroPartnerPriceBookSettings.Training_Deck_Url__c = '';
                quadroPartnerPriceBookSettings.Opportunity_Type__c = '';
                quadroPartnerPriceBookSettings.family__c = 'Quadro';
                quadroPartnerPriceBookSettings.Layout_Modified_Date__c = datetime.now();
                quadroPartnerPriceBookSettings.ShowASP__c = false;
                quadroPartnerPriceBookSettings.ShowRevenue__c = false;
                quadroPartnerPriceBookSettings.Show_ASP_Override__c = false;
                quadroPartnerPriceBookSettings.ASP_Override_Admin_Profile_s__c = '';
                quadroPartnerPriceBookSettings.ASP_Override_Admin_User_s__c = '';
                
                lstPricebook_Details.add(quadroPartnerPriceBookSettings);
                */
                
                insert lstPricebook_Details;
            }
        }
    }
    //End: setup Custom Settings: Opportunity Re Engineering Details
    
    //End: Opportunity ReEngineering related test infrastructure
    //-------------------------------------------------------------------------------------------------------------
    
    //2017.03.11: Create Community_Settings__c record to use in Test_COMM_AssignPSPG_To_CommUsrs_Batch class
    //2018.06.02 - PJENA - New COMM_Sync_CommUserDataToContactRec_Batch class to sync Commnity User Data to Contact Records
    //setup Custom Settings CRM : OCR : Settings
    public static void set_CommunitySettings(){
        Community_Settings__c csCOMMSettings = new Community_Settings__c();
        
        csCOMMSettings.Name = 'Community Settings';
        
        csCOMMSettings.ACC_COMPUTING_TESLA__c = 'Accelerated Computing';
        csCOMMSettings.CLOUD_VIRTUALIZATION_VGX__c = 'Cloud/Virtualization';
        csCOMMSettings.PROF_VISUALIZATION_VCA__c = 'Professional Visualization';
        
        csCOMMSettings.BRAINSHARK_URL__c = 'https://www.brainshark.com/portal/psapis/api/psSession.aspx';
        
        csCOMMSettings.USERNAME_EXTENSION__c = 'npnbu';
        csCOMMSettings.CONTENTVERSION_LANGUAGE_REGION_METAID__c = '00N40000002WvBR';
        csCOMMSettings.CONTENTVERSION_COMPETENCY_METAID__c = '00N40000002zGdx';
        csCOMMSettings.ERROR_EMAILS__c = 'apardeshi@nvidia.com;vakulkarni@nvidia.com;talicaya@nvidia.com;pjena@nvidia.com';
        
        csCOMMSettings.PS_PG_ASSIGN_LKBK_TIME__c = 5;
        csCOMMSettings.PS_PG_ASSIGN_RECUR__c = 2;
        csCOMMSettings.PS_PG_ENABLE_SCHDULED_JOB__c = true;
        
        csCOMMSettings.BATCHJOB_PS_PG_ASSIGN_LKBK_TIME__c = 5;
        csCOMMSettings.BATCHJOB_PS_PG_ASSIGN_RECUR__c = 2;
        csCOMMSettings.BATCHJOB_PS_PG_BATCH_SIZE__c = 25;
        csCOMMSettings.BATCHJOB_PS_PG_ENABLE_SCHDULED_JOB__c = true;
        
        //2018.06.02 - PJENA - New COMM_Sync_CommUserDataToContactRec_Batch class to sync Commnity User Data to Contact Records
        csCOMMSettings.BATCHJOB_U2CSync_LKBK_TIME__c = 5;
        csCOMMSettings.BATCHJOB_U2CSync_RECUR__c = 2;
        csCOMMSettings.BATCHJOB_U2CSync_BATCH_SIZE__c = 25;
        csCOMMSettings.BATCHJOB_U2CSync_ENABLE_SCHDULED_JOB__c = true;
        
        if (Test.isRunningTest()){
            insert csCOMMSettings;
        }
    }
    
    public static string getRandomNumber(){
        long lRandom = Math.roundToLong(Math.random() * 99999);
        long  uniqueVal = System.currentTimeMillis();
        string uniqueNameExt = lRandom + '' + uniqueVal;
        return uniqueNameExt;
    }
    
    public static string getRecordTypeId(string strSOBjectType, string strRecTypeDeveloperName){
        Id recTypeId = [SELECT DeveloperName,Id,SobjectType FROM RecordType WHERE SobjectType = :strSOBjectType AND DeveloperName = :strRecTypeDeveloperName].id;
        return recTypeId;
    }
    
    public static NVbug__C getNVBug(Id CaseId){
        NVbug__C nvbug = new NVbug__C ();
        nvbug.Case__c = CaseId;
        nvbug.name = 'Refresh';
        nvbug.NVBug_Template__c='(1000)';
        return nvbug;
    }
    
    public static NV_Ticket__c getNV_Ticket(Id CaseId, string strType,Id recTYpeId){
        NV_Ticket__c nvt = new NV_Ticket__c ();
        nvt.Case__c = CaseId;
        nvt.name = 'Refresh';
        nvt.Type__c= strType;
        nvt.RecordTypeId = recTYpeId;
        nvt.IsApplicationIntegrationEntryCreated__c=false;
        return nvt ;
    }  
    public static Environment_Profile__c getEnvironmentProfile(Id AccountId){
        Environment_Profile__c env = new Environment_Profile__c ();
        env.name='DGX';
        env.Account__C= AccountId;
        return env;
    }
    public static AccountTeamMember getAccountTeamMember(Id AccountId, Id userId, string strRoleName){
        AccountTeamMember accMember = new AccountTeamMember();
        accMember.AccountAccessLevel = 'Edit';
        accMember.AccountId = AccountId ;
        accMember.CaseAccessLevel = 'Edit';
        accMember.ContactAccessLevel = 'Edit';
        accMember.Include_in_Case_Team__c = true ;
        accMember.OpportunityAccessLevel = 'Edit' ;
        accMember.TeamMemberRole = strRoleName ;
        accMember.UserId = userId ;
        return accMember;
    }
    public static CaseTeamRole getCaseTeamRole(string strRoleName){
        CaseTeamRole caseRole = [select id from CaseTeamRole where name= :strRoleName limit 1] ;
        return caseRole;
    }    
    public static CaseTeamMember getCaseTeamMember(string strMemberId, string strRoleId, string strParentId){
        CaseTeamMember caseTeam = new CaseTeamMember();
        caseTeam.MemberId = strMemberId;
        caseTeam.ParentId = strParentId ;
        caseTeam.TeamRoleId = strRoleId ;
        return caseTeam;
    }    
          
}