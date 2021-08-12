/*
	2019.07.27 - pjena - Batch class to Update Dev_File_Download__c (One time Data Migration need, delete this after the data migration is done)
	
	//Run it in Developer Console or Workbench
	DiscoverDataMigration_DFD oDiscoverDataMigration_DFD = new DiscoverDataMigration_DFD();
	database.executeBatch(oDiscoverDataMigration_DFD , 200);

	2019.10.04 - Cleanup after Discover Data Deletion is done, ready to be deleted				

*/

public class DiscoverDataMigration_DFD{
		
	//Constructor accepting next execution time in minutes and the lookback time
    public DiscoverDataMigration_DFD(){}

}