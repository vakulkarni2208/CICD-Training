/*
	Controller class for VF vfDirect_Opportunity_By_TypeV2.page.
	Redirects to Opportunity ReEngineering Custom VF Page based on the Opportunity record type.
	
* @Manideep: 1/18/2018 - This code is updated by commenting out unwanted logic as part of Opportunity RecordType Cleanup.

*/
public class clsSelectOppRecordType_ExtensionV2 {
	private final Opportunity opp;
    private string rtName;
    
    public clsSelectOppRecordType_ExtensionV2(ApexPages.StandardController stdController) {
        try{   
            opp = (Opportunity)stdController.getRecord();
            if(opp.RecordTypeId <> null){
                rtName = [Select Name from RecordType where Id = :opp.RecordTypeId].Name;
            } else {
                // We don't know what Record Type this new Opp is for. Find out the one Record Type the user has Create permissions for         
                List<String> OppRTNames = Utils.getAccessibleRecordTypeNamesForSObject(opp);
                for(String name : OppRTNames) {
                    if (name <> 'Master') {
                        rtName = name;
                        break;
                    }
                }
                RecordType rt = [Select Id from RecordType where Name = :rtName];
                opp.RecordTypeId = rt.Id;
            }
        } 
        catch (Exception ex) {
            System.debug('====== An error occurred while evaluating the Record Type:  ' + ex);          
        }       
    }
    
    // Called by the VF page's action method, redirects the user to the correct VF page for this Opportunity record type
    public PageReference redirect(){
        /*if (rtName == 'Quadro Sales Opportunity' || rtName == 'Tesla Sales Opportunity' || rtName == 'Tegra Auto and Emb Opportunity' || rtName == 'Tegra Auto OEM Opportunity' 
        	|| rtName == 'Tegra Auto Tier 1 Opportunity' || rtName == 'Tegra Embedded Opportunity' || rtName == 'Tegra Tablets, SB, SP Opportunity' 
        	|| rtName == 'Embedded Entertainment Opportunity' || rtName == 'GeForce Sales Opportunity' || rtName == 'GRID Partner Opportunity' || rtName == 'Tesla Partner Opportunity' 
        	|| rtName == 'GRID Sales Opportunity' || rtName == 'Quadro Partner Opportunity') {
		*/
		//map<string, Opportunity_ReEngineering_Utility.Opportunity_ReEngineering_Config_Settings_Wrapper>  mapOpptyConfigWrapper = Opportunity_ReEngineering_Utility.getAllReEngineeredOpptyRecTypeAndConfigDetailsFromCS();
		map<string, Pricebook_Details__c> allOpptyReEngineeringConfigDetails = Pricebook_Details__c.getAll();
		if (allOpptyReEngineeringConfigDetails.keySet().contains(rtName)){
            string url = '/apex/vfOpportunityV2?accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&param=New';
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            return pageRef;
        } 
        /*
         * @Manideep - Opportunity RecordType Cleanup
        else if (rtName == Opportunity_ReEngineering_Constants.RT_NOTEBOOK_OPPORTUNITY) {
            String url = '/apex/Opportunity_And_Products?id=' + opp.AccountId + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity';
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            return pageRef;
        }
        */ 
        /*
        else if (rtName == 'Quadro Sales Opportunity') {
            String url = '/apex/Quadro_OppAndProducts?id=' + opp.AccountId + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity';
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            return pageRef;         
        } 
        else if (rtName == 'Tesla Sales Opportunity') {
            String url = '/apex/Tesla_OppAndProducts?id=' + opp.AccountId + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity';
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            return pageRef;         
        } 
        else if (rtName == 'Tegra Auto and Emb Opportunity') {
            String url = '/apex/TegraAuto_OppAndProducts?id=' + opp.AccountId + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity';
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            return pageRef;         
        } 
        else if (rtName == 'Tegra Auto OEM Opportunity') {
            String url = '/apex/TegraAuto_OppAndProducts?id=' + opp.AccountId + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity';
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            return pageRef;         
        } 
        else if (rtName == 'Tegra Auto Tier 1 Opportunity') {
            String url = '/apex/TegraAuto_OppAndProducts?id=' + opp.AccountId + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity';
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            return pageRef;         
        }
        else if (rtName == 'Tegra Embedded Opportunity') {
            String url = '/apex/TegraAuto_OppAndProducts?id=' + opp.AccountId + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity';
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            return pageRef;         
        }
        else if (rtName == 'Tegra Embedded Opportunity Record Type') {
            String url = '/apex/TegraEmbedded_OppAndProducts?id=' + opp.AccountId + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity';
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            return pageRef;         
        }
        else if (rtName == 'Tegra Tablets, SB, SP Opportunity') {
            String url = '/apex/TegraTablet_OppAndProducts?id=' + opp.AccountId + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity';
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            return pageRef;         
        }
        else if (rtName == 'Embedded Entertainment Opportunity') {
            String url = '/apex/Emb_Ent_OppAndProducts?id=' + opp.AccountId + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity';
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            return pageRef;         
        }  
        else if (rtName == 'GeForce Sales Opportunity') {
            String url = '/apex/GeForce_OppAndProducts?id=' + opp.AccountId + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity';
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            return pageRef;         
        } 
        */ 
        else {
            // For other record types, redirect to the standard New Opportunity page, ignoring
            // any overrides that are configured.
            String url = '/' + Opportunity.SObjectType.getDescribe().getKeyPrefix() + '/e?&nooverride=1&RecordType=' + opp.RecordTypeId;
            // Add the Account Id (if we know it) to the URL, as well as a few other parameters
            if (opp.AccountId <> null) url += '&accid=' + opp.AccountId;
            if (ApexPages.currentPage().getParameters().containsKey('retURL')) url += '&retURL=' + ApexPages.currentPage().getParameters().get('retURL');
            if (ApexPages.currentPage().getParameters().containsKey('cancelURL')) url += '&cancelURL=' + ApexPages.currentPage().getParameters().get('cancelURL');
            return new PageReference(url);
        }
    }
    
}