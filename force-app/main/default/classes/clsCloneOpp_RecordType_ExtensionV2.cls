/*
 *  Class: CloneOpportunityRecordType_Extention
 *
 *  Type: Controller Extension to an Opportunity Controller
 *
 *  Functionality: This class is a extension to the standard Opportunity controller, for Opportunity Edits, 
 *      and is called from the Edit button on an Opportunity.  You can only override a Standard Button with
 *      a Standard Controller, hence this extension, which redirects to the Opportunity_And_Products page
 *
 *  Created by: Raj Gade
 * 
 * @Manideep: 1/18/2019 - This code is updated by commenting out unwanted logic as part of Opportunity RecordType Cleanup.
*/
public class clsCloneOpp_RecordType_ExtensionV2 {

    private String rtName;
    private final Opportunity opp;

    public clsCloneOpp_RecordType_ExtensionV2(ApexPages.StandardController stdController) {
        
        opp = (Opportunity)stdController.getRecord();
        
    }
    
    public PageReference redirect(){
    rtName = [Select Name from RecordType where Id = :opp.RecordTypeId].Name;
    
        //if (rtName == 'Quadro Sales Opportunity' || rtName == 'Tesla Sales Opportunity' || rtName == 'Tegra Auto and Emb Opportunity' || rtName == 'Tegra Auto OEM Opportunity' || rtName == 'Tegra Auto Tier 1 Opportunity' || rtName == 'Tegra Embedded Opportunity' || rtName == 'Tegra Tablets, SB, SP Opportunity' || rtName == 'Embedded Entertainment Opportunity' || rtName == 'GeForce Sales Opportunity' || rtName == 'GRID Partner Opportunity' || rtName == 'Tesla Partner Opportunity') {
        //map<string, Opportunity_ReEngineering_Utility.Opportunity_ReEngineering_Config_Settings_Wrapper>  mapOpptyConfigWrapper = Opportunity_ReEngineering_Utility.getAllReEngineeredOpptyRecTypeAndConfigDetailsFromCS();
		map<string, Pricebook_Details__c> allOpptyReEngineeringConfigDetails = Pricebook_Details__c.getAll();
		if (allOpptyReEngineeringConfigDetails.keySet().contains(rtName)){
            string url = '/apex/vfOpportunityV2?accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&param=Clone&id='+opp.id;   
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            return pageRef;         
        } 
        /*
         * @Manideep - Opportunity RecordType Cleanup
        else if (rtName == Opportunity_ReEngineering_Constants.RT_NOTEBOOK_OPPORTUNITY) {
            // Use the custom OpportunityAndProduct_controller and page, passing the Opportunity Id as the Id rather than Account Id
            string url = '/apex/Opportunity_And_Products?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true&isClone=true';
            return new PageReference(url);  
        } 
        */
        /*
        else if (rtName == 'Quadro Sales Opportunity') {
            // Use the custom Quadro_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/Quadro_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true&isClone=true';
            return new PageReference(url);  
        } 
        else if (rtName == 'Tesla Sales Opportunity') {
            // Use the custom Tesla_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/Tesla_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true&isClone=true';
            return new PageReference(url);  
        } 
        else if (rtName == 'Tegra Auto and Emb Opportunity') {
            // Use the custom TegraAuto_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/TegraAuto_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true&isClone=true';
            return new PageReference(url);  
        } 
        else if (rtName == 'Tegra Tablets, SB, SP Opportunity') {
            // Use the custom TegraTablet_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/TegraTablet_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true&isClone=true';
            return new PageReference(url);  
        }
        else if (rtName == 'Tegra Embedded Opportunity Record Type') {
            // Use the custom TegraEmbedded_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/TegraEmbedded_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true&isClone=true';
            return new PageReference(url);  
        }
        else if (rtName == 'Embedded Entertainment Opportunity') {
            // Use the custom Emb_Ent_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/Emb_Ent_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true&isClone=true';
            return new PageReference(url);  
        }     
        else if (rtName == 'GeForce Sales Opportunity') {
            // Use the custom GeForce_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/GeForce_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true&isClone=true';
            return new PageReference(url);  
        } 
        */           
        else {
            // Other recordtypes use the appropriate Opportunity edit page
            String url = '/' + opp.id + '/e?nooverride=1';
            if (ApexPages.currentPage().getParameters().containsKey('retURL')) url += '&retURL=' + ApexPages.currentPage().getParameters().get('retURL');
            if (ApexPages.currentPage().getParameters().containsKey('cancelURL')) url += '&cancelURL=' + ApexPages.currentPage().getParameters().get('cancelURL');
            return null;
        }
    }
}