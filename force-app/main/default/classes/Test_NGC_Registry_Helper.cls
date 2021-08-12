@isTest(seeAllData=false)
class Test_NGC_Registry_Helper{

public testmethod static void testNGCInsert(){
Test.startTest();
Account acc = Test_COMM_Factory.getAccount('test29');
insert acc;
Product2 prd = Test_COMM_Factory.getProduct('RTX3080');
insert prd;
Entitlement ent = Test_COMM_Factory.getEntitlement('test29', acc.id);
ent.Hardware_Serial_Number__c='RTX3080';
ent.service_product__c = prd.id;
insert ent;
ent = Test_COMM_Factory.getEntitlement('test29', acc.id);
ent.Hardware_Serial_Number__c='RTX3090';
ent.service_product__c = prd.id;
insert ent;
Contact con = Test_COMM_Factory.getContact(acc.id);
con.email = 'na@na.com';
insert con;
DGX_Registry_Container__c ngc = new DGX_Registry_Container__c();
ngc.Hardware_Serial_Number_PAK_Id__c = 'RTX3080';
ngc.account__C = acc.id;
ngc.entitlement__c = ent.id;
ngc.contact__c = con.id;
ngc.email_address__c = 'na@na.com';
insert ngc;
ngc = new DGX_Registry_Container__c();
ngc.Hardware_Serial_Number_PAK_Id__c = 'RTX3090';
ngc.firstname__c = 'na';
ngc.last_name__c = 'test';
ngc.email_address__c = 'na1@na1.com';
ngc.phone_number__C = '12345678';
insert ngc;
Test.stopTest();
}
}