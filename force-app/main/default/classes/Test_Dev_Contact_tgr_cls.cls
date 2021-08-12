/*
    PJENA: 2019.08.02 -  test class for trigger class Dev_Contact_tgr_cls
    
 */
@isTest(SeeAllData=false)
private class Test_Dev_Contact_tgr_cls {

    static testMethod void testSetRegion() {
        
        //Clean up all the Country_list Records if any
        //-----------------------------------------------------------------------------------------------------
        list<Country_List__c> lstAllCountryList = [Select Name From Country_List__c];
        if (!lstAllCountryList.isEmpty()){
            Database.delete(lstAllCountryList, false);
        }
        //-----------------------------------------------------------------------------------------------------
        
        //prep Country_List__c records
        //-----------------------------------------------------------------------------------------------------
        list<Country_List__c> lstCountryList = new list<Country_List__c>();
        Country_List__c testCountry1 = new Country_List__c(name='United States', ISO_Code__c = 'US', Region__c = 'NALA', Sub_Region__c = 'LA',  Territory__c = 'LA');
        Country_List__c testCountry2 = new Country_List__c(name='United Kingdom', ISO_Code__c = 'GB', Region__c = 'EMEAI', Sub_Region__c = 'NE',  Territory__c = 'UK_NORDICS');
        lstCountryList.add(testCountry1);
        lstCountryList.add(testCountry2);
        Database.insert(lstCountryList, false);
        //-----------------------------------------------------------------------------------------------------
        
        //Crate a Dev Account
        //-----------------------------------------------------------------------------------------------------
        list<Dev_Account__c> lstDA = new list<Dev_Account__c>();
        Dev_Account__c da = new Dev_Account__c(Dev_Account_Name__c = 'Account-20190208001');
        lstDA.add(da);
        database.insert(lstDA, false);
        //-----------------------------------------------------------------------------------------------------
        
        Test.startTest();
            List<Dev_Contact__c> lstNewContacts = new List<Dev_Contact__c>();
            Dev_Contact__c conSC1 = new Dev_Contact__c(Last_Name__c='SC1LanstName', Mailing_Country__c='United States', Dev_Account_Name__c = da.Id, Email__c ='SC1Email@gmail.com', Industry_Segment_Vertical__c = 'Aerospace');
            Dev_Contact__c conSC2 = new Dev_Contact__c(Last_Name__c='SC2LanstName', Mailing_Country__c='United Kingdom', Dev_Account_Name__c = da.Id, Email__c  = 'SC2Email@gmail.com', Industry_Segment_Vertical__c = 'Aerospace');
            lstNewContacts.add(conSC1);
            lstNewContacts.add(conSC2);
            Database.insert(lstNewContacts);
            
            list<Dev_Contact__c> lstDC = [select id, Mailing_Country__c, Mailing_Region__c From Dev_Contact__c];
            system.assert(string.isNotBlank(lstDC[0].Mailing_Region__c));
        Test.stopTest();
        
    }
}