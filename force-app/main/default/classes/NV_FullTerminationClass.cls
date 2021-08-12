public class NV_FullTerminationClass implements Queueable {
    
    set<Id> setAccountID = new set<Id>();
    public NV_FullTerminationClass(set<Id> setAccountID) {
        this.setAccountID = setAccountID;
    }
        
    public void execute(QueueableContext context) {
        list<User> lstUser = [select id, isActive, isPortalEnabled from User where accountID in :setAccountId and isActive = True];
        for (User objUser : lstUser){
            objUser.isActive = false;
            objUser.isPortalEnabled = false;
        }
        update lstUser;
    }
}