@isTest
private class Test_clsPartnerPortalMyProfile {
 
  static testMethod void myUnitTest(){
  
    clsPartnerPortalMyProfile obj = new clsPartnerPortalMyProfile();
    obj.email = 'test@salesforce.com';   
    obj.phone = '5169988196';
    obj.firstname = 'Sushma';
    obj.lastname = 'Gurrala';
    obj.title = 'Salesforce Administrator';
    obj.updateUserDetail();

  }
  
}