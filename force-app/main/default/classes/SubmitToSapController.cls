public with sharing class SubmitToSapController {

    public Order objOrder {get; set;}
    public static Boolean disable {get;set;}
    public static String strResult {get; set;}

    public SubmitToSapController(ApexPages.StandardController stdController) {
        objOrder = (Order)stdController.getRecord();
    }

    public void SubmitOrderFromVF() {
        /*RenewalOrderToSAP objROToSAP = new RenewalOrderToSAP ();
        strResult = objROToSAP.SubmitOrder(objOrder.Id,false);*/
        strResult = RenewalOrderToSAP.submitOrder(objOrder.Id,false);
    }
    
    
    public void SubmitInitialSORequest() {
        list<Order> OrderList = [select id, LastModifiedById ,OrderNumber, SBQQ__Quote__c, Generate_Email__c, New_EC_Contact_SAP_Number__c, PO_Amount__c, PO_Customer_Requested_Date__c, PO_Date__c, Purchase_Order_Number__c, Sales_Organization__c, Total_Amount_of_CPQ_Products__c, SOQ_Order_To_Emails__c, SOQ_Order_CC_Emails__c, LastModifiedBy.Email, Opportunity.Owner.Email, Account.Owner.Email,SBQQ__Quote__r.Primary_NPN_OEM_ODM_Disti__c,SBQQ__Quote__r.Primary_NPN_OEM_ODM_Disti__r.Owner.Email,SBQQ__Quote__r.SBQQ__Account__c,New_End_Customer_Account_Lookup__r.SAP_Customer_Number__c ,Reseller_SAP_Number__c,Reseller_Contact_SAP_Number__c,Use_Quote_EC_Account_Info__c from order where id=: objOrder.id];
        
        //OrderTriggerClass.sendEmailfromVF(OrderList);
         List<Id> lstConDocIds = new List<Id>();
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
    
        for(order ordx : OrderList){
            lstQuoteIds2.add(ordx.SBQQ__Quote__c);
            QuoteOrderMap.put(ordx.SBQQ__Quote__c,ordx.Id);
                ordx.EffectiveDate = system.today();
                lstOrderIds.add(ordx.Id);
                lstQuoteIds.add(ordx.SBQQ__Quote__c);
                lstEmailOrders.add(ordx);
                //QuoteAmountMap.put(ordx.SBQQ__Quote__c,0.00);
                ordx.Generate_Email__c = false;
        }
    
        if(lstQuoteIds2.size()>0){
                //Double CPQTotal=0;
                    for(SBQQ__Quote__c SBQuote : [select id,Total_Amount_of_CPQ_Products__c  from SBQQ__Quote__c  WHERE id =: lstQuoteIds2]){
                           
                        OrderAmountMap.put(QuoteOrderMap.get(SBQuote.id),SBQuote.Total_Amount_of_CPQ_Products__c);    
                        system.debug('--------OrderAmountMap-----'+OrderAmountMap);
                        }
            } 
    
        for(order ordz : OrderList){
            
            ordz.Total_Amount_of_CPQ_Products__c = OrderAmountMap.get(ordz.id);
            
        }
    
        Set<Id> OrderSet = new Set<Id>(lstOrderIds);
        if(OrderSet.size()>0){
            List<ContentDocumentLink> ContentDocumentLinks = [select ContentDocumentId,id, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN : OrderSet AND ContentDocumentId != null];
            Set<Id> contentDocIds = new Set<Id>();
            EmailTemplate ETemp = [select id, DeveloperName  from EmailTemplate where DeveloperName='SOQ_New_Order_Email' limit 1];
            ID TemplateId = ETemp.Id;
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
            system.debug('>>>>>>>>>lstConVerIds>>>>>'+ lstConVerIds);
            
            
    
        for(order ordy : OrderList){
            
            ordy.Total_Amount_of_CPQ_Products__c = OrderAmountMap.get(ordy.id);
            
            system.debug('--------ordy.SOQ_Order_To_Emails__c--------'+ordy.SOQ_Order_To_Emails__c);
            list<String> ToEmails = ordy.SOQ_Order_To_Emails__c.split(',');
            list<String> CCEmails = ordy.SOQ_Order_CC_Emails__c.split(',');
            CCEmails.add(ordy.LastModifiedBy.Email);
            CCEmails.add(ordy.Opportunity.Owner.Email);
            CCEmails.add(ordy.Account.Owner.Email);
            if(ordy.SBQQ__Quote__r.Primary_NPN_OEM_ODM_Disti__r.Owner.Email !=null)
            CCEmails.add(ordy.SBQQ__Quote__r.Primary_NPN_OEM_ODM_Disti__r.Owner.Email);
            //LastModifiedBy.Email, Opportunity.Owner.Email, Account.Owner.Email
            system.debug('-------UserInfo------'+ UserInfo.getUserId());
            
            mail.setTemplateId(TemplateId);    
            //mail.setTargetObjectId(UserInfo.getUserId()); 
            mail.setTargetObjectId(ordy.LastModifiedById); 
            mail.setToAddresses(ToEmails); 
            //mail.setToAddresses(new List<String>{'vgattamaneni@nvidia.com','messayas@nvidia.com','dheerajs@nvidia.com'}); 
            mail.setCcAddresses(CCEmails);
            mail.setBccAddresses(new List<String>{'vgattamaneni@nvidia.com'});    
            mail.setSaveAsActivity(false); 
             Boolean RelatedCustomer = True;
              system.debug('---RelatedCustomer11---'+RelatedCustomer);
              system.debug('---xxxx---'+ordy.Use_Quote_EC_Account_Info__c);
              
             if(ordy.Use_Quote_EC_Account_Info__c==False){
              system.debug('---RelatedCustomer22---'+RelatedCustomer);
                 id accid = OrderTriggerClass.GetTopLevelAccount(ordy.SBQQ__Quote__r.SBQQ__Account__c);
                 system.debug('----top----'+accid);
                 List<Account> ls= [Select id, name,SAP_Customer_Number__c, parentId from Account where id =:accid];
                 string allcustomer = OrderTriggerClass.getHierarchies(ls);
                 if(allcustomer.contains(ordy.New_End_Customer_Account_Lookup__r.SAP_Customer_Number__c)){ system.debug('---RelatedCustomer33---'+RelatedCustomer);
                 }else{RelatedCustomer = False; system.debug('---RelatedCustomer33-2---'+RelatedCustomer);}
             }
             system.debug('---RelatedCustomer44---'+RelatedCustomer);
             if(!RelatedCustomer){
             	 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Order Fulfillment End Customer Account is not related to the Customer on Quote.'));
             }else if(ordy.Purchase_Order_Number__c== null || ordy.PO_Amount__c == null  || ordy.PO_Date__c== null ){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Purchase Order #, PO Date and PO Amount are required.'));
             }else if(ordy.Reseller_SAP_Number__c== null || ordy.Reseller_Contact_SAP_Number__c == null  || ordy.New_EC_Contact_SAP_Number__c== null ){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Reseller, Reseller Contact and End Customer Contact are required to submit the order. Please fill the details on Quote.'));
             }else if(ordy.Total_Amount_of_CPQ_Products__c != ordy.PO_Amount__c){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Order Amount is not matching with the PO Amount.'));
             }else If(ContentDocumentVersionListMap.size()>0){
                    ordy.status='Submitted';
                    mail.setEntityAttachments(ContentDocumentVersionListMap.get(OrderContentDocumentMap.get(ordy.id).ContentDocumentId) );
                    mail.setWhatId(ordy.id);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    OrderTriggerClass.SyncQuotes(lstQuoteIds);
                    Update ordy;
                        
             }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No PO attachment on the Order, Add Attachment before selecting Submit SO Request.'));
                }
           
        }
         
            
        }    
        
    
    }
}