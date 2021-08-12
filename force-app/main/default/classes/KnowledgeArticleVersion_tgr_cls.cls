public class KnowledgeArticleVersion_tgr_cls extends NV_TriggerHandler {
	public list<Knowledge__kav> oldRecords;
    private static list<Knowledge__kav> triggerNewList;
    private static map<Id, Knowledge__kav> mapTriggerOld;
    public override void init() { 
        //System.debug('12345 12');
        OBJECT_NAME = 'Knowledge__kav';
        oldRecords = trigger.old;
        triggerNewList = trigger.New;
        if(oldRecords != null)
            mapTriggerOld = new map<Id, Knowledge__kav>(oldRecords);
        System.debug('Old Records' + oldRecords + '1');
        System.debug('New Records' + trigger.New + '1'); 
    }
    
    //public override void afterInsert() {
    //    KnowledgeArticleVersion_tgr_cls.createCaseComments();
    //}
    public override void afterUpdate() {
        KnowledgeArticleVersion_tgr_cls.createCaseComments();
    }
    
    public static void createCaseComments() {
        //set<Id> masterArticleIds = new set<Id>();
        map<Id, String> masterArticleIdToCommentMap = new map<Id, String>();
        for(Knowledge__kav kav : triggerNewList) {
            Knowledge__kav oldRecord = mapTriggerOld.get(kav.Id);
            if(!String.isBlank(kav.Customer_Updates__c) && kav.Customer_Updates__c != oldRecord.Customer_Updates__c) {
                //masterArticleIds.add(kav.KnowledgeArticleId);
                masterArticleIdToCommentMap.put(kav.KnowledgeArticleId, kav.Customer_Updates__c);
                system.debug('');
            }
        }
        
        // Query MasterArticles
        //map<Id, Knowledge__ka> masterArticlesMap = new map<Id, Knowledge__ka>([select Id from Knowledge__kav]);
        if(masterArticleIdToCommentMap.isEmpty())
            return;
        
        //Query CaseArticles where Ids in masterArticles and Case.IsClosed = false
        list<CaseArticle> caseArticleList = [select Id, CaseId, KnowledgeArticleId from CaseArticle where KnowledgeArticleId in : masterArticleIdToCommentMap.keySet() and Case.IsClosed = false];
        if(caseArticleList.isEmpty())
            return;
        
        list<CaseComment> caseCommentsToInsert = new list<CaseComment>();
        for(CaseArticle ca : caseArticleList) {
            CaseComment cm = new CaseComment();
            cm.CommentBody = masterArticleIdToCommentMap.get(ca.KnowledgeArticleId);
            cm.IsPublished = true;
            cm.ParentId = ca.CaseId;
            caseCommentsToInsert.add(cm);
        }
   		
        if(!caseCommentsToInsert.isEmpty())
            insert caseCommentsToInsert;
    }
}