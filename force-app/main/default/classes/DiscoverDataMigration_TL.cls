/*
	2019.07.27 - pjena - Batch class to Update Tags_List__c (One time Data Migration need, delete this after the data migration is done)
	
	//Run it in Developer Console or Workbench
	DiscoverDataMigration_TL oDiscoverDataMigration_TL = new DiscoverDataMigration_TL();
	database.executeBatch(oDiscoverDataMigration_TL , 200);			

	2019.10.04 - Cleanup after Discover Data Deletion is done, ready to be deleted
*/

public class DiscoverDataMigration_TL{
	//Constructor accepting next execution time in minutes and the lookback time
    public DiscoverDataMigration_TL(){}
}