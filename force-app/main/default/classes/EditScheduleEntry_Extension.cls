/*
 * 5/8/2019 - @Manideep - The code is not being used so commented out as part of Opportunity RecordType Cleanup.
*/
public with sharing class EditScheduleEntry_Extension {

    // Dummy method for code coverage
    // This method is coverred by the class 'UnitTests_DummyCodeCoverage_DEL_Classes.cls'
    public static void fakeMethod(){
      Integer i = 0;
      i++;
    }
    
    /*
     * @Manideep - Opportunity RecordType Cleanup
    // The Opportunity being edited
    public  Opportunity     opp      {get; private set;}
    private final Schedule_Entry__c se;
    
    public Boolean          pageError      {get; private set;}
    
    public EditScheduleEntry_Extension(ApexPages.StandardController stdController) {
        
        se = (Schedule_Entry__c)stdController.getRecord();
    }
    
    public PageReference redirect(){
        
        pageError = false;
        
        // Get the "RecordType" querystring parameter. 
        // We're editing an existing Opportunity
        try {
            opp = 
              [select id, Name,RecordTypeId, AccountId, OwnerId, Pricebook2Id,
                      Migrated_From_Old_Design__c,
                      At_Risk_Indicator__c, At_Risk_Level__c, Blocking_Issues__c, 
                      CloseDate, Closed_Lost_Comments__c, Competition__c, Country__c, 
                      Code_Name_Auto__c, Distributor__c, 
                      Description, GEO_Area__c, Industry__c, LeadSource, 
                      Prefered_Partner__c, Additional_Partners__c, 
                      Product_Line__c, Project_Stage__c,
                      Type, 
                      Linked_Opportunities__c, ODM__c, Operating_System_Type__c, 
                      System_Integrator__c, Tegra_Product__c, Type_of_Device__c, 
                      Reason_for_Close__c, Sales_Lead__c, 
                      StageName, Status_Last_Step__c, Status_Next_Step__c, Probability,
                      (select id, Product_Name__c, ASP__c, Quantity,
                              PricebookEntryId, PricebookEntry.Pricebook2Id, PricebookEntry.Product2Id, PricebookEntry.Product2.Family
                       from   OpportunityLineItems 
                       order by Product_Name__c)
               from   Opportunity
               where  id = :se.Opportunity__c];
        }
        catch (Exception ex) {
            pageError = true;
            
            String str = 'Opportunity ' + se.Opportunity__c + ' does not exist.';
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
            ApexPages.addMessage(msg);                  
            return null;
        } 
            
    
        RecordType rt = [Select Name from RecordType where Id = :opp.RecordTypeId];
        if (rt.Name == 'Notebook Opportunity') {
            // Use the custom OpportunityAndProduct_controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/Opportunity_And_Products?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true';
            return new PageReference(url);  
        } 
        else if (rt.Name == 'Quadro Sales Opportunity') {
            // Use the custom Quadro_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/Quadro_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true';
            return new PageReference(url);  
        } 
        else if (rt.Name == 'Tesla Sales Opportunity') {
            // Use the custom Tesla_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/Tesla_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true';
            return new PageReference(url);  
        } 
        else if (rt.Name == 'Tegra Auto and Emb Opportunity') {
            // Use the custom TegraAuto_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/TegraAuto_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true';
            return new PageReference(url);  
        } 
        else if (rt.Name == 'Tegra Auto OEM Opportunity') {
            // Use the custom TegraAuto_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/TegraAuto_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true';
            return new PageReference(url);  
        } 
        else if (rt.Name == 'Tegra Auto Tier 1 Opportunity') {
            // Use the custom TegraAuto_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/TegraAuto_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true';
            return new PageReference(url);  
        } 
        else if (rt.Name == 'Tegra Tablets, SB, SP Opportunity') {
            // Use the custom TegraTablet_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/TegraTablet_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true';
            return new PageReference(url);  
        } 
        else if (rt.Name == 'GeForce Sales Opportunity') {
            // Use the custom GeForce_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/GeForce_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true';
            return new PageReference(url);  
        } 
        else {
            // Other recordtypes use the appropriate Opportunity edit page
            String url = '/' + opp.id + '/e?nooverride=1';
            if (ApexPages.currentPage().getParameters().containsKey('retURL')) url += '&retURL=' + ApexPages.currentPage().getParameters().get('retURL');
            if (ApexPages.currentPage().getParameters().containsKey('cancelURL')) url += '&cancelURL=' + ApexPages.currentPage().getParameters().get('cancelURL');
            return new PageReference(url);
        }
    }
    */
}