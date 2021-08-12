/*
    Test class for trigger class "Account_Tag_tgr_cls"
    2017.04.17 - After insert, after update, after delete events - set Account field "Account_Tags__c"
 */
 
@isTest(SeeAllData=false)
private class Test_Account_Tag_tgr_cls {

    static testMethod void testAccountTagInsert() {
            
        map<string, Id> mapRTNameId = new map<string, Id>();
        list<RecordType> lstRecTypes = [Select Name From RecordType Where SobjectType = 'Account' And Name = :COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY];
        for (RecordType rt : lstRecTypes){
            mapRTNameId.put(rt.Name, rt.Id);
        }

        //Create Country_List__c
        list<Country_List__c> lstCountry = new list<Country_List__c>();
        Country_List__c countryUS = new Country_List__c(name = COMM_Constants.ADDRESS_COUNTRY, ISO_Code__c = COMM_Constants.ADDRESS_US_ISO2, Region__c = COMM_Constants.ADDRESS_REGION_NALA, Sub_Region__c = COMM_Constants.ADDRESS_SUBREGION_LA, Territory__c = COMM_Constants.ADDRESS_TERRITORY_LA); 
        lstCountry.add(countryUS);
        insert lstCountry;      

        //Create a NPN Account Registry type of Account
        Account accNPNReg = new Account(name = 'NPNAccountRegistry1', RecordTypeId = mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY), BillingStreet = COMM_Constants.ADDRESS_STREET, BillingCity = COMM_Constants.ADDRESS_CITY, BillingState = COMM_Constants.ADDRESS_STATE, BillingCountry = COMM_Constants.ADDRESS_COUNTRY, BillingPostalCode = COMM_Constants.ADDRESS_ZIP, NPN_Program_Signed_Date__c = system.today() );
        insert accNPNReg;
        
        test.startTest();
            list<Account_Tag__c> lstAT = new list<Account_Tag__c>();
            Account_Tag__c oAT1 = new Account_Tag__c(AccountID__c = accNPNReg.Id, Tag__c = COMM_Constants.Account_TAG_1);
            Account_Tag__c oAT2 = new Account_Tag__c(AccountID__c = accNPNReg.Id, Tag__c = COMM_Constants.Account_TAG_2);
            lstAT.add(oAT1);
            lstAT.add(oAT2);
            insert lstAT;
            Account  accNPNRegRet = [Select AccountTags__c From Account Where Id = :accNPNReg.Id];
            system.assert(accNPNRegRet.AccountTags__c.contains(COMM_Constants.Account_TAG_1), true);
        test.stopTest();
    }
    
    static testMethod void testAccountTagDelete() {
            
        map<string, Id> mapRTNameId = new map<string, Id>();
        list<RecordType> lstRecTypes = [Select Name From RecordType Where SobjectType = 'Account' And Name = :COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY];
        for (RecordType rt : lstRecTypes){
            mapRTNameId.put(rt.Name, rt.Id);
        }

        //Create Country_List__c
        list<Country_List__c> lstCountry = new list<Country_List__c>();
        Country_List__c countryUS = new Country_List__c(name = COMM_Constants.ADDRESS_COUNTRY, ISO_Code__c = COMM_Constants.ADDRESS_US_ISO2, Region__c = COMM_Constants.ADDRESS_REGION_NALA, Sub_Region__c = COMM_Constants.ADDRESS_SUBREGION_LA, Territory__c = COMM_Constants.ADDRESS_TERRITORY_LA); 
        lstCountry.add(countryUS);
        insert lstCountry;      

        //Create a NPN Account Registry type of Account
        Account accNPNReg = new Account(name = 'NPNAccountRegistry1', RecordTypeId = mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY), BillingStreet = COMM_Constants.ADDRESS_STREET, BillingCity = COMM_Constants.ADDRESS_CITY, BillingState = COMM_Constants.ADDRESS_STATE, BillingCountry = COMM_Constants.ADDRESS_COUNTRY, BillingPostalCode = COMM_Constants.ADDRESS_ZIP, NPN_Program_Signed_Date__c = system.today() );
        insert accNPNReg;
        
        //create account tags
        list<Account_Tag__c> lstAT = new list<Account_Tag__c>();
        Account_Tag__c oAT1 = new Account_Tag__c(AccountID__c = accNPNReg.Id, Tag__c = COMM_Constants.Account_TAG_1);
        Account_Tag__c oAT2 = new Account_Tag__c(AccountID__c = accNPNReg.Id, Tag__c = COMM_Constants.Account_TAG_2);
        lstAT.add(oAT1);
        lstAT.add(oAT2);
        insert lstAT;
        
        test.startTest();
            Account_Tag__c oATForDelete = [Select Tag__c From Account_Tag__c Where Tag__c = :COMM_Constants.Account_TAG_1];
            delete oATForDelete;
            Account  accNPNRegRet = [Select AccountTags__c From Account Where Id = :accNPNReg.Id];
            system.assert(accNPNRegRet.AccountTags__c == COMM_Constants.Account_TAG_2);
        test.stopTest();
    }
    
    static testMethod void testAccountTagDeleteAll() {
            
        map<string, Id> mapRTNameId = new map<string, Id>();
        list<RecordType> lstRecTypes = [Select Name From RecordType Where SobjectType = 'Account' And Name = :COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY];
        for (RecordType rt : lstRecTypes){
            mapRTNameId.put(rt.Name, rt.Id);
        }

        //Create Country_List__c
        list<Country_List__c> lstCountry = new list<Country_List__c>();
        Country_List__c countryUS = new Country_List__c(name = COMM_Constants.ADDRESS_COUNTRY, ISO_Code__c = COMM_Constants.ADDRESS_US_ISO2, Region__c = COMM_Constants.ADDRESS_REGION_NALA, Sub_Region__c = COMM_Constants.ADDRESS_SUBREGION_LA, Territory__c = COMM_Constants.ADDRESS_TERRITORY_LA); 
        lstCountry.add(countryUS);
        insert lstCountry;      

        //Create a NPN Account Registry type of Account
        Account accNPNReg = new Account(name = 'NPNAccountRegistry1', RecordTypeId = mapRTNameId.get(COMM_Constants.ACCOUNT_RT_NPN_ACCOUNT_REGISTRY), BillingStreet = COMM_Constants.ADDRESS_STREET, BillingCity = COMM_Constants.ADDRESS_CITY, BillingState = COMM_Constants.ADDRESS_STATE, BillingCountry = COMM_Constants.ADDRESS_COUNTRY, BillingPostalCode = COMM_Constants.ADDRESS_ZIP, NPN_Program_Signed_Date__c = system.today() );
        insert accNPNReg;
        
        //create account tags
        list<Account_Tag__c> lstAT = new list<Account_Tag__c>();
        Account_Tag__c oAT1 = new Account_Tag__c(AccountID__c = accNPNReg.Id, Tag__c = COMM_Constants.Account_TAG_1);
        lstAT.add(oAT1);
        insert lstAT;
        
        test.startTest();
            list<Account_Tag__c> lstATForDelete = [Select Tag__c From Account_Tag__c Where AccountID__c = :accNPNReg.Id];
            delete lstATForDelete;
            Account  accNPNRegRet = [Select AccountTags__c From Account Where Id = :accNPNReg.Id];
            system.assert(accNPNRegRet.AccountTags__c == null);
        test.stopTest();
    }
}