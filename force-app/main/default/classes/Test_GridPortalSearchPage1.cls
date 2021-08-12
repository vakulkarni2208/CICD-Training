@isTest
private class Test_GridPortalSearchPage1{

    static testMethod void myUnitTest() {
    
        User u = [select Id from User where isActive=true and Profile.Name='System Administrator' limit 1];
        GRID_VCA_Instant_Message__c objGridVCAMsg = new GRID_VCA_Instant_Message__c();
        objGridVCAMsg.Start_Date__c = System.today();  
        objGridVCAMsg.Expiration_Date__c = System.today() + 2;
        objGridVCAMsg.Message__c = 'Hello World';                     
        insert objGridVCAMsg;        
                   
        RecordType rt = [select Id from RecordType where Name='Partner Lead' and SobjectType='Lead'];
        Lead leadObj = new Lead ();
        leadObj.RecordTypeId = rt.Id;
        leadObj.FirstName = 'SearchText';
        leadObj.LastName = 'SearchText';
        leadObj.Company = 'CompanyName';
        leadObj.LeadSource  = 'Email';        
        insert leadObj;
        
        ApexPages.CurrentPage().getParameters().put('searchText','SearchText');
        GridPortalSearchPage obj = new GridPortalSearchPage ();
        obj.ShowSearchResult();


    }
}