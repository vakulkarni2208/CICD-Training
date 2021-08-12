public class EmailMessageTriggerHelper extends NV_TriggerHandler {
    public list<EmailMessage> oldRecords;
    private static list<EmailMessage> triggerNewList;
    private static map<Id, EmailMessage> mapTriggerOld;
    
    public override void init() {
        OBJECT_NAME = 'EmailMessage';
        System.debug('12345 12');
        oldRecords = trigger.old;
        triggerNewList = trigger.New;
        if(oldRecords != null)
            mapTriggerOld = new map<Id, EmailMessage>(oldRecords);
        System.debug('Old Records' + oldRecords + '1');
        System.debug('New Records' + trigger.New + '1');
    }
    public override void afterInsert() {
        CaseUpdate();
    }
    public override void afterUpdate() {
        CaseUpdate();
    }
    public override void beforeDelete() {
        system.debug('Before Delete of child.');
        //Find Loggedin User's profile
        //Set Parent field with object name
        //get custom setting for object
        Boolean canDeleteEmailMessage = FeatureManagement.checkPermission('Service_Delete_EmailMessage');
        if(!canDeleteEmailMessage) {
            for(EmailMessage msg: mapTriggerOld.values()) {
                msg.addError('You don\'t have permission to delete this record.');
            }
        }
    }
    
    public static void CaseUpdate(){
        map<Id, string> caseIds = new map<Id, string>();
        Id userId; 
        
        //Updating Status in Case
        for(EmailMessage Email : triggerNewList){
            userId = Email.createdbyId;
            if(Email.ParentId !=null && Email.ParentId.getSobjectType() == Case.SobjectType && Email.FromAddress != 'no_reply@nvidia.com'){
                caseIds.put(Email.ParentId, Email.FromAddress);
            }
        }
        
        if(!caseIds.isEmpty())
            ServiceCloudUtils.UpdateRecentActivityOnCase(caseIds, userId, 'EmailMessage');
    }
}