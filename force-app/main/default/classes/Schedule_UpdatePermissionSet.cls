/**************************************************************************************************
* Name       : Schedule_UpdatePermissionSet
* Purpose    : Scheduler class for IDM_UpdatePermissionSet 
***************************************************************************************************
* Author            | Version    | Created Date    | Description
***************************************************************************************************
*Perficient         | 1.0        | Feb 2018      | Final Draft
**************************************************************************************************/
global class Schedule_UpdatePermissionSet implements Schedulable {
	global void execute(SchedulableContext sc) {
		IDM_UpdatePermissionSet upsRetry = new IDM_UpdatePermissionSet();
        Database.executeBatch(upsRetry,10);
	}
}