@isTest
private class Test_GRID_portalHome {
 
    static testMethod void myUnitTest() {
    GRID_portalHome objGridPortal = new GRID_portalHome();
        /*GRID_VCA_Instant_Message__c objGridVCAMsg = new GRID_VCA_Instant_Message__c();
        objGridVCAMsg.Start_Date__c = System.today();  
        objGridVCAMsg.Expiration_Date__c = System.today() + 2;
        objGridVCAMsg.Message__c = 'Hello World';                     
        insert objGridVCAMsg;        
        User u = [select Id,Profile.Name from User where isActive=true AND ContactId != null limit 1];
        
        GRID_Portal_Profiles__c obj = new GRID_Portal_Profiles__c();
        obj.Name = u.Profile.Name;
        insert obj;
        
        Portal_Permission_Sets__c objPortalPermissionSet = new Portal_Permission_Sets__c();        
        // objPortalPermissionSet.Name = 'Campaigns_Permission_Box';        
        objPortalPermissionSet.Name = 'SALES_PARTNER_PORTAL_GETTING_STARTED_BOX';        
        insert objPortalPermissionSet;                
        Portal_Home_Page_Box__c objectPortalHomeBox = new Portal_Home_Page_Box__c();        
        objectPortalHomeBox.Portal_Permission_Set__c = objPortalPermissionSet.id;        
        objectPortalHomeBox.Name = objPortalPermissionSet.Name;        
        objectPortalHomeBox.Box_Serial_Number__c = 1;        
        insert objectPortalHomeBox;
        
        List<Portal_Presentation__c> lstToInsert = new List<Portal_Presentation__c>();
        for(integer i =0;i<5;i++){
          Portal_Presentation__c pBox = new Portal_Presentation__c();
          pBox.Name = 'Selling GPU';
          pBox.Image_URL__c = 'https://cs12.salesforce.com/resource/1370038993000/GRID_Presentation_Image1';
          pBox.Portal_Profile__c = u.Profile.Name;
          pBox.Presentation_Type__c = 'NEW TECHNICAL PRESENTATIONS';
          pBox.Presentation_URL__c = 'http://www.brainshark.com/nvidia/vu?pi=832992210&sid=498375518&sky=8fdd8cd8a0834446a05fffc977fc6fea&uid=1286900';
          pBox.Permission_Set__c = objPortalPermissionSet.id;          
          pBox.Portal_Home_Page_Box__c = objectPortalHomeBox.Id;
          lstToInsert.add(pBox);
        }
        if(lstToInsert.size()>0){
          insert lstToInsert;
        }
        
        System.runAs(u){
          GRID_portalHome objGridPortal = new GRID_portalHome();
          GRID_portalHome.wrapper objWrapper = new GRID_portalHome.wrapper();
          GRID_portalHome.wrapperMain objWrapperMain = new GRID_portalHome.wrapperMain(); 
          objGridPortal.sendEmail();
          objGridPortal.closePopup();
          objGridPortal.showPopup();
         objGridPortal.showPopup1();
          objGridPortal.emailReportAProblem = 'test@salesforce.com';
          objGridPortal.phoneNumber = '9876543210';
          objGridPortal.Attach = blob.valueOf('abc');
          objGridPortal.sendEmail1();
          objGridPortal.closePopup1();
        }*/
    }
}