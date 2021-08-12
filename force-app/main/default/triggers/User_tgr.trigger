/*
	2017.01.24: User Trigger
		
*/
trigger User_tgr on User (before insert, before update) {
	
	//calls User_tgr_cls for Workday user sync
    User_tgr_cls oUserManagement = new User_tgr_cls(trigger.new, trigger.old, trigger.oldMap);
}