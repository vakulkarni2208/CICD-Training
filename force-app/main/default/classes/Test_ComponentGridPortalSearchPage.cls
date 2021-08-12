@isTest
private class Test_ComponentGridPortalSearchPage  {

    static testMethod void myUnitTest() {
        
        ApexPages.CurrentPage().getParameters().put('tab','Sales');
        GRID_VCA_Instant_Message__c objGridVCAMsg = new GRID_VCA_Instant_Message__c();
        objGridVCAMsg.Start_Date__c = System.today();  
        objGridVCAMsg.Expiration_Date__c = System.today() + 2;
        objGridVCAMsg.Message__c = 'Hello World';                     
        insert objGridVCAMsg;
        
        ComponentGridPortalSearchPage  obj = new ComponentGridPortalSearchPage ();
        obj.ShowSearchResult();
        
    }
}