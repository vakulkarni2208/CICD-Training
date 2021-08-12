public class portalHeaderController {
public string UserName {get;set;}
public string CurrentTab{get; set;}
public boolean isNewsPage{get; set;}
public string ReferrerURL{get; set;}
public List<Partner_Portal_Tab__c>lstTabs {get;set;}
public String usrProfileName {get;set;}
    public portalHeaderController ()
    {
        UserName = 'Welcome'+UserInfo.getUserName();
        ReferrerURL = ApexPages.currentPage().getHeaders().get('Referer');
        CurrentTab = ReferrerURL.right(ReferrerURL.length() - (ReferrerURL.indexOf('=')+1));
        if(ReferrerURL.right(14) == 'portalNewsPage') {
                isNewsPage = true;
        }
       usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
       lstTabs = new List<Partner_Portal_Tab__c>();
       lstTabs = [select id, Name, Tab_URL__c, Sort_Order__c from Partner_Portal_tab__c Where Partner_Profiles__c includes (:usrProfileName)  order by Sort_Order__c];      
       //List<Partner_Portal_Tab__c>Tabs = [select Name, Tab_URL__c from Partner_Portal_tab__c Where Partner_Profiles__c includes (:usrProfileName) order by Sort_Order__c];      
       System.debug('Tabs: ' + lstTabs);
     }
    public pagereference home(){
        pagereference page = new pagereference('/apex/portalSales').setRedirect(true);
        return page;
    }
}