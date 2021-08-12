@isTest(seeAllData=false)
public class Test_ESP_DGXStationCoolentNotify_BAT_SCH{

@isTest
public static void testDGXNotificationBatch(){
Test.startTest();
Account acc = Test_COMM_Factory.getAccount('dgxAcc');
insert acc;
Contact con = Test_COMM_Factory.getContact(acc.id);
con.is_DGX_Contact__c     = true;
con.Synced_IDM_DGX__c     = true;
insert con;
Profile prof= [select id from Profile where name = 'ESP Community User' limit 1];
User u = Test_COMM_Factory.createUser(con.id,prof.id);
con.community_user__c = u.id;
update con;
Product2 prd = Test_COMM_Factory.getProduct('DGX Station Product Family');
prd.family='DGX Station Product Family';
insert prd;
Contract contr = Test_COMM_Factory.getContract(acc.id);
insert contr;
SBQQ__Subscription__c subsription = Test_COMM_Factory.getSubscription(acc.Id, prd.Id, contr.Id);
insert subsription;
Entitlement ent = Test_COMM_Factory.getEntitlement('DGX Station Product Family',acc.id);
ent.startDate= system.Today().addYears(-1);
ent.EndDate= system.Today().addYears(1);
ent.Service_product__c = prd.id;
ent.Subscription__c = subsription.id;
ent.hardware_serial_number__c = '12345';
insert ent;
Announcement__c announce = Test_COMM_Factory.getAnnouncement('NVIDIA DGX Station Coolant Top Up Kit Now Available',null);
announce.Access_Level__c = 'Customer Specific';
insert announce;
SchedulableContext sc = null;
ESP_DGXStationCoolentNotify_BAT_SCH tsc = new ESP_DGXStationCoolentNotify_BAT_SCH();
tsc.execute(sc);
//ESP_DGXStationCoolentNotify_BAT_SCH dgx = new ESP_DGXStationCoolentNotify_BAT_SCH();
//Database.executeBatch(dgx,20);
Test.stopTest();
}

}