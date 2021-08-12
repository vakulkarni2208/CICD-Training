/*
	2019.07.27 - pjena - Batch class to Update Dev_Forums_Activity__c (One time Data Migration need, delete this after the data migration is done)
	
	//Run it in Developer Console or Workbench
	DiscoverDataMigration_DFACT oDiscoverDataMigration_DFACT = new DiscoverDataMigration_DFACT();
	database.executeBatch(oDiscoverDataMigration_DFACT , 200);			
	
	2019.10.04 - Cleanup after Discover Data Deletion is done, ready to be deleted
*/

public class DiscoverDataMigration_DFACT{
		
	//Constructor accepting next execution time in minutes and the lookback time
    public DiscoverDataMigration_DFACT(){}

}