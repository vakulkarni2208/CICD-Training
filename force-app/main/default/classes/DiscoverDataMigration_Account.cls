/*
	2019.07.27 - pjena - Batch class to Migrate DISCOVER Accounts to Dev_Accounts	(One time Data Migration need, delete this after the data migration is done)
	
	//Run it in Developer Console or Workbench
	DiscoverDataMigration_Account oDiscoverDataMigration_Account = new DiscoverDataMigration_Account();
	database.executeBatch(oDiscoverDataMigration_Account , 200);
	
	2019.10.04 - Cleanup after Discover Data Deletion is done, ready to be deleted

*/
public class DiscoverDataMigration_Account{
	//Constructor accepting next execution time in minutes and the lookback time
    public DiscoverDataMigration_Account(){}
}