public class AttachmentTriggerHelper extends NV_TriggerHandler  {
	
    public list<Attachment> oldRecords;
    private static list<Attachment> triggerNewList;
    private static map<Id, Attachment> mapTriggerOld;
    public override void init() { 
        System.debug('12345 12');
        oldRecords = trigger.old;
        triggerNewList = trigger.New;
        if(oldRecords != null)
            mapTriggerOld = new map<Id, Attachment>(oldRecords);
        System.debug('Old Records' + oldRecords + '1');
        System.debug('New Records' + trigger.New + '1');
    }
    public override void afterInsert() {
        CaseUpdate();
    }
	public static void CaseUpdate(){
        Map<String,Case> lstCase = new Map<String,Case>();
        
        set<Id> caseIds = new set<Id>();
        Id userId; 
        //Updating Status in Case
        for(Attachment Att : triggerNewList){
        	userId = att.createdbyId;
            if(Att.ParentId !=null && Att.ParentId.getSobjectType() == Case.SobjectType){
            	caseIds.add(Att.ParentId);
            }
        }
        
        if(!caseIds.isEmpty())
        	ServiceCloudUtils.UpdateRecentActivityOnCase(caseIds, userId, 'Attachment');
    }
    /*public static void CaseUpdate(List<Attachment> newAttachment){
        Map<String,Case> lstCase = new Map<String,Case>();
        
        //Updating Status in Case
        for(Attachment Att : newAttachment){
            if(Att.ParentId !=null && Att.ParentId.getSobjectType() == Case.SobjectType){
                Case cas = new Case(Id = Att.ParentId, Status ='In Progress');
                lstCase.put(cas.Id,cas);        
            }
        }
       update lstCase.values();
    }*/
}