@isTest
private class Test_portalSales1 {

    static testMethod void myUnitTest() {
        
        ApexPages.CurrentPage().getParameters().put('tab','Sales');
        GRID_VCA_Instant_Message__c objGridVCAMsg = new GRID_VCA_Instant_Message__c();
        objGridVCAMsg.Start_Date__c = System.today();  
        objGridVCAMsg.Expiration_Date__c = System.today() + 2;
        objGridVCAMsg.Message__c = 'Hello World';                     
        insert objGridVCAMsg;
        
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
        
        GRID_Portal_Profiles__c objGRID_Portal_Profile = new GRID_Portal_Profiles__c();
        objGRID_Portal_Profile.Name = 'GRID_VCA_Sales'; 
        insert  objGRID_Portal_Profile ;       
                 
        Partner_Portal_Label__c objPartnerPortalLabels = new Partner_Portal_Label__c();
        objPartnerPortalLabels.Name = 'Product Information';
        objPartnerPortalLabels.Partner_Portal_Tab__c =  objPartnerPortalTab.Id;
        objPartnerPortalLabels.Label_Serial_Number__c = 1;
        objPartnerPortalLabels.Display_Bullet__c  = true;
        objPartnerPortalLabels.GRID_Portal_Profile__c = objGRID_Portal_Profile.Id; 
        insert objPartnerPortalLabels;
        
        Partner_Portal_Links__c objPartner_Portal_Links = new Partner_Portal_Links__c();
        objPartner_Portal_Links.Partner_Portal_Label__c = objPartnerPortalLabels.Id;
        objPartner_Portal_Links.Link_Serial_Number__c = 1;
        objPartner_Portal_Links.Name = 'Specifications';
        objPartner_Portal_Links.Display_Page__c = 'Open in a New Tab';
        objPartner_Portal_Links.URL__c  = 'http://www.google.co.in/';
        objPartner_Portal_Links.Portal_Link_Name__c = 'Specifications';       
        insert  objPartner_Portal_Links;
         
        Partner_Portal_Links__c objPartner_Portal_Links1 = new Partner_Portal_Links__c();
        objPartner_Portal_Links1.Partner_Portal_Label__c = objPartnerPortalLabels.Id;
        objPartner_Portal_Links1.Link_Serial_Number__c = 2;
        objPartner_Portal_Links1.Name = 'Specifications';
        objPartner_Portal_Links1.Display_Page__c = 'Open in a New Tab';
        objPartner_Portal_Links1.URL__c  = 'http://www.google.co.in/';
        objPartner_Portal_Links1.Portal_Link_Name__c = 'Specifications';       
        insert  objPartner_Portal_Links1;     
                         
        Partner_Portal_Label__c objPartnerPortalLabels1 = new Partner_Portal_Label__c();
        objPartnerPortalLabels1.Name = 'Competitive Info';
        objPartnerPortalLabels1.Partner_Portal_Tab__c =  objPartnerPortalTab.Id;
        objPartnerPortalLabels1.Label_Serial_Number__c = 2;
        objPartnerPortalLabels1.Display_Bullet__c  = true;
        objPartnerPortalLabels1.GRID_Portal_Profile__c = objGRID_Portal_Profile.Id;
        insert objPartnerPortalLabels1;
        
        Partner_Portal_Links__c objPartner_Portal_Links2 = new Partner_Portal_Links__c();
        objPartner_Portal_Links2.Partner_Portal_Label__c = objPartnerPortalLabels1.Id;
        objPartner_Portal_Links2.Link_Serial_Number__c = 1;
        objPartner_Portal_Links2.Name = 'Specifications';
        objPartner_Portal_Links2.Display_Page__c = 'Open in a New Tab';
        objPartner_Portal_Links2.URL__c  = 'http://www.google.co.in/';
        objPartner_Portal_Links2.Portal_Link_Name__c = 'Specifications';       
        insert  objPartner_Portal_Links2;

         
        Partner_Portal_Label__c objPartnerPortalLabels2 = new Partner_Portal_Label__c();
        objPartnerPortalLabels2.Name = 'Case Studies';
        objPartnerPortalLabels2.Partner_Portal_Tab__c =  objPartnerPortalTab.Id;
        objPartnerPortalLabels2.Label_Serial_Number__c = 3;
        objPartnerPortalLabels2.Display_Bullet__c  = true;
        objPartnerPortalLabels2.GRID_Portal_Profile__c = objGRID_Portal_Profile.Id; 
        insert objPartnerPortalLabels2;
         
        Partner_Portal_Links__c objPartner_Portal_Links3 = new Partner_Portal_Links__c();
        objPartner_Portal_Links3.Partner_Portal_Label__c = objPartnerPortalLabels2.Id;
        objPartner_Portal_Links3.Link_Serial_Number__c = 1;
        objPartner_Portal_Links3.Name = 'Specifications';
        objPartner_Portal_Links3.Display_Page__c = 'Open in a New Tab';
        objPartner_Portal_Links3.URL__c  = 'http://www.google.co.in/';
        objPartner_Portal_Links3.Portal_Link_Name__c = 'Specifications';       
        insert  objPartner_Portal_Links3;     
                                       
        portalSales1.wrapperData wrapData = new portalSales1.wrapperData();
        portalSales1.wrapper wrap = new portalSales1.wrapper();
        List<portalSales1.wrapper> lstWrap = new List<portalSales1.wrapper>();
        lstWrap.add(wrap);
        portalSales1.CustomWrap customWrap = new portalSales1.CustomWrap(lstWrap);
        try{
        User u = [select id from User where isActive=true and Profile.Name='GRID_VCA_Sales' limit 1];
        System.runAs(u){        
            portalSales1 obj = new portalSales1();          
        }   
        }Catch(Exception ee){
            
        } 
}
}