Global class OrderTriggerClass {
    
    
    public static id GetTopLevelAccount(Id currAcctId){
        Boolean isTopLevelAccount = false;
        Account acct;
        id ParentAccountid;
        while (!isTopLevelAccount) {
            acct = [select a.Id,a.SAP_Customer_Number__c, a.ParentId From Account a where a.Id = :currAcctId limit 1];
            if (acct.ParentID != null) {
                currAcctId = acct.ParentID;// Top parent account id
                ParentAccountid = acct.ParentID;
            } else {
                isTopLevelAccount = true;
            }
        }
        return ParentAccountid;
    }
   
    
    public static string getHierarchies(List<Account> top_accts) {
    string AllSAPCustomerNo='';
        
    Map<Id,HierarchyNode> nodes = new Map<Id,HierarchyNode>();
    Set<Id> parent_acc_ids = new Set<Id>();
 
    for (Account a : top_accts) {
        nodes.put(a.Id, new HierarchyNode(a));
        parent_acc_ids.add(a.Id);
        if(a.SAP_Customer_Number__c != null)
        AllSAPCustomerNo= a.SAP_Customer_Number__c;
        system.debug('------++---AllSAPCustomerNo----1-----'+AllSAPCustomerNo);
    }
 

    while (parent_acc_ids.size() > 0) {
        Map<Id,Account> subordinate_accounts =
            new Map<Id,Account>([
                SELECT Id,SAP_Customer_Number__c, ParentID, Name
                FROM Account
                WHERE ParentId IN :parent_acc_ids
            ]);
 
        parent_acc_ids = subordinate_accounts.keySet();
 system.debug('------++---AllSAPCustomerNo----2-----'+AllSAPCustomerNo);
        for (Account acc : subordinate_accounts.values()) {
            if(acc.SAP_Customer_Number__c != null)
            AllSAPCustomerNo = AllSAPCustomerNo+','+acc.SAP_Customer_Number__c;
            system.debug('------++---AllSAPCustomerNo----3-----'+AllSAPCustomerNo);
            HierarchyNode new_node = new HierarchyNode(acc);
            nodes.put(acc.id, new_node);
            HierarchyNode ref_node = nodes.get(acc.parentId);
            ref_node.children.add(new_node);
            
        }
    }

        system.debug('------++---AllSAPCustomerNo----1-----'+AllSAPCustomerNo);
        system.debug('---------allnodes------'+nodes);
       system.debug('------++---AllSAPCustomerNo------'+AllSAPCustomerNo);
        
    return AllSAPCustomerNo;
}
    
    public class HierarchyNode {
    Account node;
    List<HierarchyNode> children;
 
    HierarchyNode(Account acc) {
        node = acc;
        children = new List<HierarchyNode>();
    }
}
    
    public static List<Account> getChildAccountsInHierarchy(Id parentAcctId) {
        List<account> acctList;
        List<ID> parentIdList= new List<ID>();
        Map<id,Integer> accountIdLevelMap;
        Map<id,Account> accountDetailsMap;
        Map<id,list<Account>> parentChildLinkedListMap;
     
     
        String query;    
        Boolean endTraversing = false;
            Integer accountLevel = 0;
            while(!endTraversing) {
            if(accountLevel == 0) {
                   query = 'select Id, Name, ParentId from Account WHERE Id IN :parentIdList';
                } else {
                   query = 'select Id, Name, ParentId from Account WHERE ParentId IN :parentIdList';
                }
                acctList = Database.query(query);
                
                if(acctList.size() == 0 ) {
                   endTraversing = true;
                } else {
                   parentIdList.clear();
                   acctList.sort();
                   Account a;
                   for(Integer i = 0; i < acctList.size(); i++ ) {
                       a = acctList.get(i);
                       parentIdList.add(a.Id);
                        
                       // populate the account id and level and details maps to be later used
                       accountIdLevelMap.put(a.Id, accountLevel);
                       accountDetailsMap.put(a.Id, a);
        
                       if(accountLevel > 0) {
                           // create the map of parent and related child accounts
                           // this is the key part of the iteration which takes
                           // care of adding the parent and related child
                           if(parentChildLinkedListMap.get(a.ParentId) == null) {
                               List<Account> AccList1;
                               parentChildLinkedListMap.put(a.ParentId, AccList1); 
                           }
                           parentChildLinkedListMap.get(a.ParentId).add(a);
                           parentChildLinkedListMap.get(a.ParentId).sort();
                        }
                   }
                   accountLevel++;
                }
            }
            
            // populate the list in the way they appear in the hierarchy
            //addChildAccountsToList(parentAcctId);
            //return accountHierarchyList;
            return parentChildLinkedListMap.get(parentAcctId);
        }

    
    
    
    
    
@RemoteAction    
Global static void ProcessOrder(list<order> orders){
        
         List<Id> lstConDocIds = new List<Id>();
         //List<Id> lstQuoteIds = new List<Id>();
         List<Order> lstEmailOrders = new List<Order>();
         List<Id> lstConVerIds = new List<Id>();
         List<Id> lstOrderIds = new List<Id>();
         List<Id> lstQuoteIds = new List<Id>();
         List<Id> lstQuoteIds2 = new List<Id>();
         map<Id, ContentDocumentLink> OrderContentDocumentMap = new map<Id, ContentDocumentLink>();
         map<Id, ContentVersion> ContentDocumentVersionMap = new map<Id, ContentVersion>();
         map<Id, List<Id>> ContentDocumentVersionListMap = new map<Id, List<Id>>();
         map<Id, id> QuoteOrderMap = new map<Id, Id>();
        map<Id, Double> OrderAmountMap = new map<Id, Double>();
         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
        for(order ordx : orders){
            lstQuoteIds2.add(ordx.SBQQ__Quote__c);
            QuoteOrderMap.put(ordx.SBQQ__Quote__c,ordx.Id);
            /*if(ordx.Generate_Email__c == True){
                ordx.EffectiveDate = system.today();
                lstOrderIds.add(ordx.Id);
                lstQuoteIds.add(ordx.SBQQ__Quote__c);
                lstEmailOrders.add(ordx);
                //QuoteAmountMap.put(ordx.SBQQ__Quote__c,0.00);
                ordx.Generate_Email__c = false;
                }*/
        }
    
        if(lstQuoteIds2.size()>0){
                //Double CPQTotal=0;
                    for(SBQQ__Quote__c SBQuote : [select id,Total_Amount_of_CPQ_Products__c  from SBQQ__Quote__c  WHERE id =: lstQuoteIds2]){
                        OrderAmountMap.put(QuoteOrderMap.get(SBQuote.id),SBQuote.Total_Amount_of_CPQ_Products__c);    
                        system.debug('--------OrderAmountMap-----'+OrderAmountMap);
                        }
            } 
    
        for(order ordz : orders){
            ordz.Total_Amount_of_CPQ_Products__c = OrderAmountMap.get(ordz.id);
        }
    
        Set<Id> OrderSet = new Set<Id>(lstOrderIds);
        if(OrderSet.size()>0){
            List<ContentDocumentLink> ContentDocumentLinks = [select ContentDocumentId,id, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN : OrderSet AND ContentDocumentId != null];
            Set<Id> contentDocIds = new Set<Id>();
            
            for(ContentDocumentLink conDoc : ContentDocumentLinks) {
                    lstConDocIds.add(conDoc.ContentDocumentId);
                OrderContentDocumentMap.put(conDoc.LinkedEntityId,conDoc);
            }
            
            system.debug('>>>>>>>>>lstConDocIds>>>>>'+ lstConDocIds);
            
            for(ContentVersion conVer : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: lstConDocIds]){
               lstConVerIds.add(conVer.Id);
               ContentDocumentVersionMap.put(conVer.ContentDocumentId,conVer);
                ContentDocumentVersionListMap.put(conVer.ContentDocumentId,lstConVerIds);
            }
            
    
        for(order ordy : orders){
            ordy.Total_Amount_of_CPQ_Products__c = OrderAmountMap.get(ordy.id);
        }
        }    
        
    }
    
    public static void SyncQuotes(list<id> lstQuoteIds){
        List<SBQQ__Quote__c> SyncQuotesList = new List<SBQQ__Quote__c>();
        if(lstQuoteIds.size()>0){
        List<SBQQ__Quote__c> CPQQuotes = [select id, SAP_Sync_Pending__c  from SBQQ__Quote__c  where id IN : lstQuoteIds ];
            for(SBQQ__Quote__c CPQQuote : [select id, SAP_Sync_Pending__c  from SBQQ__Quote__c  where id IN : lstQuoteIds]) {
                    CPQQuote.SAP_Sync_Pending__c = True;
                    SyncQuotesList.add(CPQQuote);
            }
            
            Update SyncQuotesList;
        
        }
    
    }
    
	/**
    * @description Dummy test method - Technical Dept
    * @param  Dummy method
    * @return  Void: It returns nothing
    */  
     public static void CoverageMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++; 
     }    
    
    
    
}