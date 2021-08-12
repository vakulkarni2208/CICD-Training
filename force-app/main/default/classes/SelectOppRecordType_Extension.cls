/*
 *  Class: SelectOppRecordType_Extension
 *
 *  Type: Controller Extension to an Opportunity Controller
 *
 *  This class is a extension to the standard Opportunity controller, 
 *  and is called from the New Opportunities button (on Accounts or Opportunities tab).
 *  If the user has create permissions for more than one Opportunity Record Type, then
 *  the standard controller's Opportunity's RecordTypeId will tell us which RT the user
 *  selected.
 *  If the user has create permissions for only one Opportunity Record Type, then we
 *  won't know what the Record Type is, so we have to determine it.
 *  In both cases, once we know what the record type is, we redirect the user to the
 *  correct page to create a new Opportunity of that type.
 *
 *  Created by: Duncan Stewart, for OpFocus, Summer 2010
 *
 * 5/8/2019 - @Manideep - The code is not being used and commented out as part of Opportunity RecordType Cleanup.
*/
public class SelectOppRecordType_Extension {

    // Dummy method for code coverage
    // This method is coverred by the class 'UnitTests_DummyCodeCoverage_DEL_Classes.cls'
    public static void fakeMethod(){
      Integer i = 0;
      i++;
    }
    
    /*
     * @Manideep - Opportunity RecordType Cleanup
    private final Opportunity opp;
    private String rtName;
    private Boolean isEdit = false;

    public SelectOppRecordType_Extension(ApexPages.StandardController stdController) {
        
        try{
                
            opp = (Opportunity)stdController.getRecord();
 
            if(opp.RecordTypeId <> null){
                // We already know what Record Type this new Opp is for. Get its name
                rtName = [Select Name from RecordType where Id = :opp.RecordTypeId].Name;
            } 
            else {
                // We don't know what Record Type this new Opp is for. 
                // Find out the one Record Type the user has Create permissions for         
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
    
    
    // Called by the VF page's action method, redirects the user to the
    // correct VF page for this Opportunity record type
    public PageReference redirect(){
        
        if (rtName == 'Notebook Opportunity') {
            String url = '/apex/Opportunity_And_Products?id=' + opp.AccountId + '&accid=' + opp.AccountId + '&RecordType=' + opp.RecordTypeId + '&ent=Opportunity';
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            return pageRef;         
        } 
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
*/    
}