/*
	2019.07.27 - pjena - Test class Batch class DiscoverDataMigration_DFANS to update Dev_Form_Answers__c with new Dev Contact Id(One time Data Migration need, delete this after the data migration is done)
	2019.10.04 - Cleanup after Discover Data Deletion is done, ready to be deleted
 */
 
@isTest(SeeAllData=false)
private class Test_DiscoverDataMigration_DFANS {
    static testMethod void myUnitTest() {
        test.startTest();
        	DiscoverDataMigration_DFANS oDFANS = new DiscoverDataMigration_DFANS();
        test.stopTest();
    }
}