/*
	2019.07.27 - pjena - Test class Batch class DiscoverDataMigration_Contact to Migrate DISCOVER Contacts to Dev_Contacts	(One time Data Migration need, delete this after the data migration is done)
	2019.10.04 - Cleanup after Discover Data Deletion is done, ready to be deleted
 */
 
@isTest(SeeAllData=false)
private class Test_DiscoverDataMigration_Contact {
    static testMethod void myUnitTest() {
        test.startTest();
        	DiscoverDataMigration_Contact oDDM = new DiscoverDataMigration_Contact();
        test.stopTest();
    }
}