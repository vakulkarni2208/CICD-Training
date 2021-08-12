public class NV_PartnerCommunityHeader {

    public string CurrentTab {get; set;}
    public List<Partner_Portal_Tab__c> lstTabs {get;set;}
    
    public class PPTabWrapper{
        public string tabName{get;set;}
        public string tabLocalName{get;set;}
        public string tabURL{get;set;}
    }
    public list<PPTabWrapper> lstPPTabWrapper{get;set;}
    
    public NV_PartnerCommunityHeader(){
        string ReferrerURL = ApexPages.currentPage().getHeaders().get('Referer');
        CurrentTab = ReferrerURL.right(ReferrerURL.length() - (ReferrerURL.indexOf('=')+1));
        //CurrentTab = ApexPages.currentPage().getParameters().get('tab');
        //get the country filter of the logged on user,
        //-----------------------------------------------------------
        /*
        Logic: If the user records langauge is found in the Community_User_Local_Settings__c then user the use the matching record otherwise default it to English
        */
        string currUserLocaleLangKey = UserInfo.getLanguage();
        string currUserLangName = COMM_Utility.getUserLanguage(currUserLocaleLangKey);
        //-----------------------------------------------------------
        
               
        //Find all the Permission Sets of the logged on User ending with 'Tab'
        set<string> userPSAsWithTab = new set<string>();  
        for(PermissionSetAssignment psa :[Select PermissionSet.Name From PermissionSetAssignment Where AssigneeId=:UserInfo.getUserId() And PermissionSet.Name like '%Tab']){
              userPSAsWithTab.add(psa.PermissionSet.Name);
        }
        
             
        set<Id> userPortalPSsWithTab = new set<Id>();
        for(Portal_Permission_Sets__c PortalPermissionSet : [Select Id From Portal_Permission_Sets__c Where Name in :userPSAsWithTab]){
           //if(PortalPermissionSet.Partner_Portal_Boxes__r.size()>0){
               //put a condition here that user has that box visbility which is inside this Tab.
               userPortalPSsWithTab.add(PortalPermissionSet.Id); 
           //}           
        }
        
        //Get list of Tabs for the GRID VCA Partner Portal and having the Permission Set mapped
        lstTabs = new List<Partner_Portal_Tab__c>([ Select id, Name, Local_Name__c, Community_Tab_URL__c 
                                                    From Partner_Portal_tab__c 
                                                    Where Permission_Set__c in :userPortalPSsWithTab
                                                        And Partner_PortalName__r.name =:COMM_Constants.PP_GRID_VCA_NAME
                                                        And (Language__c = :currUserLangName Or Language__c = null)
                                                    Order By Sort_Order__c]);
        
        //build the lstPPTabWrapper list
        lstPPTabWrapper = new list<PPTabWrapper>();
        for (Partner_Portal_Tab__c ppTab : lstTabs){
            PPTabWrapper tabWrapper = new PPTabWrapper();
            tabWrapper.tabName = ppTab.Name;
            tabWrapper.tabLocalName = ppTab.Local_Name__c;
            tabWrapper.tabURL = ppTab.Community_Tab_URL__c;
            
            lstPPTabWrapper.add(tabWrapper);
        }
        system.debug('lstPPTabWrapper = '+lstPPTabWrapper);
        system.debug('CurrentTab = '+CurrentTab);
        system.debug(ApexPages.currentPage().getHeaders() + ' = ApexPages.currentPage().getHeaders()' );
    }
        
    public pagereference home(){
        pagereference page = new pagereference('/apex/NV_PartnerCommunityTabs').setRedirect(true);
        return page;
    }
    
    //Delete the Portal Content Type custom setting record for the logged in user and delete it
    public pagereference deleteCustomSettingBeforeLogOut(){
        Portal_Content_Type__c userPortalContentType = Portal_Content_Type__c.getValues(UserInfo.getUserId());
        if(userPortalContentType != null){
            delete userPortalContentType;
        }
        return null;
    }
    
}