@isTest
private class Test_clsPartnerPortalPopupModal   {

    static testMethod void myUnitTest() {
        
        clsPartnerPortalPopupModal  obj = new clsPartnerPortalPopupModal ();
        obj.subject  = 'Subject';
        obj.body  = 'Body of email';
        obj.sendEmail();
        obj.closePopup();
        obj.showPopup();
        
    }
}