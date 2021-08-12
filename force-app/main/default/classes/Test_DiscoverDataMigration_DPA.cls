/*
	2019.07.27 - pjena - Test class Batch class DiscoverDataMigration_DPA to update 	Developer_Program_Application__c with new Dev Contact Id(One time Data Migration need, delete this after the data migration is done)
	2019.10.04 - Cleanup after Discover Data Deletion is done, ready to be deleted
 */
 
@isTest(SeeAllData=false)
private class Test_DiscoverDataMigration_DPA {
    static testMethod void myUnitTest() {
        test.startTest();
        	DiscoverDataMigration_DPA oDPA = new DiscoverDataMigration_DPA();
        test.stopTest();
    }
    
}