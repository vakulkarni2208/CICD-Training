/*
	Change List:
	2017.10.19 - Opp Reg 2.5 (Record Locked to Partner after Submit, Auto Extension)
	
  * @Manideep: 1/18/2018 - This code is updated by commenting out unwanted logic as part of Opportunity RecordType Cleanup.
    2021.01.25 - PJENA - SOQ-74 - remove references to unused opp fields
*/
public with sharing class clsEditScheduleEntry_ExtensionV2 {

    // The Opportunity being edited
    private String rtName;
    public  Opportunity     opp      {get; private set;}
    private final Schedule_Entry__c se;
    
    public clsEditScheduleEntry_ExtensionV2(ApexPages.StandardController stdController) {
        se = (Schedule_Entry__c)stdController.getRecord();
    }
    
    public PageReference redirect(){
        // Get the "RecordType" querystring parameter. 
        opp = [select id, Name,RecordTypeId, AccountId, RecordType.Name
               from   Opportunity
               where  id = :se.Opportunity__c];
        
        rtName = opp.RecordType.Name;
        system.debug('***rtName: ' + rtName);

	    map<string, Pricebook_Details__c> allOpptyReEngineeringConfigDetails = Pricebook_Details__c.getAll();
        system.debug('***allOpptyReEngineeringConfigDetails: ' + allOpptyReEngineeringConfigDetails);
		if (allOpptyReEngineeringConfigDetails.keySet().contains(rtName)){
            system.debug('***Redirection for Enterprise Oppty part of Opp ReEngineering');
            string url = '/apex/vfOpportunityV2?accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&param=Edit&id='+opp.id; 
            return new PageReference(url);  
        }else{
            return new PageReference('/' + opp.id + '/e?nooverride=1');
        }
        
        /*else {
            // Other recordtypes use the appropriate Opportunity edit page
	        system.debug('***Redirection for all other type of Opptys');
	        string url = '/' + opp.id + '/e?nooverride=1';
	        if (ApexPages.currentPage().getParameters().containsKey('retURL')) url += '&retURL=' + ApexPages.currentPage().getParameters().get('retURL');
	        if (ApexPages.currentPage().getParameters().containsKey('cancelURL')) url += '&cancelURL=' + ApexPages.currentPage().getParameters().get('cancelURL');
	        return new PageReference(url);
        }
        */
		
    }
}