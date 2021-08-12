/*
	2019.07.27 - pjena - Test class Batch class DiscoverDataMigration_DevEventAttendance to update 	Developer_Event_Attendance__c with new Dev Contact Id(One time Data Migration need, delete this after the data migration is done)
	2019.10.04 - Cleanup after Discover Data Deletion is done, ready to be deleted
 */
 
@isTest(SeeAllData=false)
private class Test_DiscoverDataMigration_DEA {
    static testMethod void myUnitTest() {
        test.startTest();
        	DiscoverDataMigration_DevEventAttendance oDDM = new DiscoverDataMigration_DevEventAttendance();
        test.stopTest();
    }
}