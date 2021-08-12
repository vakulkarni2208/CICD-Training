/*
 *  Controller to VF vfOpportunity_By_Record_TypeV2.page
 *
 *  Class: EditOpportunityRecordType_Extention_New
 *
 *  Type: Controller Extension to an Opportunity Controller
 *
 *  Functionality: This class is a extension to the standard Opportunity controller, for Opportunity Edits, 
 *      and is called from the Edit button on an Opportunity.  You can only override a Standard Button with
 *      a Standard Controller, hence this extension, which redirects to the Opportunity_And_Products page
 *
 *  Created by: Duncan Stewart, for OpFocus, Summer 2010
 *
 	2017.10.19 - Opp Reg 2.5 (Record Locked to Partner after Submit, Auto Extension)
 	
 * @Manideep: 1/22/2019 - This code is updated by commenting out unwanted logic as part of Opportunity RecordType Cleanup.
 
*/
public class clsEditOpportunityRecordType_ExtensionV2 {
    private string rtName;
    private final Opportunity opp;
    private Id RecordtypeId;
    
    public clsEditOpportunityRecordType_ExtensionV2(ApexPages.StandardController stdController) {
      opp = (Opportunity)stdController.getRecord();
    }
    
    /*
     * @Manideep - Opportunity RecordType Cleanup. Rewrote this method below by removing unwanted code.
     
    public PageReference redirect(){
		//2017.10.13 - PJENA - Partners are not allowed to Edit Opportunity after Submission of Opp Reg
		//get the Opp Reg record type names
		//rtName = [Select Name from RecordType where Id = :opp.RecordTypeId].Name;
		Opportunity currOpp = [Select DR_Is_Submitted_For_Approval__c, RecordTypeId, RecordType.Name From Opportunity Where Id = :opp.Id];
		rtName = currOpp.RecordType.Name;
		string oppRegRecTypeName = DR_Settings__c.getOrgDefaults().Deal_Reg_Record_Types__c;
		
		if (oppRegRecTypeName.containsIgnoreCase(rtName) && currOpp.DR_Is_Submitted_For_Approval__c == true && UserInfo.getUserType() <> COMM_Constants.USER_USERTYPE_INTERNAL){
			string url = '/' + opp.id + '?nooverride=1';
			return new PageReference(url);
		}
		//End: 2017.10.13 - PJENA - Partners are not allowed to Edit Opportunity after Submission of Opp Reg
		else{
			map<string, Pricebook_Details__c> allOpptyReEngineeringConfigDetails = Pricebook_Details__c.getAll();
			if (allOpptyReEngineeringConfigDetails.keySet().contains(rtName)){
	            RecordtypeId = ApexPages.currentPage().getParameters().get('RecordType') != null ? ApexPages.currentPage().getParameters().get('RecordType'): opp.RecordtypeId;
	            String url = '';
	            if(ApexPages.currentPage().getParameters().get('RecordType') != null){
	                url = '/apex/vfOpportunityV2?accid=' + opp.AccountId + '&RecordType=' + RecordtypeId + '&ent=Opportunity&param=Edit&id='+opp.id +'&RecordTypeChange=true';      
	            } else{
	                url = '/apex/vfOpportunityV2?accid=' + opp.AccountId + '&RecordType=' + RecordtypeId + '&ent=Opportunity&param=Edit&id='+opp.id;  
	            }
	            PageReference pageRef = new PageReference(url);
	            pageRef.setRedirect(true);
	            return pageRef;         
	         }
	         //
              * @Manideep - Opportunity RecordType Cleanup
	         else if (rtName == Opportunity_ReEngineering_Constants.RT_NOTEBOOK_OPPORTUNITY) {
	            // Use the custom OpportunityAndProduct_controller and page, passing the Opportunity Id as the Id rather than Account Id
	            String url = '/apex/Opportunity_And_Products?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true';
	            return new PageReference(url);  
	        }
	        //
	        else{ 
	            // Other recordtypes use the appropriate Opportunity edit page
	            string url = '/' + opp.id + '/e?nooverride=1';
	            if (ApexPages.currentPage().getParameters().containsKey('retURL')) url += '&retURL=' + ApexPages.currentPage().getParameters().get('retURL');
	            if (ApexPages.currentPage().getParameters().containsKey('cancelURL')) url += '&cancelURL=' + ApexPages.currentPage().getParameters().get('cancelURL');
	            return new PageReference(url);
	         }
		}
    }
    */
    
    /*
     * @Manideep - 1/22/2019 - This method was rewritten by removing unwanted code as part of Opportunity Record Type Cleanup.
    */
    public PageReference redirect() {	
		
		// get the Opp Reg record type names
		Opportunity currOpp = [Select DR_Is_Submitted_For_Approval__c, RecordTypeId, RecordType.Name From Opportunity Where Id = :opp.Id];
		rtName = currOpp.RecordType.Name;
		map<string, Pricebook_Details__c> allOpptyReEngineeringConfigDetails = Pricebook_Details__c.getAll();
		
		if(allOpptyReEngineeringConfigDetails.keySet().contains(rtName)) {
	       RecordtypeId = ApexPages.currentPage().getParameters().get('RecordType') != null ? ApexPages.currentPage().getParameters().get('RecordType'): opp.RecordtypeId;
	       String url = '';
	       if(ApexPages.currentPage().getParameters().get('RecordType') != null){
	          url = '/apex/vfOpportunityV2?accid=' + opp.AccountId + '&RecordType=' + RecordtypeId + '&ent=Opportunity&param=Edit&id='+opp.id +'&RecordTypeChange=true';      
	       } else{
	          url = '/apex/vfOpportunityV2?accid=' + opp.AccountId + '&RecordType=' + RecordtypeId + '&ent=Opportunity&param=Edit&id='+opp.id;  
	       }
	       PageReference pageRef = new PageReference(url);
	       pageRef.setRedirect(true);
	       return pageRef;         
	    }
	    // All Other RecordTypes use the appropriate Opportunity edit page
	    else{ 
	       string url = '/' + opp.id + '/e?nooverride=1';
	       if(ApexPages.currentPage().getParameters().containsKey('retURL')) 
	          url += '&retURL=' + ApexPages.currentPage().getParameters().get('retURL');
	       if(ApexPages.currentPage().getParameters().containsKey('cancelURL'))
	          url += '&cancelURL=' + ApexPages.currentPage().getParameters().get('cancelURL');
	       
	       return new PageReference(url);
	    }
    }

}