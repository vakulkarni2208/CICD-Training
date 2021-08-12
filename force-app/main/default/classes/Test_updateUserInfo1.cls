@isTest
private class Test_updateUserInfo1 {
 
  static testMethod void myUnitTest(){
  
    updateUserInfo obj = new updateUserInfo();
    obj.email = 'test@salesforce.com';   
    obj.phone = '5169988196';
    obj.firstname = 'Sushma';
    obj.lastname = 'Gurrala';
    obj.title = 'Salesforce Administrator';
    obj.updateUserDetail();

  }
  
}