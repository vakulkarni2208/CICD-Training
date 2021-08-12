/*
	2019.07.27 - pjena - Test class Batch class DiscoverDataMigration_Account to update Dev_Account names from Discover Accounts	(One time Data Migration need, delete this after the data migration is done)
	SDS-1679 - INFRA: Discover Data Migration Batch Job to retain double byte characters
	2019.10.04 - Cleanup after Discover Data Deletion is done, ready to be deleted
 */
 
@isTest(SeeAllData=false)
private class Test_DiscoverDataMigration_Account {

    static testMethod void myUnitTestSuccess() {
		test.startTest();
        	DiscoverDataMigration_Account oDDM = new DiscoverDataMigration_Account();
        test.stopTest();
        
    }
    
}