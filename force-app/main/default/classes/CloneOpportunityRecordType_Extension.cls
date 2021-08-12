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
 * 5/8/2019 - @Manideep - The code is commented out as part of Opportunity RecordType cleanup process.
*/
public class CloneOpportunityRecordType_Extension {
    
    // Dummy method for code coverage
    // This method is coverred by the class 'UnitTests_DummyCodeCoverage_DEL_Classes.cls'
    public static void fakeMethod(){
      Integer i = 0;
      i++;
    }
    
    /*
     * @Manideep - Opportunity RecordType Cleanup
     
    private final Opportunity opp;

    public CloneOpportunityRecordType_Extension(ApexPages.StandardController stdController) {
        
        opp = (Opportunity)stdController.getRecord();
        
    }
    
    public PageReference redirect(){
    
        RecordType rt = [Select Name from RecordType where Id = :opp.RecordTypeId];
        
        if (rt.Name == 'Notebook Opportunity') {
            // Use the custom OpportunityAndProduct_controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/Opportunity_And_Products?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true&isClone=true';
            return new PageReference(url);  
        } 
        else if (rt.Name == 'Quadro Sales Opportunity') {
            // Use the custom Quadro_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/Quadro_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true&isClone=true';
            return new PageReference(url);  
        } 
        else if (rt.Name == 'Tesla Sales Opportunity') {
            // Use the custom Tesla_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/Tesla_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true&isClone=true';
            return new PageReference(url);  
        } 
        else if (rt.Name == 'Tegra Auto and Emb Opportunity') {
            // Use the custom TegraAuto_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/TegraAuto_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true&isClone=true';
            return new PageReference(url);  
        } 
        else if (rt.Name == 'Tegra Tablets, SB, SP Opportunity') {
            // Use the custom TegraTablet_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/TegraTablet_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true&isClone=true';
            return new PageReference(url);  
        }
        else if (rt.Name == 'Embedded Entertainment Opportunity') {
            // Use the custom Emb_Ent_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/Emb_Ent_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true&isClone=true';
            return new PageReference(url);  
        } 
        //else if (rt.Name == 'Tegra Embedded Opportunity Record Type') 
        else if (rt.Name == 'Tegra Embedded Opportunity') {
            // Use the custom TegraEmbedded_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/TegraEmbedded_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true&isClone=true';
            return new PageReference(url);  
        }    
        else if (rt.Name == 'GeForce Sales Opportunity') {
            // Use the custom GeForce_OppAndProducts_Controller and page, passing the Opportunity Id as the Id rather than Account Id
            String url = '/apex/GeForce_OppAndProducts?id=' + opp.Id + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity&isEdit=true&isClone=true';
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