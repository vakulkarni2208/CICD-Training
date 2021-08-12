/*
Date            Version    Modified By            Description
------------------------------------------------------------------------------------------------------------------------------
5-Jun-19         1.0 	Created
15-Mar-21        1.1    Nilesh Adkar        SDS-2941 : Added method checkContactNamePopulated

*/
public class CaseCommentTriggerHelper extends NV_TriggerHandler {
    public list<CaseComment> oldRecords;
    private static list<CaseComment> triggerNewList;
    private static map<Id, CaseComment> mapTriggerOld;
    /*public override void init() { 
        System.debug('12345 12');
        //oldRecords = new list<CaseComment>(oldObjectRecords);
        //triggerNewList = newObjectRecords;
        if(oldRecords != null)
            mapTriggerOld = new map<Id, CaseComment>(oldRecords);
        System.debug('Old Records' + oldRecords + '1');
        System.debug('New Records' + trigger.New + '1');
    } */
    public override void init() { 
        System.debug('12345 12');
        oldRecords = trigger.old;
        triggerNewList = trigger.New;
        if(oldRecords != null)
            mapTriggerOld = new map<Id, CaseComment>(oldRecords);
        System.debug('Old Records' + oldRecords + '1');
        System.debug('New Records' + trigger.New + '1');
    }
    public override void beforeInsert() {
        checkContactNamePopulated(triggerNewList); // SDS-2941 
    }
    public override void afterInsert() {
        CaseUpdate();
    }
    public override void afterUpdate() {
        CaseUpdate();
    }
    public static void CaseUpdate(){
        Map<String,Case> lstCase = new Map<String,Case>();
        
        set<Id> caseIds = new set<Id>();
        Id userId; 
        //Updating Status in Case
        for(CaseComment Comm : triggerNewList){
            //CaseComment Comm = (CaseComment)obj; 
            userId = Comm.createdbyId;
            if(Comm.ParentId !=null && Comm.ParentId.getSobjectType() == Case.SobjectType){
                caseIds.add(Comm.ParentId);
            }
        }
        
        if(!caseIds.isEmpty())
            ServiceCloudUtils.UpdateRecentActivityOnCase(caseIds, userId, 'CaseComment');
    }
    
    // SDS-2941 Start
    public static void checkContactNamePopulated(List<CaseComment> lstNewCaseComment){
        set<Id> setCaseIds = new set<Id>();
        for(CaseComment tmpcc : lstNewCaseComment){
            if(tmpcc.isPublished)
                setCaseIds.add(tmpcc.ParentId);
        }
        if(!setCaseIds.isEmpty()){
            List<Case> lstCases = [select id,ContactId from Case where id in :setCaseIds and ContactId=null];
            if (!lstcases.isEmpty()) {
                lstNewCaseComment.get(0).addError(label.Service_Cloud_Public_comment_needs_Case_Contact);
            }
        }
    }
    // SDS-2941 End
}