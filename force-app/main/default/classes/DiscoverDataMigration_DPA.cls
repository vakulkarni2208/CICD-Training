/*
	2019.07.27 - pjena - Batch class to Update Developer_Program_Application__c (One time Data Migration need, delete this after the data migration is done)
	
	//Run it in Developer Console or Workbench
	DiscoverDataMigration_DPA oDiscoverDataMigration_DPA = new DiscoverDataMigration_DPA();
	database.executeBatch(oDiscoverDataMigration_DPA , 200);
			
	2019.10.04 - Cleanup after Discover Data Deletion is done, ready to be deleted	
*/

public class DiscoverDataMigration_DPA{
		
	//Constructor accepting next execution time in minutes and the lookback time
    public DiscoverDataMigration_DPA(){}
}