public class portalHeaderControllerPhase2 {

    public string UserName {get;set;}
    public string CurrentTab{get; set;}
    public boolean isNewsPage{get; set;}
    public string ReferrerURL{get; set;}    
    
    public String usrProfileName {get;set;}
    set<string> permissionSets = new set<string>();
    set<Id> customPermissionSets = new set<Id>(); 
    public List<Partner_Portal_Tab__c>lstTabs {get;set;}
    
    public portalHeaderControllerPhase2(){
        UserName = 'Welcome'+UserInfo.getUserName();
        ReferrerURL = ApexPages.currentPage().getHeaders().get('Referer');
        CurrentTab = ReferrerURL.right(ReferrerURL.length() - (ReferrerURL.indexOf('=')+1));
        if(ReferrerURL.right(14) == 'portalNewsPage') {
                isNewsPage = true;
        }
        usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
               
        // put a check for Tab which will must cotain a keyword     'Tab'      
        for(PermissionSetAssignment psa :[SELECT AssigneeId,Id,PermissionSetId,PermissionSet.Name FROM PermissionSetAssignment where AssigneeId=:UserInfo.getUserId()]){
            if(psa.PermissionSet.Name.contains('Tab'))
              permissionSets.add(psa.PermissionSet.Name);
        }
        system.debug('check---------'+permissionSets); 
             
        
        for(Portal_Permission_Sets__c PortalPermissionSet : [select Id,Name,(select Id,Name from Partner_Portal_Boxes__r) from Portal_Permission_Sets__c where Name in :permissionSets]){
           //if(PortalPermissionSet.Partner_Portal_Boxes__r.size()>0){
               //put a condition here that user has that box visbility which is inside this Tab.
               customPermissionSets.add(PortalPermissionSet.Id); 
           //}           
        }
        lstTabs = new List<Partner_Portal_Tab__c>([select id, Name, Tab_URL__c, Sort_Order__c from Partner_Portal_tab__c where Permission_Set__c in:customPermissionSets order by Sort_Order__c]);   
    }
        
    public pagereference home(){
        pagereference page = new pagereference('/apex/portalSales').setRedirect(true);
        return page;
    }
    
}