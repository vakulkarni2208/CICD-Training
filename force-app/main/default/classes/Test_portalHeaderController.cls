@isTest
private class Test_portalHeaderController {

    static testMethod void myUnitTest() {
        
        Partner_Portal__c objPartnerPortal = new Partner_Portal__c(); 
        objPartnerPortal.Name = 'GRID_VCA_Partner Portal';
        objPartnerPortal.Login_URL__c = 'https://cs12.salesforce.com/secur/login_portal.jsp?orgId=00DV000000054qp&portalId=06040000000D7uX';
        insert objPartnerPortal;
        
        Partner_Portal_Tab__c objPartnerPortalTab = new Partner_Portal_Tab__c();
        objPartnerPortalTab.Name = 'Sales';
        objPartnerPortalTab.Tab_URL__c = 'http:///apex/GRID_portalSales1?tab=Sales';
        objPartnerPortalTab.Partner_Profiles__c = 'GRID_VCA_Marketing; GRID_VCA_Sales; GRID_VCA_Manager';
        objPartnerPortalTab.Sort_Order__c = 1;
        objPartnerPortalTab.Partner_PortalName__c = objPartnerPortal.Id;
        insert objPartnerPortalTab;
        
        ApexPages.currentPage().getHeaders().put('Referer','https://c.cs12.visual.force.com/apex/portalNewsPage?tab=Sales');
        portalHeaderController obj = new portalHeaderController();
        obj.home();
        
    }
}