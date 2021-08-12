/***
 *  @name NPN_QPB_Statements_ctlr
 *  @description    The controller class for NPN_QPB_Statements page. The access to this page is granted to partner users through PP_NPN_QPB_Statements permission set. Created for SDS-1406.
 *  @date 6-Jan-2020
 */
public without sharing class NPN_QPB_Statements_ctlr {

    public boolean showTable {get; set;}
    public list<QPB_Statement__c> QPBStatementsList {get; set;}
    public list<QPBWrapper> lstQPBStatements {get; set;}
    public list<QPBWrapper> lstQPBStatementsUnsorted {get; set;}

    public NPN_QPB_Statements_ctlr() {

        showTable = false;
        QPBStatementsList = new List<QPB_Statement__c>();

        for(QPB_Statement__c qpbObj : [SELECT Id, Account__c, Account__r.Name, Fiscal_Year__c, Quarter__c, Name, Type__c, FY_QTR__c, Status__c, Attachment_Uploaded__c FROM QPB_Statement__c WHERE Account__c IN (SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId()) AND Status__c = 'Active' AND Attachment_Uploaded__c = true ORDER BY FY_QTR__c DESC]) {
            QPBStatementsList.add(qpbObj);
        }

        System.debug('QPBStatementsList '+ QPBStatementsList);
        if(!QPBStatementsList.isEmpty()) {
            showTable = true;
            loadQPBData(QPBStatementsList);
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Your account does not have any QPB Statements available'));
        }
    }

    public void loadQPBData(list<QPB_Statement__c> QPBStatementsList){

        Map<Id, QPB_Statement__c> qpbMap = new Map<Id, QPB_Statement__c>();
        //Map<Id, Id> qpbAttachmentMap = new Map<Id, Id>();
        Map<Id,Id> contentDocLinkedEntityIdMap = new Map<Id, Id>();


        lstQPBStatements = new List<QPBWrapper>();
        lstQPBStatementsUnsorted = new List<QPBWrapper>();

        for(QPB_Statement__c qObj : QPBStatementsList) {
            qpbMap.put(qObj.Id, qObj);
        }

        if(!qpbMap.isEmpty()) {

            List<ContentDocumentLink> lstContentDocumentLink = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :qpbMap.keySet()];

            if(!lstContentDocumentLink.isEmpty()) {
                for(ContentDocumentLink cdlObj : lstContentDocumentLink ) {
                    contentDocLinkedEntityIdMap.put(cdlObj.ContentDocumentId, cdlObj.LinkedEntityId);
                }
            }

            if(!contentDocLinkedEntityIdMap.isEmpty()) {
                for(ContentVersion atcObj : [SELECT ContentDocumentId,Id,VersionData FROM ContentVersion WHERE ContentDocumentId IN :contentDocLinkedEntityIdMap.keySet()]) {
                    String qpbIdStr = contentDocLinkedEntityIdMap.get(atcObj.ContentDocumentId);
                    QPBWrapper qpbWrpObj = new QPBWrapper ();

                    qpbWrpObj.qpbId = qpbMap.get(qpbIdStr).Name;
                    qpbWrpObj.fiscalYear = qpbMap.get(qpbIdStr).Fiscal_Year__c;
                    qpbWrpObj.quarter = qpbMap.get(qpbIdStr).Quarter__c;
                    qpbWrpObj.accountName = qpbMap.get(qpbIdStr).Account__r.Name;
                    qpbWrpObj.fyQtr = Integer.valueOf(qpbMap.get(qpbIdStr).FY_QTR__c);
                    qpbWrpObj.type = qpbMap.get(qpbIdStr).Type__c;
                    qpbWrpObj.attachmentLink = '/apex/ViewPdf?id='+atcObj.ContentDocumentId;

                    lstQPBStatementsUnsorted.add(qpbWrpObj);
                }
            }

            if(!lstQPBStatementsUnsorted.isEmpty()) {
                lstQPBStatements = retSortedList(lstQPBStatementsUnsorted);
            }
        }
    }

    public List<QPBWrapper> retSortedList (List<QPBWrapper> unsortedList){
        List<QPBWrapper> sortedList = new List<QPBWrapper>();

        Integer n = unsortedList.size();
        for (Integer i = 0; i < n-1; i++) {
            for (Integer j = 0; j < n-i-1; j++) {
                if (unsortedList.get(j).fyQtr < unsortedList.get(j+1).fyQtr) {
                    QPBWrapper temp = unsortedList.get(j);
                    unsortedList.set(j, unsortedList.get(j+1));
                    unsortedList.set(j+1, temp);
                }
            }
        }
        sortedList.addAll(unsortedList);
        return sortedList;
    }

    public class QPBWrapper {
        public String attachmentLink {get; set;}
        public String fiscalYear {get; set;}
        public String quarter {get; set;}
        public String accountName {get; set;}
        public String qpbId {get; set;}
        public String type {get; set;}
        public Integer fyQtr {get; set;}
    }
}