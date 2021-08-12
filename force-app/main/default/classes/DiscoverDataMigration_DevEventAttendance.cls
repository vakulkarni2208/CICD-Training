/*
	2019.07.27 - pjena - Batch class to Update Developer_Event_Attendance__c (One time Data Migration need, delete this after the data migration is done)
	
	//Run it in Developer Console or Workbench
	DiscoverDataMigration_DevEventAttendance oDiscoverDataMigration_DevEventAttendance = new DiscoverDataMigration_DevEventAttendance();
	database.executeBatch(oDiscoverDataMigration_DevEventAttendance , 200);	
	
	2019.10.04 - Cleanup after Discover Data Deletion is done, ready to be deleted	

*/
public class DiscoverDataMigration_DevEventAttendance{		
	//Constructor accepting next execution time in minutes and the lookback time
    public DiscoverDataMigration_DevEventAttendance(){}
 
}