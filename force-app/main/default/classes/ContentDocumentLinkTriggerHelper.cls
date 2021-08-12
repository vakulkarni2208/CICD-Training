public class ContentDocumentLinkTriggerHelper extends NV_TriggerHandler {
    public list<ContentDocumentLink> oldRecords;
    private static list<ContentDocumentLink> triggerNewList;
    private static map<Id, ContentDocumentLink> mapTriggerOld;
       
    /**
     * Gets FileExtension of the inserted content.
     
    public static String getFileExtension(ContentDocumentLink cdl) {
        String fileExtension;
        String docId = cdl.ContentDocumentId;
        FileExtension = [select FileExtension from ContentVersion where ContentDocumentId = :docId].get(0).FileExtension;
        return FileExtension;
    }*/
 
    /**
     * Gets the parent Case Number if the file is linked to an case.
     */
   /** public static String getCaseNumber(ContentDocumentLink cdl) {
        Integer Num;
        String id = cdl.LinkedEntityId;
        if (id.substring(0,3) == '500') {
            Num = [select CaseNumber from Case where Id = :id];
        } 
        return Num;
    }**/
     public override void init() { 
        System.debug('12345 12');
        oldRecords = trigger.old;
        triggerNewList = trigger.New;
        if(oldRecords != null)
            mapTriggerOld = new map<Id, ContentDocumentLink>(oldRecords);
        System.debug('Old Records' + oldRecords + '1');
        System.debug('New Records' + trigger.New + '1');
    }
    public override void afterInsert() {
        CaseUpdate();
        updateQPBStatements();
        LinkFilesToNvBug();
    }
    
    public override void beforeInsert() {
        updateCDLShare();
    }
    
    public static void updateCDLShare() {
        for(ContentDocumentLink objContentDocumentLink : triggerNewList){
            if(objContentDocumentLink.LinkedEntityId !=null && objContentDocumentLink.LinkedEntityId.getSobjectType() == QPB_Statement__c.SobjectType){
                objContentDocumentLink.Visibility = 'AllUsers';
            }
        }
    }
    
    public static void updateQPBStatements() {
        List<QPB_Statement__c> lstQPBStatements = new List<QPB_Statement__c>();
        set<Id> setQPBStatementId = new set<Id>();
        for(ContentDocumentLink objContentDocumentLink : triggerNewList){
            if(objContentDocumentLink.LinkedEntityId !=null && objContentDocumentLink.LinkedEntityId.getSobjectType() == QPB_Statement__c.SobjectType){
                setQPBStatementId.add(objContentDocumentLink.LinkedEntityId);
            }
        }
        if(!setQPBStatementId.isEmpty()) {
           lstQPBStatements = [SELECT Id, Name, Account__r.Name, FY_QTR__c, Type__c, Status__c, Attachment_Uploaded__c from QPB_Statement__c where ID IN :setQPBStatementId];
           if(!lstQPBStatements.isEmpty()) {
               for(QPB_Statement__c objQPBStatements : lstQPBStatements) {
                   objQPBStatements.Attachment_Uploaded__c = True;
               }
               update lstQPBStatements;
           }
        }
    }

    public static void CaseUpdate(){
        //Map<String,Case> lstCase = new Map<String,Case>();
        
        set<Id> caseIds = new set<Id>();
        Id userId = userInfo.getUserId();
    //Updating Status in Case
        for(ContentDocumentLink cdl : triggerNewList){
            //userId = cdl.createdbyId;
            if(cdl.LinkedEntityId !=null && cdl.LinkedEntityId.getSobjectType() == Case.SobjectType){
                caseIds.add(cdl.LinkedEntityId);
            }
        }
        
        if(!caseIds.isEmpty())
            ServiceCloudUtils.UpdateRecentActivityOnCase(caseIds, userId, 'ContentDocumentLink');
    }
    
    public static void LinkFilesToNvBug(){
        List<ContentDocumentLink > lstCDl = new List<ContentDocumentLink >();
        for(ContentDocumentLink cdl : triggerNewList){
            if(cdl.LinkedEntityId !=null && cdl.LinkedEntityId.getSobjectType() == NvBug__c.SobjectType){
                lstCDl.add(cdl);
            }
        }
        if(!lstCDl.isEmpty()){
            string strCDL = JSON.serialize(triggerNewList);
                NVBugOperations.linkNvBugFilesToNVbugSystem(strCDL);
        }            
    }
}