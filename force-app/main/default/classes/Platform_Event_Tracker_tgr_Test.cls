/*
    2021.04.01 - PJENA - Test class for platform event trigger Platform_Event_Tracker_tgr on Platform_Event_Tracker__e
*/

@isTest(SeeAllData=false)
public  class Platform_Event_Tracker_tgr_Test {
    static testMethod void testCreateEvent1() {
        Test.startTest();
        
        //Publish a test event
        Platform_Event_Tracker__e event = new Platform_Event_Tracker__e(RecordId__c = '123456789123456789', ObjectName__c = 'Opportunity', EventName__c = 'NPNOEMODMDISTI');
        Database.SaveResult sr = EventBus.publish(event);

        //Verify that the publish was successful
        System.assertEquals(true, sr.isSuccess());

        //Deliver the test event before Test.stopTest()
        Test.getEventBus().deliver();    

        //Check that the trigger created evePlatform_Event_Tracker_Processor__c record is present.
         List<Platform_Event_Tracker_Processor__c> lstEventTracker = [SELECT Id FROM Platform_Event_Tracker_Processor__c];
         
        //Validate that this task was found.
        Integer RecordCount = lstEventTracker.size();
        system.assertEquals(1, RecordCount);

        Test.stopTest();
    }
}