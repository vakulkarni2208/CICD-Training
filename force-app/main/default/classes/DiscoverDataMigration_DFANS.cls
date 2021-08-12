/*
	2019.07.27 - pjena - Batch class to Update Dev_Form_Answers__c (One time Data Migration need, delete this after the data migration is done)
	
	//Run it in Developer Console or Workbench
	DiscoverDataMigration_DFANS oDiscoverDataMigration_DFANS = new DiscoverDataMigration_DFANS();
	database.executeBatch(oDiscoverDataMigration_DFANS , 200);
				
	2019.10.04 - Cleanup after Discover Data Deletion is done, ready to be deleted
*/

public class DiscoverDataMigration_DFANS{
	//Constructor accepting next execution time in minutes and the lookback time
    public DiscoverDataMigration_DFANS(){}
}