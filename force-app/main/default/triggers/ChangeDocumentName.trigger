/**************************************************************************************************
* Name       : ChangeDocumentName on Quote Document trigger
* Purpose    : Attachment Names for quotes
Quote doc attached in an outgoing email should reflect the custom doc name, not the generic system generated name
***************************************************************************************************
* Author            | Version    | Created Date      | Description
***************************************************************************************************
*Venkat G           | 1.0        |  April 15,2019 | Trail code for v1.0
Techncial Debt: Need to move the code to helper method in the upcoming release. --- Techncial Debt

**************************************************************************************************/
trigger ChangeDocumentName on SBQQ__QuoteDocument__c (after Insert, after Update) {
    
    Set<id> documentids = new set<id>();
    Set<id> QDids = new set<id>();
    Map<id,SBQQ__QuoteDocument__c> Mapofdocumentids = new map<id, SBQQ__QuoteDocument__c>();
    for(SBQQ__QuoteDocument__c q: trigger.new){
        documentids.add(q.SBQQ__DocumentId__c);
        QDids.add(q.id);
        Mapofdocumentids.put(q.SBQQ__DocumentId__c, q);
    }
    List<SBQQ__QuoteDocument__c> QDlist =[select id, SBQQ__Opportunity__r.name from SBQQ__QuoteDocument__c where id in :QDids ]; 
    List<document> Doclist =[select id, name from Document where id in :documentids ]; 
    List<document> Doclist2Update = new List<document>();
    for(Document d : Doclist ){
        d.name=Mapofdocumentids.get(d.id).Name;
        Doclist2Update.add(d);
    }
    Update Doclist2Update;
    
}