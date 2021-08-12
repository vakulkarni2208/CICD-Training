/*
	2019.07.27 - pjena - Batch class to Migrate DISCOVER Contacts to Dev_Contacts	(One time Data Migration need, delete this after the data migration is done)
	
	//Run it in Developer Console or Workbench
	DiscoverDataMigration_Contact oDiscoverDataMigration_Contact = new DiscoverDataMigration_Contact();
	database.executeBatch(oDiscoverDataMigration_Contact , 200);
	
	2019.10.04 - Cleanup after Discover Data Deletion is done, ready to be deleted
*/
public class DiscoverDataMigration_Contact{
	//Constructor accepting next execution time in minutes and the lookback time
    public DiscoverDataMigration_Contact(){}
}