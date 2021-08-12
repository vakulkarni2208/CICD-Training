/*
 * @Manideep: 5/8/2019 - This code is commented out as part of Opportunity RecordType Cleanup.
*/

public with sharing class clsEditOpportunityProduct_ExtensionV2 {
   
  // Dummy method for code coverage
  // This method is coverred by the class 'UnitTests_DummyCodeCoverage_DEL_Classes.cls'
  public static void fakeMethod(){
    Integer i = 0;
    i++;
  }

/*   
    // The Opportunity being edited
    private String rtName;
    public  Opportunity     opp      {get; private set;}
    private final OpportunityLineItem oli;
    
    public Boolean          pageError      {get; private set;}
    //public ID                 OppID      {get; set;}

    public clsEditOpportunityProduct_ExtensionV2(ApexPages.StandardController stdController) {
        
        oli = (OpportunityLineItem)stdController.getRecord();
    }
    
    public PageReference redirect(){
        
        pageError = false;
        
        //OppID = oli.OpportunityId;
        
        // Get the "RecordType" querystring parameter. 
        // We're editing an existing Opportunity
        try {
            opp = 
              [select id, Name, AccountId, OwnerId, Pricebook2Id,
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
                      StageName, Status_Last_Step__c, Status_Next_Step__c, Probability, Target_Market__c,
                      (select id, Product_Name__c, ASP__c, Quantity,
                              PricebookEntryId, PricebookEntry.Pricebook2Id, PricebookEntry.Product2Id, PricebookEntry.Product2.Family
                       from   OpportunityLineItems 
                       order by Product_Name__c)
               from   Opportunity
               where  id = :oli.OpportunityId];
        }
        catch (Exception ex) {
            pageError = true;
            
            String str = 'Opportunity ' + oli.OpportunityId + ' does not exist.';
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, str);
            ApexPages.addMessage(msg);                  
            return null;
        } 
            
    
        rtName = [Select Name from RecordType where Id = :opp.RecordTypeId].Name;
        map<string, Pricebook_Details__c> allOpptyReEngineeringConfigDetails = Pricebook_Details__c.getAll();
		if (allOpptyReEngineeringConfigDetails.keySet().contains(rtName)){// Use the custom vfOpportunityV2 Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/vfOpportunityV2?accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&param=Edit&id='+opp.id;
            return new PageReference(url);  
        } 
        /////
         * @Manideep - Opportunity RecordType Cleanup
        else if (rtName == Opportunity_ReEngineering_Constants.RT_NOTEBOOK_OPPORTUNITY) {
            // Use the custom OpportunityAndProduct_controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/Opportunity_And_Products?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true';
            return new PageReference(url);  
        } 
        /////
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