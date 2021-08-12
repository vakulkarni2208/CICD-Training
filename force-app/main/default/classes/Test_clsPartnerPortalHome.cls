@isTest(seeAllData=true)
private class Test_clsPartnerPortalHome {


    static testMethod void myUnitTest() {
  clsPartnerPortalHome objGridPortal = new clsPartnerPortalHome();
      /*  GRID_VCA_Instant_Message__c objGridVCAMsg = new GRID_VCA_Instant_Message__c();
        objGridVCAMsg.Start_Date__c = System.today();  
        objGridVCAMsg.Expiration_Date__c = System.today() + 2;
        objGridVCAMsg.Message__c = 'Hello World';                     
        insert objGridVCAMsg;        
        //User u = [select Id,Profile.Name,Profile.Id from User where isActive=true AND ContactId != null limit 1];
        User u = [select id,Profile.Name,Profile.Id from User where isActive=true and userName=:Label.PortalUserName   limit 1];
        GRID_Portal_Profiles__c obj = new GRID_Portal_Profiles__c();
        obj.Name = u.Profile.Name;
        insert obj;

        Portal_Permission_Sets__c objPortalPermissionSet = new Portal_Permission_Sets__c();
        // objPortalPermissionSet.Name = 'Campaigns_Permission_Box';
        objPortalPermissionSet.Name = 'SALES_PARTNER_PORTAL_PARTNER_DEPOT_Box';
        insert objPortalPermissionSet;
        
        Portal_Home_Page_Box__c objectPortalHomeBox = new Portal_Home_Page_Box__c();
        objectPortalHomeBox.Portal_Permission_Set__c = objPortalPermissionSet.id;
        objectPortalHomeBox.Name = objPortalPermissionSet.Name;
        objectPortalHomeBox.Box_Serial_Number__c = 1;
        insert objectPortalHomeBox;
        
        Partner_Portal_Label__c objPartner_Portal_Label = new Partner_Portal_Label__c();
        objPartner_Portal_Label.Permission_Set__c = objPortalPermissionSet.Id;
        objPartner_Portal_Label.Portal_Content_Type__c = 'GRID';
        objPartner_Portal_Label.Label_Serial_Number__c = 1;
        insert objPartner_Portal_Label;
        
        
        
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
          clsPartnerPortalHome objGridPortal = new clsPartnerPortalHome();
          clsPartnerPortalHome.wrapperMain objWrapperMain = new clsPartnerPortalHome.wrapperMain(); 
          clsPartnerPortalHome.wrapper objWrapper = new clsPartnerPortalHome.wrapper();          
          clsPartnerPortalHome.wrapperMain objWrapperMain1 = new clsPartnerPortalHome.wrapperMain(); 
          clsPartnerPortalHome.wrapper objWrapper1 = new clsPartnerPortalHome.wrapper();          

          objGridPortal.sendEmail_AskAQuestion();
          objGridPortal.closePopup_AskAQuestion();
          objGridPortal.showPopup_AskAQuestion();
          objGridPortal.showPopup_LogASupportRequest();
          objGridPortal.emailReportAProblem = 'test@salesforce.com';
          objGridPortal.phoneNumber = '9876543210';
          objGridPortal.Attach = blob.valueOf('abc');
          objGridPortal.problemDescription = '';
          objGridPortal.steptoReproduceProblem = '';
          objGridPortal.sendEmail_LogASupportRequest();
          objGridPortal.closePopup_LogASupportRequest();
          objGridPortal.closePopup_AskAQuestion();
          
          List<clsPartnerPortalHome.wrapper> lstWrapper = new List<clsPartnerPortalHome.wrapper>();
          objWrapper.serialNo  = 1;
          objWrapper1.serialNo  = 2;
          lstWrapper.add(objWrapper);
          lstWrapper.add(objWrapper1);
          
          List<clsPartnerPortalHome.wrapperMain> lstWrapperMain = new List<clsPartnerPortalHome.wrapperMain>();
          objWrapperMain.srno = 1.00;
          objWrapperMain1.srno = 2.00;
          objWrapperMain.lstW  = lstWrapper;
          objWrapperMain1.lstW  = lstWrapper;
          lstWrapperMain.add(objWrapperMain);
          lstWrapperMain.add(objWrapperMain1);
          
          objGridPortal.sorting(lstWrapperMain);
          objGridPortal.sorting(lstWrapper);          
        }*/
    }
}