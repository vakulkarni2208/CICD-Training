@isTest
private class Test_popupModal   {

    static testMethod void myUnitTest() {
        
        popupModal  obj = new popupModal ();
        obj.subject  = 'Subject';
        obj.body  = 'Body of email';
        obj.sendEmail();
        obj.closePopup();
        obj.showPopup();
        
    }
}